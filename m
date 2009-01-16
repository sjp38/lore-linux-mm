Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 576736B0055
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 15:07:26 -0500 (EST)
Received: from acsinet13.oracle.com (acsinet13.oracle.com [141.146.126.235])
	by rgminet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n0GK88El006702
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 20:08:10 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by acsinet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n0GFEdrH022714
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 20:07:59 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] PAGECACHE: Page lock tracing clean up
Date: Fri, 16 Jan 2009 15:07:13 -0500
Message-ID: <20090116200713.23026.80924.stgit@ingres.1015granger.net>
In-Reply-To: <20090116193424.23026.45385.stgit@ingres.1015granger.net>
References: <20090116193424.23026.45385.stgit@ingres.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: chuck.lever@oracle.com
List-ID: <linux-mm.kvack.org>

Clean up page lock back tracing instrumentation, and introduce some
additional features: count locks and unlocks, and capture a timestamp
for each stack trace so we can tell which order the
lock_page/unlock_page occurred.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/mm_types.h |   19 +++++--
 include/linux/pagemap.h  |   16 +++---
 kernel/sched.c           |    4 +
 mm/filemap.c             |  123 ++++++++++++++++++++++++++++++++++++----------
 mm/hugetlb.c             |    2 -
 mm/page_alloc.c          |    2 -
 mm/slub.c                |    6 +-
 mm/truncate.c            |   39 ++++-----------
 8 files changed, 137 insertions(+), 74 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d68122e..548eb0f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -12,6 +12,8 @@
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/stacktrace.h>
+#include <linux/hrtimer.h>
+
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -30,6 +32,12 @@ typedef unsigned long mm_counter_t;
 
 #define PAGE_STACKTRACE_SIZE	(12UL)
 
+struct page_trace {
+	ktime_t timestamp;
+	struct stack_trace stacktrace;
+	unsigned long entries[PAGE_STACKTRACE_SIZE];
+};
+
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -100,15 +108,14 @@ struct page {
 #endif
 
 	/* XXX: DEBUGGING */
-	struct list_head bt_list;
 
-	struct stack_trace lock_backtrace;
-	unsigned long lock_entries[PAGE_STACKTRACE_SIZE];
+	struct list_head iip2r_list;	/* how we find stuck pages */
 
-	struct stack_trace unlock_backtrace;
-	unsigned long unlock_entries[PAGE_STACKTRACE_SIZE];
+	struct page_trace lock_trace;
+	struct page_trace unlock_trace;
+	struct page_trace debug_trace;
 
-	unsigned int woken_task;
+	unsigned int woken_task, waiters, locks, unlocks;
 };
 
 /*
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index d9548d5..bea9657 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -266,25 +266,27 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 	return pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 }
 
-extern void __init_page_lock_backtrace(struct page *page);
-extern void __save_page_lock_backtrace(struct page *page);
-extern void __save_page_unlock_backtrace(struct page *page);
+extern void init_page_lock_stacktrace(struct page *page);
+extern void save_page_lock_stacktrace(struct page *page);
+extern void save_page_unlock_stacktrace(struct page *page);
+extern void save_page_debug_stacktrace(struct page *page);
+extern void show_one_locked_page(struct page *page);
 
 extern void __lock_page(struct page *page);
 extern int __lock_page_killable(struct page *page);
 extern void __lock_page_nosync(struct page *page);
-extern void __lock_page_no_backtrace(struct page *page);
+extern void __lock_page_no_stacktrace(struct page *page);
 extern void unlock_page(struct page *page);
 
 static inline void set_page_locked(struct page *page)
 {
 	set_bit(PG_locked, &page->flags);
-	__save_page_lock_backtrace(page);
+	save_page_lock_stacktrace(page);
 }
 
 static inline void clear_page_locked(struct page *page)
 {
-	__save_page_unlock_backtrace(page);
+	save_page_unlock_stacktrace(page);
 	clear_bit(PG_locked, &page->flags);
 }
 
@@ -299,7 +301,7 @@ static inline int trylock_page(struct page *page)
 
 	ret = __trylock_page(page);
 	if (ret)
-		__save_page_lock_backtrace(page);
+		save_page_lock_stacktrace(page);
 	return ret;
 }
 
diff --git a/kernel/sched.c b/kernel/sched.c
index ab3d0bc..37a6a69 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -4601,12 +4601,12 @@ EXPORT_SYMBOL(__wake_up);
 unsigned int __wake_up_cel(wait_queue_head_t *q, void *key)
 {
 	unsigned long flags;
-	unsigned int pid;
+	pid_t pid;
 
 	spin_lock_irqsave(&q->lock, flags);
 	pid = __wake_up_common(q, TASK_NORMAL, 1, 0, key);
 	spin_unlock_irqrestore(&q->lock, flags);
-	return pid;
+	return (unsigned int)pid;
 }
 EXPORT_SYMBOL(__wake_up_cel);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 015a90b..30a1f73 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -33,6 +33,8 @@
 #include <linux/cpuset.h>
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
+#include <linux/hrtimer.h>
+
 #include "internal.h"
 
 /*
@@ -109,37 +111,99 @@
 /*
  * Debugging fields protected by the page lock
  */
