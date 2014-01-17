Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id EBC076B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 19:08:19 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so2833020pbc.28
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 16:08:19 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id zk9si5155446pac.173.2014.01.16.16.08.17
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 16:08:18 -0800 (PST)
Subject: [PATCH v7 0/6] MCS Lock: MCS lock code cleanup and optimizations
From: Tim Chen <tim.c.chen@linux.intel.com>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Jan 2014 16:08:04 -0800
Message-ID: <1389917284.3138.10.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

This is an update of the MCS lock patch series posted in November.

Proper passing of the mcs lock is now done with smp_load_acquire() in
mcs_spin_lock() and smp_store_release() in mcs_spin_unlock.  Note that
this is not sufficient to form a full memory barrier across cpus on
many architectures (except x86) for the mcs_unlock and mcs_lock pair.
For code that needs a full memory barrier, smp_mb__after_unlock_lock() 
should be used after mcs_lock.  I will
appreciate Paul and other experts review this portion of the code.

Will also added hooks to allow for architecture specific 
implementation and optimization of the of the contended paths of
lock and unlock of mcs_spin_lock and mcs_spin_unlock functions.

The original mcs lock code has potential leaks between critical sections, which
was not a problem when MCS was embedded within the mutex but needs
to be corrected when allowing the MCS lock to be used by itself for
other locking purposes.  The MCS lock code was previously embedded in
the mutex.c and is now sepearted.  This allows for easier reuse of MCS
lock in other places like rwsem and qrwlock.  We also did some micro
optimizations and barrier cleanup.

Tim

v7:
1. Update architecture specific hooks with concise architecture
specific arch_mcs_spin_lock_contended and arch_mcs_spin_lock_uncontended
functions. 

v6:
1. Fix a bug of improper xchg_acquire and extra space in barrier
fixing patch.
2. Added extra hooks to allow for architecture specific version
of mcs_spin_lock and mcs_spin_unlock to be used.

v5:
1. Rework barrier correction patch.  We now use smp_load_acquire()
in mcs_spin_lock() and smp_store_release() in
mcs_spin_unlock() to allow for architecture dependent barriers to be
automatically used.  This is clean and will provide the right
barriers for all architecture.

v4:
1. Move patch series to the latest tip after v3.12

v3:
1. modified memory barriers to support non x86 architectures that have
weak memory ordering.

v2:
1. change export mcs_spin_lock as a GPL export symbol
2. corrected mcs_spin_lock to references


Jason Low (1):
  MCS Lock: optimizations and extra comments

Tim Chen (1):
  MCS Lock: Restructure the MCS lock defines and locking code into its
    own file

Waiman Long (2):
  MCS Lock: Move mcs_lock/unlock function into its own file
  MCS Lock: Barrier corrections

Will Deacon (2):
  MCS Lock: allow architectures to hook in to contended paths
  MCS Lock: add Kconfig entries to allow arch-specific hooks

 arch/Kconfig                  |  3 ++
 include/linux/mcs_spinlock.h  | 33 ++++++++++++++++
 include/linux/mutex.h         |  5 ++-
 kernel/locking/Makefile       |  6 +--
 kernel/locking/mcs_spinlock.c | 89 +++++++++++++++++++++++++++++++++++++++++++
 kernel/locking/mutex.c        | 60 ++++-------------------------
 6 files changed, 138 insertions(+), 58 deletions(-)
 create mode 100644 include/linux/mcs_spinlock.h
 create mode 100644 kernel/locking/mcs_spinlock.c

-- 
1.7.11.7


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
