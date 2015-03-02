Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9443A6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 18:15:51 -0500 (EST)
Received: by pdjz10 with SMTP id z10so43195550pdj.12
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 15:15:51 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id f3si7588305pas.96.2015.03.02.15.15.49
        for <linux-mm@kvack.org>;
        Mon, 02 Mar 2015 15:15:50 -0800 (PST)
Date: Tue, 3 Mar 2015 10:12:06 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150302231206.GK18360@dastard>
References: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150222172930.6586516d.akpm@linux-foundation.org>
 <20150223073235.GT4251@dastard>
 <20150302202228.GA15089@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150302202228.GA15089@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Mon, Mar 02, 2015 at 03:22:28PM -0500, Johannes Weiner wrote:
> On Mon, Feb 23, 2015 at 06:32:35PM +1100, Dave Chinner wrote:
> > On Sun, Feb 22, 2015 at 05:29:30PM -0800, Andrew Morton wrote:
> > > When allocating pages the caller should drain its reserves in
> > > preference to dipping into the regular freelist.  This guy has already
> > > done his reclaim and shouldn't be penalised a second time.  I guess
> > > Johannes's preallocation code should switch to doing this for the same
> > > reason, plus the fact that snipping a page off
> > > task_struct.prealloc_pages is super-fast and needs to be done sometime
> > > anyway so why not do it by default.
> > 
> > That is at odds with the requirements of demand paging, which
> > allocate for objects that are reclaimable within the course of the
> > transaction. The reserve is there to ensure forward progress for
> > allocations for objects that aren't freed until after the
> > transaction completes, but if we drain it for reclaimable objects we
> > then have nothing left in the reserve pool when we actually need it.
> >
> > We do not know ahead of time if the object we are allocating is
> > going to modified and hence locked into the transaction. Hence we
> > can't say "use the reserve for this *specific* allocation", and so
> > the only guidance we can really give is "we will to allocate and
> > *permanently consume* this much memory", and the reserve pool needs
> > to cover that consumption to guarantee forwards progress.
> > 
> > Forwards progress for all other allocations is guaranteed because
> > they are reclaimable objects - they either freed directly back to
> > their source (slab, heap, page lists) or they are freed by shrinkers
> > once they have been released from the transaction.
> > 
> > Hence we need allocations to come from the free list and trigger
> > reclaim, regardless of the fact there is a reserve pool there. The
> > reserve pool needs to be a last resort once there are no other
> > avenues to allocate memory. i.e. it would be used to replace the OOM
> > killer for GFP_NOFAIL allocations.
> 
> That won't work.

I don't see why not...

> Clean cache can be temporarily unavailable and
> off-LRU for several reasons - compaction, migration, pending page
> promotion, other reclaimers.  How often are we trying before we dip
> into the reserve pool?  As you have noticed, the OOM killer goes off
> seemingly prematurely at times, and the reason for that is that we
> simply don't KNOW the exact point when we ran out of reclaimable
> memory.

Sure, but that's irrelevant to the problem at hand. At some point,
the Mm subsystem is going to decide "we're at OOM" - it's *what
happens next* that matters.

> We cannot take an atomic snapshot of all zones, of all nodes,
> of all tasks running in order to determine this reliably, we have to
> approximate it.  That's why OOM is defined as "we have scanned a great
> many pages and couldn't free any of them."

Yes, and reserve pools *do not change* the logic that leads to that
decision. What changes is that we don't "kick the OOM killer",
instead we "allocate from the reserve pool." The reserve pool
*replaces* the OOM killer as a method of guaranteeing forwards
allocation progress for those subsystems that can use reservations.
If there is no reserve pool for the current task, then you can still
kick the OOM killer....

> So unless you tell us which allocations should come from previously
> declared reserves, and which ones should rely on reclaim and may fail,
> the reserves can deplete prematurely and we're back to square one.

Like the OOM killer, filesystems are not omnipotent and are not
perfect.  Requiring us to be so is entirely unreasonable, and is
*entirely unnecessary* from the POV of the mm subsystem.

Reservations give the mm subsystem a *strong model* for guaranteeing
forwards allocation progress, and it can be independently verified
and tested without having to care about how some subsystem uses it.
The mm subsystem supplies the *mechanism*, and mm developers are
entirely focussed around ensuring the mechanism works and is
verifiable.  i.e. you could write some debug kernel module to
exercise, verify and regression test the model behaviour, which is
something that simply cannot be done with the OOM killer.

Reservation sizes required by a subsystem are *policy*. They are not
a problem the mm subsystem needs to be concerned with as the
subsystem has to get the reservations right for the mechanism to
work. i.e. Managing reservation sizes is my responsibility as a
subsystem maintainer, just like it's currently my responsibility for
ensuring that transient ENOMEM conditions don't result in a
filesystem shutdown....

> Compaction can be at an impasse for the same reasons mentioned above.
> It can not just stop_machine() to guarantee it can assemble a higher
> order page from a bunch of in-use order-0 cache pages.  If you need
> higher-order allocations in a transaction, you have to pre-allocate.

It's much simpler just to use order-0 reservations and vmalloc if we
can't get high order allocations. We already do this in most places
where high order allocations are required, so there's really no
change needed here. ;)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
