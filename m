Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id E4BB46B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 21:50:34 -0500 (EST)
Received: by widem10 with SMTP id em10so19502421wid.1
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 18:50:34 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id jo3si25268759wjc.166.2015.03.02.18.50.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 18:50:33 -0800 (PST)
Date: Mon, 2 Mar 2015 21:50:23 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150303025023.GA22453@phnom.home.cmpxchg.org>
References: <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150222172930.6586516d.akpm@linux-foundation.org>
 <20150223073235.GT4251@dastard>
 <20150302202228.GA15089@phnom.home.cmpxchg.org>
 <20150302231206.GK18360@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150302231206.GK18360@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Tue, Mar 03, 2015 at 10:12:06AM +1100, Dave Chinner wrote:
> On Mon, Mar 02, 2015 at 03:22:28PM -0500, Johannes Weiner wrote:
> > On Mon, Feb 23, 2015 at 06:32:35PM +1100, Dave Chinner wrote:
> > > On Sun, Feb 22, 2015 at 05:29:30PM -0800, Andrew Morton wrote:
> > > > When allocating pages the caller should drain its reserves in
> > > > preference to dipping into the regular freelist.  This guy has already
> > > > done his reclaim and shouldn't be penalised a second time.  I guess
> > > > Johannes's preallocation code should switch to doing this for the same
> > > > reason, plus the fact that snipping a page off
> > > > task_struct.prealloc_pages is super-fast and needs to be done sometime
> > > > anyway so why not do it by default.
> > > 
> > > That is at odds with the requirements of demand paging, which
> > > allocate for objects that are reclaimable within the course of the
> > > transaction. The reserve is there to ensure forward progress for
> > > allocations for objects that aren't freed until after the
> > > transaction completes, but if we drain it for reclaimable objects we
> > > then have nothing left in the reserve pool when we actually need it.
> > >
> > > We do not know ahead of time if the object we are allocating is
> > > going to modified and hence locked into the transaction. Hence we
> > > can't say "use the reserve for this *specific* allocation", and so
> > > the only guidance we can really give is "we will to allocate and
> > > *permanently consume* this much memory", and the reserve pool needs
> > > to cover that consumption to guarantee forwards progress.
> > > 
> > > Forwards progress for all other allocations is guaranteed because
> > > they are reclaimable objects - they either freed directly back to
> > > their source (slab, heap, page lists) or they are freed by shrinkers
> > > once they have been released from the transaction.
> > > 
> > > Hence we need allocations to come from the free list and trigger
> > > reclaim, regardless of the fact there is a reserve pool there. The
> > > reserve pool needs to be a last resort once there are no other
> > > avenues to allocate memory. i.e. it would be used to replace the OOM
> > > killer for GFP_NOFAIL allocations.
> > 
> > That won't work.
> 
> I don't see why not...
> 
> > Clean cache can be temporarily unavailable and
> > off-LRU for several reasons - compaction, migration, pending page
> > promotion, other reclaimers.  How often are we trying before we dip
> > into the reserve pool?  As you have noticed, the OOM killer goes off
> > seemingly prematurely at times, and the reason for that is that we
> > simply don't KNOW the exact point when we ran out of reclaimable
> > memory.
> 
> Sure, but that's irrelevant to the problem at hand. At some point,
> the Mm subsystem is going to decide "we're at OOM" - it's *what
> happens next* that matters.

It's not irrelevant at all.  That point is an arbitrary magic number
that is a byproduct of many implementation details and concurrency in
the memory management layer.  It's completely fine to tie allocations
which can fail to this point, but you can't reasonably calibrate your
emergency reserves, which are supposed to guarantee progress, to such
an unpredictable variable.

When you reserve based on the share of allocations that you know will
be unreclaimable, you are assuming that all other allocations will be
reclaimable, and that is simply flawed.  There is so much concurrency
in the MM subsystem that you can't reasonably expect a single scanner
instance to recover the majority of theoretically reclaimable memory.

> > We cannot take an atomic snapshot of all zones, of all nodes,
> > of all tasks running in order to determine this reliably, we have to
> > approximate it.  That's why OOM is defined as "we have scanned a great
> > many pages and couldn't free any of them."
> 
> Yes, and reserve pools *do not change* the logic that leads to that
> decision. What changes is that we don't "kick the OOM killer",
> instead we "allocate from the reserve pool." The reserve pool
> *replaces* the OOM killer as a method of guaranteeing forwards
> allocation progress for those subsystems that can use reservations.

In order to replace the OOM killer in its role as progress guarantee,
the reserves can't run dry during the transaction.  Because what are
we going to do in that case?

> If there is no reserve pool for the current task, then you can still
> kick the OOM killer....

... so we are not actually replacing the OOM killer, we just defer it
with reserves that were calibrated to an anecdotal snapshot of a fuzzy
quantity of reclaim activity?  Is the idea here to just pile sh*tty,
mostly-working mechanisms on top of each other in the hope that one of
them will kick things along just enough to avoid locking up?

> > So unless you tell us which allocations should come from previously
> > declared reserves, and which ones should rely on reclaim and may fail,
> > the reserves can deplete prematurely and we're back to square one.
> 
> Like the OOM killer, filesystems are not omnipotent and are not
> perfect.  Requiring us to be so is entirely unreasonable, and is
> *entirely unnecessary* from the POV of the mm subsystem.
> 
> Reservations give the mm subsystem a *strong model* for guaranteeing
> forwards allocation progress, and it can be independently verified
> and tested without having to care about how some subsystem uses it.
> The mm subsystem supplies the *mechanism*, and mm developers are
> entirely focussed around ensuring the mechanism works and is
> verifiable.  i.e. you could write some debug kernel module to
> exercise, verify and regression test the model behaviour, which is
> something that simply cannot be done with the OOM killer.
> 
> Reservation sizes required by a subsystem are *policy*. They are not
> a problem the mm subsystem needs to be concerned with as the
> subsystem has to get the reservations right for the mechanism to
> work. i.e. Managing reservation sizes is my responsibility as a
> subsystem maintainer, just like it's currently my responsibility for
> ensuring that transient ENOMEM conditions don't result in a
> filesystem shutdown....

Anything that depends on the point at which the memory management
system gives up reclaiming pages is not verifiable in the slightest.
It will vary from kernel to kernel, from workload to workload, from
run to run.  It will regress in the blink of an eye.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
