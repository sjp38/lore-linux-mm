Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id B856C6B003B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 14:45:56 -0400 (EDT)
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <1371486122.1778.14.camel@buesod1.americas.hpqcorp.net>
References: <1371165333.27102.568.camel@schen9-DESK>
	 <1371167015.1754.14.camel@buesod1.americas.hpqcorp.net>
	 <51BD8A77.2080201@intel.com>
	 <1371486122.1778.14.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 17 Jun 2013 11:45:46 -0700
Message-ID: <1371494746.27102.633.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Alex Shi <alex.shi@intel.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 2013-06-17 at 09:22 -0700, Davidlohr Bueso wrote:
> On Sun, 2013-06-16 at 17:50 +0800, Alex Shi wrote:
> > On 06/14/2013 07:43 AM, Davidlohr Bueso wrote:
> > > I was hoping that the lack of spin on owner was the main difference with
> > > rwsems and am/was in the middle of implementing it. Could you send your
> > > patch so I can give it a try on my workloads?
> > > 
> > > Note that there have been a few recent (3.10) changes to mutexes that
> > > give a nice performance boost, specially on large systems, most
> > > noticeably:
> > > 
> > > commit 2bd2c92c (mutex: Make more scalable by doing less atomic
> > > operations)
> > > 
> > > commit 0dc8c730 (mutex: Queue mutex spinners with MCS lock to reduce
> > > cacheline contention)
> > > 
> > > It might be worth looking into doing something similar to commit
> > > 0dc8c730, in addition to the optimistic spinning.
> > 
> > It is a good tunning for large machine. I just following what the commit 
> > 0dc8c730 done, give a RFC patch here. I tried it on my NHM EP machine. seems no
> > clear help on aim7. but maybe it is helpful on large machine.  :)
> 
> After a lot of benchmarking, I finally got the ideal results for aim7,
> so far: this patch + optimistic spinning with preemption disabled. Just
> like optimistic spinning, this patch by itself makes little to no
> difference, yet combined is where we actually outperform 3.10-rc5. In
> addition, I noticed extra throughput when disabling preemption in
> try_optimistic_spin().
> 
> With i_mmap as a rwsem and these changes I could see performance
> benefits for alltests (+14.5%), custom (+17%), disk (+11%), high_systime
> (+5%), shared (+15%) and short (+4%), most of them after around 500
> users, for fewer users, it made little to no difference.
> 

Thanks.  Those are encouraging numbers.  On my exim workload I didn't
get a boost when I added in the preempt disable in optimistic spin and
put Alex's changes in. Can you send me your combined patch to see if
there may be something you did that I've missed.  I have a tweak to
Alex's patch below to simplify things a bit.  

Tim

> Thanks,
> Davidlohr
> 
> > 
> > 
> > diff --git a/include/asm-generic/rwsem.h b/include/asm-generic/rwsem.h
> > index bb1e2cd..240729a 100644
> > --- a/include/asm-generic/rwsem.h
> > +++ b/include/asm-generic/rwsem.h
> > @@ -70,11 +70,11 @@ static inline void __down_write(struct rw_semaphore *sem)
> >  
> >  static inline int __down_write_trylock(struct rw_semaphore *sem)
> >  {
> > -	long tmp;
> > +	if (unlikely(&sem->count != RWSEM_UNLOCKED_VALUE))
> > +		return 0;
> >  
> > -	tmp = cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
> > -		      RWSEM_ACTIVE_WRITE_BIAS);
> > -	return tmp == RWSEM_UNLOCKED_VALUE;
> > +	return cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
> > +		      RWSEM_ACTIVE_WRITE_BIAS) == RWSEM_UNLOCKED_VALUE;
> >  }
> >  
> >  /*
> > diff --git a/lib/rwsem.c b/lib/rwsem.c
> > index 19c5fa9..9e54e20 100644
> > --- a/lib/rwsem.c
> > +++ b/lib/rwsem.c
> > @@ -64,7 +64,7 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
> >  	struct rwsem_waiter *waiter;
> >  	struct task_struct *tsk;
> >  	struct list_head *next;
> > -	long oldcount, woken, loop, adjustment;
> > +	long woken, loop, adjustment;
> >  
> >  	waiter = list_entry(sem->wait_list.next, struct rwsem_waiter, list);
> >  	if (waiter->type == RWSEM_WAITING_FOR_WRITE) {
> > @@ -75,7 +75,7 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
> >  			 * will block as they will notice the queued writer.
> >  			 */
> >  			wake_up_process(waiter->task);
> > -		goto out;
> > +		return sem;
> >  	}
> >  
> >  	/* Writers might steal the lock before we grant it to the next reader.
> > @@ -85,15 +85,28 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
> >  	adjustment = 0;
> >  	if (wake_type != RWSEM_WAKE_READ_OWNED) {
> >  		adjustment = RWSEM_ACTIVE_READ_BIAS;
> > - try_reader_grant:
> > -		oldcount = rwsem_atomic_update(adjustment, sem) - adjustment;
> > -		if (unlikely(oldcount < RWSEM_WAITING_BIAS)) {
> > -			/* A writer stole the lock. Undo our reader grant. */
> > +		while (1) {
> > +			long oldcount;
> > +
> > +			/* A writer stole the lock. */
> > +			if (unlikely(sem->count & RWSEM_ACTIVE_MASK))
> > +				return sem;
> > +
> > +			if (unlikely(sem->count < RWSEM_WAITING_BIAS)) {
> > +				cpu_relax();
> > +				continue;
> > +			}

The above two if statements could be cleaned up as a single check:
		
			if (unlikely(sem->count < RWSEM_WAITING_BIAS))
				return sem;
	 
This one statement is sufficient to check that we don't have a writer
stolen the lock before we attempt to acquire the read lock by modifying
sem->count.  





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
