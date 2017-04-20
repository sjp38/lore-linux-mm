Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 23DC96B03A5
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 16:48:00 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m91so17003481qte.10
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 13:48:00 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id t31si7067676qta.184.2017.04.20.13.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 13:47:59 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v5 08/11] mm: hwpoison: soft offline supports thp migration
Date: Thu, 20 Apr 2017 16:47:49 -0400
Message-Id: <20170420204752.79703-9-zi.yan@sent.com>
In-Reply-To: <20170420204752.79703-1-zi.yan@sent.com>
References: <20170420204752.79703-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch enables thp migration for soft offline.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

ChangeLog: v1 -> v5:
- fix page isolation counting error

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/memory-failure.c | 35 ++++++++++++++---------------------
 1 file changed, 14 insertions(+), 21 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 9b77476ef31f..23ff02eb3ed4 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1481,7 +1481,17 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
 	if (PageHuge(p))
 		return alloc_huge_page_node(page_hstate(compound_head(p)),
 						   nid);
-	else
+	else if (thp_migration_supported() && PageTransHuge(p)) {
+		struct page *thp;
+
+		thp = alloc_pages_node(nid,
+			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
+			HPAGE_PMD_ORDER);
+		if (!thp)
+			return NULL;
+		prep_transhuge_page(thp);
+		return thp;
+	} else
 		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
 }
 
@@ -1665,8 +1675,8 @@ static int __soft_offline_page(struct page *page, int flags)
 		 * cannot have PAGE_MAPPING_MOVABLE.
 		 */
 		if (!__PageMovable(page))
-			inc_node_page_state(page, NR_ISOLATED_ANON +
-						page_is_file_cache(page));
+			mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
+						page_is_file_cache(page), hpage_nr_pages(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
@@ -1689,28 +1699,11 @@ static int __soft_offline_page(struct page *page, int flags)
 static int soft_offline_in_use_page(struct page *page, int flags)
 {
 	int ret;
-	struct page *hpage = compound_head(page);
-
-	if (!PageHuge(page) && PageTransHuge(hpage)) {
-		lock_page(hpage);
-		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
-			unlock_page(hpage);
-			if (!PageAnon(hpage))
-				pr_info("soft offline: %#lx: non anonymous thp\n", page_to_pfn(page));
-			else
-				pr_info("soft offline: %#lx: thp split failed\n", page_to_pfn(page));
-			put_hwpoison_page(hpage);
-			return -EBUSY;
-		}
-		unlock_page(hpage);
-		get_hwpoison_page(page);
-		put_hwpoison_page(hpage);
-	}
 
 	if (PageHuge(page))
 		ret = soft_offline_huge_page(page, flags);
 	else
-		ret = __soft_offline_page(page, flags);
+		ret = __soft_offline_page(compound_head(page), flags);
 
 	return ret;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
