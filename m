Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 569976B0036
	for <linux-mm@kvack.org>; Tue, 13 May 2014 14:19:47 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id k48so794081wev.31
        for <linux-mm@kvack.org>; Tue, 13 May 2014 11:19:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t6si4134659wif.101.2014.05.13.11.19.45
        for <linux-mm@kvack.org>;
        Tue, 13 May 2014 11:19:46 -0700 (PDT)
Date: Tue, 13 May 2014 20:18:52 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
	waitqueue lookups in unlock_page fastpath
Message-ID: <20140513181852.GB12123@redhat.com>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de> <1399974350-11089-20-git-send-email-mgorman@suse.de> <20140513125313.GR23991@suse.de> <20140513141748.GD2485@laptop.programming.kicks-ass.net> <20140513152719.GF18164@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140513152719.GF18164@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On 05/13, Paul E. McKenney wrote:
>
> On Tue, May 13, 2014 at 04:17:48PM +0200, Peter Zijlstra wrote:
> >
> > diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barriers.txt
> > index 46412bded104..dae5158c2382 100644
> > --- a/Documentation/memory-barriers.txt
> > +++ b/Documentation/memory-barriers.txt
> > @@ -1881,9 +1881,9 @@ The whole sequence above is available in various canned forms, all of which
> >  	event_indicated = 1;
> >  	wake_up_process(event_daemon);
> >
> > -A write memory barrier is implied by wake_up() and co. if and only if they wake
> > -something up.  The barrier occurs before the task state is cleared, and so sits
> > -between the STORE to indicate the event and the STORE to set TASK_RUNNING:
> > +A full memory barrier is implied by wake_up() and co. The barrier occurs
>
> Last I checked, the memory barrier was guaranteed

I have to admit, I am confused. I simply do not understand what "memory
barrier" actually means in this discussion.

To me, wake_up/ttwu should only guarantee one thing: all the preceding
STORE's should be serialized with all the subsequent manipulations with
task->state (even with LOAD(task->state)).

> If there is a sleep-wakeup race, for example,
> between wait_event_interruptible() and wake_up(), then it looks to me
> that the following can happen:
>
> o	Task A invokes wait_event_interruptible(), waiting for
> 	X==1.
>
> o	Before Task A gets anywhere, Task B sets Y=1, does
> 	smp_mb(), then sets X=1.
>
> o	Task B invokes wake_up(), which invokes __wake_up(), which
> 	acquires the wait_queue_head_t's lock and invokes
> 	__wake_up_common(), which sees nothing to wake up.
>
> o	Task A tests the condition, finds X==1, and returns without
> 	locks, memory barriers, atomic instructions, or anything else
> 	that would guarantee ordering.
>
> o	Task A then loads from Y.  Because there have been no memory
> 	barriers, it might well see Y==0.

Sure, but I can't understand "Because there have been no memory barriers".

IOW. Suppose we add mb() into wake_up(). The same can happen anyway?

And "if a wakeup actually occurred" is not clear to me too in this context.
For example, suppose that ttwu() clears task->state but that task was not
deactivated and it is going to check the condition, do we count this as
"wakeup actually occurred" ? In this case that task still can see Y==0.


> On the other hand, if a wake_up() really does happen, then
> the fast-path out of wait_event_interruptible() is not taken,
> and __wait_event_interruptible() is called instead.  This calls
> ___wait_event(), which eventually calls prepare_to_wait_event(), which
> in turn calls set_current_state(), which calls set_mb(), which does a
> full memory barrier.

Can't understand this part too... OK, and suppose that right after that
the task B from the scenario above does

	Y = 1;
	mb();
	X = 1;
	wake_up();

After that task A checks the condition, sees X==1, and returns from
wait_event() without spin_lock(wait_queue_head_t->lock) (if it also
sees list_empty_careful() == T). Then it can see Y==0 again?

> 	A read and a write memory barrier (-not- a full memory barrier)
> 	are implied by wake_up() and co. if and only if they wake
> 	something up.

Now this looks as if you document that, say,

	X = 1;
	wake_up();
	Y = 1;

doesn't need wmb() before "Y = 1" if wake_up() wakes something up. Do we
really want to document this? Is it fine to rely on this guarantee?

> The write barrier occurs before the task state is
> 	cleared, and so sits between the STORE to indicate the event and
> 	the STORE to set TASK_RUNNING, and the read barrier after that:

Plus: between the STORE to indicate the event and the LOAD which checks
task->state, otherwise:

> 	CPU 1				CPU 2
> 	===============================	===============================
> 	set_current_state();		STORE event_indicated
> 	  set_mb();			wake_up();
> 	    STORE current->state	  <write barrier>
> 	    <general barrier>		  STORE current->state
> 	LOAD event_indicated		  <read barrier>

this code is still racy.

In short: I am totally confused and most probably misunderstood you ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