-void __init_page_lock_backtrace(struct page *page)
+static void init_page_trace(struct page_trace *pt)
+{
+	pt->stacktrace.nr_entries = 0;
+	pt->stacktrace.max_entries = PAGE_STACKTRACE_SIZE;
+	pt->stacktrace.entries = pt->entries;
+	pt->stacktrace.skip = 2;
+}
+
+static void save_page_trace(struct page_trace *pt)
+{
+	pt->timestamp = ktime_get();
+
+	init_page_trace(pt);
+	save_stack_trace(&pt->stacktrace);
+	pt->stacktrace.nr_entries--;
+}
+
+static void print_trace_timestamp(struct page_trace *pt)
 {
-	INIT_LIST_HEAD(&page->bt_list);
-	page->lock_backtrace.nr_entries = 0;
-	page->unlock_backtrace.nr_entries = 0;
+	struct timespec ts = ktime_to_timespec(pt->timestamp);
+
+	printk(KERN_ERR "  trace timestamp: %ld sec, %ld nsec\n",
+		ts.tv_sec , ts.tv_nsec);
 }
-EXPORT_SYMBOL(__init_page_lock_backtrace);
 
-void __save_page_lock_backtrace(struct page *page)
+void init_page_lock_stacktrace(struct page *page)
 {
-	page->lock_backtrace.nr_entries = 0;
-	page->lock_backtrace.max_entries = PAGE_STACKTRACE_SIZE;
-	page->lock_backtrace.entries = page->lock_entries;
-	page->lock_backtrace.skip = 2;
+	INIT_LIST_HEAD(&page->iip2r_list);
 
-	save_stack_trace(&page->lock_backtrace);
-	page->lock_backtrace.nr_entries--;
+	init_page_trace(&page->lock_trace);
+	init_page_trace(&page->unlock_trace);
+	init_page_trace(&page->debug_trace);
+
+	page->woken_task = 0;
+	page->waiters = 0;
+	page->locks = 0;
+	page->unlocks = 0;
 }
-EXPORT_SYMBOL(__save_page_lock_backtrace);
+EXPORT_SYMBOL(init_page_lock_stacktrace);
 
-void __save_page_unlock_backtrace(struct page *page)
+void save_page_lock_stacktrace(struct page *page)
 {
-	page->unlock_backtrace.nr_entries = 0;
-	page->unlock_backtrace.max_entries = PAGE_STACKTRACE_SIZE;
-	page->unlock_backtrace.entries = page->unlock_entries;
-	page->unlock_backtrace.skip = 2;
+	save_page_trace(&page->lock_trace);
+	page->locks++;
+}
+EXPORT_SYMBOL(save_page_lock_stacktrace);
 
-	save_stack_trace(&page->unlock_backtrace);
-	page->unlock_backtrace.nr_entries--;
+void save_page_unlock_stacktrace(struct page *page)
+{
+	save_page_trace(&page->unlock_trace);
+	page->unlocks++;
 }
