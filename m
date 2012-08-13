Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 9EBD06B0072
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 07:14:55 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Mon, 13 Aug 2012 16:44:53 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7DBEoeD28180572
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 16:44:50 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7DBEoOq004903
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:14:50 +1000
Message-ID: <5028E1A8.4010402@linux.vnet.ibm.com>
Date: Mon, 13 Aug 2012 19:14:48 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 05/12] thp: remove wake_up_interruptible in the exit path
References: <5028E12C.70101@linux.vnet.ibm.com>
In-Reply-To: <5028E12C.70101@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Add the check of kthread_should_stop() to the conditions which are used
to wakeup on khugepaged_wait, then kthread_stop is enough to let the
thread exit

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/huge_memory.c |   35 +++++++++++++++++++++--------------
 1 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b218700..86f71af 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -154,8 +154,6 @@ static int start_khugepaged(void)

 		set_recommended_min_free_kbytes();
 	} else if (khugepaged_thread) {
-		/* wakeup to exit */
-		wake_up_interruptible(&khugepaged_wait);
 		kthread_stop(khugepaged_thread);
 		khugepaged_thread = NULL;
 	}
@@ -2236,7 +2234,7 @@ static int khugepaged_has_work(void)
 static int khugepaged_wait_event(void)
 {
 	return !list_empty(&khugepaged_scan.mm_head) ||
-		!khugepaged_enabled();
+		kthread_should_stop();
 }

 static void khugepaged_do_scan(struct page **hpage)
@@ -2303,6 +2301,24 @@ static struct page *khugepaged_alloc_hugepage(void)
 }
 #endif

+static void khugepaged_wait_work(void)
+{
+	try_to_freeze();
+
+	if (khugepaged_has_work()) {
+		if (!khugepaged_scan_sleep_millisecs)
+			return;
+
+		wait_event_freezable_timeout(khugepaged_wait,
+					     kthread_should_stop(),
+			msecs_to_jiffies(khugepaged_scan_sleep_millisecs));
+		return;
+	}
+
+	if (khugepaged_enabled())
+		wait_event_freezable(khugepaged_wait, khugepaged_wait_event());
+}
+
 static void khugepaged_loop(void)
 {
 	struct page *hpage;
@@ -2327,17 +2343,8 @@ static void khugepaged_loop(void)
 		if (hpage)
 			put_page(hpage);
 #endif
-		try_to_freeze();
-		if (unlikely(kthread_should_stop()))
-			break;
-		if (khugepaged_has_work()) {
-			if (!khugepaged_scan_sleep_millisecs)
-				continue;
-			wait_event_freezable_timeout(khugepaged_wait, false,
-			    msecs_to_jiffies(khugepaged_scan_sleep_millisecs));
-		} else if (khugepaged_enabled())
-			wait_event_freezable(khugepaged_wait,
-					     khugepaged_wait_event());
+
+		khugepaged_wait_work();
 	}
 }

-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
