Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 74C2D6B0031
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 02:17:04 -0500 (EST)
Received: by mail-la0-f49.google.com with SMTP id y1so3353lam.22
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 23:17:03 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id m9si14387121lae.150.2014.02.04.23.17.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Feb 2014 23:17:02 -0800 (PST)
Message-ID: <52F1E561.8020804@parallels.com>
Date: Wed, 5 Feb 2014 11:16:49 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: vmscan: get rid of DEFAULT_SEEKS and document
 shrink_slab logic
References: <4e2efebe688e06574f6495c634ac45d799e1518d.1389982079.git.vdavydov@parallels.com> <e204471853100447541ce36b198c0d45bf06379c.1389982079.git.vdavydov@parallels.com> <20140204135836.05c09c765073513e62edd174@linux-foundation.org>
In-Reply-To: <20140204135836.05c09c765073513e62edd174@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@gmail.com>

On 02/05/2014 01:58 AM, Andrew Morton wrote:
> On Fri, 17 Jan 2014 23:25:30 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:
>
>> Each shrinker must define the number of seeks it takes to recreate a
>> shrinkable cache object. It is used to balance slab reclaim vs page
>> reclaim: assuming it costs one seek to replace an LRU page, we age equal
>> percentages of the LRU and ageable caches. So far, everything sounds
>> clear, but the code implementing this behavior is rather confusing.
>>
>> First, there is the DEFAULT_SEEKS constant, which equals 2 for some
>> reason:
>>
>>   #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
>>
>> Most shrinkers define `seeks' to be equal to DEFAULT_SEEKS, some use
>> DEFAULT_SEEKS*N, and there are a few that totally ignore it. What is
>> peculiar, dcache and icache shrinkers have seeks=DEFAULT_SEEKS although
>> recreating an inode typically requires one seek. Does this mean that we
>> scan twice more inodes than we should?
>>
>> Actually, no. The point is that vmscan handles DEFAULT_SEEKS as if it
>> were 1 (`delta' is the number of objects we are going to scan):
>>
>>   shrink_slab_node():
>>     delta = (4 * nr_pages_scanned) / shrinker->seeks;
>>     delta *= freeable;
>>     do_div(delta, lru_pages + 1);
>>
>> i.e.
>>
>>             2 * nr_pages_scanned    DEFAULT_SEEKS
>>     delta = -------------------- * --------------- * freeable;
>>                  lru_pages         shrinker->seeks
>>
>> Here we double the number of pages scanned in order to take into account
>> moves of on-LRU pages from the inactive list to the active list, which
>> we do not count in nr_pages_scanned.
>>
>> That said, shrinker->seeks=DEFAULT_SEEKS*N is equivalent to N seeks, so
>> why on the hell do we need it?
>>
>> IMO, the existence of the DEFAULT_SEEKS constant only causes confusion
>> for both users of the shrinker interface and those trying to understand
>> how slab shrinking works. The meaning of the `seeks' is perfectly
>> explained by the comment to it and there is no need in any obscure
>> constants for using it.
>>
>> That's why I'm sending this patch which completely removes DEFAULT_SEEKS
>> and makes all shrinkers use N instead of N*DEFAULT_SEEKS, documenting
>> the idea lying behind shrink_slab() in the meanwhile.
>>
>> Unfortunately, there are a few shrinkers that define seeks=1, which is
>> impossible to transfer to the new interface intact, namely:
>>
>>   nfsd_reply_cache_shrinker
>>   ttm_pool_manager::mm_shrink
>>   ttm_pool_manager::mm_shrink
>>   dm_bufio_client::shrinker
>>
>> It seems to me their authors were simply deceived by this mysterious
>> DEFAULT_SEEKS constant, because I've found no documentation why these
>> particular caches should be scanned more aggressively than the page and
>> other slab caches. For them, this patch leaves seeks=1. Thus, it DOES
>> introduce a functional change: the shrinkers enumerated above will be
>> scanned twice less intensively than they are now. I do not think that
>> this will cause any problems though.
>>
> um, yes.  DEFAULT_SEEKS is supposed to be "the number of seeks if you
> don't know any better".  Using DEFAULT_SEEKS*n is just daft.
>
> So why did I originally make DEFAULT_SEEKS=2?  Because I figured that to
> recreate (say) an inode would require a seek to the inode data then a
> seek back.  Is it legitimate to include the
> seek-back-to-what-you-were-doing-before seek in the cost of an inode
> reclaim?  I guess so...

Hmm, that explains this 2. Since we typically don't need to "seek back"
when recreating a cache page, as they are usually read in bunches by
readahead, the number of seeks to bring back a user page is 1, while the
number of seeks to recreate an average inode is 2, right?

Then to scan inodes and user pages so that they would generate
approximately the same number of seeks, we should calculate the number
of objects to scan as follows:

nr_objects_to_scan = nr_pages_scanned / lru_pages *
                                        nr_freeable_objects /
shrinker->seeks

where shrinker->seeks = DEFAULT_SEEKS = 2 for inodes. But currently we
have four times that. I can explain why we should multiply this by 2 -
we do not count pages moving from active to inactive lrus in
nr_pages_scanned, and 2*nr_pages_scanned can be a good approximation for
that - but I have no idea why we multiply it by 4...

Thanks.

>
> If a filesystem were to require a seek to the superblock for every
> inode read (ok, bad example) then the cost of reestablishing that inode
> would be 3.
>
> All that being said, why did you go through and halve everything?  The
> cost of reestablishing an ext2 inode should be "2 seeks", but the patch
> makes it "1".
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
