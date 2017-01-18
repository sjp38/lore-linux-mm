Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C73C66B026F
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:17:57 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d134so16775419pfd.0
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:17:57 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id h9si234194pli.37.2017.01.18.05.17.55
        for <linux-mm@kvack.org>;
        Wed, 18 Jan 2017 05:17:56 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v5 10/13] lockdep: Apply crossrelease to PG_locked locks
Date: Wed, 18 Jan 2017 22:17:36 +0900
Message-Id: <1484745459-2055-11-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

lock_page() and its family can cause deadlock. Nevertheless, it could
not use the lock correctness validator until now, becasue unlock_page()
might be called in a different context from the acquisition context,
which, we believed, violates lockdep's assumption. But it's not true.

Thanks to CONFIG_LOCKDEP_CROSSRELEASE, we can now apply the lockdep
detector to page locks. Applied it.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/mm_types.h |   8 ++++
 include/linux/pagemap.h  | 100 ++++++++++++++++++++++++++++++++++++++++++++---
 lib/Kconfig.debug        |   8 ++++
 mm/filemap.c             |   4 +-
 mm/page_alloc.c          |   3 ++
 5 files changed, 115 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 4a8aced..06adfa2 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -16,6 +16,10 @@
 #include <asm/page.h>
 #include <asm/mmu.h>
 
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+#include <linux/lockdep.h>
+#endif
+
 #ifndef AT_VECTOR_SIZE_ARCH
 #define AT_VECTOR_SIZE_ARCH 0
 #endif
@@ -221,6 +225,10 @@ struct page {
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	int _last_cpupid;
 #endif
+
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+	struct lockdep_map_cross map;
+#endif
 }
 /*
  * The struct page can be forced to be double word aligned so that atomic ops
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index a8ee59a..a3ecec1 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -14,6 +14,9 @@
 #include <linux/bitops.h>
 #include <linux/hardirq.h> /* for in_interrupt() */
 #include <linux/hugetlb_inline.h>
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+#include <linux/lockdep.h>
+#endif
 
 /*
  * Bits in mapping->flags.
@@ -432,26 +435,90 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 	return pgoff;
 }
 
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+#define lock_page_init(p)						\
+do {									\
+	static struct lock_class_key __key;				\
+	lockdep_init_map_crosslock((struct lockdep_map *)&(p)->map,	\
+			"(PG_locked)" #p, &__key, 0);			\
+} while (0)
+
+static inline void lock_page_acquire(struct page *page, int try)
+{
+	page = compound_head(page);
+	lock_acquire_exclusive((struct lockdep_map *)&page->map, 0,
+			       try, NULL, _RET_IP_);
+}
+
+static inline void lock_page_release(struct page *page)
+{
+	page = compound_head(page);
+	/*
+	 * lock_commit_crosslock() is necessary for crosslocks.
+	 */
+	lock_commit_crosslock((struct lockdep_map *)&page->map);
+	lock_release((struct lockdep_map *)&page->map, 0, _RET_IP_);
+}
+#else
+static inline void lock_page_init(struct page *page) {}
+static inline void lock_page_free(struct page *page) {}
+static inline void lock_page_acquire(struct page *page, int try) {}
+static inline void lock_page_release(struct page *page) {}
+#endif
+
 extern void __lock_page(struct page *page);
 extern int __lock_page_killable(struct page *page);
 extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 				unsigned int flags);
-extern void unlock_page(struct page *page);
+extern void do_raw_unlock_page(struct page *page);
 
-static inline int trylock_page(struct page *page)
+static inline void unlock_page(struct page *page)
+{
+	lock_page_release(page);
+	do_raw_unlock_page(page);
+}
+
+static inline int do_raw_trylock_page(struct page *page)
 {
 	page = compound_head(page);
 	return (likely(!test_and_set_bit_lock(PG_locked, &page->flags)));
 }
 
