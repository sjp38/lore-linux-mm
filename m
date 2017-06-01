Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4885E6B02FD
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 04:17:20 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id q81so31853201itc.9
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:20 -0700 (PDT)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id 64si18199819iov.133.2017.06.01.01.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 01:17:19 -0700 (PDT)
Received: by mail-io0-x243.google.com with SMTP id 12so4190225iol.1
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:19 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 6/9] mm: hwpoison: introduce memory_failure_hugetlb()
Date: Thu,  1 Jun 2017 17:16:56 +0900
Message-Id: <1496305019-5493-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

memory_failure() is a big function and hard to maintain.
Handling hugetlb- and non-hugetlb- case in a single function is not
good, so this patch separates PageHuge() branch into a new function,
which saves many PageHuge() check.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 134 ++++++++++++++++++++++++++++++++--------------------
 1 file changed, 82 insertions(+), 52 deletions(-)

diff --git v4.12-rc3/mm/memory-failure.c v4.12-rc3_patched/mm/memory-failure.c
index a5f52cc..31b761a 100644
--- v4.12-rc3/mm/memory-failure.c
+++ v4.12-rc3_patched/mm/memory-failure.c
@@ -1009,6 +1009,76 @@ static bool hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	return unmap_success;
 }
 
+static int memory_failure_hugetlb(unsigned long pfn, int trapno, int flags)
+{
+	struct page_state *ps;
+	struct page *p = pfn_to_page(pfn);
+	struct page *head = compound_head(p);
+	int res;
+	unsigned long page_flags;
+
+	if (TestSetPageHWPoison(head)) {
+		pr_err("Memory failure: %#lx: already hardware poisoned\n",
+		       pfn);
+		return 0;
+	}
+
+	num_poisoned_pages_inc();
+
+	if (!(flags & MF_COUNT_INCREASED) && !get_hwpoison_page(p)) {
+		/*
+		 * Check "filter hit" and "race with other subpage."
+		 */
+		lock_page(head);
+		if (PageHWPoison(head)) {
+			if ((hwpoison_filter(p) && TestClearPageHWPoison(p))
+			    || (p != head && TestSetPageHWPoison(head))) {
+				num_poisoned_pages_dec();
+				unlock_page(head);
+				return 0;
+			}
+		}
+		unlock_page(head);
+		dissolve_free_huge_page(p);
+		action_result(pfn, MF_MSG_FREE_HUGE, MF_DELAYED);
+		return 0;
+	}
+
+	lock_page(head);
+	page_flags = head->flags;
+
+	if (!PageHWPoison(head)) {
+		pr_err("Memory failure: %#lx: just unpoisoned\n", pfn);
+		num_poisoned_pages_dec();
+		unlock_page(head);
+		put_hwpoison_page(head);
+		return 0;
+	}
+
+	if (!hwpoison_user_mappings(p, pfn, trapno, flags, &head)) {
+		action_result(pfn, MF_MSG_UNMAP_FAILED, MF_IGNORED);
+		res = -EBUSY;
+		goto out;
+	}
+
+	res = -EBUSY;
+
+	for (ps = error_states;; ps++)
+		if ((p->flags & ps->mask) == ps->res)
+			break;
+
+	page_flags |= (p->flags & (1UL << PG_dirty));
+
+	if (!ps->mask)
+		for (ps = error_states;; ps++)
+			if ((page_flags & ps->mask) == ps->res)
+				break;
+	res = page_action(ps, p, pfn);
+out:
+	unlock_page(head);
+	return res;
+}
+
 /**
  * memory_failure - Handle memory failure of a page.
  * @pfn: Page Number of the corrupted page
@@ -1046,33 +1116,22 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	}
 
 	p = pfn_to_page(pfn);
-	orig_head = hpage = compound_head(p);
-
-	/* tmporary check code, to be updated in later patches */
-	if (PageHuge(p)) {
-		if (TestSetPageHWPoison(hpage)) {
-			pr_err("Memory failure: %#lx: already hardware poisoned\n", pfn);
-			return 0;
-		}
-		goto tmp;
-	}
+	if (PageHuge(p))
+		return memory_failure_hugetlb(pfn, trapno, flags);
 	if (TestSetPageHWPoison(p)) {
 		pr_err("Memory failure: %#lx: already hardware poisoned\n",
 			pfn);
 		return 0;
 	}
 
