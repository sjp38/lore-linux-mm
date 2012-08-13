Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 3CBCB6B0073
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 07:15:19 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Mon, 13 Aug 2012 16:45:16 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7DBFDp237879954
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 16:45:14 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7DBFDba006607
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:15:13 +1000
Message-ID: <5028E1BF.1020902@linux.vnet.ibm.com>
Date: Mon, 13 Aug 2012 19:15:11 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 06/12] thp: remove some code depend on CONFIG_NUMA
References: <5028E12C.70101@linux.vnet.ibm.com>
In-Reply-To: <5028E12C.70101@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

If NUMA is disabled, hpage is used as page pre-alloc, so there are
two cases for hpage:
- it is !NULL, means the page is not consumed otherwise,
- the page has been consumed

If NUMA is enabled, hpage is just used as alloc-fail indicator which
is not a real page, NULL means not fail triggered.

So, we can release the page only if !IS_ERR_OR_NULL

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/huge_memory.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 86f71af..5f620cf 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2321,11 +2321,8 @@ static void khugepaged_wait_work(void)

 static void khugepaged_loop(void)
 {
-	struct page *hpage;
+	struct page *hpage = NULL;

-#ifdef CONFIG_NUMA
-	hpage = NULL;
-#endif
 	while (likely(khugepaged_enabled())) {
 #ifndef CONFIG_NUMA
 		hpage = khugepaged_alloc_hugepage();
@@ -2339,10 +2336,9 @@ static void khugepaged_loop(void)
 #endif

 		khugepaged_do_scan(&hpage);
-#ifndef CONFIG_NUMA
-		if (hpage)
+
+		if (!IS_ERR_OR_NULL(hpage))
 			put_page(hpage);
-#endif

 		khugepaged_wait_work();
 	}
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