-EXPORT_SYMBOL(__save_page_unlock_backtrace);
+EXPORT_SYMBOL(save_page_unlock_stacktrace);
+
+void save_page_debug_stacktrace(struct page *page)
+{
+	save_page_trace(&page->debug_trace);
+}
+EXPORT_SYMBOL(save_page_debug_stacktrace);
+
+void show_one_locked_page(struct page *page)
+{
+	struct stack_trace *locker = &page->lock_trace.stacktrace;
+	struct stack_trace *unlocker = &page->unlock_trace.stacktrace;
+	struct stack_trace *stuck = &page->debug_trace.stacktrace;
+
+	printk(KERN_ERR "  index: %lu\n", page->index);
+	printk(KERN_ERR "  current flags: 0x%lx\n", page->flags);
+	printk(KERN_ERR "  lock_page() calls: %u unlock_page() calls(): %u\n",
+			page->locks, page->unlocks);
+
+	if (stuck->nr_entries) {
+		printk(KERN_ERR "  stack trace of stuck task:\n");
+		print_trace_timestamp(&page->debug_trace);
+		print_stack_trace(stuck, 5);
+	}
+
+	if (locker->nr_entries) {
+		printk(KERN_ERR "  stack trace of last locker:\n");
+		print_trace_timestamp(&page->lock_trace);
+		print_stack_trace(locker, 5);
+	}
+
+	if (unlocker->nr_entries) {
+		printk(KERN_ERR "  woken task: %u\n", page->woken_task);
+		printk(KERN_ERR "  stack trace of last unlocker:\n");
+		print_trace_timestamp(&page->unlock_trace);
+		print_stack_trace(unlocker, 5);
+	}
+
+	printk(KERN_ERR "\n");
+}
+EXPORT_SYMBOL(show_one_locked_page);
 
 /*
  * Remove a page from the page cache and free it. Caller has to make
@@ -599,7 +663,7 @@ EXPORT_SYMBOL(wait_on_page_bit);
  */
 void unlock_page(struct page *page)
 {
-	__save_page_unlock_backtrace(page);
+	save_page_unlock_stacktrace(page);
 	smp_mb__before_clear_bit();
 	if (!test_and_clear_bit(PG_locked, &page->flags))
 		BUG();
@@ -640,17 +704,18 @@ void __lock_page(struct page *page)
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 	__wait_on_bit_lock(page_waitqueue(page), &wait, sync_page,
 							TASK_UNINTERRUPTIBLE);
-	__save_page_lock_backtrace(page);
+	save_page_lock_stacktrace(page);
 }
 EXPORT_SYMBOL(__lock_page);
 
-void __lock_page_no_backtrace(struct page *page)
+void __lock_page_no_stacktrace(struct page *page)
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 	__wait_on_bit_lock(page_waitqueue(page), &wait, sync_page,
 							TASK_UNINTERRUPTIBLE);
+	page->locks++;
 }
-EXPORT_SYMBOL(__lock_page_no_backtrace);
+EXPORT_SYMBOL(__lock_page_no_stacktrace);
 
 int __lock_page_killable(struct page *page)
 {
@@ -660,7 +725,11 @@ int __lock_page_killable(struct page *page)
 	ret = __wait_on_bit_lock(page_waitqueue(page), &wait,
 					sync_page_killable, TASK_KILLABLE);
 	if (ret == 0)
-		__save_page_lock_backtrace(page);
+		save_page_lock_stacktrace(page);
+	else {
+		printk(KERN_ERR "lock_page_killable:\n");
+		show_one_locked_page(page);
+	}
 	return ret;
 }
 
@@ -676,7 +745,7 @@ void __lock_page_nosync(struct page *page)
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 	__wait_on_bit_lock(page_waitqueue(page), &wait, __sleep_on_page_lock,
 							TASK_UNINTERRUPTIBLE);
