Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 0C7116B006C
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 07:14:16 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Mon, 13 Aug 2012 16:44:14 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7DBE7bT39714964
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 16:44:07 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7DBE7k0002431
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:14:07 +1000
Message-ID: <5028E17D.3040007@linux.vnet.ibm.com>
Date: Mon, 13 Aug 2012 19:14:05 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 03/12] thp: move khugepaged_mutex out of khugepaged
References: <5028E12C.70101@linux.vnet.ibm.com>
In-Reply-To: <5028E12C.70101@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Currently, hugepaged_mutex is used really complexly and hard to understand,
actually, it is just used to serialize start_khugepaged and khugepaged for
these reasons:
- khugepaged_thread is shared between them
- the thp disable path (echo never > transparent_hugepage/enabled) is
  nonblocking, so we need to protect khugepaged_thread to get a stable
  running state

These can be avoided by:
- use the lock to serialize the thread creation and cancel
- thp disable path can not finised until the thread exits

Then khugepaged_thread is fully controlled by start_khugepaged, khugepaged
will be happy without the lock

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/huge_memory.c |   36 +++++++++++++-----------------------
 1 files changed, 13 insertions(+), 23 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 399e8c9..3715c52 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -139,9 +139,6 @@ static int start_khugepaged(void)
 {
 	int err = 0;
 	if (khugepaged_enabled()) {
-		int wakeup;
-
-		mutex_lock(&khugepaged_mutex);
 		if (!khugepaged_thread)
 			khugepaged_thread = kthread_run(khugepaged, NULL,
 							"khugepaged");
@@ -151,15 +148,17 @@ static int start_khugepaged(void)
 			err = PTR_ERR(khugepaged_thread);
 			khugepaged_thread = NULL;
 		}
-		wakeup = !list_empty(&khugepaged_scan.mm_head);
-		mutex_unlock(&khugepaged_mutex);
-		if (wakeup)
+
+		if (!list_empty(&khugepaged_scan.mm_head))
 			wake_up_interruptible(&khugepaged_wait);

 		set_recommended_min_free_kbytes();
-	} else
+	} else if (khugepaged_thread) {
 		/* wakeup to exit */
 		wake_up_interruptible(&khugepaged_wait);
+		kthread_stop(khugepaged_thread);
+		khugepaged_thread = NULL;
+	}

 	return err;
 }
@@ -221,7 +220,12 @@ static ssize_t enabled_store(struct kobject *kobj,
 				TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG);

 	if (ret > 0) {
-		int err = start_khugepaged();
+		int err;
+
+		mutex_lock(&khugepaged_mutex);
+		err = start_khugepaged();
+		mutex_unlock(&khugepaged_mutex);
+
 		if (err)
 			ret = err;
 	}
@@ -2344,20 +2348,10 @@ static int khugepaged(void *none)
 	set_freezable();
 	set_user_nice(current, 19);

-	/* serialize with start_khugepaged() */
-	mutex_lock(&khugepaged_mutex);
-
-	for (;;) {
-		mutex_unlock(&khugepaged_mutex);
+	while (!kthread_should_stop()) {
 		VM_BUG_ON(khugepaged_thread != current);
 		khugepaged_loop();
 		VM_BUG_ON(khugepaged_thread != current);
-
-		mutex_lock(&khugepaged_mutex);
-		if (!khugepaged_enabled())
-			break;
-		if (unlikely(kthread_should_stop()))
-			break;
 	}

 	spin_lock(&khugepaged_mm_lock);
@@ -2366,10 +2360,6 @@ static int khugepaged(void *none)
 	if (mm_slot)
 		collect_mm_slot(mm_slot);
 	spin_unlock(&khugepaged_mm_lock);
-
-	khugepaged_thread = NULL;
-	mutex_unlock(&khugepaged_mutex);
-
 	return 0;
 }

-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
