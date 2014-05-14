Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id E8D6F6B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 10:26:40 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so1438165eek.36
        for <linux-mm@kvack.org>; Wed, 14 May 2014 07:26:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id d1si1822452eem.85.2014.05.14.07.26.33
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 07:26:34 -0700 (PDT)
Date: Wed, 14 May 2014 16:25:34 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
	waitqueue lookups in unlock_page fastpath
Message-ID: <20140514142534.GA31018@redhat.com>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de> <1399974350-11089-20-git-send-email-mgorman@suse.de> <20140513125313.GR23991@suse.de> <20140513141748.GD2485@laptop.programming.kicks-ass.net> <20140513152719.GF18164@linux.vnet.ibm.com> <20140513154435.GG2485@laptop.programming.kicks-ass.net> <20140513161418.GH18164@linux.vnet.ibm.com> <20140513185742.GD12123@redhat.com> <20140513202448.GR18164@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140513202448.GR18164@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On 05/13, Paul E. McKenney wrote:
>
> On Tue, May 13, 2014 at 08:57:42PM +0200, Oleg Nesterov wrote:
> > On 05/13, Paul E. McKenney wrote:
> > >
> > > On Tue, May 13, 2014 at 05:44:35PM +0200, Peter Zijlstra wrote:
> > > >
> > > > Ah, yes, so I'll defer to Oleg and Linus to explain that one. As per the
> > > > name: smp_mb__before_spinlock() should of course imply a full barrier.
> > >
> > > How about if I queue a name change to smp_wmb__before_spinlock()?
> >
> > I agree, this is more accurate, simply because it describes what it
> > actually does.
> >
> > But just in case, as for try_to_wake_up() it does not actually need
> > wmb() between "CONDITION = T" and "task->state = RUNNING". It would
> > be fine if these 2 STORE's are re-ordered, we can rely on rq->lock.
> >
> > What it actually needs is a barrier between "CONDITION = T" and
> > "task->state & state" check. But since we do not have a store-load
> > barrier, wmb() was added to ensure that "CONDITION = T" can't leak
> > into the critical section.
> >
> > But it seems that set_tlb_flush_pending() already assumes that it
> > acts as wmb(), so probably smp_wmb__before_spinlock() is fine.
>
> Except that when I go to make the change, I find the following in
> the documentation:
>
>      Memory operations issued before the ACQUIRE may be completed after
>      the ACQUIRE operation has completed.  An smp_mb__before_spinlock(),
>      combined with a following ACQUIRE, orders prior loads against
>      subsequent loads and stores and also orders prior stores against
>      subsequent stores.  Note that this is weaker than smp_mb()!  The
>      smp_mb__before_spinlock() primitive is free on many architectures.
>
> Which means that either the documentation is wrong or the implementation
> is.  Yes, smp_wmb() has the semantics called out above on many platforms,
> but not on Alpha or ARM.

Well, I think the documentation is wrong in any case. "prior loads
against subsequent loads" is not true. And it doesn't document that
the initial goal was "prior stores against the subsequent loads".
"prior stores against the subsequent stores" is obviously true for
the default implementation, but this is the "side effect" because
it uses wmb().


The only intent of wmb() added by 04e2f174 "Add memory barrier semantics
to wake_up() & co" (afaics at least) was: make sure that ttwu() does not
read p->state before the preceding stores are completed.

e0acd0a68e "sched: fix the theoretical signal_wake_up() vs schedule()
race" added the new helper for documentation, to explain that the
default implementation abuses wmb() to achieve the serialization above.

> So, as you say, set_tlb_flush_pending() only relies on smp_wmb().

The comment says ;) and this means that even if we suddenly have a new
load_store() barrier (which could work for ttwu/schedule) we can no
longer change smp_mb__before_spinlock() to use it.

> The comment in try_to_wake_up() seems to be assuming a full memory
> barrier.  The comment in __schedule() also seems to be relying on
> a full memory barrier (prior write against subsequent read).  Yow!

Well yes, but see above. Again, we need load_store() before reading
p->state, which we do not have. wmb() before spin_lock() can be used
instead.

But, try_to_wake_up() and __schedule() do not need a full barrier in
a sense that if we are going to wake this task up (or just clear its
->state), then "CONDITION = T" can be delayed till spin_unlock().

We do not care if that tasks misses CONDITION in this case, it will
call schedule() which will take the same lock. But if we are not going
to wake it up, we need to ensure that the task can't miss CONDITION.

IOW, this all is simply about

	CONDITION = T;			current->state = TASK_XXX;
					mb();

	if (p->state)			if (!CONDITION)
		wake_it_up();			schedule();

race.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