+static inline int trylock_page(struct page *page)
+{
+	if (do_raw_trylock_page(page)) {
+		lock_page_acquire(page, 1);
+		return 1;
+	}
+	return 0;
+}
+
 /*
  * lock_page may only be called if we have the page's inode pinned.
  */
 static inline void lock_page(struct page *page)
 {
 	might_sleep();
-	if (!trylock_page(page))
+
+	if (!do_raw_trylock_page(page))
 		__lock_page(page);
+	/*
+	 * acquire() must be after actual lock operation for crosslocks.
+	 * This way a crosslock and other locks can be serialized like:
+	 *
+	 *	CONTEXT 1		CONTEXT 2
+	 *	---------		---------
+	 *	lock A (cross)
+	 *	acquire A
+	 *	  atomic_inc_return()
+	 *	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ serialize
+	 *				acquire B
+	 *				  atomic_read_acquire()
+	 *				lock B
+	 *
+	 * so that 'A -> B' can be seen globally.
+	 */
+	lock_page_acquire(page, 0);
 }
 
 /*
@@ -461,9 +528,20 @@ static inline void lock_page(struct page *page)
  */
 static inline int lock_page_killable(struct page *page)
 {
+	int ret;
+
 	might_sleep();
-	if (!trylock_page(page))
-		return __lock_page_killable(page);
+
+	if (!do_raw_trylock_page(page)) {
+		ret = __lock_page_killable(page);
+		if (ret)
+			return ret;
+	}
+	/*
+	 * acquire() must be after actual lock operation for crosslocks.
+	 * This way a crosslock and other locks can be serialized.
+	 */
+	lock_page_acquire(page, 0);
 	return 0;
 }
 
@@ -478,7 +556,17 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
 				     unsigned int flags)
 {
 	might_sleep();
-	return trylock_page(page) || __lock_page_or_retry(page, mm, flags);
+
+	if (do_raw_trylock_page(page) || __lock_page_or_retry(page, mm, flags)) {
+		/*
+		 * acquire() must be after actual lock operation for crosslocks.
+		 * This way a crosslock and other locks can be serialized.
+		 */
+		lock_page_acquire(page, 0);
+		return 1;
+	}
+
+	return 0;
 }
 
 /*
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index ad172b5..69364d0 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1063,6 +1063,14 @@ config LOCKDEP_COMPLETE
 	 A deadlock caused by wait_for_completion() and complete() can be
 	 detected by lockdep using crossrelease feature.
 
+config LOCKDEP_PAGELOCK
+	bool "Lock debugging: allow PG_locked lock to use deadlock detector"
+	select LOCKDEP_CROSSRELEASE
+	default n
+	help
+	 PG_locked lock is a kind of crosslock. Using crossrelease feature,
+	 PG_locked lock can work with runtime deadlock detector, lockdep.
+
 config PROVE_LOCKING
 	bool "Lock debugging: prove locking correctness"
 	depends on DEBUG_KERNEL && TRACE_IRQFLAGS_SUPPORT && STACKTRACE_SUPPORT && LOCKDEP_SUPPORT
diff --git a/mm/filemap.c b/mm/filemap.c
index 50b52fe..d439cc7 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -858,7 +858,7 @@ void add_page_wait_queue(struct page *page, wait_queue_t *waiter)
  * The mb is necessary to enforce ordering between the clear_bit and the read
  * of the waitqueue (to avoid SMP races with a parallel wait_on_page_locked()).
  */
-void unlock_page(struct page *page)
+void do_raw_unlock_page(struct page *page)
 {
 	page = compound_head(page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
@@ -866,7 +866,7 @@ void unlock_page(struct page *page)
 	smp_mb__after_atomic();
 	wake_up_page(page, PG_locked);
 }
-EXPORT_SYMBOL(unlock_page);
+EXPORT_SYMBOL(do_raw_unlock_page);
 
 /**
  * end_page_writeback - end writeback against a page
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440..36d5f9e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5063,6 +5063,9 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		} else {
 			__init_single_pfn(pfn, zone, nid);
 		}
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+		lock_page_init(pfn_to_page(pfn));
+#endif
 	}
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
