Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id EF2396B0388
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 04:26:08 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 190so282797880pgg.3
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 01:26:08 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id b85si14081185pfk.118.2017.03.14.01.26.06
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 01:26:07 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v6 00/15] lockdep: Implement crossrelease feature
Date: Tue, 14 Mar 2017 17:18:47 +0900
Message-ID: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

I checked if crossrelease feature works well on my qemu-i386 machine.
There's no problem at all to work on mine. But I wonder if it's still
true on other machines. Especially, on large system. Could you let me
know if it doesn't work on yours or if crossrelease feature is useful?

-----8<-----

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

Byungchul Park (15):
  lockdep: Refactor lookup_chain_cache()
  lockdep: Add a function building a chain between two classes
  lockdep: Change the meaning of check_prev_add()'s return value
  lockdep: Make check_prev_add() able to handle external stack_trace
  lockdep: Implement crossrelease feature
  lockdep: Handle non(or multi)-acquisition of a crosslock
  lockdep: Avoid adding redundant direct links of crosslocks
  lockdep: Fix incorrect condition to print bug msgs for
    MAX_LOCKDEP_CHAIN_HLOCKS
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
 include/linux/lockdep.h                | 147 +++++-
 include/linux/mm_types.h               |   4 +
 include/linux/page-flags.h             |  43 +-
 include/linux/page_ext.h               |   4 +
 include/linux/pagemap.h                | 125 ++++-
 include/linux/sched.h                  |   8 +
 kernel/exit.c                          |   1 +
 kernel/fork.c                          |   3 +
 kernel/locking/lockdep.c               | 789 +++++++++++++++++++++++++----
 kernel/sched/completion.c              |  54 +-
 kernel/workqueue.c                     |   1 +
 lib/Kconfig.debug                      |  29 ++
 mm/filemap.c                           |  73 ++-
 mm/page_ext.c                          |   4 +
 17 files changed, 2149 insertions(+), 152 deletions(-)
 create mode 100644 Documentation/locking/crossrelease.txt

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
