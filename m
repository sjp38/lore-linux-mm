Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id E6A7F6B025A
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:40:15 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so162759690wib.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:40:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fm3si20815889wic.41.2015.07.28.07.40.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 07:40:10 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC PATCH 07/14] mm/huge_page: Convert khugepaged() into kthread worker API
Date: Tue, 28 Jul 2015 16:39:24 +0200
Message-Id: <1438094371-8326-8-git-send-email-pmladek@suse.com>
In-Reply-To: <1438094371-8326-1-git-send-email-pmladek@suse.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
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

It keeps the functionality except that we do not wakeup
the worker when it is already created and someone
calls start() once again.

Note that we could not longer check for kthread_should_stop()
in the works. The kthread used by the worker has to stay alive
until all queued works are finished. Instead, we use the existing
check khugepaged_enabled() that returns false when we are going down.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 mm/huge_memory.c | 91 +++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 57 insertions(+), 34 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c107094f79ba..55733735a487 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -54,7 +54,17 @@ static unsigned int khugepaged_full_scans;
 static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
 /* during fragmentation poll the hugepage allocator once every minute */
 static unsigned int khugepaged_alloc_sleep_millisecs __read_mostly = 60000;
-static struct task_struct *khugepaged_thread __read_mostly;
+
+static void khugepaged_init_func(struct kthread_work *dummy);
+static void khugepaged_do_scan_func(struct kthread_work *dummy);
+static void khugepaged_wait_func(struct kthread_work *dummy);
+static void khugepaged_cleanup_func(struct kthread_work *dummy);
+static DEFINE_KTHREAD_WORKER(khugepaged_worker);
+static DEFINE_KTHREAD_WORK(khugepaged_init_work, khugepaged_init_func);
+static DEFINE_KTHREAD_WORK(khugepaged_do_scan_work, khugepaged_do_scan_func);
+static DEFINE_KTHREAD_WORK(khugepaged_wait_work, khugepaged_wait_func);
+static DEFINE_KTHREAD_WORK(khugepaged_cleanup_work, khugepaged_cleanup_func);
+
 static DEFINE_MUTEX(khugepaged_mutex);
 static DEFINE_SPINLOCK(khugepaged_mm_lock);
 static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
@@ -65,7 +75,6 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
  */
 static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
 
-static int khugepaged(void *none);
 static int khugepaged_slab_init(void);
 static void khugepaged_slab_exit(void);
 
@@ -146,25 +155,34 @@ static int start_stop_khugepaged(void)
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
+		if (kthread_worker_created(&khugepaged_worker))
+			goto out;
+
+		err = create_kthread_worker(&khugepaged_worker,
+					    "khugepaged");
+
+		if (unlikely(err)) {
+			pr_err("khugepaged: failed to create kthread worker\n");
+			goto out;
 		}
 
-		if (!list_empty(&khugepaged_scan.mm_head))
-			wake_up_interruptible(&khugepaged_wait);
+		queue_kthread_work(&khugepaged_worker,
+				   &khugepaged_init_work);
+
+		if (list_empty(&khugepaged_scan.mm_head))
+			queue_kthread_work(&khugepaged_worker,
+					   &khugepaged_wait_work);
+		else
+			queue_kthread_work(&khugepaged_worker,
+					   &khugepaged_do_scan_work);
 
 		set_recommended_min_free_kbytes();
-	} else if (khugepaged_thread) {
-		kthread_stop(khugepaged_thread);
-		khugepaged_thread = NULL;
+	} else if (kthread_worker_created(&khugepaged_worker)) {
+		queue_kthread_work(&khugepaged_worker,
+				   &khugepaged_cleanup_work);
+		wakeup_and_destroy_kthread_worker(&khugepaged_worker);
 	}
-fail:
+out:
 	return err;
 }
 
@@ -2780,11 +2798,17 @@ static int khugepaged_has_work(void)
 
 static int khugepaged_wait_event(void)
 {
-	return !list_empty(&khugepaged_scan.mm_head) ||
-		kthread_should_stop();
+	return (!list_empty(&khugepaged_scan.mm_head) ||
+		!khugepaged_enabled());
+}
+
+static void khugepaged_init_func(struct kthread_work *dummy)
+{
+	set_freezable();
+	set_user_nice(current, MAX_NICE);
 }
 
-static void khugepaged_do_scan(void)
+static void khugepaged_do_scan_func(struct kthread_work *dummy)
 {
 	struct page *hpage = NULL;
 	unsigned int progress = 0, pass_through_head = 0;
@@ -2799,7 +2823,7 @@ static void khugepaged_do_scan(void)
 
 		cond_resched();
 
-		if (unlikely(kthread_should_stop() || try_to_freeze()))
+		if (unlikely(!khugepaged_enabled() || try_to_freeze()))
 			break;
 
 		spin_lock(&khugepaged_mm_lock);
@@ -2816,43 +2840,42 @@ static void khugepaged_do_scan(void)
 
 	if (!IS_ERR_OR_NULL(hpage))
 		put_page(hpage);
+
+	if (khugepaged_enabled())
+		queue_kthread_work(&khugepaged_worker, &khugepaged_wait_work);
 }
 
-static void khugepaged_wait_work(void)
+static void khugepaged_wait_func(struct kthread_work *dummy)
 {
 	if (khugepaged_has_work()) {
 		if (!khugepaged_scan_sleep_millisecs)
-			return;
+			goto out;
 
 		wait_event_freezable_timeout(khugepaged_wait,
-					     kthread_should_stop(),
+					     !khugepaged_enabled(),
 			msecs_to_jiffies(khugepaged_scan_sleep_millisecs));
-		return;
+		goto out;
 	}
 
 	if (khugepaged_enabled())
 		wait_event_freezable(khugepaged_wait, khugepaged_wait_event());
+
+out:
+	if (khugepaged_enabled())
+		queue_kthread_work(&khugepaged_worker,
+				   &khugepaged_do_scan_work);
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
