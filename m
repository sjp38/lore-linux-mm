Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 830836B0648
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 15:35:29 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 67so40526214qkj.18
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 12:35:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w7si3537342qte.36.2018.11.08.12.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 12:35:28 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 00/12] locking/lockdep: Add a new class of terminal locks
Date: Thu,  8 Nov 2018 15:34:16 -0500
Message-Id: <1541709268-3766-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

The purpose of this patchset is to add a new class of locks called
terminal locks and converts some of the low level raw or regular
spinlocks to terminal locks. A terminal lock does not have forward
dependency and it won't allow a lock or unlock operation on another
lock. Two level nesting of terminal locks is allowed, though.

Only spinlocks that are acquired with the _irq/_irqsave variants or
acquired in an IRQ disabled context should be classified as terminal
locks.

Because of the restrictions on terminal locks, we can do simple checks on
them without using the lockdep lock validation machinery. The advantages
of making these changes are as follows:

 1) The lockdep check will be faster for terminal locks without using
    the lock validation code.
 2) It saves table entries used by the validation code and hence make
    it harder to overflow those tables.

In fact, it is possible to overflow some of the tables by running
a variety of different workloads on a debug kernel. I have seen bug
reports about exhausting MAX_LOCKDEP_KEYS, MAX_LOCKDEP_ENTRIES and
MAX_STACK_TRACE_ENTRIES. This patch will help to reduce the chance
of overflowing some of the tables.

Performance wise, there was no statistically significant difference in
performanace when doing a parallel kernel build on a debug kernel.

Below were selected output lines from the lockdep_stats files of the
patched and unpatched kernels after bootup and running parallel kernel
builds.

  Item                     Unpatched kernel  Patched kernel  % Change
  ----                     ----------------  --------------  --------
  direct dependencies           9732             8994          -7.6%
  dependency chains            18776            17033          -9.3%
  dependency chain hlocks      76044            68419         -10.0%
  stack-trace entries         110403           104341          -5.5%

There were some reductions in the size of the lockdep tables. They were
not significant, but it is still a good start to rein in the number of
entries in those tables to make it harder to overflow them.

Waiman Long (12):
  locking/lockdep: Rework lockdep_set_novalidate_class()
  locking/lockdep: Add a new terminal lock type
  locking/lockdep: Add DEFINE_TERMINAL_SPINLOCK() and related macros
  printk: Make logbuf_lock a terminal lock
  debugobjects: Mark pool_lock as a terminal lock
  debugobjects: Move printk out of db lock critical sections
  locking/lockdep: Add support for nested terminal locks
  debugobjects: Make object hash locks nested terminal locks
  lib/stackdepot: Make depot_lock a terminal spinlock
  locking/rwsem: Mark rwsem.wait_lock as a terminal lock
  cgroup: Mark the rstat percpu lock as terminal
  mm/kasan: Make quarantine_lock a terminal lock

 include/linux/lockdep.h            | 34 +++++++++++++++---
 include/linux/rwsem.h              | 11 +++++-
 include/linux/spinlock_types.h     | 34 ++++++++++++------
 kernel/cgroup/rstat.c              |  9 +++--
 kernel/locking/lockdep.c           | 67 ++++++++++++++++++++++++++++++------
 kernel/locking/lockdep_internals.h |  5 +++
 kernel/locking/lockdep_proc.c      | 11 ++++--
 kernel/locking/rwsem-xadd.c        |  1 +
 kernel/printk/printk.c             |  2 +-
 kernel/printk/printk_safe.c        |  2 +-
 lib/debugobjects.c                 | 70 ++++++++++++++++++++++++++------------
 lib/stackdepot.c                   |  2 +-
 mm/kasan/quarantine.c              |  2 +-
 13 files changed, 195 insertions(+), 55 deletions(-)

-- 
1.8.3.1
