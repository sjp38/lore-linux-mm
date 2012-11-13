Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 690AF6B006C
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 08:31:19 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so5512336pad.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 05:31:18 -0800 (PST)
Date: Tue, 13 Nov 2012 22:31:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zram OOM behavior
Message-ID: <20121113133109.GA5204@barrios>
References: <20121102063958.GC3326@bbox>
 <20121102083057.GG8218@suse.de>
 <20121102223630.GA2070@barrios>
 <20121105144614.GJ8218@suse.de>
 <20121106002550.GA3530@barrios>
 <20121106085822.GN8218@suse.de>
 <20121106101719.GA2005@barrios>
 <20121109095024.GI8218@suse.de>
 <20121112133218.GA3156@barrios>
 <20121112140631.GV8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121112140631.GV8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Mon, Nov 12, 2012 at 02:06:31PM +0000, Mel Gorman wrote:
> On Mon, Nov 12, 2012 at 10:32:18PM +0900, Minchan Kim wrote:
> > Sorry for the late reply.
> > I'm still going on training course until this week so my response would be delayed, too.
> > 
> > > > > > > <SNIP>
> > > > > > > It may be completely unnecessary to reclaim memory if the process that was
> > > > > > > throttled and killed just exits quickly. As the fatal signal is pending
> > > > > > > it will be able to use the pfmemalloc reserves.
> > > > > > > 
> > > > > > > > If he can't make forward progress with direct reclaim, he can ends up OOM path but
> > > > > > > > out_of_memory checks signal check of current and allow to access reserved memory pool
> > > > > > > > for quick exit and return without killing other victim selection.
> > > > > > > 
> > > > > > > While this is true, what advantage is there to having a killed process
> > > > > > > potentially reclaiming memory it does not need to?
> > > > > > 
> > > > > > Killed process needs a memory for him to be terminated. I think it's not a good idea for him
> > > > > > to use reserved memory pool unconditionally although he is throtlled and killed.
> > > > > > Because reserved memory pool is very stricted resource for emergency so using reserved memory
> > > > > > pool should be last resort after he fail to reclaim.
> > > > > > 
> > > > > 
> > > > > Part of that reclaim can be the process reclaiming its own pages and
> > > > > putting them in swap just so it can exit shortly afterwards. If it was
> > > > > throttled in this path, it implies that swap-over-NFS is enabled where
> > > > 
> > > > Could we make sure it's only the case for swap-over-NFS?
> > > 
> > > The PFMEMALLOC reserves being consumed to the point of throttline is only
> > > expected in the case of swap-over-network -- check the pgscan_direct_throttle
> > > counter to be sure. So it's already the case that this throttling logic and
> > > its signal handling is mostly a swap-over-NFS thing. It is possible that
> > > a badly behaving driver using GFP_ATOMIC to allocate long-lived buffers
> > > could force a situation where a process gets throttled but I'm not aware
> > > of a case where this happens todays.
> > 
> > I saw some custom drviers in embedded side have used GFP_ATOMIC easily to protect
> > avoiding deadlock.
> 
> They must be getting a lot of allocation failures in that case.

It depends on workload and I didn't received any report from them.

> 
> > Of course, it's not a good behavior but it lives with us.
> > Even, we can't fix it because we don't have any source. :(
> > 
> > > 
> > > > I think it can happen if the system has very slow thumb card.
> > > > 
> > > 
> > > How? They shouldn't be stuck in throttling in this case. They should be
> > > blocked on IO, congestion wait, dirty throttling etc.
> > 
> > Some block driver(ex, mmc) uses a thread model with PF_MEMALLOC so I think
> > they can be stucked by the throttling logic.
> > 
> 
> If they are using PF_MEMALLOC + GFP_ATOMIC, there is a strong chance
> that they'll actually deadlock their system if there are a storm of
> allocations. The drivers is fundamentally broken in a dangerous way.
> None of that is fixed by forcing an exiting process to enter direct reclaim.

Agreed.

> 
> > > 
> > > > > such reclaim in fact might require the pfmemalloc reserves to be used to
> > > > > allocate network buffers. It's potentially unnecessary work because the
> > > > 
> > > > You mean we need pfmemalloc reserve to swap out anon pages by swap-over-NFS?
> > > 
> > > In very low-memory situations - yes. We can be at the min watermark but
> > > still need to allocate a page for a network buffer to swap out the anon page.
> > > 
> > > > Yes. In this case, you're right. I would be better to use reserve pool for
> > > > just exiting instead of swap out over network. But how can you make sure that
> > > > we have only anonymous page when we try to reclaim? 
> > > > If there are some file-backed pages, we can avoid swapout at that time.
> > > > Maybe we need some check.
> > > > 
> > > 
> > > That would be a fairly invasive set of checks for a corner case. if
> > > swap-over-nfs + critically low + about to OOM + file pages available then
> > > only reclaim files.
> > > 
> > > It's getting off track as to why we're having this discussion in the first
> > > place -- looping due to improper handling of fatal signal pending.
> > 
> > If some user tune /proc/sys/vm/swappiness, we could have many page cache pages
> > when swap-over-NFS happens.
> 
> That's a BIG if. swappiness could be anything and it'll depend on the
> workload anyway.

Yes but we don't have to ignore such case.

> 
> > My point is that why do we should use emergency memory pool although we have
> > reclaimalble memory?
> > 
> 
> Because as I have already pointed out, the use of swap-over-nfs itself
> creates more allocation pressure if it is used in the reclaim path. The
> emergency memory pool is used *anyway* unless there are clean file pages
> that can be discarded. But that's a big "if". The safer path is to try
> and exit and if *that* fails *then* enter direct reclaim.

Okay. Let's see your code again POV side effect other than OOM deadlock problem.

1. pfmemalloc_watermark_ok == false but the process is received SIGKILL
   before calling throttle_direct_reclaim.

In this case, it enters direct reclaim path and would swap out anon pages.
It's a thing you are concerning now(ie, creates more allocation pressure)
Is it okay?

2. pfmemalloc_watermark_ok == false but the process is received SIGKILL
   while throttling.

In this case, it skips direct reclaim in first path and retry to allocate page.
If another procces free some memory or is killed, it can get a free page and
return. Yes. it would be good rather than unnecessary swap out and OOM kill.
Otherwise, it calls direct compaction again and then enter direct reclaim path.
It ends up consuming emergency memory pool to swap out anonymous pages or
OOM killed. Again, it's a thing you are concerning now.

So, your patch's effect depends on timing that other process release memory.
Is it right?
If it is your intention, I don't oppose it any more because apprantely it
has a benefit than I suggested. But please write description more clearly.
Below previous description focused only OOM deadlock problem and didn't explain
patch's side effect which I mentioned above.

[
mm: vmscan: Check for fatal signals iff the process was throttled

commit 5515061d22f0 ("mm: throttle direct reclaimers if PF_MEMALLOC reserves
are low and swap is backed by network storage") introduced a check for
fatal signals after a process gets throttled for network storage. The
intention was that if a process was throttled and got killed that it
should not trigger the OOM killer. As pointed out by Minchan Kim and
David Rientjes, this check is in the wrong place and too broad. If a
system is in am OOM situation and a process is exiting, it can loop in
__alloc_pages_slowpath() and calling direct reclaim in a loop. As the
fatal signal is pending it returns 1 as if it is making forward progress
and can effectively deadlock.

This patch moves the fatal_signal_pending() check after throttling to
throttle_direct_reclaim() where it belongs.

If this patch passes review it should be considered a -stable candidate
for 3.6.
]

> 
> -- 
> Mel Gorman
> SUSE Labs

-- 
Kind Regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
