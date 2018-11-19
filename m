Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AB366B1B87
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:56:52 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id z68so46720610qkb.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:56:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l91si2515667qtd.76.2018.11.19.10.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:56:50 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 00/17] locking/lockdep: Add a new class of terminal locks
Date: Mon, 19 Nov 2018 13:55:09 -0500
Message-Id: <1542653726-5655-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

 v1->v2:
  - Mark more locks as terminal.
  - Add a patch to remove the unused version field from lock_class.
  - Steal some bits from pin_count of held_lock for flags.
  - Add a patch to warn if a task holding a raw spinlock is acquiring an
    non-raw lock.

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

 1) It saves table entries used by the validation code and hence make
    it harder to overflow those tables.

 2) The lockdep check in __lock_acquire() will be a little bit faster
    for terminal locks without using the lock validation code.

In fact, it is possible to overflow some of the tables by running
a variety of different workloads on a debug kernel. I have seen bug
reports about exhausting MAX_LOCKDEP_KEYS, MAX_LOCKDEP_ENTRIES and
MAX_STACK_TRACE_ENTRIES. This patch will help to reduce the chance
of overflowing some of the tables.

Below were selected output lines from the lockdep_stats files of the
patched and unpatched kernels after bootup and running parallel kernel
builds and some perf benchmarks.

  Item                     Unpatched kernel  Patched kernel  % Change
  ----                     ----------------  --------------  --------
  direct dependencies           9924             9032          -9.0%
  dependency chains            18258            16326         -10.6%
  dependency chain hlocks      73198            64927         -11.3%
  stack-trace entries         110502           103225          -6.6%

There were some reductions in the size of the lockdep tables. They were
not significant, but it is still a good start to rein in the number of
entries in those tables to make it harder to overflow them.

In term of performance, there isn't that much noticeable differences
in both the kernel build and perf benchmark. Low level locking
microbenchmark with 4 locking threads shows the following locking rates
on a Haswell system:

       Kernel             Lock                 Rate
       ------             ----                 ----
   Unpatched kernel    Regular lock         2,288 kop/s
   Patched kernel      Regular lock         2,352 kop/s
                       Terminal lock        2,512 kop/s

I was not sure why there was a slight performance improvement with
the patched kernel. However, comparing the regular and terminal lock
results, there was a slight 7% improvement in locking throughput for
terminal locks.

Looking at the perf ouput for regular lock:

   5.43%  run-locktest  [kernel.vmlinux]  [k] __lock_acquire
   4.65%  run-locktest  [kernel.vmlinux]  [k] lock_contended
   2.80%  run-locktest  [kernel.vmlinux]  [k] lock_acquired
   2.53%  run-locktest  [kernel.vmlinux]  [k] lock_release
   1.42%  run-locktest  [kernel.vmlinux]  [k] mark_lock

For terminal lock:

   5.00%  run-locktest  [kernel.vmlinux]  [k] __lock_acquire
   4.66%  run-locktest  [kernel.vmlinux]  [k] lock_contended
   2.88%  run-locktest  [kernel.vmlinux]  [k] lock_acquired
   2.55%  run-locktest  [kernel.vmlinux]  [k] lock_release
   1.34%  run-locktest  [kernel.vmlinux]  [k] mark_lock

The __lock_acquire() function ran a bit faster with terminal lock,
but the other lockdep functions remain more or less the same in term
of performance.

In term internal lockdep structure sizes, there should be no size
increase for 64-bit architectures with CONFIG_LOCK_STAT defined.
The lockdep_map structure will increase in size for 32-bit architectures
or when CONFIG_LOCK_STAT isn't defined.

Waiman Long (17):
  locking/lockdep: Remove version from lock_class structure
  locking/lockdep: Rework lockdep_set_novalidate_class()
  locking/lockdep: Add a new terminal lock type
  locking/lockdep: Add DEFINE_TERMINAL_SPINLOCK() and related macros
  printk: Mark logbuf_lock & console_owner_lock as terminal locks
  debugobjects: Mark pool_lock as a terminal lock
  debugobjects: Move printk out of db lock critical sections
  locking/lockdep: Add support for nestable terminal locks
  debugobjects: Make object hash locks nestable terminal locks
  lib/stackdepot: Make depot_lock a terminal spinlock
  locking/rwsem: Mark rwsem.wait_lock as a terminal lock
  cgroup: Mark the rstat percpu lock as terminal
  mm/kasan: Make quarantine_lock a terminal lock
  dma-debug: Mark free_entries_lock as terminal
  kernfs: Mark kernfs_open_node_lock as terminal lock
  delay_acct: Mark task's delays->lock as terminal spinlock
  locking/lockdep: Check raw/non-raw locking conflicts

 fs/kernfs/file.c                   |  2 +-
 include/linux/lockdep.h            | 59 +++++++++++++++++++++++----
 include/linux/rwsem.h              | 11 +++++-
 include/linux/spinlock_types.h     | 34 ++++++++++------
 kernel/cgroup/rstat.c              |  9 ++++-
 kernel/delayacct.c                 |  4 +-
 kernel/dma/debug.c                 |  2 +-
 kernel/locking/lockdep.c           | 81 ++++++++++++++++++++++++++++++++------
 kernel/locking/lockdep_internals.h |  5 +++
 kernel/locking/lockdep_proc.c      | 11 +++++-
 kernel/locking/rwsem-xadd.c        |  1 +
 kernel/locking/spinlock_debug.c    |  1 +
 kernel/printk/printk.c             |  4 +-
 kernel/printk/printk_safe.c        |  2 +-
 lib/debugobjects.c                 | 70 ++++++++++++++++++++++----------
 lib/stackdepot.c                   |  2 +-
 mm/kasan/quarantine.c              |  2 +-
 17 files changed, 235 insertions(+), 65 deletions(-)

-- 
1.8.3.1
