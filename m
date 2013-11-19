Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E9A806B0070
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 14:54:56 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id rd3so3053059pab.41
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 11:54:56 -0800 (PST)
Received: from psmtp.com ([74.125.245.190])
        by mx.google.com with SMTP id sg3si12348417pbb.193.2013.11.19.11.54.53
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 11:54:55 -0800 (PST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 19 Nov 2013 12:54:52 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id D5B961FF0021
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 12:54:32 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAJHqqtv2425094
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 18:52:52 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAJJvgwJ006309
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 12:57:44 -0700
Date: Tue, 19 Nov 2013 11:54:47 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 1/4] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
Message-ID: <20131119195447.GU4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1383935697.git.tim.c.chen@linux.intel.com>
 <1383940312.11046.414.camel@schen9-DESK>
 <20131119191038.GN4138@linux.vnet.ibm.com>
 <1384890152.11046.434.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384890152.11046.434.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Nov 19, 2013 at 11:42:32AM -0800, Tim Chen wrote:
> On Tue, 2013-11-19 at 11:10 -0800, Paul E. McKenney wrote:
> > On Fri, Nov 08, 2013 at 11:51:52AM -0800, Tim Chen wrote:
> > > We will need the MCS lock code for doing optimistic spinning for rwsem
> > > and queue rwlock.  Extracting the MCS code from mutex.c and put into
> > > its own file allow us to reuse this code easily.
> > > 
> > > Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> > > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> > 
> > Please see comments below.
> > 
> 
> Thanks for reviewing the code.
> 
> > 							Thanx, Paul
> > 
> > > ---
> > >  include/linux/mcs_spinlock.h |   64 ++++++++++++++++++++++++++++++++++++++++++
> > >  include/linux/mutex.h        |    5 ++-
> > >  kernel/locking/mutex.c       |   60 ++++----------------------------------
> > >  3 files changed, 74 insertions(+), 55 deletions(-)
> > >  create mode 100644 include/linux/mcs_spinlock.h
> > > 
> > > diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
> > > new file mode 100644
> > > index 0000000..b5de3b0
> > > --- /dev/null
> > > +++ b/include/linux/mcs_spinlock.h
> > > @@ -0,0 +1,64 @@
> > > +/*
> > > + * MCS lock defines
> > > + *
> > > + * This file contains the main data structure and API definitions of MCS lock.
> > > + *
> > > + * The MCS lock (proposed by Mellor-Crummey and Scott) is a simple spin-lock
> > > + * with the desirable properties of being fair, and with each cpu trying
> > > + * to acquire the lock spinning on a local variable.
> > > + * It avoids expensive cache bouncings that common test-and-set spin-lock
> > > + * implementations incur.
> > > + */
> > > +#ifndef __LINUX_MCS_SPINLOCK_H
> > > +#define __LINUX_MCS_SPINLOCK_H
> > > +
> > > +struct mcs_spinlock {
> > > +	struct mcs_spinlock *next;
> > > +	int locked; /* 1 if lock acquired */
> > > +};
> > > +
> > > +/*
> > > + * We don't inline mcs_spin_lock() so that perf can correctly account for the
> > > + * time spent in this lock function.
> > > + */
> > > +static noinline
> > > +void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> > > +{
> > > +	struct mcs_spinlock *prev;
> > > +
> > > +	/* Init node */
> > > +	node->locked = 0;
> > > +	node->next   = NULL;
> > > +
> > > +	prev = xchg(lock, node);
> > 
> > OK, the full memory barriers implied by xchg() ensure that *node will be
> > initialized before the "ACCESS_ONCE(prev->next) = node" below puts the
> > node into the list.  This rules out the misordering scenario that Tim
> > Chen called out in message-id <1380322005.3467.186.camel@schen9-DESK>
> > on September 27th.
> > 
> > Assuming of course a corresponding barrier on the lock handoff side.
> > 
> > > +	if (likely(prev == NULL)) {
> > > +		/* Lock acquired */
> > > +		node->locked = 1;
> > > +		return;
> > > +	}
> > > +	ACCESS_ONCE(prev->next) = node;
> > > +	smp_wmb();
> > 
> > I don't see what the above memory barrier does.  Here are some things
> > that it cannot be doing:
> > 
> > o	Ordering the insertion into the list above with the polling
> > 	below.  First, smp_wmb() does not order prior writes against
> > 	later reads, and second misordering is harmless.  If we start
> > 	polling before the insertion is complete, all that happens
> > 	is that the first few polls have no chance of seeing a lock
> > 	grant.
> > 
> > o	Ordering the polling against the initialization -- the above
> > 	xchg() is already doing that for us.
> > 
> > So what is its purpose?
> 
> Agree that the smp_wmb is not needed.  It is in the existing mcs code
> residing in mutex.c and we're re-factoring the code only here and hasn't
> corrected the memory barrier.

Ah, so I should have been more aggressive about reviewing some time back,
then...  ;-)

							Thanx, Paul

