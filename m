Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id D1CEB6B0074
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 07:15:47 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Mon, 13 Aug 2012 21:14:54 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7DB72Du17629190
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:07:02 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7DBFgT7032658
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:15:42 +1000
Message-ID: <5028E1DB.10702@linux.vnet.ibm.com>
Date: Mon, 13 Aug 2012 19:15:39 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 07/12] thp: merge page pre-alloc in khugepaged_loop into khugepaged_do_scan
References: <5028E12C.70101@linux.vnet.ibm.com>
In-Reply-To: <5028E12C.70101@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

There are two pre-alloc operations in these two function, the different is:
- it allows to sleep if page alloc fail in khugepaged_loop
- it exits immediately if page alloc fail in khugepaged_do_scan

Actually, in khugepaged_do_scan, we can allow the pre-alloc to sleep on the
first failure, then the operation in khugepaged_loop can be removed

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/huge_memory.c |   97 +++++++++++++++++++++++++-----------------------------
 1 files changed, 45 insertions(+), 52 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5f620cf..42d3d74 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2237,10 +2237,40 @@ static int khugepaged_wait_event(void)
 		kthread_should_stop();
 }

-static void khugepaged_do_scan(struct page **hpage)
+static void khugepaged_alloc_sleep(void)
+{
+	wait_event_freezable_timeout(khugepaged_wait, false,
+			msecs_to_jiffies(khugepaged_alloc_sleep_millisecs));
+}
+
+#ifndef CONFIG_NUMA
+static struct page *khugepaged_alloc_hugepage(bool *wait)
+{
+	struct page *hpage;
+
+	do {
+		hpage = alloc_hugepage(khugepaged_defrag());
+		if (!hpage) {
+			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
+			if (!*wait)
+				return NULL;
+
+			*wait = false;
+			khugepaged_alloc_sleep();
+		} else
+			count_vm_event(THP_COLLAPSE_ALLOC);
+	} while (unlikely(!hpage) && likely(khugepaged_enabled()));
+
+	return hpage;
+}
+#endif
+
+static void khugepaged_do_scan(void)
 {
+	struct page *hpage = NULL;
 	unsigned int progress = 0, pass_through_head = 0;
 	unsigned int pages = khugepaged_pages_to_scan;
+	bool wait = true;

 	barrier(); /* write khugepaged_pages_to_scan to local stack */

@@ -2248,17 +2278,18 @@ static void khugepaged_do_scan(struct page **hpage)
 		cond_resched();

 #ifndef CONFIG_NUMA
-		if (!*hpage) {
-			*hpage = alloc_hugepage(khugepaged_defrag());
-			if (unlikely(!*hpage)) {
-				count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
+		if (!hpage)
+			hpage = khugepaged_alloc_hugepage(&wait);
+
+		if (unlikely(!hpage))
+			break;
+#else
+		if (IS_ERR(hpage)) {
+			if (!wait)
 				break;
-			}
-			count_vm_event(THP_COLLAPSE_ALLOC);
+			wait = false;
+			khugepaged_alloc_sleep();
 		}
-#else
-		if (IS_ERR(*hpage))
-			break;
 #endif

 		if (unlikely(kthread_should_stop() || freezing(current)))
@@ -2270,37 +2301,16 @@ static void khugepaged_do_scan(struct page **hpage)
 		if (khugepaged_has_work() &&
 		    pass_through_head < 2)
 			progress += khugepaged_scan_mm_slot(pages - progress,
-							    hpage);
+							    &hpage);
 		else
 			progress = pages;
 		spin_unlock(&khugepaged_mm_lock);
 	}
-}

-static void khugepaged_alloc_sleep(void)
-{
-	wait_event_freezable_timeout(khugepaged_wait, false,
-			msecs_to_jiffies(khugepaged_alloc_sleep_millisecs));
+	if (!IS_ERR_OR_NULL(hpage))
+		put_page(hpage);
 }

-#ifndef CONFIG_NUMA
-static struct page *khugepaged_alloc_hugepage(void)
-{
-	struct page *hpage;
-
-	do {
-		hpage = alloc_hugepage(khugepaged_defrag());
-		if (!hpage) {
-			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
-			khugepaged_alloc_sleep();
-		} else
-			count_vm_event(THP_COLLAPSE_ALLOC);
-	} while (unlikely(!hpage) &&
-		 likely(khugepaged_enabled()));
-	return hpage;
-}
-#endif
-
 static void khugepaged_wait_work(void)
 {
 	try_to_freeze();
@@ -2321,25 +2331,8 @@ static void khugepaged_wait_work(void)

 static void khugepaged_loop(void)
 {
-	struct page *hpage = NULL;
-
 	while (likely(khugepaged_enabled())) {
-#ifndef CONFIG_NUMA
-		hpage = khugepaged_alloc_hugepage();
-		if (unlikely(!hpage))
-			break;
-#else
-		if (IS_ERR(hpage)) {
-			khugepaged_alloc_sleep();
-			hpage = NULL;
-		}
-#endif
-
-		khugepaged_do_scan(&hpage);
-
-		if (!IS_ERR_OR_NULL(hpage))
-			put_page(hpage);
-
+		khugepaged_do_scan();
 		khugepaged_wait_work();
 	}
 }
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
