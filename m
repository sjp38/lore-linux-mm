Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id DFBF96B0034
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 18:28:40 -0400 (EDT)
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <1371495933.1778.29.camel@buesod1.americas.hpqcorp.net>
References: <1371165333.27102.568.camel@schen9-DESK>
	 <1371167015.1754.14.camel@buesod1.americas.hpqcorp.net>
	 <51BD8A77.2080201@intel.com>
	 <1371486122.1778.14.camel@buesod1.americas.hpqcorp.net>
	 <1371494746.27102.633.camel@schen9-DESK>
	 <1371495933.1778.29.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 17 Jun 2013 15:28:41 -0700
Message-ID: <1371508121.27102.640.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Alex Shi <alex.shi@intel.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 2013-06-17 at 12:05 -0700, Davidlohr Bueso wrote:

> > 
> > Thanks.  Those are encouraging numbers.  On my exim workload I didn't
> > get a boost when I added in the preempt disable in optimistic spin and
> > put Alex's changes in. Can you send me your combined patch to see if
> > there may be something you did that I've missed.  I have a tweak to
> > Alex's patch below to simplify things a bit.  
> > 
> 
> I'm using:
> 
> int rwsem_optimistic_spin(struct rw_semaphore *sem)
> {
>         struct  task_struct     *owner;
> 
>         /* sem->wait_lock should not be held when attempting optimistic spinning */
>         if (!rwsem_can_spin_on_owner(sem))
>                 return 0;
> 
>         preempt_disable();
>         for (;;) {
>                 owner = ACCESS_ONCE(sem->owner);
>                 if (owner && !rwsem_spin_on_owner(sem, owner))
>                         break;
> 
>                 /* wait_lock will be acquired if write_lock is obtained */
>                 if (rwsem_try_write_lock(sem->count, true, sem)) {
>                         preempt_enable();
>                         return 1;
>                 }
> 
>                 /*                                                                                                                                                                   
>                  * When there's no owner, we might have preempted between the                                                                                                        
>                  * owner acquiring the lock and setting the owner field. If                                                                                                          
>                  * we're an RT task that will live-lock because we won't let                                                                                                         
>                  * the owner complete.                                                                                                                                               
>                  */
>                 if (!owner && (need_resched() || rt_task(current)))
>                         break;
> 
>                 /*                                                                                                                                                                   
>                  * The cpu_relax() call is a compiler barrier which forces                                                                                                           
>                  * everything in this loop to be re-loaded. We don't need                                                                                                            
>                  * memory barriers as we'll eventually observe the right                                                                                                             
>                  * values at the cost of a few extra spins.                                                                                                                          
>                  */
>                 arch_mutex_cpu_relax();
> 
>         }
> 
>         preempt_enable();
>         return 0;
> }

This is identical to the changes that I've tested.  Thanks for sharing.

Tim

> > > > @@ -85,15 +85,28 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
> > > >  	adjustment = 0;
> > > >  	if (wake_type != RWSEM_WAKE_READ_OWNED) {
> > > >  		adjustment = RWSEM_ACTIVE_READ_BIAS;
> > > > - try_reader_grant:
> > > > -		oldcount = rwsem_atomic_update(adjustment, sem) - adjustment;
> > > > -		if (unlikely(oldcount < RWSEM_WAITING_BIAS)) {
> > > > -			/* A writer stole the lock. Undo our reader grant. */
> > > > +		while (1) {
> > > > +			long oldcount;
> > > > +
> > > > +			/* A writer stole the lock. */
> > > > +			if (unlikely(sem->count & RWSEM_ACTIVE_MASK))
> > > > +				return sem;
> > > > +
> > > > +			if (unlikely(sem->count < RWSEM_WAITING_BIAS)) {
> > > > +				cpu_relax();
> > > > +				continue;
> > > > +			}
> > 
> > The above two if statements could be cleaned up as a single check:
> > 		
> > 			if (unlikely(sem->count < RWSEM_WAITING_BIAS))
> > 				return sem;
> > 	 
> > This one statement is sufficient to check that we don't have a writer
> > stolen the lock before we attempt to acquire the read lock by modifying
> > sem->count.  
> 
> We probably still want to keep the cpu relaxation if the statement
> doesn't comply.
> 
> Thanks,
> Davidlohr
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
