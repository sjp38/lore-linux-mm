Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8336B02AD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:24:13 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id y10so305653128qty.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:24:13 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id w196si14794913qka.203.2016.09.26.08.24.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:24:12 -0700 (PDT)
From: zi.yan@sent.com
Subject: [PATCH v1 08/12] mm: hwpoison: soft offline supports thp migration
Date: Mon, 26 Sep 2016 11:22:30 -0400
Message-Id: <20160926152234.14809-9-zi.yan@sent.com>
In-Reply-To: <20160926152234.14809-1-zi.yan@sent.com>
References: <20160926152234.14809-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch enables thp migration for soft offline.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 31 ++++++++++++-------------------
 1 file changed, 12 insertions(+), 19 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index e105f91..36eb064 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1494,7 +1494,17 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
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
 
@@ -1697,28 +1707,11 @@ static int __soft_offline_page(struct page *page, int flags)
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
