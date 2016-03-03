Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 06E6F6B0261
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 02:42:40 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 63so10165459pfe.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:39 -0800 (PST)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id a6si2609340pfj.20.2016.03.02.23.42.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 23:42:39 -0800 (PST)
Received: by mail-pf0-x22a.google.com with SMTP id 124so10273937pfg.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:39 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 11/11] mm: memory_hotplug: memory hotremove supports thp migration
Date: Thu,  3 Mar 2016 16:41:58 +0900
Message-Id: <1456990918-30906-12-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

This patch enables thp migration for memory hotremove. Stub definition of
prep_transhuge_page() is added for CONFIG_TRANSPARENT_HUGEPAGE=n.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/huge_mm.h | 3 +++
 mm/memory_hotplug.c     | 8 ++++++++
 mm/page_isolation.c     | 8 ++++++++
 3 files changed, 19 insertions(+)

diff --git v4.5-rc5-mmotm-2016-02-24-16-18/include/linux/huge_mm.h v4.5-rc5-mmotm-2016-02-24-16-18_patched/include/linux/huge_mm.h
index 09b215d..7944346 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/include/linux/huge_mm.h
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/include/linux/huge_mm.h
@@ -175,6 +175,9 @@ static inline bool thp_migration_supported(void)
 #define transparent_hugepage_enabled(__vma) 0
 
 #define transparent_hugepage_flags 0UL
+static inline void prep_transhuge_page(struct page *page)
+{
+}
 static inline int
 split_huge_page_to_list(struct page *page, struct list_head *list)
 {
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/memory_hotplug.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/memory_hotplug.c
index e62aa07..b4b23d5 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/mm/memory_hotplug.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/memory_hotplug.c
@@ -1511,6 +1511,14 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
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
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/page_isolation.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/page_isolation.c
index 92c4c36..b2d22e8 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/mm/page_isolation.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/page_isolation.c
@@ -294,6 +294,14 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
 		nodes_complement(dst, src);
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					    next_node(page_to_nid(page), dst));
+	} else if (thp_migration_supported() && PageTransHuge(page)) {
+		struct page *thp;
+
+		thp = alloc_pages(GFP_TRANSHUGE, HPAGE_PMD_ORDER);
+		if (!thp)
+			return NULL;
+		prep_transhuge_page(thp);
+		return thp;
 	}
 
 	if (PageHighMem(page))
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
