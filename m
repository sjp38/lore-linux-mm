Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E495E6B0317
	for <linux-mm@kvack.org>; Thu, 25 May 2017 10:19:57 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id k74so82766774qke.4
        for <linux-mm@kvack.org>; Thu, 25 May 2017 07:19:57 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id 44si3191877qtx.46.2017.05.25.07.19.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 07:19:57 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v6 10/10] mm: memory_hotplug: memory hotremove supports thp migration
Date: Thu, 25 May 2017 10:19:45 -0400
Message-Id: <20170525141945.56028-11-zi.yan@sent.com>
In-Reply-To: <20170525141945.56028-1-zi.yan@sent.com>
References: <20170525141945.56028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com, dave.hansen@intel.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch enables thp migration for memory hotremove.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
ChangeLog v1->v2:
- base code switched from alloc_migrate_target to new_node_page()
---
 mm/memory_hotplug.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 599c675ad538..5572b183dcdd 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1429,6 +1429,7 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 	int nid = page_to_nid(page);
 	nodemask_t nmask = node_states[N_MEMORY];
 	struct page *new_page = NULL;
+	unsigned int order = 0;
 
 	/*
 	 * TODO: allocate a destination hugepage from a nearest neighbor node,
@@ -1439,6 +1440,11 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					next_node_in(nid, nmask));
 
+	if (thp_migration_supported() && PageTransHuge(page)) {
+		order = HPAGE_PMD_ORDER;
+		gfp_mask |= GFP_TRANSHUGE;
+	}
+
 	node_clear(nid, nmask);
 
 	if (PageHighMem(page)
@@ -1446,12 +1452,15 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 		gfp_mask |= __GFP_HIGHMEM;
 
 	if (!nodes_empty(nmask))
-		new_page = __alloc_pages_nodemask(gfp_mask, 0,
+		new_page = __alloc_pages_nodemask(gfp_mask, order,
 					node_zonelist(nid, gfp_mask), &nmask);
 	if (!new_page)
-		new_page = __alloc_pages(gfp_mask, 0,
+		new_page = __alloc_pages(gfp_mask, order,
 					node_zonelist(nid, gfp_mask));
 
+	if (new_page && PageTransHuge(page))
+		prep_transhuge_page(new_page);
+
 	return new_page;
 }
 
@@ -1481,7 +1490,9 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
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
