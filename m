Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id B58346B0032
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 16:53:27 -0400 (EDT)
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20130627083651.GA3730@gmail.com>
References: <1371165992.27102.573.camel@schen9-DESK>
	 <20130619131611.GC24957@gmail.com> <1371660831.27102.663.camel@schen9-DESK>
	 <1372205996.22432.119.camel@schen9-DESK> <20130626095108.GB29181@gmail.com>
	 <1372282560.22432.139.camel@schen9-DESK>
	 <1372292701.22432.152.camel@schen9-DESK>  <20130627083651.GA3730@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 27 Jun 2013 13:53:05 -0700
Message-ID: <1372366385.22432.185.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Thu, 2013-06-27 at 10:36 +0200, Ingo Molnar wrote:
> * Tim Chen <tim.c.chen@linux.intel.com> wrote:
> 
> > On Wed, 2013-06-26 at 14:36 -0700, Tim Chen wrote:
> > > On Wed, 2013-06-26 at 11:51 +0200, Ingo Molnar wrote: 
> > > > * Tim Chen <tim.c.chen@linux.intel.com> wrote:
> > > > 
> > > > > On Wed, 2013-06-19 at 09:53 -0700, Tim Chen wrote: 
> > > > > > On Wed, 2013-06-19 at 15:16 +0200, Ingo Molnar wrote:
> > > > > > 
> > > > > > > > vmstat for mutex implementation: 
> > > > > > > > procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
> > > > > > > >  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
> > > > > > > > 38  0      0 130957920  47860 199956    0    0     0    56 236342 476975 14 72 14  0  0
> > > > > > > > 41  0      0 130938560  47860 219900    0    0     0     0 236816 479676 14 72 14  0  0
> > > > > > > > 
> > > > > > > > vmstat for rw-sem implementation (3.10-rc4)
> > > > > > > > procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
> > > > > > > >  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
> > > > > > > > 40  0      0 130933984  43232 202584    0    0     0     0 321817 690741 13 71 16  0  0
> > > > > > > > 39  0      0 130913904  43232 224812    0    0     0     0 322193 692949 13 71 16  0  0
> > > > > > > 
> > > > > > > It appears the main difference is that the rwsem variant context-switches 
> > > > > > > about 36% more than the mutex version, right?
> > > > > > > 
> > > > > > > I'm wondering how that's possible - the lock is mostly write-locked, 
> > > > > > > correct? So the lock-stealing from Davidlohr Bueso and Michel Lespinasse 
> > > > > > > ought to have brought roughly the same lock-stealing behavior as mutexes 
> > > > > > > do, right?
> > > > > > > 
> > > > > > > So the next analytical step would be to figure out why rwsem lock-stealing 
> > > > > > > is not behaving in an equivalent fashion on this workload. Do readers come 
> > > > > > > in frequently enough to disrupt write-lock-stealing perhaps?
> > > > > 
> > > > > Ingo, 
> > > > > 
> > > > > I did some instrumentation on the write lock failure path.  I found that
> > > > > for the exim workload, there are no readers blocking for the rwsem when
> > > > > write locking failed.  The lock stealing is successful for 9.1% of the
> > > > > time and the rest of the write lock failure caused the writer to go to
> > > > > sleep.  About 1.4% of the writers sleep more than once. Majority of the
> > > > > writers sleep once.
> > > > > 
> > > > > It is weird that lock stealing is not successful more often.
> > > > 
> > > > For this to be comparable to the mutex scalability numbers you'd have to 
> > > > compare wlock-stealing _and_ adaptive spinning for failed-wlock rwsems.
> > > > 
> > > > Are both techniques applied in the kernel you are running your tests on?
> > > > 
> > > 
> > > Ingo,
> > > 
> > > The previous experiment was done on a kernel without spinning. 
> > > I've redone the testing on two kernel for a 15 sec stretch of the
> > > workload run.  One with the adaptive (or optimistic) 
> > > spinning and the other without.  Both have the patches from Alex to avoid 
> > > cmpxchg induced cache bouncing.
> > > 
> > > With the spinning, I sleep much less for lock acquisition (18.6% vs 91.58%).
> > > However, I've got doubling of write lock acquisition getting
> > > blocked.  So that offset the gain from spinning which may be why
> > > I didn't see gain for this particular workload.
> > > 
> > > 						No Opt Spin	Opt Spin
> > > Writer acquisition blocked count		3448946		7359040
> > > Blocked by reader				0.00%		0.55%
> > > Lock acquired first attempt (lock stealing)	8.42%		16.92%
> > > Lock acquired second attempt (1 sleep)	90.26%		17.60%
> > > Lock acquired after more than 1 sleep	1.32%		1.00%
> > > Lock acquired with optimistic spin		N/A		64.48%
> > > 
> > 
> > Adding also the mutex statistics for the 3.10-rc4 kernel with mutex
> > implemenation of lock for anon_vma tree.  Wonder if Ingo has any
> > insight on why mutex performs better from these stats.
> > 
> > Mutex acquisition blocked count			14380340
> > Lock acquired in slowpath (no sleep)		0.06%
> > Lock acquired in slowpath (1 sleep)		0.24%
> > Lock acquired in slowpath more than 1 sleep	0.98%
> > Lock acquired with optimistic spin		99.6%
> 
> This is how I interpret the stats:
> 
> It does appear that in the mutex case we manage to acquire via spinning 
> with a very high percentage - i.e. it essentialy behaves as a spinlock.
> 
> That is actually good news in a way, because it makes it rather simple how 
> rwsems should behave in this case: since they have no substantial 
> read-locking aspect in this workload, the down_write()/up_write()s should 
> essentially behave like spinlocks as well, right?

