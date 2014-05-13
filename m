Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5506B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 11:27:25 -0400 (EDT)
Received: by mail-yk0-f176.google.com with SMTP id q9so413465ykb.21
        for <linux-mm@kvack.org>; Tue, 13 May 2014 08:27:24 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id x54si20690410yhe.109.2014.05.13.08.27.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 13 May 2014 08:27:24 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 13 May 2014 09:27:23 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 59D0E19D8041
	for <linux-mm@kvack.org>; Tue, 13 May 2014 09:27:15 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4DFQUcx65667072
	for <linux-mm@kvack.org>; Tue, 13 May 2014 17:26:30 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s4DFVDg3015009
	for <linux-mm@kvack.org>; Tue, 13 May 2014 09:31:13 -0600
Date: Tue, 13 May 2014 08:27:19 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
 waitqueue lookups in unlock_page fastpath
Message-ID: <20140513152719.GF18164@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140513141748.GD2485@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Tue, May 13, 2014 at 04:17:48PM +0200, Peter Zijlstra wrote:
> On Tue, May 13, 2014 at 01:53:13PM +0100, Mel Gorman wrote:
> > On Tue, May 13, 2014 at 10:45:50AM +0100, Mel Gorman wrote:
> > >  void unlock_page(struct page *page)
> > >  {
> > > +	wait_queue_head_t *wqh = clear_page_waiters(page);
> > > +
> > >  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> > > +
> > > +	/*
> > > +	 * No additional barrier needed due to clear_bit_unlock barriering all updates
> > > +	 * before waking waiters
> > > +	 */
> > >  	clear_bit_unlock(PG_locked, &page->flags);
> > > -	smp_mb__after_clear_bit();
> > > -	wake_up_page(page, PG_locked);
> > 
> > This is wrong. The smp_mb__after_clear_bit() is still required to ensure
> > that the cleared bit is visible before the wakeup on all architectures.
> 
> wakeup implies a mb, and I just noticed that our Documentation is
> 'obsolete' and only mentions it implies a wmb.
> 
> Also, if you're going to use smp_mb__after_atomic() you can use
> clear_bit() and not use clear_bit_unlock().
> 
> 
> 
> ---
> Subject: doc: Update wakeup barrier documentation
> 
> As per commit e0acd0a68ec7 ("sched: fix the theoretical signal_wake_up()
> vs schedule() race") both wakeup and schedule now imply a full barrier.
> 
> Furthermore, the barrier is unconditional when calling try_to_wake_up()
> and has been for a fair while.
> 
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: David Howells <dhowells@redhat.com>
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>

Some questions below.

							Thanx, Paul

> ---
>  Documentation/memory-barriers.txt | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barriers.txt
> index 46412bded104..dae5158c2382 100644
> --- a/Documentation/memory-barriers.txt
> +++ b/Documentation/memory-barriers.txt
> @@ -1881,9 +1881,9 @@ The whole sequence above is available in various canned forms, all of which
>  	event_indicated = 1;
>  	wake_up_process(event_daemon);
> 
> -A write memory barrier is implied by wake_up() and co. if and only if they wake
> -something up.  The barrier occurs before the task state is cleared, and so sits
> -between the STORE to indicate the event and the STORE to set TASK_RUNNING:
> +A full memory barrier is implied by wake_up() and co. The barrier occurs

Last I checked, the memory barrier was guaranteed only if a wakeup
actually occurred.  If there is a sleep-wakeup race, for example,
between wait_event_interruptible() and wake_up(), then it looks to me
that the following can happen:

o	Task A invokes wait_event_interruptible(), waiting for
	X==1.

o	Before Task A gets anywhere, Task B sets Y=1, does
	smp_mb(), then sets X=1.

o	Task B invokes wake_up(), which invokes __wake_up(), which
	acquires the wait_queue_head_t's lock and invokes
	__wake_up_common(), which sees nothing to wake up.

o	Task A tests the condition, finds X==1, and returns without
	locks, memory barriers, atomic instructions, or anything else
	that would guarantee ordering.

o	Task A then loads from Y.  Because there have been no memory
	barriers, it might well see Y==0.

So what am I missing here?

On the other hand, if a wake_up() really does happen, then
the fast-path out of wait_event_interruptible() is not taken,
and __wait_event_interruptible() is called instead.  This calls
___wait_event(), which eventually calls prepare_to_wait_event(), which
in turn calls set_current_state(), which calls set_mb(), which does a
full memory barrier.  And if that isn't good enough, there is the
call to schedule() itself.  ;-)

So if a wait actually sleeps, it does imply a full memory barrier
several times over.

On the wake_up() side, wake_up() calls __wake_up(), which as mentioned
earlier calls __wake_up_common() under a lock.  This invokes the
wake-up function stored by the sleeping task, for example,
autoremove_wake_function(), which calls default_wake_function(),
which invokes try_to_wake_up(), which does smp_mb__before_spinlock()
before acquiring the to-be-waked task's PI lock.

The definition of smp_mb__before_spinlock() is smp_wmb().  There is
also an smp_rmb() in try_to_wake_up(), which still does not get us
to a full memory barrier.  It also calls select_task_rq(), which
does not seem to guarantee any particular memory ordering (but
I could easily have missed something).  It also calls ttwu_queue(),
which invokes ttwu_do_activate() under the RQ lock.  I don't see a
full memory barrier in ttwu_do_activate(), but again could easily
have missed one.  Ditto for ttwu_stat().

All the locks nest, so other than the smp_wmb() and smp_rmb(), things
could bleed in.

> +before the task state is cleared, and so sits between the STORE to indicate
> +the event and the STORE to set TASK_RUNNING:

If I am in fact correct, and if we really want to advertise the read
memory barrier, I suggest the following replacement text:

	A read and a write memory barrier (-not- a full memory barrier)
	are implied by wake_up() and co. if and only if they wake
	something up.  The write barrier occurs before the task state is
	cleared, and so sits between the STORE to indicate the event and
	the STORE to set TASK_RUNNING, and the read barrier after that:

	CPU 1				CPU 2
	===============================	===============================
	set_current_state();		STORE event_indicated
	  set_mb();			wake_up();
	    STORE current->state	  <write barrier>
	    <general barrier>		  STORE current->state
	LOAD event_indicated		  <read barrier>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
