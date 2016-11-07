Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 69A9D6B0253
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 18:41:32 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n85so57895755pfi.4
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:41:32 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id 26si33391757pfo.279.2016.11.07.15.32.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:32:44 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id n85so17317255pfi.3
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:32:44 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 12/12] mm: memory_hotplug: memory hotremove supports thp migration
Date: Tue,  8 Nov 2016 08:31:57 +0900
Message-Id: <1478561517-4317-13-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

This patch enables thp migration for memory hotremove.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
ChangeLog v1->v2:
- base code switched from alloc_migrate_target to new_node_page()
---
 mm/memory_hotplug.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/memory_hotplug.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memory_hotplug.c
index b18dab40..a9c3fe1 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/mm/memory_hotplug.c
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memory_hotplug.c
@@ -1543,6 +1543,7 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 	int nid = page_to_nid(page);
 	nodemask_t nmask = node_states[N_MEMORY];
 	struct page *new_page = NULL;
+	unsigned int order = 0;
 
 	/*
 	 * TODO: allocate a destination hugepage from a nearest neighbor node,
@@ -1553,6 +1554,11 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					next_node_in(nid, nmask));
 
+	if (thp_migration_supported() && PageTransHuge(page)) {
+		order = HPAGE_PMD_ORDER;
+		gfp_mask |= GFP_TRANSHUGE;
+	}
+
 	node_clear(nid, nmask);
 
 	if (PageHighMem(page)
@@ -1560,12 +1566,15 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 		gfp_mask |= __GFP_HIGHMEM;
 
 	if (!nodes_empty(nmask))
-		new_page = __alloc_pages_nodemask(gfp_mask, 0,
+		new_page = __alloc_pages_nodemask(gfp_mask, order,
 					node_zonelist(nid, gfp_mask), &nmask);
 	if (!new_page)
-		new_page = __alloc_pages(gfp_mask, 0,
+		new_page = __alloc_pages(gfp_mask, order,
 					node_zonelist(nid, gfp_mask));
 
+	if (new_page && order == HPAGE_PMD_ORDER)
+		prep_transhuge_page(new_page);
+
 	return new_page;
 }
 
@@ -1595,7 +1604,9 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			if (isolate_huge_page(page, &source))
 				move_pages -= 1 << compound_order(head);
 			continue;
-		}
+		} else if (thp_migration_supported() && PageTransHuge(page))
+			pfn = page_to_pfn(compound_head(page))
+				+ HPAGE_PMD_NR - 1;
 
 		if (!get_page_unless_zero(page))
 			continue;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
