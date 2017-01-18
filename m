Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 078496B0260
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:17:52 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z67so16426111pgb.0
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:17:51 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f4si204697pgc.224.2017.01.18.05.17.49
        for <linux-mm@kvack.org>;
        Wed, 18 Jan 2017 05:17:50 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v5 00/13] lockdep: Implement crossrelease feature
Date: Wed, 18 Jan 2017 22:17:26 +0900
Message-Id: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

I checked if crossrelease feature works well on my qemu-i386 machine.
There's no problem at all to work on mine. But I wonder if it's also
true even on other machines. Especially, on large system. Could you
let me know if it doesn't work on yours? Or Could you let me know if
crossrelease feature is useful? Please let me know if you need to
backport it to another version but it's not easy. Then I can provide
the backported version after working it.

-----8<-----

Change from v4
	- rebase on vanilla v4.9 tag
	- re-name pend_lock(plock) to hist_lock(xhlock)
	- allow overwriting ring buffer for hist_lock
	- unwind ring buffer instead of tagging id for each irq
	- introduce lockdep_map_cross embedding cross_lock
	- make each work of workqueue distinguishable
	- enhance comments
	(I will update the document at the next spin.)

Change from v3
	- reviced document

Change from v2
	- rebase on vanilla v4.7 tag
	- move lockdep data for page lock from struct page to page_ext
	- allocate plocks buffer via vmalloc instead of in struct task
	- enhanced comments and document
	- optimize performance
	- make reporting function crossrelease-aware

Change from v1
	- enhanced the document
	- removed save_stack_trace() optimizing patch
	- made this based on the seperated save_stack_trace patchset
	  https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1182242.html

Can we detect deadlocks below with original lockdep?

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

where A and B are different lock classes.

No, we cannot.

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

where A and B are different lock classes.

No, we cannot.

Example 3)

	PROCESS X	PROCESS Y
	--------------	--------------
			mutex_lock A
	mutex_lock A
			wait_for_complete B // DEADLOCK
	mutex_unlock A
	complete B
			mutex_unlock A

where A is a lock class and B is a completion variable.

No, we cannot.

Not only lock operations, but also any operations causing to wait or
spin for something can cause deadlock unless it's eventually *released*
by someone. The important point here is that the waiting or spinning
must be *released* by someone.

Using crossrelease feature, we can check dependency and detect deadlock
possibility not only for typical lock, but also for lock_page(),
wait_for_xxx() and so on, which might be released in any context.

See the last patch including the document for more information.

Byungchul Park (13):
  lockdep: Refactor lookup_chain_cache()
  lockdep: Fix wrong condition to print bug msgs for
    MAX_LOCKDEP_CHAIN_HLOCKS
  lockdep: Add a function building a chain between two classes
  lockdep: Refactor save_trace()
  lockdep: Pass a callback arg to check_prev_add() to handle stack_trace
  lockdep: Implement crossrelease feature
  lockdep: Make print_circular_bug() aware of crossrelease
  lockdep: Apply crossrelease to completions
  pagemap.h: Remove trailing white space
  lockdep: Apply crossrelease to PG_locked locks
  lockdep: Apply lock_acquire(release) on __Set(__Clear)PageLocked
  lockdep: Move data of CONFIG_LOCKDEP_PAGELOCK from page to page_ext
  lockdep: Crossrelease feature documentation

 Documentation/locking/crossrelease.txt | 1053 ++++++++++++++++++++++++++++++++
 include/linux/completion.h             |  118 +++-
 include/linux/irqflags.h               |   24 +-
 include/linux/lockdep.h                |  129 ++++
 include/linux/mm_types.h               |    4 +
 include/linux/page-flags.h             |   43 +-
 include/linux/page_ext.h               |    4 +
 include/linux/pagemap.h                |  124 +++-
 include/linux/sched.h                  |    9 +
 kernel/exit.c                          |    9 +
 kernel/fork.c                          |   23 +
 kernel/locking/lockdep.c               |  763 ++++++++++++++++++++---
 kernel/sched/completion.c              |   54 +-
 kernel/workqueue.c                     |    1 +
 lib/Kconfig.debug                      |   30 +
 mm/filemap.c                           |   76 ++-
 mm/page_ext.c                          |    4 +
 17 files changed, 2324 insertions(+), 144 deletions(-)
 create mode 100644 Documentation/locking/crossrelease.txt

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
