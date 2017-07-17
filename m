Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 835686B0313
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 15:40:31 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id e127so22240433qka.8
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 12:40:31 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id 69si84825qta.97.2017.07.17.12.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 12:40:30 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v9 09/10] mm: migrate: move_pages() supports thp migration
Date: Mon, 17 Jul 2017 15:39:54 -0400
Message-Id: <20170717193955.20207-10-zi.yan@sent.com>
In-Reply-To: <20170717193955.20207-1-zi.yan@sent.com>
References: <20170717193955.20207-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch enables thp migration for move_pages(2).

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

ChangeLog: v1 -> v5:
- fix page counting

ChangeLog: v5 -> v6:
- drop changes on soft-offline in unmap_and_move()

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/migrate.c | 45 ++++++++++++++++++++++++++++++++-------------
 1 file changed, 32 insertions(+), 13 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 0e2916f0c201..fd33aa444f47 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -184,8 +184,8 @@ void putback_movable_pages(struct list_head *l)
 			unlock_page(page);
 			put_page(page);
 		} else {
-			dec_node_page_state(page, NR_ISOLATED_ANON +
-					page_is_file_cache(page));
+			mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
+					page_is_file_cache(page), -hpage_nr_pages(page));
 			putback_lru_page(page);
 		}
 	}
@@ -1145,8 +1145,8 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		 * as __PageMovable
 		 */
 		if (likely(!__PageMovable(page)))
-			dec_node_page_state(page, NR_ISOLATED_ANON +
-					page_is_file_cache(page));
+			mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
+					page_is_file_cache(page), -hpage_nr_pages(page));
 	}
 
 	/*
@@ -1420,7 +1420,17 @@ static struct page *new_page_node(struct page *p, unsigned long private,
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
@@ -1447,6 +1457,8 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 	for (pp = pm; pp->node != MAX_NUMNODES; pp++) {
 		struct vm_area_struct *vma;
 		struct page *page;
+		struct page *head;
+		unsigned int follflags;
 
 		err = -EFAULT;
 		vma = find_vma(mm, pp->addr);
@@ -1454,8 +1466,10 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 			goto set_status;
 
 		/* FOLL_DUMP to ignore special (like zero) pages */
-		page = follow_page(vma, pp->addr,
-				FOLL_GET | FOLL_SPLIT | FOLL_DUMP);
+		follflags = FOLL_GET | FOLL_DUMP;
+		if (!thp_migration_supported())
+			follflags |= FOLL_SPLIT;
+		page = follow_page(vma, pp->addr, follflags);
 
 		err = PTR_ERR(page);
 		if (IS_ERR(page))
@@ -1465,7 +1479,6 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		if (!page)
 			goto set_status;
 
-		pp->page = page;
 		err = page_to_nid(page);
 
 		if (err == pp->node)
@@ -1480,16 +1493,22 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 			goto put_and_set;
 
 		if (PageHuge(page)) {
-			if (PageHead(page))
+			if (PageHead(page)) {
 				isolate_huge_page(page, &pagelist);
+				err = 0;
+				pp->page = page;
+			}
 			goto put_and_set;
 		}
 
-		err = isolate_lru_page(page);
+		pp->page = compound_head(page);
+		head = compound_head(page);
+		err = isolate_lru_page(head);
 		if (!err) {
-			list_add_tail(&page->lru, &pagelist);
-			inc_node_page_state(page, NR_ISOLATED_ANON +
-					    page_is_file_cache(page));
+			list_add_tail(&head->lru, &pagelist);
+			mod_node_page_state(page_pgdat(head),
+				NR_ISOLATED_ANON + page_is_file_cache(head),
+				hpage_nr_pages(head));
 		}
 put_and_set:
 		/*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
