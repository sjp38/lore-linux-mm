Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1106B0313
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 03:14:14 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p20so87180396pfj.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 00:14:14 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y10si4308550pfk.573.2017.08.07.00.14.12
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 00:14:13 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Date: Mon,  7 Aug 2017 16:12:47 +0900
Message-Id: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

Change from v7
	- rebase on latest tip/sched/core (Jul 26 2017)
	- apply peterz's suggestions
	- simplify code of crossrelease_{hist/soft/hard}_{start/end}
	- exclude a patch avoiding redundant links
	- exclude a patch already applied onto the base

Change from v6
	- unwind the ring buffer instead tagging for 'work' context
	- introduce hist_id to distinguish every entry of ring buffer
	- change the point calling crossrelease_work_start()
	- handle cases the ring buffer was overwritten
	- change LOCKDEP_CROSSRELEASE config in Kconfig
	  (select PROVE_LOCKING -> depends on PROVE_LOCKING)
	- rename xhlock_used() -> xhlock_valid()
	- simplify serveral code (e.g. traversal the ring buffer)
	- add/enhance several comments and changelogs

Change from v5
	- force XHLOCKS_SIZE to be power of 2 and simplify code
	- remove nmi check
	- separate an optimization using prev_gen_id with a full changelog
	- separate non(multi)-acquisition handling with a full changelog
	- replace vmalloc with kmallock(GFP_KERNEL) for xhlocks
	- select PROVE_LOCKING when choosing CROSSRELEASE
	- clean serveral code (e.g. loose some ifdefferies)
	- enhance several comments and changelogs

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

Byungchul Park (14):
  lockdep: Refactor lookup_chain_cache()
  lockdep: Add a function building a chain between two classes
  lockdep: Change the meaning of check_prev_add()'s return value
  lockdep: Make check_prev_add() able to handle external stack_trace
  lockdep: Implement crossrelease feature
  lockdep: Detect and handle hist_lock ring buffer overwrite
  lockdep: Handle non(or multi)-acquisition of a crosslock
  lockdep: Make print_circular_bug() aware of crossrelease
  lockdep: Apply crossrelease to completions
  pagemap.h: Remove trailing white space
  lockdep: Apply crossrelease to PG_locked locks
  lockdep: Apply lock_acquire(release) on __Set(__Clear)PageLocked
  lockdep: Move data of CONFIG_LOCKDEP_PAGELOCK from page to page_ext
  lockdep: Crossrelease feature documentation

 Documentation/locking/crossrelease.txt | 874 +++++++++++++++++++++++++++++++++
 include/linux/completion.h             | 118 ++++-
 include/linux/irqflags.h               |  24 +-
 include/linux/lockdep.h                | 150 +++++-
 include/linux/mm_types.h               |   4 +
 include/linux/page-flags.h             |  43 +-
 include/linux/page_ext.h               |   4 +
 include/linux/pagemap.h                | 125 ++++-
 include/linux/sched.h                  |  11 +
 kernel/exit.c                          |   1 +
 kernel/fork.c                          |   4 +
 kernel/locking/lockdep.c               | 862 ++++++++++++++++++++++++++++----
 kernel/sched/completion.c              |  56 ++-
 kernel/workqueue.c                     |   2 +
 lib/Kconfig.debug                      |  29 ++
 mm/filemap.c                           |  73 ++-
 mm/page_ext.c                          |   4 +
 17 files changed, 2233 insertions(+), 151 deletions(-)
 create mode 100644 Documentation/locking/crossrelease.txt

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
