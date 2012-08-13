Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id A44556B0081
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 07:16:59 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Mon, 13 Aug 2012 21:16:04 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7DBGraf2162808
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:16:53 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7DBGq5o003106
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:16:53 +1000
Message-ID: <5028E222.8020005@linux.vnet.ibm.com>
Date: Mon, 13 Aug 2012 19:16:50 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 10/12] thp: remove khugepaged_loop
References: <5028E12C.70101@linux.vnet.ibm.com>
In-Reply-To: <5028E12C.70101@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Merge khugepaged_loop into khugepaged

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/huge_memory.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 82f6cce..6ddf671 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2354,14 +2354,6 @@ static void khugepaged_wait_work(void)
 		wait_event_freezable(khugepaged_wait, khugepaged_wait_event());
 }

-static void khugepaged_loop(void)
-{
-	while (likely(khugepaged_enabled())) {
-		khugepaged_do_scan();
-		khugepaged_wait_work();
-	}
-}
-
 static int khugepaged(void *none)
 {
 	struct mm_slot *mm_slot;
@@ -2369,8 +2361,10 @@ static int khugepaged(void *none)
 	set_freezable();
 	set_user_nice(current, 19);

-	while (!kthread_should_stop())
-		khugepaged_loop();
+	while (!kthread_should_stop()) {
+		khugepaged_do_scan();
+		khugepaged_wait_work();
+	}

 	spin_lock(&khugepaged_mm_lock);
 	mm_slot = khugepaged_scan.mm_slot;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
