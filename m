Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E23CA6B0253
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:16:35 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e9so16839517pgc.5
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:16:35 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id y133si32062965pfb.72.2016.12.08.21.16.34
        for <linux-mm@kvack.org>;
        Thu, 08 Dec 2016 21:16:34 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 00/15] lockdep: Implement crossrelease feature
Date: Fri,  9 Dec 2016 14:11:56 +0900
Message-Id: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
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

I added output text of 'cat /proc/lockdep' on my machine applying
crossrelease feature, showing dependencies of lockdep. You can check
what kind of dependencies are added by crossrelease feature. Please
use '(complete)' or '(PG_locked)' as a keyword to find dependencies
added by this patch set.

And I still keep the base unchanged (v4.7). I will rebase it on the
latest once you have a consensus on it. Your opinions?

-----8<-----

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
	mutex_unlock A
			wait_for_complete B // DEADLOCK
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
  x86/dumpstack: Optimize save_stack_trace
  x86/dumpstack: Add save_stack_trace()_fast()
  lockdep: Refactor lookup_chain_cache()
  lockdep: Add a function building a chain between two classes
  lockdep: Make check_prev_add can use a separate stack_trace
  lockdep: Make save_trace can skip stack tracing of the current
  lockdep: Implement crossrelease feature
  lockdep: Make crossrelease use save_stack_trace_fast()
  lockdep: Make print_circular_bug() crosslock-aware
  lockdep: Apply crossrelease to completion operation
  pagemap.h: Remove trailing white space
  lockdep: Apply crossrelease to PG_locked lock
  lockdep: Apply lock_acquire(release) on __Set(__Clear)PageLocked
  lockdep: Move data used in CONFIG_LOCKDEP_PAGELOCK from page to
    page_ext
  lockdep: Crossrelease feature documentation

 Documentation/locking/crossrelease.txt | 1053 ++++++++++++++++++++++++++++++++
 arch/x86/include/asm/stacktrace.h      |    1 +
 arch/x86/kernel/dumpstack.c            |    4 +
 arch/x86/kernel/dumpstack_32.c         |    2 +
 arch/x86/kernel/stacktrace.c           |   32 +
 include/linux/completion.h             |  121 +++-
 include/linux/irqflags.h               |   12 +-
 include/linux/lockdep.h                |  122 ++++
 include/linux/mm_types.h               |    4 +
 include/linux/page-flags.h             |   43 +-
 include/linux/page_ext.h               |    5 +
 include/linux/pagemap.h                |  124 +++-
 include/linux/sched.h                  |    5 +
 include/linux/stacktrace.h             |    2 +
 kernel/exit.c                          |    9 +
 kernel/fork.c                          |   20 +
 kernel/locking/lockdep.c               |  804 +++++++++++++++++++++---
 kernel/sched/completion.c              |   54 +-
 lib/Kconfig.debug                      |   30 +
 mm/filemap.c                           |   76 ++-
 mm/page_ext.c                          |    4 +
 21 files changed, 2392 insertions(+), 135 deletions(-)
 create mode 100644 Documentation/locking/crossrelease.txt

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
