Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A364F6B0047
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 15:07:19 -0500 (EST)
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n0GK8utN027861
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 20:08:58 GMT
Received: from acsmt355.oracle.com (acsmt355.oracle.com [141.146.40.155])
	by rgminet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n0GGKxkG032627
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 20:07:14 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] PAGECACHE: Record stack backtrace in lock_page()
Date: Fri, 16 Jan 2009 15:07:06 -0500
Message-ID: <20090116200706.23026.9243.stgit@ingres.1015granger.net>
In-Reply-To: <20090116193424.23026.45385.stgit@ingres.1015granger.net>
References: <20090116193424.23026.45385.stgit@ingres.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: chuck.lever@oracle.com
List-ID: <linux-mm.kvack.org>

To track down a dropped unlock_page() after a SIGKILL, record stack
backtrace of each page locker and unlocker.  Also record the pid of
the task awoken by unlock_page().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 drivers/char/sysrq.c     |    4 ++
 include/linux/mm_types.h |   14 ++++++++
 include/linux/pagemap.h  |   19 ++++++++++-
 include/linux/wait.h     |    2 +
 kernel/sched.c           |   24 +++++++++++++-
 kernel/wait.c            |    9 +++++
 mm/filemap.c             |   61 +++++++++++++++++++++++++++++++++---
 mm/hugetlb.c             |    1 +
 mm/page_alloc.c          |    4 ++
 mm/slub.c                |    5 +++
 mm/truncate.c            |   79 +++++++++++++++++++++++++++++++++++++++++++++-
 11 files changed, 214 insertions(+), 8 deletions(-)

diff --git a/drivers/char/sysrq.c b/drivers/char/sysrq.c
index 8fdfe9c..a439acc 100644
--- a/drivers/char/sysrq.c
+++ b/drivers/char/sysrq.c
@@ -251,9 +251,12 @@ static struct sysrq_key_op sysrq_showregs_op = {
 	.enable_mask	= SYSRQ_ENABLE_DUMP,
 };
 
