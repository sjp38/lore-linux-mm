Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFC886B02B0
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:24:15 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id y10so305654275qty.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:24:15 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id 42si6387972qkr.224.2016.09.26.08.24.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:24:15 -0700 (PDT)
From: zi.yan@sent.com
Subject: [PATCH v1 11/12] mm: memory_hotplug: memory hotremove supports thp migration
Date: Mon, 26 Sep 2016 11:22:33 -0400
Message-Id: <20160926152234.14809-12-zi.yan@sent.com>
In-Reply-To: <20160926152234.14809-1-zi.yan@sent.com>
References: <20160926152234.14809-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch enables thp migration for memory hotremove. Stub definition of
prep_transhuge_page() is added for CONFIG_TRANSPARENT_HUGEPAGE=n.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/huge_mm.h | 3 +++
 mm/memory_hotplug.c     | 8 ++++++++
 mm/page_isolation.c     | 9 +++++++++
 3 files changed, 20 insertions(+)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 4ae156e..fe8766dc 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -174,6 +174,9 @@ static inline bool thp_migration_supported(void)
 static inline void prep_transhuge_page(struct page *page) {}
 
 #define transparent_hugepage_flags 0UL
+static inline void prep_transhuge_page(struct page *page)
+{
+}
 static inline int
 split_huge_page_to_list(struct page *page, struct list_head *list)
 {
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b58906b..6abe898 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1609,6 +1609,14 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			if (isolate_huge_page(page, &source))
 				move_pages -= 1 << compound_order(head);
 			continue;
+		} else if (thp_migration_supported() && PageTransHuge(page)) {
+			struct page *head = compound_head(page);
+
+			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
+			if (compound_order(head) > PFN_SECTION_SHIFT) {
+				ret = -EBUSY;
+				break;
+			}
 		}
 
 		if (!get_page_unless_zero(page))
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 064b7fb..43ecdf6 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -294,6 +294,15 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					    next_node_in(page_to_nid(page),
 							 node_online_map));
+	else if (thp_migration_supported() && PageTransHuge(page)) {
+		struct page *thp;
+
+		thp = alloc_pages(GFP_TRANSHUGE, HPAGE_PMD_ORDER);
+		if (!thp)
+			return NULL;
+		prep_transhuge_page(thp);
+		return thp;
+	}
 
 	if (PageHighMem(page))
 		gfp_mask |= __GFP_HIGHMEM;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
