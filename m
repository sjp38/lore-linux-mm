Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0746B0031
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 20:37:34 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so3340606pde.41
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 17:37:33 -0800 (PST)
Received: from psmtp.com ([74.125.245.180])
        by mx.google.com with SMTP id ku6si12912966pbc.156.2013.11.19.17.37.31
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 17:37:32 -0800 (PST)
Subject: [PATCH v6 0/5] MCS Lock: MCS lock code cleanup and optimizations
From: Tim Chen <tim.c.chen@linux.intel.com>
References: <cover.1384885312.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Nov 2013 17:37:26 -0800
Message-ID: <1384911446.11046.450.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul
 E.McKenney" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>, "Figo.zhang" <figo1802@gmail.com>

In this patch series, we separated out the MCS lock code which was
previously embedded in the mutex.c.  This allows for easier reuse of
MCS lock in other places like rwsem and qrwlock.  We also did some micro
optimizations and barrier cleanup.  

The original code has potential leaks between critical sections, which
was not a problem when MCS was embedded within the mutex but needs
to be corrected when allowing the MCS lock to be used by itself for
other locking purposes. 

Proper barriers are now embedded with the usage of smp_load_acquire() in
mcs_spin_lock() and smp_store_release() in mcs_spin_unlock.  See
http://marc.info/?l=linux-arch&m=138386254111507 for info on the
new smp_load_acquire() and smp_store_release() functions. 

This patches were previously part of the rwsem optimization patch series
but now we spearate them out.

We have also added hooks to allow for architecture specific 
implementation of the mcs_spin_lock and mcs_spin_unlock functions.

Will, do you want to take a crack at adding implementation for ARM
with wfe instruction?

Tim

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

Tim Chen (2):
  MCS Lock: Restructure the MCS lock defines and locking code into its
    own file
  MCS Lock: Allows for architecture specific mcs lock and unlock

Waiman Long (2):
  MCS Lock: Move mcs_lock/unlock function into its own file
  MCS Lock: Barrier corrections

 arch/Kconfig                  |  3 ++
 include/linux/mcs_spinlock.h  | 30 +++++++++++++
 include/linux/mutex.h         |  5 ++-
 kernel/locking/Makefile       |  6 +--
 kernel/locking/mcs_spinlock.c | 98 +++++++++++++++++++++++++++++++++++++++++++
 kernel/locking/mutex.c        | 60 ++++----------------------
 6 files changed, 144 insertions(+), 58 deletions(-)
 create mode 100644 include/linux/mcs_spinlock.h
 create mode 100644 kernel/locking/mcs_spinlock.c

-- 
1.7.11.7


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
