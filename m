Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id C38376B025C
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:05:35 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so145396663wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:05:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dm8si30293352wjb.19.2015.09.21.06.05.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:05:33 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC v2 09/18] mm/huge_page: Convert khugepaged() into kthread worker API
Date: Mon, 21 Sep 2015 15:03:50 +0200
Message-Id: <1442840639-6963-10-git-send-email-pmladek@suse.com>
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

Kthreads are currently implemented as an infinite loop. Each
has its own variant of checks for terminating, freezing,
awakening. In many cases it is unclear to say in which state
it is and sometimes it is done a wrong way.

The plan is to convert kthreads into kthread_worker or workqueues
API. It allows to split the functionality into separate operations.
It helps to make a better structure. Also it defines a clean state
where no locks are taken, IRQs blocked, the kthread might sleep
or even be safely migrated.

The kthread worker API is useful when we want to have a dedicated
single thread for the work. It helps to make sure that it is
available when needed. Also it allows a better control, e.g.
define a scheduling priority.

This patch converts khugepaged() in kthread worker API
because it modifies the scheduling.

It keeps the functionality except that we do not wakeup the worker
when it is already created and someone calls start() once again.

The scan work is queued only when the list of scanned pages is
not empty. They delay between scans is done using delayed work.

Note that @khugepaged_wait waitqueue had two purposes. It was used
to wait between scans and when an allocation failed. It is still used
for the second purpose. Therefore it was renamed to better describe
the current use.

Also note that we could not longer check for kthread_should_stop()
in the works. The kthread used by the worker has to stay alive
until all queued works are finished. Instead, we use the existing
check khugepaged_enabled() that returns false when we are going down.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 mm/huge_memory.c | 116 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 62 insertions(+), 54 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4b06b8db9df2..d5030fe7b687 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -57,10 +57,19 @@ static unsigned int khugepaged_full_scans;
 static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
 /* during fragmentation poll the hugepage allocator once every minute */
 static unsigned int khugepaged_alloc_sleep_millisecs __read_mostly = 60000;
-static struct task_struct *khugepaged_thread __read_mostly;
+
+static void khugepaged_init_func(struct kthread_work *dummy);
+static void khugepaged_do_scan_func(struct kthread_work *dummy);
+static void khugepaged_cleanup_func(struct kthread_work *dummy);
+static struct kthread_worker *khugepaged_worker;
+static DEFINE_KTHREAD_WORK(khugepaged_init_work, khugepaged_init_func);
+static DEFINE_DELAYED_KTHREAD_WORK(khugepaged_do_scan_work,
+				   khugepaged_do_scan_func);
+static DEFINE_KTHREAD_WORK(khugepaged_cleanup_work, khugepaged_cleanup_func);
+
 static DEFINE_MUTEX(khugepaged_mutex);
 static DEFINE_SPINLOCK(khugepaged_mm_lock);
-static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
+static DECLARE_WAIT_QUEUE_HEAD(khugepaged_alloc_wait);
 /*
  * default collapse hugepages if there is at least one pte mapped like
  * it would have happened if the vma was large enough during page
@@ -68,7 +77,6 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
  */
 static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
 
-static int khugepaged(void *none);
 static int khugepaged_slab_init(void);
 static void khugepaged_slab_exit(void);
 
@@ -144,29 +152,43 @@ static void set_recommended_min_free_kbytes(void)
 	setup_per_zone_wmarks();
 }
 
+static int khugepaged_has_work(void)
+{
+	return !list_empty(&khugepaged_scan.mm_head) &&
+		khugepaged_enabled();
+}
+
 static int start_stop_khugepaged(void)
 {
 	int err = 0;
 	if (khugepaged_enabled()) {
-		if (!khugepaged_thread)
-			khugepaged_thread = kthread_run(khugepaged, NULL,
-							"khugepaged");
-		if (unlikely(IS_ERR(khugepaged_thread))) {
-			pr_err("khugepaged: kthread_run(khugepaged) failed\n");
-			err = PTR_ERR(khugepaged_thread);
-			khugepaged_thread = NULL;
-			goto fail;
+		if (khugepaged_worker)
+			goto out;
+
+		khugepaged_worker = create_kthread_worker("khugepaged");
+
+		if (unlikely(IS_ERR(khugepaged_worker))) {
+			pr_err("khugepaged: failed to create kthread worker\n");
+			khugepaged_worker = NULL;
+			goto out;
 		}
 
+		queue_kthread_work(khugepaged_worker,
+				   &khugepaged_init_work);
+
 		if (!list_empty(&khugepaged_scan.mm_head))
-			wake_up_interruptible(&khugepaged_wait);
+			queue_delayed_kthread_work(khugepaged_worker,
+						   &khugepaged_do_scan_work,
+						   0);
 
 		set_recommended_min_free_kbytes();
-	} else if (khugepaged_thread) {
-		kthread_stop(khugepaged_thread);
-		khugepaged_thread = NULL;
+	} else if (khugepaged_worker) {
+		cancel_delayed_kthread_work_sync(&khugepaged_do_scan_work);
+		queue_kthread_work(khugepaged_worker, &khugepaged_cleanup_work);
+		destroy_kthread_worker(khugepaged_worker);
+		khugepaged_worker = NULL;
 	}
-fail:
+out:
 	return err;
 }
 
@@ -425,7 +447,10 @@ static ssize_t scan_sleep_millisecs_store(struct kobject *kobj,
 		return -EINVAL;
 
 	khugepaged_scan_sleep_millisecs = msecs;
-	wake_up_interruptible(&khugepaged_wait);
+	if (khugepaged_has_work())
+		mod_delayed_kthread_work(khugepaged_worker,
+					 &khugepaged_do_scan_work,
+					 0);
 
 	return count;
 }
@@ -452,7 +477,7 @@ static ssize_t alloc_sleep_millisecs_store(struct kobject *kobj,
 		return -EINVAL;
 
 	khugepaged_alloc_sleep_millisecs = msecs;
-	wake_up_interruptible(&khugepaged_wait);
+	wake_up_interruptible(&khugepaged_alloc_wait);
 
 	return count;
 }
@@ -2120,7 +2145,9 @@ int __khugepaged_enter(struct mm_struct *mm)
 
 	atomic_inc(&mm->mm_count);
 	if (wakeup)
-		wake_up_interruptible(&khugepaged_wait);
+		mod_delayed_kthread_work(khugepaged_worker,
+					 &khugepaged_do_scan_work,
+					 0);
 
 	return 0;
 }
