Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD8976B02AF
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:24:14 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 16so306762680qtn.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:24:14 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id 31si14814984qtc.58.2016.09.26.08.24.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:24:14 -0700 (PDT)
From: zi.yan@sent.com
Subject: [PATCH v1 10/12] mm: migrate: move_pages() supports thp migration
Date: Mon, 26 Sep 2016 11:22:32 -0400
Message-Id: <20160926152234.14809-11-zi.yan@sent.com>
In-Reply-To: <20160926152234.14809-1-zi.yan@sent.com>
References: <20160926152234.14809-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch enables thp migration for move_pages(2).

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/migrate.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index dfca530..132e8db 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1417,7 +1417,17 @@ static struct page *new_page_node(struct page *p, unsigned long private,
 	if (PageHuge(p))
 		return alloc_huge_page_node(page_hstate(compound_head(p)),
 					pm->node);
-	else
+	else if (thp_migration_supported() && PageTransHuge(p)) {
+		struct page *thp;
+
+		thp = alloc_pages_node(pm->node,
+			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
+			HPAGE_PMD_ORDER);
+		if (!thp)
+			return NULL;
+		prep_transhuge_page(thp);
+		return thp;
+	} else
 		return __alloc_pages_node(pm->node,
 				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
 }
@@ -1444,6 +1454,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 	for (pp = pm; pp->node != MAX_NUMNODES; pp++) {
 		struct vm_area_struct *vma;
 		struct page *page;
+		unsigned int follflags;
 
 		err = -EFAULT;
 		vma = find_vma(mm, pp->addr);
@@ -1451,8 +1462,10 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 			goto set_status;
 
 		/* FOLL_DUMP to ignore special (like zero) pages */
-		page = follow_page(vma, pp->addr,
-				FOLL_GET | FOLL_SPLIT | FOLL_DUMP);
+		follflags = FOLL_GET | FOLL_SPLIT | FOLL_DUMP;
+		if (thp_migration_supported())
+			follflags &= ~FOLL_SPLIT;
+		page = follow_page(vma, pp->addr, follflags);
 
 		err = PTR_ERR(page);
 		if (IS_ERR(page))
@@ -1480,6 +1493,11 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 			if (PageHead(page))
 				isolate_huge_page(page, &pagelist);
 			goto put_and_set;
+		} else if (PageTransCompound(page)) {
+			if (PageTail(page)) {
+				err = pp->node;
+				goto put_and_set;
+			}
 		}
 
 		err = isolate_lru_page(page);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
