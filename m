Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id DC7E7828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 12:50:28 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id 128so177137487wmz.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 09:50:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iy4si11468697wjb.144.2016.02.03.09.50.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 09:50:27 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, hugetlb: don't require CMA for runtime gigantic pages
Date: Wed,  3 Feb 2016 18:50:11 +0100
Message-Id: <1454521811-11409-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Luiz Capitulino <lcapitulino@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>, Davidlohr Bueso <dave@stgolabs.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>

Commit 944d9fec8d7a ("hugetlb: add support for gigantic page allocation at
runtime") has added the runtime gigantic page allocation via
alloc_contig_range(), making this support available only when CONFIG_CMA is
enabled. Because it doesn't depend on MIGRATE_CMA pageblocks and the
associated infrastructure, it is possible with few simple adjustments to
require only CONFIG_MEMORY_ISOLATION instead of full CONFIG_CMA.

After this patch, alloc_contig_range() and related functions are available
and used for gigantic pages with just CONFIG_MEMORY_ISOLATION enabled. Note
CONFIG_CMA selects CONFIG_MEMORY_ISOLATION. This allows supporting runtime
gigantic pages without the CMA-specific checks in page allocator fastpaths.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Luiz Capitulino <lcapitulino@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/gfp.h | 6 +++---
 mm/hugetlb.c        | 2 +-
 mm/page_alloc.c     | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 8942af0813e3..752bb6259218 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -539,16 +539,16 @@ static inline bool pm_suspended_storage(void)
 }
 #endif /* CONFIG_PM_SLEEP */
 
-#ifdef CONFIG_CMA
-
+#ifdef CONFIG_MEMORY_ISOLATION
 /* The below functions must be run on a range from a single zone. */
 extern int alloc_contig_range(unsigned long start, unsigned long end,
 			      unsigned migratetype);
 extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
+#endif
 
+#ifdef CONFIG_CMA
 /* CMA stuff */
 extern void init_cma_reserved_pageblock(struct page *page);
-
 #endif
 
 #endif /* __LINUX_GFP_H */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ef6963b577fd..66529a1c7929 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1002,7 +1002,7 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
 		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
 		nr_nodes--)
 
-#if defined(CONFIG_CMA) && defined(CONFIG_X86_64)
+#if defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_X86_64)
 static void destroy_compound_gigantic_page(struct page *page,
 					unsigned int order)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d666df5ef95..29c530cdd7f4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6599,7 +6599,7 @@ bool is_pageblock_removable_nolock(struct page *page)
 	return !has_unmovable_pages(zone, page, 0, true);
 }
 
-#ifdef CONFIG_CMA
+#ifdef CONFIG_MEMORY_ISOLATION
 
 static unsigned long pfn_max_align_down(unsigned long pfn)
 {
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
