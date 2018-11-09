Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 104856B0696
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 01:47:35 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id n22-v6so787488pff.2
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 22:47:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b21-v6sor8159922pfj.13.2018.11.08.22.47.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 22:47:33 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC][PATCH v1 02/11] mm: soft-offline: add missing error check of set_hwpoison_free_buddy_page()
Date: Fri,  9 Nov 2018 15:47:06 +0900
Message-Id: <1541746035-13408-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>

set_hwpoison_free_buddy_page() could fail, then the target page is
finally not isolated, so it's better to report -EBUSY for userspace
to know the failure and chance of retry.

And for consistency, this patch moves set_hwpoison_free_buddy_page()
in unmap_and_move() to __soft_offline_page().

Fixes: 6bc9b56433b7 ("mm: fix race on soft-offlining free huge pages")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 15 ++++++++++++---
 mm/migrate.c        |  9 ---------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git v4.19-mmotm-2018-10-30-16-08/mm/memory-failure.c v4.19-mmotm-2018-10-30-16-08_patched/mm/memory-failure.c
index 9f09bf3..11e283e 100644
--- v4.19-mmotm-2018-10-30-16-08/mm/memory-failure.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/mm/memory-failure.c
@@ -1719,14 +1719,18 @@ static int soft_offline_huge_page(struct page *page, int flags)
 		/*
 		 * We set PG_hwpoison only when the migration source hugepage
 		 * was successfully dissolved, because otherwise hwpoisoned
-		 * hugepage remains on free hugepage list, then userspace will
-		 * find it as SIGBUS by allocation failure. That's not expected
-		 * in soft-offlining.
+		 * hugepage remains on free hugepage list. The allocator ignores
+		 * such a hwpoisoned page so it's never allocated, but it could
+		 * kill a process because of no-memory rather than hwpoison.
+		 * Soft-offline never impacts the userspace, so this is
+		 * undesired.
 		 */
 		ret = dissolve_free_huge_page(page);
 		if (!ret) {
 			if (set_hwpoison_free_buddy_page(page))
 				num_poisoned_pages_inc();
+			else
+				ret = -EBUSY;
 		}
 	}
 	return ret;
@@ -1804,6 +1808,11 @@ static int __soft_offline_page(struct page *page, int flags)
 				pfn, ret, page->flags, &page->flags);
 			if (ret > 0)
 				ret = -EIO;
+		} else {
+			if (set_hwpoison_free_buddy_page(page))
+				num_poisoned_pages_inc();
+			else
+				ret = -EBUSY;
 		}
 	} else {
 		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %lx (%pGp)\n",
diff --git v4.19-mmotm-2018-10-30-16-08/mm/migrate.c v4.19-mmotm-2018-10-30-16-08_patched/mm/migrate.c
index f7e4bfd..1742372 100644
--- v4.19-mmotm-2018-10-30-16-08/mm/migrate.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/mm/migrate.c
@@ -1199,15 +1199,6 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 	 */
 	if (rc == MIGRATEPAGE_SUCCESS) {
 		put_page(page);
-		if (reason == MR_MEMORY_FAILURE) {
-			/*
-			 * Set PG_HWPoison on just freed page
-			 * intentionally. Although it's rather weird,
-			 * it's how HWPoison flag works at the moment.
-			 */
-			if (set_hwpoison_free_buddy_page(page))
-				num_poisoned_pages_inc();
-		}
 	} else {
 		if (rc != -EAGAIN) {
 			if (likely(!__PageMovable(page))) {
-- 
2.7.0
