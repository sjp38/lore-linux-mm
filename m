Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 892E46B0062
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 09:06:36 -0500 (EST)
Date: Mon, 12 Nov 2012 14:06:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: zram OOM behavior
Message-ID: <20121112140631.GV8218@suse.de>
References: <20121102063958.GC3326@bbox>
 <20121102083057.GG8218@suse.de>
 <20121102223630.GA2070@barrios>
 <20121105144614.GJ8218@suse.de>
 <20121106002550.GA3530@barrios>
 <20121106085822.GN8218@suse.de>
 <20121106101719.GA2005@barrios>
 <20121109095024.GI8218@suse.de>
 <20121112133218.GA3156@barrios>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121112133218.GA3156@barrios>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Mon, Nov 12, 2012 at 10:32:18PM +0900, Minchan Kim wrote:
> Sorry for the late reply.
> I'm still going on training course until this week so my response would be delayed, too.
> 
> > > > > > <SNIP>
> > > > > > It may be completely unnecessary to reclaim memory if the process that was
> > > > > > throttled and killed just exits quickly. As the fatal signal is pending
> > > > > > it will be able to use the pfmemalloc reserves.
> > > > > > 
> > > > > > > If he can't make forward progress with direct reclaim, he can ends up OOM path but
> > > > > > > out_of_memory checks signal check of current and allow to access reserved memory pool
> > > > > > > for quick exit and return without killing other victim selection.
> > > > > > 
> > > > > > While this is true, what advantage is there to having a killed process
> > > > > > potentially reclaiming memory it does not need to?
> > > > > 
> > > > > Killed process needs a memory for him to be terminated. I think it's not a good idea for him
> > > > > to use reserved memory pool unconditionally although he is throtlled and killed.
> > > > > Because reserved memory pool is very stricted resource for emergency so using reserved memory
> > > > > pool should be last resort after he fail to reclaim.
> > > > > 
> > > > 
> > > > Part of that reclaim can be the process reclaiming its own pages and
> > > > putting them in swap just so it can exit shortly afterwards. If it was
> > > > throttled in this path, it implies that swap-over-NFS is enabled where
> > > 
> > > Could we make sure it's only the case for swap-over-NFS?
> > 
> > The PFMEMALLOC reserves being consumed to the point of throttline is only
> > expected in the case of swap-over-network -- check the pgscan_direct_throttle
> > counter to be sure. So it's already the case that this throttling logic and
> > its signal handling is mostly a swap-over-NFS thing. It is possible that
> > a badly behaving driver using GFP_ATOMIC to allocate long-lived buffers
> > could force a situation where a process gets throttled but I'm not aware
> > of a case where this happens todays.
> 
> I saw some custom drviers in embedded side have used GFP_ATOMIC easily to protect
> avoiding deadlock.

They must be getting a lot of allocation failures in that case.

> Of course, it's not a good behavior but it lives with us.
> Even, we can't fix it because we don't have any source. :(
> 
> > 
> > > I think it can happen if the system has very slow thumb card.
> > > 
> > 
> > How? They shouldn't be stuck in throttling in this case. They should be
> > blocked on IO, congestion wait, dirty throttling etc.
> 
> Some block driver(ex, mmc) uses a thread model with PF_MEMALLOC so I think
> they can be stucked by the throttling logic.
> 

If they are using PF_MEMALLOC + GFP_ATOMIC, there is a strong chance
that they'll actually deadlock their system if there are a storm of
allocations. The drivers is fundamentally broken in a dangerous way.
None of that is fixed by forcing an exiting process to enter direct reclaim.

> > 
> > > > such reclaim in fact might require the pfmemalloc reserves to be used to
> > > > allocate network buffers. It's potentially unnecessary work because the
> > > 
> > > You mean we need pfmemalloc reserve to swap out anon pages by swap-over-NFS?
> > 
> > In very low-memory situations - yes. We can be at the min watermark but
> > still need to allocate a page for a network buffer to swap out the anon page.
> > 
> > > Yes. In this case, you're right. I would be better to use reserve pool for
> > > just exiting instead of swap out over network. But how can you make sure that
> > > we have only anonymous page when we try to reclaim? 
> > > If there are some file-backed pages, we can avoid swapout at that time.
> > > Maybe we need some check.
> > > 
> > 
> > That would be a fairly invasive set of checks for a corner case. if
> > swap-over-nfs + critically low + about to OOM + file pages available then
> > only reclaim files.
> > 
> > It's getting off track as to why we're having this discussion in the first
> > place -- looping due to improper handling of fatal signal pending.
> 
> If some user tune /proc/sys/vm/swappiness, we could have many page cache pages
> when swap-over-NFS happens.

That's a BIG if. swappiness could be anything and it'll depend on the
workload anyway.

> My point is that why do we should use emergency memory pool although we have
> reclaimalble memory?
> 

Because as I have already pointed out, the use of swap-over-nfs itself
creates more allocation pressure if it is used in the reclaim path. The
emergency memory pool is used *anyway* unless there are clean file pages
that can be discarded. But that's a big "if". The safer path is to try
and exit and if *that* fails *then* enter direct reclaim.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
