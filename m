Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id A022A6B0267
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:32:19 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id t74so32856650ioi.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:32:19 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id m140si620076itm.70.2016.07.07.02.32.16
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 02:32:16 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [RFC v2 00/13] lockdep: Implement crossrelease feature
Date: Thu,  7 Jul 2016 18:29:50 +0900
Message-Id: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, npiggin@kernel.dk, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Change from v1
	- enhanced the document
	- removed save_stack_trace() optimizing patch
	- made this based on the seperated save_stack_trace patchset
	  https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1182242.html

Can we detect deadlocks descriped below, with lockdep? No.

Example 1)

	PROCESS X	PROCESS Y
	--------------	--------------
	mutext_lock A
			lock_page B
	lock_page B
			mutext_lock A // DEADLOCK
	unlock_page B
			mutext_unlock A
	mutex_unlock A
			unlock_page B

We are not checking the dependency for lock_page() at all now.

Example 2)

	PROCESS X	PROCESS Y	PROCESS Z
	--------------	--------------	--------------
			mutex_lock A
	lock_page B
			lock_page B
					mutext_lock A // DEADLOCK
					mutext_unlock A
					unlock_page B
					(B was held by PROCESS X)
			unlock_page B
			mutex_unlock A

We cannot detect this kind of deadlock with lockdep, even though we
apply the dependency check using lockdep on lock_page().

Example 3)

	PROCESS X	PROCESS Y
	--------------	--------------
			mutex_lock A
	mutex_lock A
	mutex_unlock A
			wait_for_complete B // DEADLOCK
	complete B
			mutex_unlock A

wait_for_complete() and complete() also can cause a deadlock, however
we cannot detect it with lockdep, either.

Not only lock operations, but also any operations causing to wait or
spin for something can cause deadlock unless it's eventually *released*
by someone. The important point here is that the waiting or spinning
must be *released* by someone. In other words, we have to focus whether
the waiting or spinning can be *released* or not to check a deadlock
possibility, rather than the waiting or spinning itself.

In this point of view, typical lock is a special case where the acquire
context is same as the release context, so no matter in which context
the checking is performed for typical lock.

Of course, in order to be able to report deadlock imediately at the time
real deadlock actually occures, the checking must be performed before
actual blocking or spinning happens when acquiring it. However, deadlock
*possibility* can be detected and reported even the checking is done
when releasing it, which means the time we can identify the release
context.

Given that the assumption the current lockdep has is relaxed, we can
check dependency and detect deadlock possibility not only for typical
lock, but also for lock_page() using PG_locked, wait_for_xxx() and so
on, which might be released by different context from the context which
held the lock.

My implementation makes it possible. See the last patch including the
document for more information.

---

Byungchul Park (13):
  lockdep: Refactor lookup_chain_cache()
  lockdep: Add a function building a chain between two hlocks
  lockdep: Make check_prev_add can use a stack_trace of other context
  lockdep: Make save_trace can copy from other stack_trace
  lockdep: Implement crossrelease feature
  lockdep: Apply crossrelease to completion
  pagemap.h: Remove trailing white space
  lockdep: Apply crossrelease to PG_locked lock
  cifs/file.c: Remove trailing white space
  mm/swap_state.c: Remove trailing white space
  lockdep: Call lock_acquire(release) when accessing PG_locked manually
  lockdep: Make crossrelease use save_stack_trace_norm() instead
  lockdep: Add a document describing crossrelease feature

 Documentation/locking/crossrelease.txt | 457 ++++++++++++++++++
 fs/cifs/file.c                         |   6 +-
 include/linux/completion.h             | 121 ++++-
 include/linux/irqflags.h               |  16 +-
 include/linux/lockdep.h                | 139 ++++++
 include/linux/mm_types.h               |   9 +
 include/linux/pagemap.h                | 104 +++-
 include/linux/sched.h                  |   5 +
 kernel/fork.c                          |   4 +
 kernel/locking/lockdep.c               | 852 ++++++++++++++++++++++++++++++---
 kernel/sched/completion.c              |  55 ++-
 lib/Kconfig.debug                      |  30 ++
 mm/filemap.c                           |  10 +-
 mm/ksm.c                               |   1 +
 mm/migrate.c                           |   1 +
 mm/page_alloc.c                        |   3 +
 mm/shmem.c                             |   2 +
 mm/swap_state.c                        |  12 +-
 mm/vmscan.c                            |   1 +
 19 files changed, 1706 insertions(+), 122 deletions(-)
 create mode 100644 Documentation/locking/crossrelease.txt

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
