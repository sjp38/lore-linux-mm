Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 2258A6B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 17:04:20 -0400 (EDT)
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20130628093809.GB29205@gmail.com>
References: <1371165992.27102.573.camel@schen9-DESK>
	 <20130619131611.GC24957@gmail.com> <1371660831.27102.663.camel@schen9-DESK>
	 <1372205996.22432.119.camel@schen9-DESK> <20130626095108.GB29181@gmail.com>
	 <1372282560.22432.139.camel@schen9-DESK>
	 <1372292701.22432.152.camel@schen9-DESK> <20130627083651.GA3730@gmail.com>
	 <1372366385.22432.185.camel@schen9-DESK>
	 <1372375873.22432.200.camel@schen9-DESK> <20130628093809.GB29205@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 28 Jun 2013 14:04:21 -0700
Message-ID: <1372453461.22432.216.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, 2013-06-28 at 11:38 +0200, Ingo Molnar wrote:
> * Tim Chen <tim.c.chen@linux.intel.com> wrote:
> 
> > I tried some tweaking that checks sem->count for read owned lock. Even 
> > though it reduces the percentage of acquisitions that need sleeping by 
> > 8.14% (from 18.6% to 10.46%), it increases the writer acquisition 
> > blocked count by 11%. This change still doesn't boost throughput and has 
> > a tiny regression for the workload.
> > 
> > 						Opt Spin Opt Spin
> > 							 (with tweak)	
> > Writer acquisition blocked count		7359040	8168006
> > Blocked by reader				 0.55%	 0.52%
> > Lock acquired first attempt (lock stealing)	16.92%	19.70%
> > Lock acquired second attempt (1 sleep)	17.60%	 9.32%
> > Lock acquired after more than 1 sleep		 1.00%	 1.14%
> > Lock acquired with optimistic spin		64.48%	69.84%
> > Optimistic spin abort 1 			11.77%	 1.14%
> > Optimistic spin abort 2			 6.81%	 9.22%
> > Optimistic spin abort 3			 0.02%	 0.10%
> 
> So lock stealing+spinning now acquires the lock successfully ~90% of the 
> time, the remaining sleeps are:
> 
> > Lock acquired second attempt (1 sleep)	......	 9.32%
> 
> And the reason these sleeps are mostly due to:
> 
> > Optimistic spin abort 2			 .....	 9.22%
> 
> Right?
> 
> So this particular #2 abort point is:
> 
> |       preempt_disable();
> |       for (;;) {
> |               owner = ACCESS_ONCE(sem->owner);
> |               if (owner && !rwsem_spin_on_owner(sem, owner))
> |                       break;   <--------------------------- abort (2)
> 
> Next step would be to investigate why we decide to not spin there, why 
> does rwsem_spin_on_owner() fail?
> 
> If I got all the patches right, rwsem_spin_on_owner() is this:
> 
> +static noinline
> +int rwsem_spin_on_owner(struct rw_semaphore *lock, struct task_struct *owner)
> +{
> +       rcu_read_lock();
> +       while (owner_running(lock, owner)) {
> +               if (need_resched())
> +                       break;
> +
> +               arch_mutex_cpu_relax();
> +       }
> +       rcu_read_unlock();
> +
> +       /*
> +        * We break out the loop above on need_resched() and when the
> +        * owner changed, which is a sign for heavy contention. Return
> +        * success only when lock->owner is NULL.
> +        */
> +       return lock->owner == NULL;
> +}
> 
> where owner_running() is similar to the mutex spinning code: it in the end 
> checks owner->on_cpu - like the mutex code.
> 
> If my analysis is correct so far then it might be useful to add two more 
> stats: did rwsem_spin_on_owner() fail because lock->owner == NULL [owner 
> released the rwsem], or because owner_running() failed [owner went to 
> sleep]?

Ingo, 

I tabulated the cases where rwsem_spin_on_owner returns false and causes
us to stop spinning.

97.12%  was due to lock's owner switching to another writer
 0.01% was due to the owner of the lock sleeping
 2.87%  was due to need_resched() 

I made a change to allow us to continue to spin even when lock's 
owner switch to another writer.  I did get the lock to be acquired
now mostly (98%) via optimistic spin and lock stealing, but my
benchmark's throughput actually got reduced by 30% (too many cycles
spent on useless spinning?).  The lock statistics are below:

Writer acquisition blocked count		7538864
Blocked by reader				 0.37%
Lock acquired first attempt (lock stealing)	18.45%
Lock acquired second attempt (1 sleep)		 1.69%
Lock acquired after more than 1 sleep		 0.25%
Lock acquired with optimistic spin		79.62%
Optimistic spin failure (abort point 1) 	 1.37%
Optimistic spin failure (abort point 2)		 0.32%
Optimistic spin failure (abort point 3)		 0.23%
(Opt spin abort point 2 breakdown) owner sleep	 0.00%
(Opt spin abort point 2 breakdown) need_resched	 0.32%


Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