-tmp:
+	orig_head = hpage = compound_head(p);
 	num_poisoned_pages_inc();
 
 	/*
 	 * We need/can do nothing about count=0 pages.
 	 * 1) it's a free page, and therefore in safe hand:
 	 *    prep_new_page() will be the gate keeper.
-	 * 2) it's a free hugepage, which is also safe:
-	 *    an affected hugepage will be dequeued from hugepage freelist,
-	 *    so there's no concern about reusing it ever after.
-	 * 3) it's part of a non-compound high order page.
+	 * 2) it's part of a non-compound high order page.
 	 *    Implies some kernel user: cannot stop them from
 	 *    R/W the page; let's pray that the page has been
 	 *    used and will be freed some time later.
@@ -1083,31 +1142,13 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 		if (is_free_buddy_page(p)) {
 			action_result(pfn, MF_MSG_BUDDY, MF_DELAYED);
 			return 0;
-		} else if (PageHuge(hpage)) {
-			/*
-			 * Check "filter hit" and "race with other subpage."
-			 */
-			lock_page(hpage);
-			if (PageHWPoison(hpage)) {
-				if ((hwpoison_filter(p) && TestClearPageHWPoison(p))
-				    || (p != hpage && TestSetPageHWPoison(hpage))) {
-					num_poisoned_pages_dec();
-					unlock_page(hpage);
-					return 0;
-				}
-			}
-			res = dequeue_hwpoisoned_huge_page(hpage);
-			action_result(pfn, MF_MSG_FREE_HUGE,
-				      res ? MF_IGNORED : MF_DELAYED);
-			unlock_page(hpage);
-			return res;
 		} else {
 			action_result(pfn, MF_MSG_KERNEL_HIGH_ORDER, MF_IGNORED);
 			return -EBUSY;
 		}
 	}
 
-	if (!PageHuge(p) && PageTransHuge(hpage)) {
+	if (PageTransHuge(hpage)) {
 		lock_page(p);
 		if (!PageAnon(p) || unlikely(split_huge_page(p))) {
 			unlock_page(p);
@@ -1145,7 +1186,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 		return 0;
 	}
 
-	lock_page(hpage);
+	lock_page(p);
 
 	/*
 	 * The page could have changed compound pages during the locking.
@@ -1172,33 +1213,22 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	if (!PageHWPoison(p)) {
 		pr_err("Memory failure: %#lx: just unpoisoned\n", pfn);
 		num_poisoned_pages_dec();
-		unlock_page(hpage);
-		put_hwpoison_page(hpage);
+		unlock_page(p);
+		put_hwpoison_page(p);
 		return 0;
 	}
 	if (hwpoison_filter(p)) {
 		if (TestClearPageHWPoison(p))
 			num_poisoned_pages_dec();
-		unlock_page(hpage);
-		put_hwpoison_page(hpage);
+		unlock_page(p);
+		put_hwpoison_page(p);
 		return 0;
 	}
 
-	if (!PageHuge(p) && !PageTransTail(p) && !PageLRU(p))
+	if (!PageTransTail(p) && !PageLRU(p))
 		goto identify_page_state;
 
 	/*
-	 * For error on the tail page, we should set PG_hwpoison
-	 * on the head page to show that the hugepage is hwpoisoned
-	 */
-	if (PageHuge(p) && PageTail(p) && TestSetPageHWPoison(hpage)) {
-		action_result(pfn, MF_MSG_POISONED_HUGE, MF_IGNORED);
-		unlock_page(hpage);
-		put_hwpoison_page(hpage);
-		return 0;
-	}
-
-	/*
 	 * It's very difficult to mess with pages currently under IO
 	 * and in many cases impossible, so we just avoid it here.
 	 */
@@ -1245,7 +1275,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 				break;
 	res = page_action(ps, p, pfn);
 out:
-	unlock_page(hpage);
+	unlock_page(p);
 	return res;
 }
 EXPORT_SYMBOL_GPL(memory_failure);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
