Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id DB997831CF
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 11:46:18 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o135so242811176qke.3
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:46:18 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id b6si687177qke.265.2017.03.13.08.46.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 08:46:18 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v4 08/11] mm: hwpoison: soft offline supports thp migration
Date: Mon, 13 Mar 2017 11:45:04 -0400
Message-Id: <20170313154507.3647-9-zi.yan@sent.com>
In-Reply-To: <20170313154507.3647-1-zi.yan@sent.com>
References: <20170313154507.3647-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch enables thp migration for soft offline.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 31 ++++++++++++-------------------
 1 file changed, 12 insertions(+), 19 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index b78d08016254..4c9f124c95c8 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1483,7 +1483,17 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
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
 
@@ -1691,28 +1701,11 @@ static int __soft_offline_page(struct page *page, int flags)
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
