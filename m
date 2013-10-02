Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B8A426B0036
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 18:38:30 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so1682231pad.19
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 15:38:30 -0700 (PDT)
Subject: [PATCH v8 0/9] rwsem performance optimizations
From: Tim Chen <tim.c.chen@linux.intel.com>
References: <cover.1380748401.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 02 Oct 2013 15:38:13 -0700
Message-ID: <1380753493.11046.82.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Jason Low <jason.low2@hp.com>, Waiman Long <Waiman.Long@hp.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

For version 8 of the patchset, we included the patch from Waiman
to streamline wakeup operations and also optimize the MCS lock
used in rwsem and mutex.

In this patchset, we introduce three categories of optimizations to read
write semaphore.  The first four patches from Alex Shi reduce cache
bouncing of the sem->count field by doing a pre-read of the sem->count
and avoid cmpxchg if possible.

The next four patches from Tim, Davidlohr and Jason
introduce optimistic spinning logic similar to that in the
mutex code for the writer lock acquisition of rwsem. This addresses the
general 'mutexes out perform writer-rwsems' situations that has been
seen in more than one case.  Users now need not worry about performance
issues when choosing between these two locking mechanisms.  We have
also factored out the MCS lock originally in the mutex code into its
own file, and performed micro optimizations and corrected the memory
barriers so it could be used for general lock/unlock of critical
sections.
 
The last patch from Waiman help to streamline the wake up operation
by avoiding multiple threads all doing wakeup operations when only
one wakeup thread is enough.  This significantly reduced lock
contentions from multiple wakeup threads. 

Tim got the following improvement for exim mail server 
workload on 40 core system:

Alex+Tim's patchset:    	   +4.8%
Alex+Tim+Waiman's patchset:        +5.3%

Without these optimizations, Davidlohr Bueso saw a -8% regression to
aim7's shared and high_systime workloads when he switched i_mmap_mutex
to rwsem.  Tests were on 8 socket 80 cores system.  With Alex
and Tim's patches, he got significant improvements to the aim7 
suite instead of regressions:

alltests (+16.3%), custom (+20%), disk (+19.5%), high_systime (+7%),
shared (+18.4%) and short (+6.3%).

More Aim7 numbers will be posted when Davidlohr has a chance
to test the complete patchset including Waiman's patch.

Thanks to Ingo Molnar, Peter Hurley, Peter Zijlstra and Paul McKenney
for helping to review this patchset.

Tim

Changelog:

v8:
1. Added Waiman's patch to avoid multiple wakeup thread lock contention.
2. Micro-optimizations of MCS lock.
3. Correct the barriers of MCS lock to prevent critical sections from
leaking.

v7:
1. Rename mcslock.h to mcs_spinlock.h and also rename mcs related fields
with mcs prefix.
2. Properly define type of *mcs_lock field instead of leaving it as *void.
3. Added breif explanation of mcs lock.

v6:
1. Fix missing mcslock.h file.
2. Fix various code style issues.

v5:
1. Try optimistic spinning before we put the writer on the wait queue
to avoid bottlenecking at wait queue.  This provides 5% boost to exim workload
and between 2% to 8% boost to aim7.
2. Put MCS locking code into its own mcslock.h file for better reuse
between mutex.c and rwsem.c
3. Remove the configuration RWSEM_SPIN_ON_WRITE_OWNER and make the
operations default per Ingo's suggestions.

v4:
1. Fixed a bug in task_struct definition in rwsem_can_spin_on_owner
2. Fix another typo for RWSEM_SPIN_ON_WRITE_OWNER config option

v3:
1. Added ACCESS_ONCE to sem->count access in rwsem_can_spin_on_owner.
2. Fix typo bug for RWSEM_SPIN_ON_WRITE_OWNER option in init/Kconfig

v2:
1. Reorganize changes to down_write_trylock and do_wake into 4 patches and fixed
   a bug referencing &sem->count when sem->count is intended.
2. Fix unsafe sem->owner de-reference in rwsem_can_spin_on_owner.
the option to be on for more seasoning but can be turned off should it be detrimental.
3. Various patch comments update

Alex Shi (4):
  rwsem: check the lock before cpmxchg in down_write_trylock
  rwsem: remove 'out' label in do_wake
  rwsem: remove try_reader_grant label do_wake
  rwsem/wake: check lock before do atomic update

Jason Low (2):
  MCS Lock: optimizations and extra comments
  MCS Lock: Barrier corrections

Tim Chen (2):
  MCS Lock: Restructure the MCS lock defines and locking code into its
    own file
  rwsem: do optimistic spinning for writer lock acquisition

Waiman Long (1):
  rwsem: reduce spinlock contention in wakeup code path

 include/asm-generic/rwsem.h  |    8 +-
 include/linux/mcs_spinlock.h |   82 ++++++++++++++
 include/linux/mutex.h        |    5 +-
 include/linux/rwsem.h        |    9 ++-
 kernel/mutex.c               |   60 +---------
 kernel/rwsem.c               |   19 +++-
 lib/rwsem.c                  |  255 +++++++++++++++++++++++++++++++++++++-----
 7 files changed, 349 insertions(+), 89 deletions(-)
 create mode 100644 include/linux/mcs_spinlock.h

-- 
1.7.4.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
