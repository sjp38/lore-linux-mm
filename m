Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id A7B3C6B0034
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 04:36:56 -0400 (EDT)
Received: by mail-ea0-f169.google.com with SMTP id h15so225877eak.14
        for <linux-mm@kvack.org>; Thu, 27 Jun 2013 01:36:55 -0700 (PDT)
Date: Thu, 27 Jun 2013 10:36:51 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
Message-ID: <20130627083651.GA3730@gmail.com>
References: <1371165992.27102.573.camel@schen9-DESK>
 <20130619131611.GC24957@gmail.com>
 <1371660831.27102.663.camel@schen9-DESK>
 <1372205996.22432.119.camel@schen9-DESK>
 <20130626095108.GB29181@gmail.com>
 <1372282560.22432.139.camel@schen9-DESK>
 <1372292701.22432.152.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372292701.22432.152.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> On Wed, 2013-06-26 at 14:36 -0700, Tim Chen wrote:
> > On Wed, 2013-06-26 at 11:51 +0200, Ingo Molnar wrote: 
> > > * Tim Chen <tim.c.chen@linux.intel.com> wrote:
> > > 
> > > > On Wed, 2013-06-19 at 09:53 -0700, Tim Chen wrote: 
> > > > > On Wed, 2013-06-19 at 15:16 +0200, Ingo Molnar wrote:
> > > > > 
> > > > > > > vmstat for mutex implementation: 
> > > > > > > procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
> > > > > > >  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
> > > > > > > 38  0      0 130957920  47860 199956    0    0     0    56 236342 476975 14 72 14  0  0
> > > > > > > 41  0      0 130938560  47860 219900    0    0     0     0 236816 479676 14 72 14  0  0
> > > > > > > 
> > > > > > > vmstat for rw-sem implementation (3.10-rc4)
> > > > > > > procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
> > > > > > >  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
> > > > > > > 40  0      0 130933984  43232 202584    0    0     0     0 321817 690741 13 71 16  0  0
> > > > > > > 39  0      0 130913904  43232 224812    0    0     0     0 322193 692949 13 71 16  0  0
> > > > > > 
> > > > > > It appears the main difference is that the rwsem variant context-switches 
> > > > > > about 36% more than the mutex version, right?
> > > > > > 
> > > > > > I'm wondering how that's possible - the lock is mostly write-locked, 
> > > > > > correct? So the lock-stealing from Davidlohr Bueso and Michel Lespinasse 
> > > > > > ought to have brought roughly the same lock-stealing behavior as mutexes 
> > > > > > do, right?
> > > > > > 
> > > > > > So the next analytical step would be to figure out why rwsem lock-stealing 
> > > > > > is not behaving in an equivalent fashion on this workload. Do readers come 
> > > > > > in frequently enough to disrupt write-lock-stealing perhaps?
> > > > 
> > > > Ingo, 
> > > > 
> > > > I did some instrumentation on the write lock failure path.  I found that
> > > > for the exim workload, there are no readers blocking for the rwsem when
> > > > write locking failed.  The lock stealing is successful for 9.1% of the
> > > > time and the rest of the write lock failure caused the writer to go to
> > > > sleep.  About 1.4% of the writers sleep more than once. Majority of the
> > > > writers sleep once.
> > > > 
> > > > It is weird that lock stealing is not successful more often.
> > > 
> > > For this to be comparable to the mutex scalability numbers you'd have to 
> > > compare wlock-stealing _and_ adaptive spinning for failed-wlock rwsems.
> > > 
> > > Are both techniques applied in the kernel you are running your tests on?
> > > 
> > 
> > Ingo,
> > 
> > The previous experiment was done on a kernel without spinning. 
> > I've redone the testing on two kernel for a 15 sec stretch of the
> > workload run.  One with the adaptive (or optimistic) 
> > spinning and the other without.  Both have the patches from Alex to avoid 
> > cmpxchg induced cache bouncing.
> > 
> > With the spinning, I sleep much less for lock acquisition (18.6% vs 91.58%).
> > However, I've got doubling of write lock acquisition getting
> > blocked.  So that offset the gain from spinning which may be why
> > I didn't see gain for this particular workload.
> > 
> > 						No Opt Spin	Opt Spin
> > Writer acquisition blocked count		3448946		7359040
> > Blocked by reader				0.00%		0.55%
> > Lock acquired first attempt (lock stealing)	8.42%		16.92%
> > Lock acquired second attempt (1 sleep)	90.26%		17.60%
> > Lock acquired after more than 1 sleep	1.32%		1.00%
> > Lock acquired with optimistic spin		N/A		64.48%
> > 
> 
> Adding also the mutex statistics for the 3.10-rc4 kernel with mutex
> implemenation of lock for anon_vma tree.  Wonder if Ingo has any
> insight on why mutex performs better from these stats.
> 
> Mutex acquisition blocked count			14380340
> Lock acquired in slowpath (no sleep)		0.06%
> Lock acquired in slowpath (1 sleep)		0.24%
> Lock acquired in slowpath more than 1 sleep	0.98%
> Lock acquired with optimistic spin		99.6%

This is how I interpret the stats:

It does appear that in the mutex case we manage to acquire via spinning 
with a very high percentage - i.e. it essentialy behaves as a spinlock.

That is actually good news in a way, because it makes it rather simple how 
rwsems should behave in this case: since they have no substantial 
read-locking aspect in this workload, the down_write()/up_write()s should 
essentially behave like spinlocks as well, right?

Yet in the rwsem-spinning case the stats show that we only acquire the 
lock via spinning in 65% of the cases, plus we lock-steal in 16.9% of the 
cases:

Because lock stealing is essentially a single-spin spinning as well:

> > Lock acquired first attempt (lock stealing)	......		16.92%

So rwsems in this case behave like spinlocks in 65%+16.9% == 81.9% of the 
time.

What remains is the sleeping component:

> > Lock acquired second attempt (1 sleep)	......		17.60%

Yet the 17.6% sleep percentage is still much higher than the 1% in the 
mutex case. Why doesn't spinning work - do we time out of spinning 
differently?

Is there some other aspect that defeats optimistic spinning and forces the 
slowpath and creates sleeping, scheduling and thus extra overhead?

For example after a failed lock-stealing, do we still try optimistic 
spinning to write-acquire the rwsem, or go into the slowpath and thus 
trigger excessive context-switches?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