-	__save_page_lock_backtrace(page);
+	save_page_lock_stacktrace(page);
 }
 
 /**
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1732317..c706dd9 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -458,7 +458,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 	h->nr_huge_pages--;
 	h->nr_huge_pages_node[page_to_nid(page)]--;
 	for (i = 0; i < pages_per_huge_page(h); i++) {
-		__save_page_unlock_backtrace(&page[i]);
+		save_page_unlock_stacktrace(&page[i]);
 		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
 				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
 				1 << PG_private | 1<< PG_writeback);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 48cf7cc..2f97604 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -629,7 +629,7 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 	if (order && (gfp_flags & __GFP_COMP))
 		prep_compound_page(page, order);
 
-	__init_page_lock_backtrace(page);
+	init_page_lock_stacktrace(page);
 
 	return 0;
 }
diff --git a/mm/slub.c b/mm/slub.c
index eb7fa4f..d86f46a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1205,12 +1205,12 @@ static void discard_slab(struct kmem_cache *s, struct page *page)
 static __always_inline void slab_lock(struct page *page)
 {
 	bit_spin_lock(PG_locked, &page->flags);
-	__save_page_lock_backtrace(page);
+	save_page_lock_stacktrace(page);
 }
 
 static __always_inline void slab_unlock(struct page *page)
 {
-	__save_page_unlock_backtrace(page);
+	save_page_unlock_stacktrace(page);
 	__bit_spin_unlock(PG_locked, &page->flags);
 }
 
@@ -1220,7 +1220,7 @@ static __always_inline int slab_trylock(struct page *page)
 
 	rc = bit_spin_trylock(PG_locked, &page->flags);
 	if (rc)
-		__save_page_lock_backtrace(page);
+		save_page_lock_stacktrace(page);
 
 	return rc;
 }
diff --git a/mm/truncate.c b/mm/truncate.c
index 4b348a7..cfd2df2 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -376,29 +376,8 @@ static int do_launder_page(struct address_space *mapping, struct page *page)
 static DEFINE_MUTEX(iip2r_mutex);
 static LIST_HEAD(iip2r_waiters);
 
-static void show_one_locked_page(struct list_head *pos)
-{
-	struct page *page = list_entry(pos, struct page, bt_list);
-
-	printk(KERN_ERR "  index: %lu\n", page->index);
-	printk(KERN_ERR "  current flags: 0x%lx\n", page->flags);
-
-	if (page->lock_backtrace.nr_entries) {
-		printk(KERN_ERR "  backtrace of last locker:\n");
-		print_stack_trace(&page->lock_backtrace, 5);
-	}
-
-	if (page->unlock_backtrace.nr_entries) {
-		printk(KERN_ERR "  woken task: %u\n", page->woken_task);
-		printk(KERN_ERR "  backtrace of last unlocker:\n");
-		print_stack_trace(&page->unlock_backtrace, 5);
-	}
-
-	printk(KERN_ERR "\n");
-}
-
 /**
- * show_locked_pages - Show backtraces for pages in iip2r_waiters
+ * show_locked_pages - Show stack backtraces for pages in iip2r_waiters
  *
  * Invoked via sysRq-T or sysRq-W.
  *
@@ -413,8 +392,11 @@ void show_locked_pages(void)
 		printk(KERN_ERR "pages waiting in "
 					"invalidate_inode_pages2_range:\n");
 
-		list_for_each(pos, &iip2r_waiters)
-			show_one_locked_page(pos);
+		list_for_each(pos, &iip2r_waiters) {
+			struct page *page = list_entry(pos, struct page,
+								iip2r_list);
+			show_one_locked_page(page);
+		}
 	} else
 		printk(KERN_ERR "no pages waiting in "
 					"invalidate_inode_pages2_range\n");
@@ -436,13 +418,16 @@ static void iip2r_lock_page(struct page *page)
 {
 	if (!__trylock_page(page)) {
 		mutex_lock(&iip2r_mutex);
-		list_add(&page->bt_list, &iip2r_waiters);
+		list_add(&page->iip2r_list, &iip2r_waiters);
 		mutex_unlock(&iip2r_mutex);
 
-		__lock_page_no_backtrace(page);
+		/* debug stacktrace not protected by page lock, but
+		 * instead by caller's serialization */
+		save_page_debug_stacktrace(page);
+		__lock_page_no_stacktrace(page);
 
 		mutex_lock(&iip2r_mutex);
-		list_del_init(&page->bt_list);
+		list_del_init(&page->iip2r_list);
 		mutex_unlock(&iip2r_mutex);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
