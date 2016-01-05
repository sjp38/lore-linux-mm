Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id D1A716B0007
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 11:35:39 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id e32so191871887qgf.3
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 08:35:39 -0800 (PST)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id 80si4963478qkq.59.2016.01.05.08.35.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Jan 2016 08:35:38 -0800 (PST)
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 5 Jan 2016 09:35:37 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 6CC6E1FF0049
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 09:23:46 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u05GZZTm19464290
	for <linux-mm@kvack.org>; Tue, 5 Jan 2016 09:35:35 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u05GZY6q026208
	for <linux-mm@kvack.org>; Tue, 5 Jan 2016 09:35:35 -0700
Date: Tue, 5 Jan 2016 08:35:37 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [Intel-gfx] [PATCH v2 1/3] drm/i915: Enable lockless lookup of
 request tracking via RCU
Message-ID: <20160105163537.GL32217@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1450869563-23892-1-git-send-email-chris@chris-wilson.co.uk>
 <1450877756-2902-1-git-send-email-chris@chris-wilson.co.uk>
 <20160105145951.GN8076@phenom.ffwll.local>
 <20160105150213.GP6344@twins.programming.kicks-ass.net>
 <20160105150648.GT6373@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160105150648.GT6373@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, Linux MM <linux-mm@kvack.org>, Jens Axboe <jens.axboe@oracle.com>, Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, Jan 05, 2016 at 04:06:48PM +0100, Peter Zijlstra wrote:
> On Tue, Jan 05, 2016 at 04:02:13PM +0100, Peter Zijlstra wrote:
> > > Shouldn't the slab subsystem do this for us if we request it delays the
> > > actual kfree? Seems like a core bug to me ... Adding more folks.
> > 
> > note that sync_rcu() can take a terribly long time.. but yes, I seem to
> > remember Paul talking about adding this to reclaim paths for just this
> > reason. Not sure that ever happened thouhg.

There is an RCU OOM notifier, but it just ensures that existing callbacks
get processed in a timely fashion.  It does not block, as that would
prevent other OOM notifiers from getting their memory freed quickly.

> Also, you might be wanting rcu_barrier() instead, that not only waits
> for a GP to complete, but also for all pending callbacks to be
> processed.

And in fact what the RCU OOM notifier does can be thought of as an
asynchronous open-coded rcu_barrier().  If you are interested, please
see rcu_register_oom_notifier() and friends.

> Without the latter there might still not be anything to free after it.

Another approach is synchronize_rcu() after some largish number of
requests.  The advantage of this approach is that it throttles the
production of callbacks at the source.  The corresponding disadvantage
is that it slows things up.

Another approach is to use call_rcu(), but if the previous call_rcu()
is still in flight, block waiting for it.  Yet another approach is
the get_state_synchronize_rcu() / cond_synchronize_rcu() pair.  The
idea is to do something like this:

	cond_synchronize_rcu(cookie);
	cookie = get_state_synchronize_rcu();

You would of course do an initial get_state_synchronize_rcu() to
get things going.  This would not block unless there was less than
one grace period's worth of time between invocations.  But this
assumes a busy system, where there is almost always a grace period
in flight.  But you can make that happen as follows:

	cond_synchronize_rcu(cookie);
	cookie = get_state_synchronize_rcu();
	call_rcu(&my_rcu_head, noop_function);

Note that you need additional code to make sure that the old callback
has completed before doing a new one.  Setting and clearing a flag
with appropriate memory ordering control suffices (e.g,. smp_load_acquire()
and smp_store_release()).

And there are probably other approaches as well...

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
