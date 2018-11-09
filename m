Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E14C06B06A6
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 01:47:50 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id f28-v6so782893pfh.6
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 22:47:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q14-v6sor6959767pgv.63.2018.11.08.22.47.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 22:47:49 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC][PATCH v1 09/11] mm: hwpoison: apply buddy page handling code to hard-offline
Date: Fri,  9 Nov 2018 15:47:13 +0900
Message-Id: <1541746035-13408-10-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>

Hard-offline of free buddy pages can be handled in the same manner as
soft-offline. So this patch applies the new semantics to hard-offline to
more complete isolation of offlined page. As a result, the successful
case is worth MF_RECOVERED instead of MF_DELAYED, so this patch also
changes it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 38 ++++++++++++++++++++++++++++----------
 1 file changed, 28 insertions(+), 10 deletions(-)

diff --git v4.19-mmotm-2018-10-30-16-08/mm/memory-failure.c v4.19-mmotm-2018-10-30-16-08_patched/mm/memory-failure.c
index ecafd4a..af541141 100644
--- v4.19-mmotm-2018-10-30-16-08/mm/memory-failure.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/mm/memory-failure.c
@@ -772,6 +772,16 @@ static int me_swapcache_clean(struct page *p, unsigned long pfn)
 		return MF_FAILED;
 }
 
+static int me_huge_free_page(struct page *p)
+{
+	int rc = dissolve_free_huge_page(p);
+
+	if (!rc && set_hwpoison_free_buddy_page(p))
+		return MF_RECOVERED;
+	else
+		return MF_FAILED;
+}
+
 /*
  * Huge pages. Needs work.
  * Issues:
@@ -799,8 +809,7 @@ static int me_huge_page(struct page *p, unsigned long pfn)
 		 */
 		if (PageAnon(hpage))
 			put_page(hpage);
-		dissolve_free_huge_page(p);
-		res = MF_RECOVERED;
+		res = me_huge_free_page(p);
 		lock_page(hpage);
 	}
 
@@ -1108,8 +1117,11 @@ static int memory_failure_hugetlb(unsigned long pfn, int flags)
 			}
 		}
 		unlock_page(head);
-		dissolve_free_huge_page(p);
-		action_result(pfn, MF_MSG_FREE_HUGE, MF_DELAYED);
+
+		res = me_huge_free_page(p);
+		if (res == MF_FAILED)
+			num_poisoned_pages_dec();
+		action_result(pfn, MF_MSG_FREE_HUGE, res);
 		return 0;
 	}
 
@@ -1270,6 +1282,13 @@ int memory_failure(unsigned long pfn, int flags)
 	p = pfn_to_page(pfn);
 	if (PageHuge(p))
 		return memory_failure_hugetlb(pfn, flags);
+
+	if (set_hwpoison_free_buddy_page(p)) {
+		action_result(pfn, MF_MSG_BUDDY, MF_RECOVERED);
+		num_poisoned_pages_inc();
+		return 0;
+	}
+
 	if (TestSetPageHWPoison(p)) {
 		pr_err("Memory failure: %#lx: already hardware poisoned\n",
 			pfn);
@@ -1281,8 +1300,7 @@ int memory_failure(unsigned long pfn, int flags)
 
 	/*
 	 * We need/can do nothing about count=0 pages.
-	 * 1) it's a free page, and therefore in safe hand:
-	 *    prep_new_page() will be the gate keeper.
+	 * 1) it's a free page, and removed from buddy allocator.
 	 * 2) it's part of a non-compound high order page.
 	 *    Implies some kernel user: cannot stop them from
 	 *    R/W the page; let's pray that the page has been
@@ -1291,8 +1309,8 @@ int memory_failure(unsigned long pfn, int flags)
 	 * that may make page_ref_freeze()/page_ref_unfreeze() mismatch.
 	 */
 	if (!get_hwpoison_page(p)) {
-		if (is_free_buddy_page(p)) {
-			action_result(pfn, MF_MSG_BUDDY, MF_DELAYED);
+		if (set_hwpoison_free_buddy_page(p)) {
+			action_result(pfn, MF_MSG_BUDDY, MF_RECOVERED);
 			return 0;
 		} else {
 			action_result(pfn, MF_MSG_KERNEL_HIGH_ORDER, MF_IGNORED);
@@ -1330,8 +1348,8 @@ int memory_failure(unsigned long pfn, int flags)
 	 */
 	shake_page(p, 0);
 	/* shake_page could have turned it free. */
-	if (!PageLRU(p) && is_free_buddy_page(p)) {
-		action_result(pfn, MF_MSG_BUDDY_2ND, MF_DELAYED);
+	if (!PageLRU(p) && set_hwpoison_free_buddy_page(p)) {
+		action_result(pfn, MF_MSG_BUDDY_2ND, MF_RECOVERED);
 		return 0;
 	}
 
-- 
2.7.0
