Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC2D6B0033
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 00:16:48 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id k24so1817622pff.20
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 21:16:48 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y5si395527plr.811.2017.12.03.21.16.45
        for <linux-mm@kvack.org>;
        Sun, 03 Dec 2017 21:16:46 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v2 1/4] lockdep: Apply crossrelease to PG_locked locks
Date: Mon,  4 Dec 2017 14:16:20 +0900
Message-Id: <1512364583-26070-2-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1512364583-26070-1-git-send-email-byungchul.park@lge.com>
References: <1512364583-26070-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com, jack@suse.cz, jlayton@redhat.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, npiggin@gmail.com, rgoldwyn@suse.com, vbabka@suse.cz, mhocko@suse.com, pombredanne@nexb.com, vinmenon@codeaurora.org, gregkh@linuxfoundation.org

Although lock_page() and its family can cause deadlock, lockdep have not
worked with them, becasue unlock_page() might be called in a different
context from the acquire context, which violated lockdep's assumption.

Now CONFIG_LOCKDEP_CROSSRELEASE has been introduced, lockdep can work
with page locks.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/mm_types.h |   8 ++++
 include/linux/pagemap.h  | 101 ++++++++++++++++++++++++++++++++++++++++++++---
 lib/Kconfig.debug        |   7 ++++
 mm/filemap.c             |   4 +-
 mm/page_alloc.c          |   3 ++
 5 files changed, 115 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index c85f11d..263b861 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -17,6 +17,10 @@
 
 #include <asm/mmu.h>
 
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+#include <linux/lockdep.h>
+#endif
+
 #ifndef AT_VECTOR_SIZE_ARCH
 #define AT_VECTOR_SIZE_ARCH 0
 #endif
@@ -218,6 +222,10 @@ struct page {
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
index e08b533..35b4f67 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -15,6 +15,9 @@
 #include <linux/bitops.h>
 #include <linux/hardirq.h> /* for in_interrupt() */
 #include <linux/hugetlb_inline.h>
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+#include <linux/lockdep.h>
+#endif
 
 /*
  * Bits in mapping->flags.
@@ -457,26 +460,91 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
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
+	 * This way a crosslock and current lock can be ordered like:
+	 *
+	 *	CONTEXT 1		CONTEXT 2
+	 *	---------		---------
+	 *	lock A (cross)
+	 *	acquire A
+	 *	  X = atomic_inc_return(&cross_gen_id)
+	 *	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+	 *				acquire B
+	 *				  Y = atomic_read_acquire(&cross_gen_id)
+	 *				lock B
+	 *
+	 * so that 'lock A and then lock B' can be seen globally,
+	 * if X <= Y.
+	 */
+	lock_page_acquire(page, 0);
 }
 
 /*
@@ -486,9 +554,20 @@ static inline void lock_page(struct page *page)
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
+	 * This way a crosslock and other locks can be ordered.
+	 */
+	lock_page_acquire(page, 0);
 	return 0;
 }
 
@@ -503,7 +582,17 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
 				     unsigned int flags)
 {
 	might_sleep();
-	return trylock_page(page) || __lock_page_or_retry(page, mm, flags);
+
+	if (do_raw_trylock_page(page) || __lock_page_or_retry(page, mm, flags)) {
+		/*
+		 * acquire() must be after actual lock operation for crosslocks.
+		 * This way a crosslock and other locks can be ordered.
+		 */
+		lock_page_acquire(page, 0);
+		return 1;
+	}
+
+	return 0;
 }
 
 /*
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 2b439a5..2e8c679 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1094,6 +1094,7 @@ config PROVE_LOCKING
 	select DEBUG_LOCK_ALLOC
 	select LOCKDEP_CROSSRELEASE
 	select LOCKDEP_COMPLETIONS
+	select LOCKDEP_PAGELOCK
 	select TRACE_IRQFLAGS
 	default n
 	help
@@ -1179,6 +1180,12 @@ config LOCKDEP_COMPLETIONS
 	 A deadlock caused by wait_for_completion() and complete() can be
 	 detected by lockdep using crossrelease feature.
 
+config LOCKDEP_PAGELOCK
+	bool
+	help
+	 PG_locked lock is a kind of crosslock. Using crossrelease feature,
+	 PG_locked lock can work with lockdep.
+
 config BOOTPARAM_LOCKDEP_CROSSRELEASE_FULLSTACK
 	bool "Enable the boot parameter, crossrelease_fullstack"
 	depends on LOCKDEP_CROSSRELEASE
diff --git a/mm/filemap.c b/mm/filemap.c
index 594d73f..870d442 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1099,7 +1099,7 @@ static inline bool clear_bit_unlock_is_negative_byte(long nr, volatile void *mem
  * portably (architectures that do LL/SC can test any bit, while x86 can
  * test the sign bit).
  */
-void unlock_page(struct page *page)
+void do_raw_unlock_page(struct page *page)
 {
 	BUILD_BUG_ON(PG_waiters != 7);
 	page = compound_head(page);
@@ -1107,7 +1107,7 @@ void unlock_page(struct page *page)
 	if (clear_bit_unlock_is_negative_byte(PG_locked, &page->flags))
 		wake_up_page_bit(page, PG_locked);
 }
-EXPORT_SYMBOL(unlock_page);
+EXPORT_SYMBOL(do_raw_unlock_page);
 
 /**
  * end_page_writeback - end writeback against a page
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c..8436b28 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5371,6 +5371,9 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
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
