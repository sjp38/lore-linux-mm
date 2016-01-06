Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id AB96A6B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 03:07:01 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id f206so63903566wmf.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 00:07:01 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id bk7si106560971wjb.34.2016.01.06.00.07.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 00:07:00 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id f206so50651859wmf.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 00:07:00 -0800 (PST)
Date: Wed, 6 Jan 2016 09:06:58 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Intel-gfx] [PATCH v2 1/3] drm/i915: Enable lockless lookup of
 request tracking via RCU
Message-ID: <20160106080658.GC8076@phenom.ffwll.local>
References: <1450869563-23892-1-git-send-email-chris@chris-wilson.co.uk>
 <1450877756-2902-1-git-send-email-chris@chris-wilson.co.uk>
 <20160105145951.GN8076@phenom.ffwll.local>
 <20160105150213.GP6344@twins.programming.kicks-ass.net>
 <20160105150648.GT6373@twins.programming.kicks-ass.net>
 <20160105163537.GL32217@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160105163537.GL32217@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, Linux MM <linux-mm@kvack.org>, Jens Axboe <jens.axboe@oracle.com>, Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, Jan 05, 2016 at 08:35:37AM -0800, Paul E. McKenney wrote:
> On Tue, Jan 05, 2016 at 04:06:48PM +0100, Peter Zijlstra wrote:
> > On Tue, Jan 05, 2016 at 04:02:13PM +0100, Peter Zijlstra wrote:
> > > > Shouldn't the slab subsystem do this for us if we request it delays the
> > > > actual kfree? Seems like a core bug to me ... Adding more folks.
> > > 
> > > note that sync_rcu() can take a terribly long time.. but yes, I seem to
> > > remember Paul talking about adding this to reclaim paths for just this
> > > reason. Not sure that ever happened thouhg.
> 
> There is an RCU OOM notifier, but it just ensures that existing callbacks
> get processed in a timely fashion.  It does not block, as that would
> prevent other OOM notifiers from getting their memory freed quickly.
> 
> > Also, you might be wanting rcu_barrier() instead, that not only waits
> > for a GP to complete, but also for all pending callbacks to be
> > processed.
> 
> And in fact what the RCU OOM notifier does can be thought of as an
> asynchronous open-coded rcu_barrier().  If you are interested, please
> see rcu_register_oom_notifier() and friends.
> 
> > Without the latter there might still not be anything to free after it.
> 
> Another approach is synchronize_rcu() after some largish number of
> requests.  The advantage of this approach is that it throttles the
> production of callbacks at the source.  The corresponding disadvantage
> is that it slows things up.
> 
> Another approach is to use call_rcu(), but if the previous call_rcu()
> is still in flight, block waiting for it.  Yet another approach is
> the get_state_synchronize_rcu() / cond_synchronize_rcu() pair.  The
> idea is to do something like this:
> 
> 	cond_synchronize_rcu(cookie);
> 	cookie = get_state_synchronize_rcu();
> 
> You would of course do an initial get_state_synchronize_rcu() to
> get things going.  This would not block unless there was less than
> one grace period's worth of time between invocations.  But this
> assumes a busy system, where there is almost always a grace period
> in flight.  But you can make that happen as follows:
> 
> 	cond_synchronize_rcu(cookie);
> 	cookie = get_state_synchronize_rcu();
> 	call_rcu(&my_rcu_head, noop_function);
> 
> Note that you need additional code to make sure that the old callback
> has completed before doing a new one.  Setting and clearing a flag
> with appropriate memory ordering control suffices (e.g,. smp_load_acquire()
> and smp_store_release()).

This pretty much went over my head ;-) What I naively hoped for is that
kfree() on an rcu-freeing slab could be tought to magically stall a bit
(or at least expedite the delayed freeing) if we're piling up too many
freed objects. Doing that only in OOM is probably too late since OOM
handling is a bit unreliable/unpredictable. And I thought we're not the
first ones running into this problem.

Do all the other users of rcu-freed slabs just open-code their own custom
approach? If that's the recommendation we can certainly follow that, too.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
