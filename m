Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 23B306B0036
	for <linux-mm@kvack.org>; Tue, 13 May 2014 14:52:56 -0400 (EDT)
Received: by mail-yk0-f172.google.com with SMTP id 79so665499ykr.31
        for <linux-mm@kvack.org>; Tue, 13 May 2014 11:52:55 -0700 (PDT)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id s32si21450536yhj.55.2014.05.13.11.52.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 13 May 2014 11:52:55 -0700 (PDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 13 May 2014 12:52:54 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 0062F19D803E
	for <linux-mm@kvack.org>; Tue, 13 May 2014 12:52:46 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4DIq1e15636482
	for <linux-mm@kvack.org>; Tue, 13 May 2014 20:52:01 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s4DIuhev023282
	for <linux-mm@kvack.org>; Tue, 13 May 2014 12:56:44 -0600
Date: Tue, 13 May 2014 11:52:50 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
 waitqueue lookups in unlock_page fastpath
Message-ID: <20140513185250.GM18164@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140513152719.GF18164@linux.vnet.ibm.com>
 <20140513181852.GB12123@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140513181852.GB12123@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Tue, May 13, 2014 at 08:18:52PM +0200, Oleg Nesterov wrote:
> On 05/13, Paul E. McKenney wrote:
> >
> > On Tue, May 13, 2014 at 04:17:48PM +0200, Peter Zijlstra wrote:
> > >
> > > diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barriers.txt
> > > index 46412bded104..dae5158c2382 100644
> > > --- a/Documentation/memory-barriers.txt
> > > +++ b/Documentation/memory-barriers.txt
> > > @@ -1881,9 +1881,9 @@ The whole sequence above is available in various canned forms, all of which
> > >  	event_indicated = 1;
> > >  	wake_up_process(event_daemon);
> > >
> > > -A write memory barrier is implied by wake_up() and co. if and only if they wake
> > > -something up.  The barrier occurs before the task state is cleared, and so sits
> > > -between the STORE to indicate the event and the STORE to set TASK_RUNNING:
> > > +A full memory barrier is implied by wake_up() and co. The barrier occurs
> >
> > Last I checked, the memory barrier was guaranteed
> 
> I have to admit, I am confused. I simply do not understand what "memory
> barrier" actually means in this discussion.
> 
> To me, wake_up/ttwu should only guarantee one thing: all the preceding
> STORE's should be serialized with all the subsequent manipulations with
> task->state (even with LOAD(task->state)).

I was thinking in terms of "everything done before the wake_up() is
visible after the wait_event*() returns" -- but only if the task doing
the wait_event*() actually sleeps and is awakened by that particular
wake_up().

Admittedly a bit of a weak guarantee!

> > If there is a sleep-wakeup race, for example,
> > between wait_event_interruptible() and wake_up(), then it looks to me
> > that the following can happen:
> >
> > o	Task A invokes wait_event_interruptible(), waiting for
> > 	X==1.
> >
> > o	Before Task A gets anywhere, Task B sets Y=1, does
> > 	smp_mb(), then sets X=1.
> >
> > o	Task B invokes wake_up(), which invokes __wake_up(), which
> > 	acquires the wait_queue_head_t's lock and invokes
> > 	__wake_up_common(), which sees nothing to wake up.
> >
> > o	Task A tests the condition, finds X==1, and returns without
> > 	locks, memory barriers, atomic instructions, or anything else
> > 	that would guarantee ordering.
> >
> > o	Task A then loads from Y.  Because there have been no memory
> > 	barriers, it might well see Y==0.
> 
> Sure, but I can't understand "Because there have been no memory barriers".
> 
> IOW. Suppose we add mb() into wake_up(). The same can happen anyway?

If the mb() is placed just after the fastpath condition check, then the
awakened task will be guaranteed to see Y=1.  Either that memory barrier
or the wait_queue_head_t's lock will guarantee the serialization, I think,
anyway.

> And "if a wakeup actually occurred" is not clear to me too in this context.
> For example, suppose that ttwu() clears task->state but that task was not
> deactivated and it is going to check the condition, do we count this as
> "wakeup actually occurred" ? In this case that task still can see Y==0.

I was thinking in terms of the task doing the wait_event*() actually
entering the scheduler.

> > On the other hand, if a wake_up() really does happen, then
> > the fast-path out of wait_event_interruptible() is not taken,
> > and __wait_event_interruptible() is called instead.  This calls
> > ___wait_event(), which eventually calls prepare_to_wait_event(), which
> > in turn calls set_current_state(), which calls set_mb(), which does a
> > full memory barrier.
> 
> Can't understand this part too... OK, and suppose that right after that
> the task B from the scenario above does
> 
> 	Y = 1;
> 	mb();
> 	X = 1;
> 	wake_up();
> 
> After that task A checks the condition, sees X==1, and returns from
> wait_event() without spin_lock(wait_queue_head_t->lock) (if it also
> sees list_empty_careful() == T). Then it can see Y==0 again?

Yes.  You need the barriers to be paired, and in this case, Task A isn't
executing a memory barrier.  Yes, the mb() has forced Task B's CPU to
commit the writes in order (or at least pretend to), but Task A might
have speculated the read to Y.

Or am I missing your point?

> > 	A read and a write memory barrier (-not- a full memory barrier)
> > 	are implied by wake_up() and co. if and only if they wake
> > 	something up.
> 
> Now this looks as if you document that, say,
> 
> 	X = 1;
> 	wake_up();
> 	Y = 1;
> 
> doesn't need wmb() before "Y = 1" if wake_up() wakes something up. Do we
> really want to document this? Is it fine to rely on this guarantee?

That is an excellent question.  It would not be hard to argue that we
should either make the guarantee unconditional by adding smp_mb() to
the wait_event*() paths or alternatively just saying that there isn't
a guarantee to begin with.

Thoughts?

> > The write barrier occurs before the task state is
> > 	cleared, and so sits between the STORE to indicate the event and
> > 	the STORE to set TASK_RUNNING, and the read barrier after that:
> 
> Plus: between the STORE to indicate the event and the LOAD which checks
> task->state, otherwise:
> 
> > 	CPU 1				CPU 2
> > 	===============================	===============================
> > 	set_current_state();		STORE event_indicated
> > 	  set_mb();			wake_up();
> > 	    STORE current->state	  <write barrier>
> > 	    <general barrier>		  STORE current->state
> > 	LOAD event_indicated		  <read barrier>
> 
> this code is still racy.

Yeah, it is missing some key components.  That said, we should figure
out exactly what we want to guarantee before I try to fix it.  ;-)

> In short: I am totally confused and most probably misunderstood you ;)

Oleg, if it confuses you, it is in desperate need of help!  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
