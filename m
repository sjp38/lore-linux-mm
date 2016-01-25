Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 49382828E2
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:48:13 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id n5so86669765wmn.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 07:48:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n123si25131660wmb.41.2016.01.25.07.48.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 07:48:12 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v4 13/22] mm/huge_page: Convert khugepaged() into kthread worker API
Date: Mon, 25 Jan 2016 16:45:02 +0100
Message-Id: <1453736711-6703-14-git-send-email-pmladek@suse.com>
In-Reply-To: <1453736711-6703-1-git-send-email-pmladek@suse.com>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

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

Note that kthread works get associated with a single kthread worker.
They must be initialized if we want to use them with another worker.
This is needed also when the worker is restarted.

set_freezable() is not needed because the kthread worker is
created as freezable.

set_user_nice() is called from start_stop_khugepaged(). It need
not be done from within the kthread.

The scan work must be queued only when the worker is available.
We have to use "khugepaged_mm_lock" to avoid a race between the check
and queuing. I admit that this was a bit easier before because wake_up()
was a nope when the kthread did not exist.

Also the scan work is queued only when the list of scanned pages is
not empty. It adds one check but it is cleaner.

They delay between scans is done using a delayed work.

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
 mm/huge_memory.c | 138 ++++++++++++++++++++++++++++++-------------------------
 1 file changed, 76 insertions(+), 62 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fd3a07b3e6f4..828d741ed242 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -89,10 +89,16 @@ static unsigned int khugepaged_full_scans;
 static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
 /* during fragmentation poll the hugepage allocator once every minute */
 static unsigned int khugepaged_alloc_sleep_millisecs __read_mostly = 60000;
-static struct task_struct *khugepaged_thread __read_mostly;
+
+static void khugepaged_do_scan_func(struct kthread_work *dummy);
+static void khugepaged_cleanup_func(struct kthread_work *dummy);
+static struct kthread_worker *khugepaged_worker;
+static struct delayed_kthread_work khugepaged_do_scan_work;
+static struct kthread_work khugepaged_cleanup_work;
+
 static DEFINE_MUTEX(khugepaged_mutex);
 static DEFINE_SPINLOCK(khugepaged_mm_lock);
-static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
+static DECLARE_WAIT_QUEUE_HEAD(khugepaged_alloc_wait);
 /*
  * default collapse hugepages if there is at least one pte mapped like
  * it would have happened if the vma was large enough during page
@@ -100,7 +106,6 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
  */
 static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
 
-static int khugepaged(void *none);
 static int khugepaged_slab_init(void);
 static void khugepaged_slab_exit(void);
 
@@ -180,29 +185,55 @@ static void set_recommended_min_free_kbytes(void)
 	setup_per_zone_wmarks();
 }
 
