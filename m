Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 21B386B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 06:26:02 -0500 (EST)
Received: by lfdl133 with SMTP id l133so3865197lfd.2
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 03:26:01 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id b142si19979745lfb.164.2015.12.01.03.25.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 03:25:59 -0800 (PST)
Date: Tue, 1 Dec 2015 14:25:45 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] vmscan: do not throttle kthreads due to too_many_isolated
Message-ID: <20151201112544.GB11488@esperanza>
References: <1448465801-3280-1-git-send-email-vdavydov@virtuozzo.com>
 <5655D789.80201@suse.cz>
 <20151125162756.GJ29014@esperanza>
 <20151126081624.GK29014@esperanza>
 <20151127125005.GH2493@dhcp22.suse.cz>
 <20151127134003.GR29014@esperanza>
 <20151127150133.GI2493@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151127150133.GI2493@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 27, 2015 at 04:01:33PM +0100, Michal Hocko wrote:
> On Fri 27-11-15 16:40:03, Vladimir Davydov wrote:
> > On Fri, Nov 27, 2015 at 01:50:05PM +0100, Michal Hocko wrote:
> > > On Thu 26-11-15 11:16:24, Vladimir Davydov wrote:
> [...]
> > > > Anyway, kthreads that use GFP_NOIO and/or mempool aren't safe either,
> > > > because it isn't an allocation context problem: the reclaimer locks up
> > > > not because it tries to take an fs/io lock the caller holds, but because
> > > > it waits for isolated pages to be put back, which will never happen,
> > > > since processes that isolated them depend on the kthread making
> > > > progress. This is purely a reclaimer heuristic, which kmalloc users are
> > > > not aware of.
> > > > 
> > > > My point is that, in contrast to userspace processes, it is dangerous to
> > > > throttle kthreads in the reclaimer, because they might be responsible
> > > > for reclaimer progress (e.g. performing writeback).
> > > 
> > > Wouldn't it be better if your writeback kthread did PF_MEMALLOC/__GFP_MEMALLOC
> > > instead because it is in fact a reclaimer so it even get to the reclaim.
> > 
> > The driver we use is similar to loop. It works as a proxy to fs it works
> > on top of. Allowing it to access emergency reserves would deplete them
> > quickly, just like in case of plain loop.
> 
> OK, I see. I thought it would be using only a very limited amount of
> memory for the writeback.

Even if it does, there's still a chance of a dead lock: even if kthread
uses mempool + NOIO, it can go into direct reclaim and start looping in
too_many_isolated AFAIU. The probability of this happening is much less
though.

> 
> > The problem is not about our driver, in fact. I'm pretty sure one can
> > hit it when using memcg along with loop or dm-crypt for instance.
> 
> I am not familiar much with neither but from a quick look the loop
> driver doesn't use mempools tool, it simply relays the data to the
> underlaying file and relies on the underlying fs to write all the pages
> and only prevents from the recursion by clearing GFP_FS and GFP_IO. Then
> I am not really sure how can we guarantee a forward progress. The
> GFP_NOFS allocation might loop inside the allocator endlessly and so
> the writeback wouldn't make any progress. This doesn't seem to be only
> memcg specific. The global case would just replace the deadlock by a
> livelock. I certainly must be missing something here.

Yeah, I think you're right. If the loop kthread gets stuck in the
reclaimer, it might occur that other processes will isolate, reclaim and
then dirty reclaimed pages, preventing the kthread from running and
cleaning memory, so that we might end up with all memory being under
writeback and no reclaimable memory left for kthread to run and clean
it. Due to dirty limit, this is unlikely to happen though, but I'm not
sure.

OTOH, with legacy memcg, there is no dirty limit and we can isolate a
lot of pages (SWAP_CLUSTER_MAX = 512 now) per process and wait on page
writeback to complete before releasing them, which sounds bad. And we
can't just remove this wait_on_page_writeback from shrink_page_list,
otherwise OOM might be triggered prematurely. May be, we should putback
rotated pages and release all reclaimed pages before initiating wait?

> 
> > > There way too many allocations done from the kernel thread context to be
> > > not throttled (just look at worker threads).
> > 
> > What about throttling them only once then?
> 
> This still sounds way too broad to me and I am even not sure it solves
> the problem. If anything I think we really should make it specific
> only to those callers who are really required to make a forward
> progress. What about PF_LESS_THROTTLE? NFS is already using this flag for a
> similar purpose and we indeed do not throttle at few places during the
> reclaim. So I would expect current_may_throttle(current) check there
> although I must confess I have no idea about the whole condition right
> now.

Yeah, thanks for the tip. I'll take a look.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
