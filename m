Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF66A6B0338
	for <linux-mm@kvack.org>; Sat,  1 Jul 2017 09:40:54 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id m54so68918845qtb.9
        for <linux-mm@kvack.org>; Sat, 01 Jul 2017 06:40:54 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id h73si10112406qka.69.2017.07.01.06.40.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jul 2017 06:40:53 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v8 10/10] mm: memory_hotplug: memory hotremove supports thp migration
Date: Sat,  1 Jul 2017 09:40:08 -0400
Message-Id: <20170701134008.110579-11-zi.yan@sent.com>
In-Reply-To: <20170701134008.110579-1-zi.yan@sent.com>
References: <20170701134008.110579-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch enables thp migration for memory hotremove.

---
ChangeLog v1->v2:
- base code switched from alloc_migrate_target to new_node_page()

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

ChangeLog v2->v7:
- base code switched from new_node_page() new_page_nodemask()

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 include/linux/migrate.h | 15 ++++++++++++++-
 mm/memory_hotplug.c     |  4 +++-
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 67ca33665e83..ff1f76683ee6 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -35,16 +35,29 @@ static inline struct page *new_page_nodemask(struct page *page, int preferred_ni
 		nodemask_t *nodemask)
 {
 	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE | __GFP_RETRY_MAYFAIL;
+	unsigned int order = 0;
+	struct page *new_page = NULL;
 
 	if (PageHuge(page))
 		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
 				preferred_nid, nodemask);
 
+	if (thp_migration_supported() && PageTransHuge(page)) {
+		order = HPAGE_PMD_ORDER;
+		gfp_mask |= GFP_TRANSHUGE;
+	}
+
 	if (PageHighMem(page)
 	    || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
 		gfp_mask |= __GFP_HIGHMEM;
 
-	return __alloc_pages_nodemask(gfp_mask, 0, preferred_nid, nodemask);
+	new_page = __alloc_pages_nodemask(gfp_mask, order,
+				preferred_nid, nodemask);
+
+	if (new_page && PageTransHuge(page))
+		prep_transhuge_page(new_page);
+
+	return new_page;
 }
 
 #ifdef CONFIG_MIGRATION
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 57b03be3a8da..72110ea2ee1b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1416,7 +1416,9 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
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
