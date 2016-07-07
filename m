Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA9E96B0260
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:31:57 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u81so21284280oia.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:31:57 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id d129si206256itc.63.2016.07.07.02.31.51
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 02:31:52 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [RFC v2 08/13] lockdep: Apply crossrelease to PG_locked lock
Date: Thu,  7 Jul 2016 18:29:58 +0900
Message-Id: <1467883803-29132-9-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
References: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, npiggin@kernel.dk, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org

lock_page() and its family can cause deadlock. Nevertheless, it cannot
use the lock correctness validator becasue unlock_page() can be called
in different context from the context calling lock_page(), which
violates original lockdep's assumption.

However, thanks to CONFIG_LOCKDEP_CROSSRELEASE, we can apply the lockdep
detector to lock_page() using PG_locked. Applied it.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/mm_types.h |  9 +++++
 include/linux/pagemap.h  | 95 +++++++++++++++++++++++++++++++++++++++++++++---
 lib/Kconfig.debug        |  9 +++++
 mm/filemap.c             |  4 +-
 mm/page_alloc.c          |  3 ++
 5 files changed, 112 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 624b78b..ab33ee3 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -15,6 +15,10 @@
 #include <asm/page.h>
 #include <asm/mmu.h>
 
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+#include <linux/lockdep.h>
+#endif
+
 #ifndef AT_VECTOR_SIZE_ARCH
 #define AT_VECTOR_SIZE_ARCH 0
 #endif
@@ -215,6 +219,11 @@ struct page {
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	int _last_cpupid;
 #endif
+
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+	struct lockdep_map map;
+	struct cross_lock xlock;
+#endif
 }
 /*
  * The struct page can be forced to be double word aligned so that atomic ops
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index c0049d9..2fc4af1 100644
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
  * Bits in mapping->flags.  The lower __GFP_BITS_SHIFT bits are the page
@@ -441,26 +444,81 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 	return pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 }
 
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+#define lock_page_init(p)					\
+do {								\
+	static struct lock_class_key __key;			\
+	lockdep_init_map_crosslock(&(p)->map, &(p)->xlock,	\
+			"(PG_locked)" #p, &__key, 0);		\
+} while (0)
+
+static inline void lock_page_acquire(struct page *page, int try)
+{
+	page = compound_head(page);
+	lock_acquire_exclusive(&page->map, 0, try, NULL, _RET_IP_);
+}
+
+static inline void lock_page_release(struct page *page)
+{
+	page = compound_head(page);
+	/*
+	 * Calling lock_commit_crosslock() is necessary
+	 * for cross-releasable lock when the lock is
+	 * releasing before calling lock_release().
+	 */
+	lock_commit_crosslock(&page->map);
+	lock_release(&page->map, 0, _RET_IP_);
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
+	 * The acquire function must be after actual lock operation
+	 * for crossrelease lock, because the lock instance is
+	 * searched by release operation in any context and more
+	 * than two instances acquired make it confused.
+	 */
+	lock_page_acquire(page, 0);
 }
 
 /*
@@ -470,9 +528,22 @@ static inline void lock_page(struct page *page)
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
+	 * The acquire function must be after actual lock operation
+	 * for crossrelease lock, because the lock instance is
+	 * searched by release operation in any context and more
+	 * than two instances acquired make it confused.
+	 */
+	lock_page_acquire(page, 0);
 	return 0;
 }
 
@@ -487,7 +558,19 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
 				     unsigned int flags)
 {
 	might_sleep();
-	return trylock_page(page) || __lock_page_or_retry(page, mm, flags);
+
+	if (do_raw_trylock_page(page) || __lock_page_or_retry(page, mm, flags)) {
+		/*
+		 * The acquire function must be after actual lock operation
+		 * for crossrelease lock, because the lock instance is
+		 * searched by release operation in any context and more
+		 * than two instances acquired make it confused.
+		 */
+		lock_page_acquire(page, 0);
+		return 1;
+	}
+
+	return 0;
 }
 
 /*
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index b5946c7..ee7faca 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1014,6 +1014,15 @@ config LOCKDEP_COMPLETE
 	 A deadlock caused by wait and complete can be detected by lockdep
 	 using crossrelease feature.
 
+config LOCKDEP_PAGELOCK
+	bool "Lock debugging: allow PG_locked lock to use deadlock detector"
+	select LOCKDEP_CROSSRELEASE
+	default n
+	help
+	 PG_locked lock is a kind of cross-released lock. This makes
+	 PG_locked lock possible to use deadlock detector, using
+	 crossrelease feature.
+
 config PROVE_LOCKING
 	bool "Lock debugging: prove locking correctness"
 	depends on DEBUG_KERNEL && TRACE_IRQFLAGS_SUPPORT && STACKTRACE_SUPPORT && LOCKDEP_SUPPORT
diff --git a/mm/filemap.c b/mm/filemap.c
index 3461d97..47fc5c0 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -814,7 +814,7 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
  * The mb is necessary to enforce ordering between the clear_bit and the read
  * of the waitqueue (to avoid SMP races with a parallel wait_on_page_locked()).
  */
-void unlock_page(struct page *page)
+void do_raw_unlock_page(struct page *page)
 {
 	page = compound_head(page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
@@ -822,7 +822,7 @@ void unlock_page(struct page *page)
 	smp_mb__after_atomic();
 	wake_up_page(page, PG_locked);
 }
-EXPORT_SYMBOL(unlock_page);
+EXPORT_SYMBOL(do_raw_unlock_page);
 
 /**
  * end_page_writeback - end writeback against a page
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 838ca8bb..17ed9a8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4538,6 +4538,9 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
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
