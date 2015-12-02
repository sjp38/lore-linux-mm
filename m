Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 22BC06B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 08:52:28 -0500 (EST)
Received: by wmvv187 with SMTP id v187so255898988wmv.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 05:52:27 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id t1si5276818wmd.24.2015.12.02.05.52.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 05:52:26 -0800 (PST)
Received: by wmvv187 with SMTP id v187so255897957wmv.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 05:52:26 -0800 (PST)
Date: Wed, 2 Dec 2015 14:52:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmscan: do not throttle kthreads due to too_many_isolated
Message-ID: <20151202135224.GF25284@dhcp22.suse.cz>
References: <1448465801-3280-1-git-send-email-vdavydov@virtuozzo.com>
 <5655D789.80201@suse.cz>
 <20151125162756.GJ29014@esperanza>
 <20151126081624.GK29014@esperanza>
 <20151127125005.GH2493@dhcp22.suse.cz>
 <20151127134003.GR29014@esperanza>
 <20151127150133.GI2493@dhcp22.suse.cz>
 <20151201112544.GB11488@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151201112544.GB11488@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 01-12-15 14:25:45, Vladimir Davydov wrote:
> On Fri, Nov 27, 2015 at 04:01:33PM +0100, Michal Hocko wrote:
> > On Fri 27-11-15 16:40:03, Vladimir Davydov wrote:
[...]
> > > The problem is not about our driver, in fact. I'm pretty sure one can
> > > hit it when using memcg along with loop or dm-crypt for instance.
> > 
> > I am not familiar much with neither but from a quick look the loop
> > driver doesn't use mempools tool, it simply relays the data to the
> > underlaying file and relies on the underlying fs to write all the pages
> > and only prevents from the recursion by clearing GFP_FS and GFP_IO. Then
> > I am not really sure how can we guarantee a forward progress. The
> > GFP_NOFS allocation might loop inside the allocator endlessly and so
> > the writeback wouldn't make any progress. This doesn't seem to be only
> > memcg specific. The global case would just replace the deadlock by a
> > livelock. I certainly must be missing something here.
> 
> Yeah, I think you're right. If the loop kthread gets stuck in the
> reclaimer, it might occur that other processes will isolate, reclaim and
> then dirty reclaimed pages, preventing the kthread from running and
> cleaning memory, so that we might end up with all memory being under
> writeback and no reclaimable memory left for kthread to run and clean
> it. Due to dirty limit, this is unlikely to happen though, but I'm not
> sure.
> 
> OTOH, with legacy memcg, there is no dirty limit and we can isolate a
> lot of pages (SWAP_CLUSTER_MAX = 512 now) per process and wait on page
> writeback to complete before releasing them, which sounds bad. And we
> can't just remove this wait_on_page_writeback from shrink_page_list,
> otherwise OOM might be triggered prematurely. May be, we should putback
> rotated pages and release all reclaimed pages before initiating wait?

So you want to write for the page while it is on the LRU? I think it
would be better to simply not throttle the loopback kthread endlessly in
the first place.

I was tempted to add an exception and do not wait for writeback on
loopback (and alike) devices but this is a dirty hack and I think it
is reasonable to rely on the global case to work properly and guarantee
a forward progress. And this seems broken currently:

FS1 (marks page Writeback) -> request -> BLK -> LOOP -> vfs_iter_write -> FS2

So the writeback bit will be set until vfs_iter_write finishes and that
doesn't require data to be written down to the FS2 backing store AFAICS.
But what happens if vfs_iter_write gets throttled on the dirty limit
or FS2 performs a GFP_NOFS allocation? We will get stuck there for ever
without any progress. If loopback FS load is dominant then we are
screwed. So I think the global case needs a fix. If it works properly
our waiting in the memcg reclaim will be finite as well.

On the other hand if all the reclaimable memory is marked as writeback
or dirty then we should trigger OOM killer sooner or later so I am not
so sure this is such a big deal. I have to play with this though.

Anyway I guess we at least want to wait for the writebit killable. I
will cook up a patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