Yes, it makes sense.

> 
> Yet in the rwsem-spinning case the stats show that we only acquire the 
> lock via spinning in 65% of the cases, plus we lock-steal in 16.9% of the 
> cases:
> 
> Because lock stealing is essentially a single-spin spinning as well:
> 
> > > Lock acquired first attempt (lock stealing)	......		16.92%
> 
> So rwsems in this case behave like spinlocks in 65%+16.9% == 81.9% of the 
> time.
> 
> What remains is the sleeping component:
> 
> > > Lock acquired second attempt (1 sleep)	......		17.60%
> 
> Yet the 17.6% sleep percentage is still much higher than the 1% in the 
> mutex case. Why doesn't spinning work - do we time out of spinning 
> differently?

I have some stats for the 18.6% cases (including 1% more than 
1 sleep cases) that go to sleep and failed optimistic spinning. 
There are 3 abort points in the rwsem_optimistic_spin code: 

1. 11.8% is due to abort point #1, where we don't find an owner and
assumed that probably a reader owned lock as we've just tried
to acquire lock previously for lock stealing.  I think I will need
to actually check the sem->count to make sure we have reader owned lock 
before aborting spin.  

2. 6.8% is due to abort point #2, where the mutex owner switches
to another writer or we need rescheduling.

3. Minuscule amount due to abort point #3, where we don't have
a owner of the lock but need rescheduling

int rwsem_optimistic_spin(struct rw_semaphore *sem)
{
       struct  task_struct     *owner;
       int     ret = 0;

       /* sem->wait_lock should not be held when doing optimistic spinning */
       if (!rwsem_can_spin_on_owner(sem))
               return ret;  <------------------------------- abort (1)

       preempt_disable();
       for (;;) {
               owner = ACCESS_ONCE(sem->owner);
               if (owner && !rwsem_spin_on_owner(sem, owner))
                       break;   <--------------------------- abort (2)

               /* wait_lock will be acquired if write_lock is obtained */
               if (rwsem_try_write_lock(sem->count, true, sem)) {
                       ret = 1;
                       break;
               }

               /*
                * When there's no owner, we might have preempted between the
                * owner acquiring the lock and setting the owner field. If
                * we're an RT task that will live-lock because we won't let
                * the owner complete.
                */
               if (!owner && (need_resched() || rt_task(current)))
                       break;   <---------------------------- abort (3)

               /*
                * The cpu_relax() call is a compiler barrier which forces
                * everything in this loop to be re-loaded. We don't need
                * memory barriers as we'll eventually observe the right
                * values at the cost of a few extra spins.
                */
               arch_mutex_cpu_relax();

       }

       preempt_enable();
       return ret;

See the other thread for complete patch of rwsem optimistic spin code:
https://lkml.org/lkml/2013/6/26/692

Any suggestions on tweaking this is appreciated.

> Is there some other aspect that defeats optimistic spinning and forces the 
> slowpath and creates sleeping, scheduling and thus extra overhead?
> 
There are other aspects that are different from mutex in my optimistic
spinning for rwsem:

1. Mutex spinning has MCS lock.
	I have disabled MCS lock in mutex and get same profile and
 	performance for my tests.  So this is probably not a reason for
 	performance difference.

2. Preemption was disabled at the beginning of mutex acquisition. 
	I have tried moving the preemption disable of rwsem from
	the optimistic spin to the top of rwsem_down_write_failed.
	However, I didn't see a change in performance.


> For example after a failed lock-stealing, do we still try optimistic 
> spinning to write-acquire the rwsem, or go into the slowpath and thus 
> trigger excessive context-switches?

I do try optimistic spinning after a failed lock stealing.  However,
not after we have gone to sleep.

Thanks,

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