@@ -2335,10 +2362,10 @@ static void khugepaged_alloc_sleep(void)
 {
 	DEFINE_WAIT(wait);
 
-	add_wait_queue(&khugepaged_wait, &wait);
+	add_wait_queue(&khugepaged_alloc_wait, &wait);
 	freezable_schedule_timeout_interruptible(
 		msecs_to_jiffies(khugepaged_alloc_sleep_millisecs));
-	remove_wait_queue(&khugepaged_wait, &wait);
+	remove_wait_queue(&khugepaged_alloc_wait, &wait);
 }
 
 static int khugepaged_node_load[MAX_NUMNODES];
@@ -2849,19 +2876,13 @@ breakouterloop_mmap_sem:
 	return progress;
 }
 
-static int khugepaged_has_work(void)
-{
-	return !list_empty(&khugepaged_scan.mm_head) &&
-		khugepaged_enabled();
-}
-
-static int khugepaged_wait_event(void)
+static void khugepaged_init_func(struct kthread_work *dummy)
 {
-	return !list_empty(&khugepaged_scan.mm_head) ||
-		kthread_should_stop();
+	set_freezable();
+	set_user_nice(current, MAX_NICE);
 }
 
-static void khugepaged_do_scan(void)
+static void khugepaged_do_scan_func(struct kthread_work *dummy)
 {
 	struct page *hpage = NULL;
 	unsigned int progress = 0, pass_through_head = 0;
@@ -2876,7 +2897,7 @@ static void khugepaged_do_scan(void)
 
 		cond_resched();
 
-		if (unlikely(kthread_should_stop() || try_to_freeze()))
+		if (unlikely(!khugepaged_enabled() || try_to_freeze()))
 			break;
 
 		spin_lock(&khugepaged_mm_lock);
@@ -2893,43 +2914,30 @@ static void khugepaged_do_scan(void)
 
 	if (!IS_ERR_OR_NULL(hpage))
 		put_page(hpage);
-}
 
-static void khugepaged_wait_work(void)
-{
 	if (khugepaged_has_work()) {
-		if (!khugepaged_scan_sleep_millisecs)
-			return;
 
-		wait_event_freezable_timeout(khugepaged_wait,
-					     kthread_should_stop(),
-			msecs_to_jiffies(khugepaged_scan_sleep_millisecs));
-		return;
-	}
+		unsigned long delay = 0;
 
-	if (khugepaged_enabled())
-		wait_event_freezable(khugepaged_wait, khugepaged_wait_event());
+		if (khugepaged_scan_sleep_millisecs)
+			delay = msecs_to_jiffies(khugepaged_scan_sleep_millisecs);
+
+		queue_delayed_kthread_work(khugepaged_worker,
+					   &khugepaged_do_scan_work,
+					   delay);
+	}
 }
 
-static int khugepaged(void *none)
+static void khugepaged_cleanup_func(struct kthread_work *dummy)
 {
 	struct mm_slot *mm_slot;
 
-	set_freezable();
-	set_user_nice(current, MAX_NICE);
-
-	while (!kthread_should_stop()) {
-		khugepaged_do_scan();
-		khugepaged_wait_work();
-	}
-
 	spin_lock(&khugepaged_mm_lock);
 	mm_slot = khugepaged_scan.mm_slot;
 	khugepaged_scan.mm_slot = NULL;
 	if (mm_slot)
 		collect_mm_slot(mm_slot);
 	spin_unlock(&khugepaged_mm_lock);
-	return 0;
 }
 
 static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
