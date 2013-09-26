Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7814B6B0037
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 18:21:03 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so1719439pbc.11
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 15:21:03 -0700 (PDT)
Subject: [PATCH v7 0/6] rwsem: performance optimizations
From: Tim Chen <tim.c.chen@linux.intel.com>
References: <cover.1380231690.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 26 Sep 2013 15:20:56 -0700
Message-ID: <1380234056.3467.86.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

We fixed various style issues for version 7 of this patchset 
and added brief explanations of the MCS lock code that we put
in a separate file. We will like to have it merged if
there are no objections.

In this patchset, we introduce two categories of optimizations to read
write semaphore.  The first four patches from Alex Shi reduce cache
bouncing of the sem->count field by doing a pre-read of the sem->count
and avoid cmpxchg if possible.

The last two patches introduce similar optimistic spinning logic as the
mutex code for the writer lock acquisition of rwsem. This addresses the
general 'mutexes out perform writer-rwsems' situations that has been
seen in more than one case.  Users now need not worry about performance
issues when choosing between these two locking mechanisms.

Without these optimizations, Davidlohr Bueso saw a -8% regression to
aim7's shared and high_systime workloads when he switched i_mmap_mutex
to rwsem.  Tests were on 8 socket 80 cores system.  With the patchset,
he got significant improvements to the aim7 suite instead of regressions:

alltests (+16.3%), custom (+20%), disk (+19.5%), high_systime (+7%),
shared (+18.4%) and short (+6.3%).

Tim Chen also got a +5% improvements to exim mail server workload on a
40 core system.

Thanks to Ingo Molnar, Peter Hurley and Peter Zijlstra for reviewing
this patchset.

Regards,
Tim Chen

Changelog:

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

Tim Chen (2):
  MCS Lock: Restructure the MCS lock defines and locking code into its
    own file
  rwsem: do optimistic spinning for writer lock acquisition

 include/asm-generic/rwsem.h  |    8 +-
 include/linux/mcs_spinlock.h |   64 ++++++++++++
 include/linux/mutex.h        |    5 +-
 include/linux/rwsem.h        |    7 +-
 kernel/mutex.c               |   60 ++----------
 kernel/rwsem.c               |   19 ++++-
 lib/rwsem.c                  |  226 ++++++++++++++++++++++++++++++++++++-----
 7 files changed, 300 insertions(+), 89 deletions(-)
 create mode 100644 include/linux/mcs_spinlock.h

-- 
1.7.4.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
