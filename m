Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id AEBAA831CE
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 11:46:19 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n141so238941146qke.1
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:46:19 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id p89si703695qtd.31.2017.03.13.08.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 08:46:18 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v4 11/11] mm: memory_hotplug: memory hotremove supports thp migration
Date: Mon, 13 Mar 2017 11:45:07 -0400
Message-Id: <20170313154507.3647-12-zi.yan@sent.com>
In-Reply-To: <20170313154507.3647-1-zi.yan@sent.com>
References: <20170313154507.3647-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch enables thp migration for memory hotremove.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
ChangeLog v1->v2:
- base code switched from alloc_migrate_target to new_node_page()
---
 include/linux/huge_mm.h |  8 ++++++++
 mm/memory_hotplug.c     | 17 ++++++++++++++---
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 6f44a2352597..92c2161704c3 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -189,6 +189,13 @@ static inline int hpage_nr_pages(struct page *page)
 	return 1;
 }
 
+static inline int hpage_order(struct page *page)
+{
+	if (unlikely(PageTransHuge(page)))
+		return HPAGE_PMD_ORDER;
+	return 0;
+}
+
 struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 		pmd_t *pmd, int flags);
 struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
@@ -233,6 +240,7 @@ static inline bool thp_migration_supported(void)
 #define HPAGE_PUD_SIZE ({ BUILD_BUG(); 0; })
 
 #define hpage_nr_pages(x) 1
+#define hpage_order(x) 0
 
 #define transparent_hugepage_enabled(__vma) 0
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6fb6bd2df787..2b014017a217 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1566,6 +1566,7 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 	int nid = page_to_nid(page);
 	nodemask_t nmask = node_states[N_MEMORY];
 	struct page *new_page = NULL;
+	unsigned int order = 0;
 
 	/*
 	 * TODO: allocate a destination hugepage from a nearest neighbor node,
@@ -1576,6 +1577,11 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					next_node_in(nid, nmask));
 
+	if (thp_migration_supported() && PageTransHuge(page)) {
+		order = hpage_order(page);
+		gfp_mask |= GFP_TRANSHUGE;
+	}
+
 	node_clear(nid, nmask);
 
 	if (PageHighMem(page)
@@ -1583,12 +1589,15 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 		gfp_mask |= __GFP_HIGHMEM;
 
 	if (!nodes_empty(nmask))
-		new_page = __alloc_pages_nodemask(gfp_mask, 0,
+		new_page = __alloc_pages_nodemask(gfp_mask, order,
 					node_zonelist(nid, gfp_mask), &nmask);
 	if (!new_page)
-		new_page = __alloc_pages(gfp_mask, 0,
+		new_page = __alloc_pages(gfp_mask, order,
 					node_zonelist(nid, gfp_mask));
 
+	if (new_page && order == hpage_order(page))
+		prep_transhuge_page(new_page);
+
 	return new_page;
 }
 
@@ -1618,7 +1627,9 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			if (isolate_huge_page(page, &source))
 				move_pages -= 1 << compound_order(head);
 			continue;
-		}
+		} else if (thp_migration_supported() && PageTransHuge(page))
+			pfn = page_to_pfn(compound_head(page))
+				+ hpage_nr_pages(page) - 1;
 
 		if (!get_page_unless_zero(page))
 			continue;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
