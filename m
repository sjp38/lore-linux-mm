Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 99F966B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:10:16 -0500 (EST)
Received: by mail-lb0-f171.google.com with SMTP id c11so2027478lbj.2
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:10:15 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id kv5si1082289lbc.36.2014.02.06.10.51.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Feb 2014 10:51:59 -0800 (PST)
Message-ID: <52F3D9A9.1070107@parallels.com>
Date: Thu, 6 Feb 2014 22:51:21 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: vmscan: get rid of DEFAULT_SEEKS and document
 shrink_slab logic
References: <4e2efebe688e06574f6495c634ac45d799e1518d.1389982079.git.vdavydov@parallels.com> <e204471853100447541ce36b198c0d45bf06379c.1389982079.git.vdavydov@parallels.com> <20140204135836.05c09c765073513e62edd174@linux-foundation.org> <52F1E561.8020804@parallels.com> <20140205125230.e1705369abcb634ddf141008@linux-foundation.org>
In-Reply-To: <20140205125230.e1705369abcb634ddf141008@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@gmail.com>

On 02/06/2014 12:52 AM, Andrew Morton wrote:
> On Wed, 5 Feb 2014 11:16:49 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:
>
>>> So why did I originally make DEFAULT_SEEKS=2?  Because I figured that to
>>> recreate (say) an inode would require a seek to the inode data then a
>>> seek back.  Is it legitimate to include the
>>> seek-back-to-what-you-were-doing-before seek in the cost of an inode
>>> reclaim?  I guess so...
>> Hmm, that explains this 2. Since we typically don't need to "seek back"
>> when recreating a cache page, as they are usually read in bunches by
>> readahead, the number of seeks to bring back a user page is 1, while the
>> number of seeks to recreate an average inode is 2, right?
> Sounds right to me.
>
>> Then to scan inodes and user pages so that they would generate
>> approximately the same number of seeks, we should calculate the number
>> of objects to scan as follows:
>>
>> nr_objects_to_scan = nr_pages_scanned / lru_pages *
>>                                         nr_freeable_objects /
>> shrinker->seeks
>>
>> where shrinker->seeks = DEFAULT_SEEKS = 2 for inodes.
> hm, I wonder if we should take the size of the object into account. 
> Should we be maximizing (memory-reclaimed / seeks-to-reestablish-it).

I'm not sure I understand you quite right. You mean that if two slab
caches have obj sizes 1k and 2k and both of them need 2 seeks to
recreate an object, we should scan the 1k (or 2k?) slab cache more
aggressively than the 2k one? Hmm... I don't know. It depends on what we
want to achieve. But this won't balance the seeks, which is our goal for
now, IIUC.

>> But currently we
>> have four times that. I can explain why we should multiply this by 2 -
>> we do not count pages moving from active to inactive lrus in
>> nr_pages_scanned, and 2*nr_pages_scanned can be a good approximation for
>> that - but I have no idea why we multiply it by 4...
> I don't understand this code at all:
>
> 	total_scan = nr;
> 	delta = (4 * nr_pages_scanned) / shrinker->seeks;
> 	delta *= freeable;
> 	do_div(delta, lru_pages + 1);
> 	total_scan += delta;
>
> If it actually makes any sense, it sorely sorely needs documentation.

To find its roots I had to checkout the linux history tree:

commit c3f4656118a78c1c294e0b4d338ac946265a822b
Author: Andrew Morton <akpm@osdl.org>
Date:   Mon Dec 29 23:48:44 2003 -0800

    [PATCH] shrink_slab acounts for seeks incorrectly
   
    wli points out that shrink_slab inverts the sense of
shrinker->seeks: those
    caches which require more seeks to reestablish an object are shrunk
harder.
    That's wrong - they should be shrunk less.
   
    So fix that up, but scaling the result so that the patch is actually
a no-op
    at this time, because all caches use DEFAULT_SEEKS (2).

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b8594827bbac..f2da3c9fb346 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -154,7 +154,7 @@ static int shrink_slab(long scanned, unsigned int
gfp_mask)
        list_for_each_entry(shrinker, &shrinker_list, list) {
                unsigned long long delta;
 
-               delta = scanned * shrinker->seeks;
+               delta = 4 * (scanned / shrinker->seeks);
                delta *= (*shrinker->shrinker)(0, gfp_mask);
                do_div(delta, pages + 1);
                shrinker->nr += delta;


So the idea seemed to be fixing a bug without introducing any functional
changes. Since then we have been living with this "4", which makes no
sense (?). Nobody complained though.

Thanks.

> David, you touched it last.  Any hints?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