+static int khugepaged_has_work(void)
+{
+	return !list_empty(&khugepaged_scan.mm_head);
+}
+
 static int start_stop_khugepaged(void)
 {
+	struct kthread_worker *worker;
 	int err = 0;
+
 	if (khugepaged_enabled()) {
-		if (!khugepaged_thread)
-			khugepaged_thread = kthread_run(khugepaged, NULL,
-							"khugepaged");
-		if (IS_ERR(khugepaged_thread)) {
-			pr_err("khugepaged: kthread_run(khugepaged) failed\n");
-			err = PTR_ERR(khugepaged_thread);
-			khugepaged_thread = NULL;
-			goto fail;
+		if (khugepaged_worker)
+			goto out;
+
+		worker = create_kthread_worker(KTW_FREEZABLE, "khugepaged");
+		if (IS_ERR(worker)) {
+			pr_err("khugepaged: failed to create kthread worker\n");
+			goto out;
 		}
+		set_user_nice(worker->task, MAX_NICE);
 
-		if (!list_empty(&khugepaged_scan.mm_head))
-			wake_up_interruptible(&khugepaged_wait);
+		/* Always initialize the works when the worker is started. */
+		init_delayed_kthread_work(&khugepaged_do_scan_work,
+					  khugepaged_do_scan_func);
+		init_kthread_work(&khugepaged_cleanup_work,
+				  khugepaged_cleanup_func);
+
+		/* Make the worker public and check for work synchronously. */
+		spin_lock(&khugepaged_mm_lock);
+		khugepaged_worker = worker;
+		if (khugepaged_has_work())
+			queue_delayed_kthread_work(worker,
+						   &khugepaged_do_scan_work,
+						   0);
+		spin_unlock(&khugepaged_mm_lock);
 
 		set_recommended_min_free_kbytes();
-	} else if (khugepaged_thread) {
-		kthread_stop(khugepaged_thread);
-		khugepaged_thread = NULL;
+	} else if (khugepaged_worker) {
+		/* First, stop others from using the worker. */
+		spin_lock(&khugepaged_mm_lock);
+		worker = khugepaged_worker;
+		khugepaged_worker = NULL;
+		spin_unlock(&khugepaged_mm_lock);
+
+		cancel_delayed_kthread_work_sync(&khugepaged_do_scan_work);
+		queue_kthread_work(worker, &khugepaged_cleanup_work);
+		destroy_kthread_worker(worker);
 	}
-fail:
+out:
 	return err;
 }
 
@@ -461,7 +492,13 @@ static ssize_t scan_sleep_millisecs_store(struct kobject *kobj,
 		return -EINVAL;
 
 	khugepaged_scan_sleep_millisecs = msecs;
-	wake_up_interruptible(&khugepaged_wait);
+
+	spin_lock(&khugepaged_mm_lock);
+	if (khugepaged_worker && khugepaged_has_work())
+		mod_delayed_kthread_work(khugepaged_worker,
+					 &khugepaged_do_scan_work,
+					 0);
+	spin_unlock(&khugepaged_mm_lock);
 
 	return count;
 }
@@ -488,7 +525,7 @@ static ssize_t alloc_sleep_millisecs_store(struct kobject *kobj,
 		return -EINVAL;
 
 	khugepaged_alloc_sleep_millisecs = msecs;
-	wake_up_interruptible(&khugepaged_wait);
+	wake_up_interruptible(&khugepaged_alloc_wait);
 
 	return count;
 }
@@ -1878,7 +1915,7 @@ static inline int khugepaged_test_exit(struct mm_struct *mm)
 int __khugepaged_enter(struct mm_struct *mm)
 {
 	struct mm_slot *mm_slot;
-	int wakeup;
+	int has_work;
 
 	mm_slot = alloc_mm_slot();
 	if (!mm_slot)
@@ -1897,13 +1934,15 @@ int __khugepaged_enter(struct mm_struct *mm)
 	 * Insert just behind the scanning cursor, to let the area settle
 	 * down a little.
 	 */
-	wakeup = list_empty(&khugepaged_scan.mm_head);
+	has_work = khugepaged_has_work();
 	list_add_tail(&mm_slot->mm_node, &khugepaged_scan.mm_head);
-	spin_unlock(&khugepaged_mm_lock);
 
 	atomic_inc(&mm->mm_count);
-	if (wakeup)
-		wake_up_interruptible(&khugepaged_wait);
+	if (khugepaged_worker && has_work)
+		mod_delayed_kthread_work(khugepaged_worker,
+					 &khugepaged_do_scan_work,
+					 0);
+	spin_unlock(&khugepaged_mm_lock);
 
 	return 0;
 }
@@ -2142,10 +2181,10 @@ static void khugepaged_alloc_sleep(void)
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
@@ -2716,19 +2755,7 @@ breakouterloop_mmap_sem:
 	return progress;
 }
 
-static int khugepaged_has_work(void)
-{
-	return !list_empty(&khugepaged_scan.mm_head) &&
-		khugepaged_enabled();
-}
-
-static int khugepaged_wait_event(void)
-{
-	return !list_empty(&khugepaged_scan.mm_head) ||
-		kthread_should_stop();
-}
-
-static void khugepaged_do_scan(void)
+static void khugepaged_do_scan_func(struct kthread_work *dummy)
 {
 	struct page *hpage = NULL;
 	unsigned int progress = 0, pass_through_head = 0;
@@ -2743,7 +2770,7 @@ static void khugepaged_do_scan(void)
 
 		cond_resched();
 
-		if (unlikely(kthread_should_stop() || try_to_freeze()))
+		if (unlikely(!khugepaged_enabled() || try_to_freeze()))
 			break;
 
 		spin_lock(&khugepaged_mm_lock);
@@ -2760,43 +2787,30 @@ static void khugepaged_do_scan(void)
 
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