+void show_locked_pages(void);
+
 static void sysrq_handle_showstate(int key, struct tty_struct *tty)
 {
 	show_state();
+	show_locked_pages();
 }
 static struct sysrq_key_op sysrq_showstate_op = {
 	.handler	= sysrq_handle_showstate,
@@ -265,6 +268,7 @@ static struct sysrq_key_op sysrq_showstate_op = {
 static void sysrq_handle_showstate_blocked(int key, struct tty_struct *tty)
 {
 	show_state_filter(TASK_UNINTERRUPTIBLE);
+	show_locked_pages();
 }
 static struct sysrq_key_op sysrq_showstate_blocked_op = {
 	.handler	= sysrq_handle_showstate_blocked,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index bf33413..d68122e 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -11,6 +11,7 @@
 #include <linux/rwsem.h>
 #include <linux/completion.h>
 #include <linux/cpumask.h>
+#include <linux/stacktrace.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -27,6 +28,8 @@ typedef atomic_long_t mm_counter_t;
 typedef unsigned long mm_counter_t;
 #endif /* NR_CPUS < CONFIG_SPLIT_PTLOCK_CPUS */
 
+#define PAGE_STACKTRACE_SIZE	(12UL)
+
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -95,6 +98,17 @@ struct page {
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 	unsigned long page_cgroup;
 #endif
+
+	/* XXX: DEBUGGING */
+	struct list_head bt_list;
+
+	struct stack_trace lock_backtrace;
+	unsigned long lock_entries[PAGE_STACKTRACE_SIZE];
+
+	struct stack_trace unlock_backtrace;
+	unsigned long unlock_entries[PAGE_STACKTRACE_SIZE];
+
+	unsigned int woken_task;
 };
 
 /*
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 5da31c1..d9548d5 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -266,26 +266,43 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 	return pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 }
 
+extern void __init_page_lock_backtrace(struct page *page);
+extern void __save_page_lock_backtrace(struct page *page);
+extern void __save_page_unlock_backtrace(struct page *page);
+
 extern void __lock_page(struct page *page);
 extern int __lock_page_killable(struct page *page);
 extern void __lock_page_nosync(struct page *page);
+extern void __lock_page_no_backtrace(struct page *page);
 extern void unlock_page(struct page *page);
 
 static inline void set_page_locked(struct page *page)
 {
 	set_bit(PG_locked, &page->flags);
+	__save_page_lock_backtrace(page);
 }
 
 static inline void clear_page_locked(struct page *page)
 {
+	__save_page_unlock_backtrace(page);
 	clear_bit(PG_locked, &page->flags);
 }
 
-static inline int trylock_page(struct page *page)
+static inline int __trylock_page(struct page *page)
 {
 	return !test_and_set_bit(PG_locked, &page->flags);
 }
 
+static inline int trylock_page(struct page *page)
+{
+	int ret;
+
+	ret = __trylock_page(page);
+	if (ret)
+		__save_page_lock_backtrace(page);
+	return ret;
+}
+
 /*
  * lock_page may only be called if we have the page's inode pinned.
  */
diff --git a/include/linux/wait.h b/include/linux/wait.h
index 0081147..c0d4f8a 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -142,9 +142,11 @@ static inline void __remove_wait_queue(wait_queue_head_t *head,
 }
 
 void __wake_up(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
+unsigned int __wake_up_cel(wait_queue_head_t *q, void *key);
 extern void __wake_up_locked(wait_queue_head_t *q, unsigned int mode);
 extern void __wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr);
 void __wake_up_bit(wait_queue_head_t *, void *, int);
+unsigned int __wake_up_bit_cel(wait_queue_head_t *, void *, int);
 int __wait_on_bit(wait_queue_head_t *, struct wait_bit_queue *, int (*)(void *), unsigned);
 int __wait_on_bit_lock(wait_queue_head_t *, struct wait_bit_queue *, int (*)(void *), unsigned);
 void wake_up_bit(void *, int);
diff --git a/kernel/sched.c b/kernel/sched.c
index ad1962d..ab3d0bc 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -4556,18 +4556,23 @@ EXPORT_SYMBOL(default_wake_function);
  * started to run but is not in state TASK_RUNNING. try_to_wake_up() returns
  * zero in this (rare) case, and we handle it by continuing to scan the queue.
  */
-static void __wake_up_common(wait_queue_head_t *q, unsigned int mode,
+static pid_t __wake_up_common(wait_queue_head_t *q, unsigned int mode,
 			     int nr_exclusive, int sync, void *key)
 {
 	wait_queue_t *curr, *next;
+	pid_t pid = 0;
 
 	list_for_each_entry_safe(curr, next, &q->task_list, task_list) {
 		unsigned flags = curr->flags;
+		struct task_struct *t = (struct task_struct *)curr->private;
 
+		if (t)
+			pid = t->pid;
 		if (curr->func(curr, mode, sync, key) &&
 				(flags & WQ_FLAG_EXCLUSIVE) && !--nr_exclusive)
 			break;
 	}
+	return pid;
 }
 
 /**
@@ -4588,6 +4593,23 @@ void __wake_up(wait_queue_head_t *q, unsigned int mode,
 }
 EXPORT_SYMBOL(__wake_up);
 
+/**
+ * __wake_up_cel - wake up first exclusive thread blocked on a waitqueue
+ * @q: the waitqueue
+ * @key: is directly passed to the wakeup function
+ */
+unsigned int __wake_up_cel(wait_queue_head_t *q, void *key)
+{
+	unsigned long flags;
+	unsigned int pid;
+
+	spin_lock_irqsave(&q->lock, flags);
+	pid = __wake_up_common(q, TASK_NORMAL, 1, 0, key);
+	spin_unlock_irqrestore(&q->lock, flags);
+	return pid;
+}
+EXPORT_SYMBOL(__wake_up_cel);
+
 /*
  * Same as __wake_up but called with the spinlock in wait_queue_head_t held.
  */
diff --git a/kernel/wait.c b/kernel/wait.c
index c275c56..0580757 100644
--- a/kernel/wait.c
+++ b/kernel/wait.c
@@ -219,6 +219,15 @@ void __wake_up_bit(wait_queue_head_t *wq, void *word, int bit)
 }
 EXPORT_SYMBOL(__wake_up_bit);
 
+unsigned int __wake_up_bit_cel(wait_queue_head_t *wq, void *word, int bit)
+{
+	struct wait_bit_key key = __WAIT_BIT_KEY_INITIALIZER(word, bit);
+	if (waitqueue_active(wq))
+		return __wake_up_cel(wq, &key);
+	return 0;
+}
+EXPORT_SYMBOL(__wake_up_bit_cel);
+
 /**
  * wake_up_bit - wake up a waiter on a bit
  * @word: the word being waited on, a kernel virtual address
diff --git a/mm/filemap.c b/mm/filemap.c
index 876bc59..015a90b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -107,6 +107,41 @@
  */
 
 /*
+ * Debugging fields protected by the page lock
+ */
+void __init_page_lock_backtrace(struct page *page)
+{
+	INIT_LIST_HEAD(&page->bt_list);
+	page->lock_backtrace.nr_entries = 0;
+	page->unlock_backtrace.nr_entries = 0;
+}
+EXPORT_SYMBOL(__init_page_lock_backtrace);
+
+void __save_page_lock_backtrace(struct page *page)
+{
+	page->lock_backtrace.nr_entries = 0;
+	page->lock_backtrace.max_entries = PAGE_STACKTRACE_SIZE;
+	page->lock_backtrace.entries = page->lock_entries;
+	page->lock_backtrace.skip = 2;
+
+	save_stack_trace(&page->lock_backtrace);
+	page->lock_backtrace.nr_entries--;
+}
+EXPORT_SYMBOL(__save_page_lock_backtrace);
+
+void __save_page_unlock_backtrace(struct page *page)
+{
+	page->unlock_backtrace.nr_entries = 0;
+	page->unlock_backtrace.max_entries = PAGE_STACKTRACE_SIZE;
+	page->unlock_backtrace.entries = page->unlock_entries;
+	page->unlock_backtrace.skip = 2;
+
+	save_stack_trace(&page->unlock_backtrace);
+	page->unlock_backtrace.nr_entries--;
+}
+EXPORT_SYMBOL(__save_page_unlock_backtrace);
+
+/*
  * Remove a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
  * is safe.  The caller must hold the mapping's tree_lock.
@@ -564,11 +599,13 @@ EXPORT_SYMBOL(wait_on_page_bit);
  */
 void unlock_page(struct page *page)
 {
+	__save_page_unlock_backtrace(page);
 	smp_mb__before_clear_bit();
 	if (!test_and_clear_bit(PG_locked, &page->flags))
 		BUG();
 	smp_mb__after_clear_bit(); 
-	wake_up_page(page, PG_locked);
+	page->woken_task = __wake_up_bit_cel(page_waitqueue(page),
+						&page->flags, PG_locked);
 }
 EXPORT_SYMBOL(unlock_page);
 
@@ -601,18 +638,30 @@ EXPORT_SYMBOL(end_page_writeback);
 void __lock_page(struct page *page)
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
-
 	__wait_on_bit_lock(page_waitqueue(page), &wait, sync_page,
 							TASK_UNINTERRUPTIBLE);
+	__save_page_lock_backtrace(page);
 }
 EXPORT_SYMBOL(__lock_page);
 
+void __lock_page_no_backtrace(struct page *page)
+{
+	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+	__wait_on_bit_lock(page_waitqueue(page), &wait, sync_page,
+							TASK_UNINTERRUPTIBLE);
+}
+EXPORT_SYMBOL(__lock_page_no_backtrace);
+
 int __lock_page_killable(struct page *page)
 {
+	int ret;
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
-	return __wait_on_bit_lock(page_waitqueue(page), &wait,
+	ret = __wait_on_bit_lock(page_waitqueue(page), &wait,
 					sync_page_killable, TASK_KILLABLE);
+	if (ret == 0)
+		__save_page_lock_backtrace(page);
+	return ret;
 }
 
 /**
@@ -627,6 +676,7 @@ void __lock_page_nosync(struct page *page)
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 	__wait_on_bit_lock(page_waitqueue(page), &wait, __sleep_on_page_lock,
 							TASK_UNINTERRUPTIBLE);
+	__save_page_lock_backtrace(page);
 }
 
 /**
@@ -982,8 +1032,9 @@ static void shrink_readahead_size_eio(struct file *filp,
  * This is really ugly. But the goto's actually try to clarify some
  * of the logic when it comes to error handling etc.
  */
-static void do_generic_file_read(struct file *filp, loff_t *ppos,
-		read_descriptor_t *desc, read_actor_t actor)
+static noinline void do_generic_file_read(struct file *filp, loff_t *ppos,
+					  read_descriptor_t *desc,
+					  read_actor_t actor)
 {
 	struct address_space *mapping = filp->f_mapping;
 	struct inode *inode = mapping->host;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 67a7119..1732317 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -458,6 +458,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 	h->nr_huge_pages--;
 	h->nr_huge_pages_node[page_to_nid(page)]--;
 	for (i = 0; i < pages_per_huge_page(h); i++) {
+		__save_page_unlock_backtrace(&page[i]);
 		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
 				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
 				1 << PG_private | 1<< PG_writeback);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 27b8681..48cf7cc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -462,6 +462,8 @@ static inline int free_pages_check(struct page *page)
 		bad_page(page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
+	BUG_ON(PageLocked(page));
+
 	/*
 	 * For now, we report if PG_reserved was found set, but do not
 	 * clear it, and do not free the page.  But we shall soon need
@@ -627,6 +629,8 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 	if (order && (gfp_flags & __GFP_COMP))
 		prep_compound_page(page, order);
 
+	__init_page_lock_backtrace(page);
+
 	return 0;
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index 0c83e6a..eb7fa4f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1205,10 +1205,12 @@ static void discard_slab(struct kmem_cache *s, struct page *page)
 static __always_inline void slab_lock(struct page *page)
 {
 	bit_spin_lock(PG_locked, &page->flags);
+	__save_page_lock_backtrace(page);
 }
 
 static __always_inline void slab_unlock(struct page *page)
 {
+	__save_page_unlock_backtrace(page);
 	__bit_spin_unlock(PG_locked, &page->flags);
 }
 
@@ -1217,6 +1219,9 @@ static __always_inline int slab_trylock(struct page *page)
 	int rc = 1;
 
 	rc = bit_spin_trylock(PG_locked, &page->flags);
+	if (rc)
+		__save_page_lock_backtrace(page);
+
 	return rc;
 }
 
diff --git a/mm/truncate.c b/mm/truncate.c
index 6650c1d..4b348a7 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -9,6 +9,8 @@
 
 #include <linux/kernel.h>
 #include <linux/backing-dev.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
 #include <linux/mm.h>
 #include <linux/swap.h>
 #include <linux/module.h>
@@ -371,6 +373,80 @@ static int do_launder_page(struct address_space *mapping, struct page *page)
 	return mapping->a_ops->launder_page(page);
 }
 
+static DEFINE_MUTEX(iip2r_mutex);
+static LIST_HEAD(iip2r_waiters);
+
+static void show_one_locked_page(struct list_head *pos)
+{
+	struct page *page = list_entry(pos, struct page, bt_list);
+
+	printk(KERN_ERR "  index: %lu\n", page->index);
+	printk(KERN_ERR "  current flags: 0x%lx\n", page->flags);
+
+	if (page->lock_backtrace.nr_entries) {
+		printk(KERN_ERR "  backtrace of last locker:\n");
+		print_stack_trace(&page->lock_backtrace, 5);
+	}
+
+	if (page->unlock_backtrace.nr_entries) {
+		printk(KERN_ERR "  woken task: %u\n", page->woken_task);
+		printk(KERN_ERR "  backtrace of last unlocker:\n");
+		print_stack_trace(&page->unlock_backtrace, 5);
+	}
+
+	printk(KERN_ERR "\n");
+}
+
+/**
+ * show_locked_pages - Show backtraces for pages in iip2r_waiters
+ *
+ * Invoked via sysRq-T or sysRq-W.
+ *
+ */
+void show_locked_pages(void)
+{
+	struct list_head *pos;
+
+	mutex_lock(&iip2r_mutex);
+
+	if (!list_empty(&iip2r_waiters)) {
+		printk(KERN_ERR "pages waiting in "
+					"invalidate_inode_pages2_range:\n");
+
+		list_for_each(pos, &iip2r_waiters)
+			show_one_locked_page(pos);
+	} else
+		printk(KERN_ERR "no pages waiting in "
+					"invalidate_inode_pages2_range\n");
+
+	mutex_unlock(&iip2r_mutex);
+}
+EXPORT_SYMBOL(show_locked_pages);
+
+/*
+ * If we can't get the page lock immediately, queue the page on our
+ * "waiting pages" list, and dive into the lock_page slow path.
+ * As soon as it returns, unqueue the page.
+ *
+ * Short-term waiters will pop on and off the queue quickly, but
+ * any long-term waiters will sit on the queue and show up in
+ * show_locked_pages().
+ */
+static void iip2r_lock_page(struct page *page)
+{
+	if (!__trylock_page(page)) {
+		mutex_lock(&iip2r_mutex);
+		list_add(&page->bt_list, &iip2r_waiters);
+		mutex_unlock(&iip2r_mutex);
+
+		__lock_page_no_backtrace(page);
+
+		mutex_lock(&iip2r_mutex);
+		list_del_init(&page->bt_list);
+		mutex_unlock(&iip2r_mutex);
+	}
+}
+
 /**
  * invalidate_inode_pages2_range - remove range of pages from an address_space
  * @mapping: the address_space
@@ -402,7 +478,8 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 			struct page *page = pvec.pages[i];
 			pgoff_t page_index;
 
-			lock_page(page);
+			iip2r_lock_page(page);
+
 			if (page->mapping != mapping) {
 				unlock_page(page);
 				continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