> The particular smp_wmb() is removed in Patch 4/4 that corrects the
> memory barriers.
> 
> > 
> > > +	/* Wait until the lock holder passes the lock down */
> > > +	while (!ACCESS_ONCE(node->locked))
> > > +		arch_mutex_cpu_relax();
> > 
> > On the other hand, I don't see how we get away without a barrier here.
> > As written, what prevents the caller's load from ->owner from being
> > reordered with the above load from ->locked?  (Perhaps you can argue
> > that such reordering is only a performance problem, but if so we need
> > that argument recorded in comments.)
> > 
> > Of course, if anyone ever tries to use mcs_spin_lock() as a full lock,
> > they will need a memory barrier here to prevent the critical section
> > from leaking out.
> 
> Agree too.  The appropriate memory barrier is added in Patch 4/4.
> 
> > 
> > > +}
> > > +
> > > +static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> > > +{
> > > +	struct mcs_spinlock *next = ACCESS_ONCE(node->next);
> > > +
> > > +	if (likely(!next)) {
> > > +		/*
> > > +		 * Release the lock by setting it to NULL
> > > +		 */
> > > +		if (cmpxchg(lock, node, NULL) == node)
> > > +			return;
> > > +		/* Wait until the next pointer is set */
> > > +		while (!(next = ACCESS_ONCE(node->next)))
> > > +			arch_mutex_cpu_relax();
> > > +	}
> > 
> > We need a memory barrier somewhere before here in this function,
> > otherwise the critical section can leak out.  I do not believe that
> > we can rely on the prohibition against speculative stores that Peter
> > Zijlstra and I have been discussing because that does not provide the
> > transitivity required by locking primitives.  I believe that we -could-
> > make the access below be an smp_store_release(), though.
> > 
> > Placing the barrier here (or at least not preceding the initial
> > fetch from node->next) has the advantage of allowing it to pair with
> > the xchg() in mcs_spin_lock(), though given the dependency only an
> > smp_read_barrier_depends() is required for that purpose.
> > 
> > > +	ACCESS_ONCE(next->locked) = 1;
> > > +	smp_wmb();
> > 
> > I don't see what this barrier does for us.  It is ordering the unlock
> > store with what, exactly?
> > 
> > If it really is doing something, we need a big fat comment stating what
> > that is, and checkpatch.pl will be happy to inform you.  ;-)
> > 
> > > +}
> > > +
> > > +#endif /* __LINUX_MCS_SPINLOCK_H */
> > > diff --git a/include/linux/mutex.h b/include/linux/mutex.h
> > > index bab49da..32a32e6 100644
> > > --- a/include/linux/mutex.h
> > > +++ b/include/linux/mutex.h
> > > @@ -46,6 +46,7 @@
> > >   * - detects multi-task circular deadlocks and prints out all affected
> > >   *   locks and tasks (and only those tasks)
> > >   */
> > > +struct mcs_spinlock;
> > >  struct mutex {
> > >  	/* 1: unlocked, 0: locked, negative: locked, possible waiters */
> > >  	atomic_t		count;
> > > @@ -55,7 +56,7 @@ struct mutex {
> > >  	struct task_struct	*owner;
> > >  #endif
> > >  #ifdef CONFIG_MUTEX_SPIN_ON_OWNER
> > > -	void			*spin_mlock;	/* Spinner MCS lock */
> > > +	struct mcs_spinlock	*mcs_lock;	/* Spinner MCS lock */
> > >  #endif
> > >  #ifdef CONFIG_DEBUG_MUTEXES
> > >  	const char 		*name;
> > > @@ -179,4 +180,4 @@ extern int atomic_dec_and_mutex_lock(atomic_t *cnt, struct mutex *lock);
> > >  # define arch_mutex_cpu_relax() cpu_relax()
> > >  #endif
> > > 
> > > -#endif
> > > +#endif /* __LINUX_MUTEX_H */
> > > diff --git a/kernel/locking/mutex.c b/kernel/locking/mutex.c
> > > index d24105b..e08b183 100644
> > > --- a/kernel/locking/mutex.c
> > > +++ b/kernel/locking/mutex.c
> > > @@ -25,6 +25,7 @@
> > >  #include <linux/spinlock.h>
> > >  #include <linux/interrupt.h>
> > >  #include <linux/debug_locks.h>
> > > +#include <linux/mcs_spinlock.h>
> > > 
> > >  /*
> > >   * In the DEBUG case we are using the "NULL fastpath" for mutexes,
> > > @@ -52,7 +53,7 @@ __mutex_init(struct mutex *lock, const char *name, struct lock_class_key *key)
> > >  	INIT_LIST_HEAD(&lock->wait_list);
> > >  	mutex_clear_owner(lock);
> > >  #ifdef CONFIG_MUTEX_SPIN_ON_OWNER
> > > -	lock->spin_mlock = NULL;
> > > +	lock->mcs_lock = NULL;
> > >  #endif
> > > 
> > >  	debug_mutex_init(lock, name, key);
> > > @@ -111,54 +112,7 @@ EXPORT_SYMBOL(mutex_lock);
> > >   * more or less simultaneously, the spinners need to acquire a MCS lock
> > >   * first before spinning on the owner field.
> > >   *
> > > - * We don't inline mspin_lock() so that perf can correctly account for the
> > > - * time spent in this lock function.
> > >   */
> > > -struct mspin_node {
> > > -	struct mspin_node *next ;
> > > -	int		  locked;	/* 1 if lock acquired */
> > > -};
> > > -#define	MLOCK(mutex)	((struct mspin_node **)&((mutex)->spin_mlock))
> > > -
> > > -static noinline
> > > -void mspin_lock(struct mspin_node **lock, struct mspin_node *node)
> > > -{
> > > -	struct mspin_node *prev;
> > > -
> > > -	/* Init node */
> > > -	node->locked = 0;
> > > -	node->next   = NULL;
> > > -
> > > -	prev = xchg(lock, node);
> > > -	if (likely(prev == NULL)) {
> > > -		/* Lock acquired */
> > > -		node->locked = 1;
> > > -		return;
> > > -	}
> > > -	ACCESS_ONCE(prev->next) = node;
> > > -	smp_wmb();
> > > -	/* Wait until the lock holder passes the lock down */
> > > -	while (!ACCESS_ONCE(node->locked))
> > > -		arch_mutex_cpu_relax();
> > > -}
> > > -
> > > -static void mspin_unlock(struct mspin_node **lock, struct mspin_node *node)
> > > -{
> > > -	struct mspin_node *next = ACCESS_ONCE(node->next);
> > > -
> > > -	if (likely(!next)) {
> > > -		/*
> > > -		 * Release the lock by setting it to NULL
> > > -		 */
> > > -		if (cmpxchg(lock, node, NULL) == node)
> > > -			return;
> > > -		/* Wait until the next pointer is set */
> > > -		while (!(next = ACCESS_ONCE(node->next)))
> > > -			arch_mutex_cpu_relax();
> > > -	}
> > > -	ACCESS_ONCE(next->locked) = 1;
> > > -	smp_wmb();
> > > -}
> > > 
> > >  /*
> > >   * Mutex spinning code migrated from kernel/sched/core.c
> > > @@ -448,7 +402,7 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
> > > 
> > >  	for (;;) {
> > >  		struct task_struct *owner;
> > > -		struct mspin_node  node;
> > > +		struct mcs_spinlock  node;
> > > 
> > >  		if (use_ww_ctx && ww_ctx->acquired > 0) {
> > >  			struct ww_mutex *ww;
> > > @@ -470,10 +424,10 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
> > >  		 * If there's an owner, wait for it to either
> > >  		 * release the lock or go to sleep.
> > >  		 */
> > > -		mspin_lock(MLOCK(lock), &node);
> > > +		mcs_spin_lock(&lock->mcs_lock, &node);
> > >  		owner = ACCESS_ONCE(lock->owner);
> > >  		if (owner && !mutex_spin_on_owner(lock, owner)) {
> > > -			mspin_unlock(MLOCK(lock), &node);
> > > +			mcs_spin_unlock(&lock->mcs_lock, &node);
> > >  			goto slowpath;
> > >  		}
> > > 
> > > @@ -488,11 +442,11 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
> > >  			}
> > > 
> > >  			mutex_set_owner(lock);
> > > -			mspin_unlock(MLOCK(lock), &node);
> > > +			mcs_spin_unlock(&lock->mcs_lock, &node);
> > >  			preempt_enable();
> > >  			return 0;
> > >  		}
> > > -		mspin_unlock(MLOCK(lock), &node);
> > > +		mcs_spin_unlock(&lock->mcs_lock, &node);
> > > 
> > >  		/*
> > >  		 * When there's no owner, we might have preempted between the
> > > -- 
> > > 1.7.4.4
> > > 
> > > 
> > > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
