Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f44.google.com (mail-lf0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id B5BE16B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 08:40:19 -0500 (EST)
Received: by lfs39 with SMTP id 39so127223432lfs.3
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 05:40:19 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id bn6si21475768lbc.62.2015.11.27.05.40.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 05:40:17 -0800 (PST)
Date: Fri, 27 Nov 2015 16:40:03 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] vmscan: do not throttle kthreads due to too_many_isolated
Message-ID: <20151127134003.GR29014@esperanza>
References: <1448465801-3280-1-git-send-email-vdavydov@virtuozzo.com>
 <5655D789.80201@suse.cz>
 <20151125162756.GJ29014@esperanza>
 <20151126081624.GK29014@esperanza>
 <20151127125005.GH2493@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151127125005.GH2493@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 27, 2015 at 01:50:05PM +0100, Michal Hocko wrote:
> On Thu 26-11-15 11:16:24, Vladimir Davydov wrote:
> > On Wed, Nov 25, 2015 at 07:27:57PM +0300, Vladimir Davydov wrote:
> > > On Wed, Nov 25, 2015 at 04:45:13PM +0100, Vlastimil Babka wrote:
> > > > On 11/25/2015 04:36 PM, Vladimir Davydov wrote:
> > > > > Block device drivers often hand off io request processing to kernel
> > > > > threads (example: device mapper). If such a thread calls kmalloc, it can
> > > > > dive into direct reclaim path and end up waiting for too_many_isolated
> > > > > to return false, blocking writeback. This can lead to a dead lock if the
> > > > 
> > > > Shouldn't such allocation lack __GFP_IO to prevent this and other kinds of
> > > > deadlocks? And/or have mempools?
> > > 
> > > Not necessarily. loopback is an example: it can call
> > > grab_cache_write_begin -> add_to_page_cache_lru with GFP_KERNEL.
> 
> AFAIR loop driver reduces the gfp_maks via inode mapping.

Yeah, it does, missed that, thanks for pointing this out. But it doesn't
really make much difference, because it still can get stuck in
too_many_isolated, although it does reduce the chance of this happening.
When I hit it, DMA only got 3 inactive file pages and 68 isolated file
pages, as I mentioned in the comment to the patch, so even >> 3 wouldn't
save us.

>  
> > Anyway, kthreads that use GFP_NOIO and/or mempool aren't safe either,
> > because it isn't an allocation context problem: the reclaimer locks up
> > not because it tries to take an fs/io lock the caller holds, but because
> > it waits for isolated pages to be put back, which will never happen,
> > since processes that isolated them depend on the kthread making
> > progress. This is purely a reclaimer heuristic, which kmalloc users are
> > not aware of.
> > 
> > My point is that, in contrast to userspace processes, it is dangerous to
> > throttle kthreads in the reclaimer, because they might be responsible
> > for reclaimer progress (e.g. performing writeback).
> 
> Wouldn't it be better if your writeback kthread did PF_MEMALLOC/__GFP_MEMALLOC
> instead because it is in fact a reclaimer so it even get to the reclaim.

The driver we use is similar to loop. It works as a proxy to fs it works
on top of. Allowing it to access emergency reserves would deplete them
quickly, just like in case of plain loop.

The problem is not about our driver, in fact. I'm pretty sure one can
hit it when using memcg along with loop or dm-crypt for instance.

> 
> There way too many allocations done from the kernel thread context to be
> not throttled (just look at worker threads).

What about throttling them only once then?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 97ba9e1cde09..9253f4531b9c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1578,6 +1578,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		/* We are about to die and free our memory. Return now. */
 		if (fatal_signal_pending(current))
 			return SWAP_CLUSTER_MAX;
+
+		if (current->flags & PF_KTHREAD)
+			break;
 	}
 
 	lru_add_drain();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
