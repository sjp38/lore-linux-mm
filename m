Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF1106B0011
	for <linux-mm@kvack.org>; Thu,  3 May 2018 19:29:55 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id x2-v6so14548602qto.10
        for <linux-mm@kvack.org>; Thu, 03 May 2018 16:29:55 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id b40-v6si13359092qvb.240.2018.05.03.16.29.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 16:29:54 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 2/4] mm: check for proper migrate type during isolation
Date: Thu,  3 May 2018 16:29:33 -0700
Message-Id: <20180503232935.22539-3-mike.kravetz@oracle.com>
In-Reply-To: <20180503232935.22539-1-mike.kravetz@oracle.com>
References: <20180503232935.22539-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Reinette Chatre <reinette.chatre@intel.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

The routine start_isolate_page_range and alloc_contig_range have
comments saying that migratetype must be either MIGRATE_MOVABLE or
MIGRATE_CMA.  However, this is not enforced.  What is important is
that that all pageblocks in the range are of type migratetype.
This is because blocks will be set to migratetype on error.

Add a boolean argument enforce_migratetype to the routine
start_isolate_page_range.  If set, it will check that all pageblocks
in the range have the passed migratetype.  Return -EINVAL is pageblock
is wrong type is found in range.

A boolean is used for enforce_migratetype as there are two primary
users.  Contiguous range allocation which wants to enforce migration
type checking.  Memory offline (hotplug) which is not concerned about
type checking.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/page-isolation.h |  8 +++-----
 mm/memory_hotplug.c            |  2 +-
 mm/page_alloc.c                | 17 +++++++++--------
 mm/page_isolation.c            | 40 ++++++++++++++++++++++++++++++----------
 4 files changed, 43 insertions(+), 24 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 4ae347cbc36d..2ab7e5a399ac 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -38,8 +38,6 @@ int move_freepages_block(struct zone *zone, struct page *page,
 
 /*
  * Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE.
- * If specified range includes migrate types other than MOVABLE or CMA,
- * this will fail with -EBUSY.
  *
  * For isolating all pages in the range finally, the caller have to
  * free all pages in the range. test_page_isolated() can be used for
@@ -47,11 +45,11 @@ int move_freepages_block(struct zone *zone, struct page *page,
  */
 int
 start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
-			 unsigned migratetype, bool skip_hwpoisoned_pages);
+			 unsigned migratetype, bool skip_hwpoisoned_pages,
+			 bool enforce_migratetype);
 
 /*
- * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
- * target range is [start_pfn, end_pfn)
+ * Changes MIGRATE_ISOLATE to migratetype for range [start_pfn, end_pfn)
  */
 int
 undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f74826cdceea..ebc1c8c330e2 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1601,7 +1601,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 
 	/* set above range as isolated */
 	ret = start_isolate_page_range(start_pfn, end_pfn,
-				       MIGRATE_MOVABLE, true);
+				       MIGRATE_MOVABLE, true, false);
 	if (ret)
 		return ret;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0fd5e8e2456e..cb1a5e0be6ee 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7787,9 +7787,10 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
  * alloc_contig_range() -- tries to allocate given range of pages
  * @start:	start PFN to allocate
  * @end:	one-past-the-last PFN to allocate
- * @migratetype:	migratetype of the underlaying pageblocks (either
- *			#MIGRATE_MOVABLE or #MIGRATE_CMA).  All pageblocks
- *			in range must have the same migratetype and it must
+ * @migratetype:	migratetype of the underlaying pageblocks.  All
+ *			pageblocks in range must have the same migratetype.
+ *			migratetype is typically MIGRATE_MOVABLE or
+ *			MIGRATE_CMA, but this is not a requirement.
  *			be either of the two.
  * @gfp_mask:	GFP mask to use during compaction
  *
@@ -7840,15 +7841,15 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	 * allocator removing them from the buddy system.  This way
 	 * page allocator will never consider using them.
 	 *
-	 * This lets us mark the pageblocks back as
-	 * MIGRATE_CMA/MIGRATE_MOVABLE so that free pages in the
-	 * aligned range but not in the unaligned, original range are
-	 * put back to page allocator so that buddy can use them.
+	 * This lets us mark the pageblocks back as their original
+	 * migrate type so that free pages in the  aligned range but
+	 * not in the unaligned, original range are put back to page
+	 * allocator so that buddy can use them.
 	 */
 
 	ret = start_isolate_page_range(pfn_max_align_down(start),
 				       pfn_max_align_up(end), migratetype,
-				       false);
+				       false, true);
 	if (ret)
 		return ret;
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 43e085608846..472191cc1909 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -16,7 +16,8 @@
 #include <trace/events/page_isolation.h>
 
 static int set_migratetype_isolate(struct page *page, int migratetype,
-				bool skip_hwpoisoned_pages)
+				bool skip_hwpoisoned_pages,
+				bool enforce_migratetype)
 {
 	struct zone *zone;
 	unsigned long flags, pfn;
@@ -36,6 +37,17 @@ static int set_migratetype_isolate(struct page *page, int migratetype,
 	if (is_migrate_isolate_page(page))
 		goto out;
 
+	/*
+	 * If requested, check migration type of pageblock and make sure
+	 * it matches migratetype
+	 */
+	if (enforce_migratetype) {
+		if (get_pageblock_migratetype(page) != migratetype) {
+			ret = -EINVAL;
+			goto out;
+		}
+	}
+
 	pfn = page_to_pfn(page);
 	arg.start_pfn = pfn;
 	arg.nr_pages = pageblock_nr_pages;
@@ -167,14 +179,16 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
  * to be MIGRATE_ISOLATE.
  * @start_pfn: The lower PFN of the range to be isolated.
  * @end_pfn: The upper PFN of the range to be isolated.
- * @migratetype: migrate type to set in error recovery.
+ * @migratetype: migrate type of all blocks in range.
  *
  * Making page-allocation-type to be MIGRATE_ISOLATE means free pages in
  * the range will never be allocated. Any free pages and pages freed in the
  * future will not be allocated again.
  *
  * start_pfn/end_pfn must be aligned to pageblock_order.
- * Return 0 on success and -EBUSY if any part of range cannot be isolated.
+ * Return 0 on success or error returned by set_migratetype_isolate.  Typical
+ * errors are -EBUSY if any part of range cannot be isolated or -EINVAL if
+ * any page block is not of migratetype.
  *
  * There is no high level synchronization mechanism that prevents two threads
  * from trying to isolate overlapping ranges.  If this happens, one thread
@@ -185,11 +199,13 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
  * prevents two threads from simultaneously working on overlapping ranges.
  */
 int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
-			     unsigned migratetype, bool skip_hwpoisoned_pages)
+			     unsigned migratetype, bool skip_hwpoisoned_pages,
+			     bool enforce_migratetype)
 {
 	unsigned long pfn;
 	unsigned long undo_pfn;
 	struct page *page;
+	int ret = 0;
 
 	BUG_ON(!IS_ALIGNED(start_pfn, pageblock_nr_pages));
 	BUG_ON(!IS_ALIGNED(end_pfn, pageblock_nr_pages));
@@ -198,13 +214,17 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	     pfn < end_pfn;
 	     pfn += pageblock_nr_pages) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
-		if (page &&
-		    set_migratetype_isolate(page, migratetype, skip_hwpoisoned_pages)) {
-			undo_pfn = pfn;
-			goto undo;
+		if (page) {
+			ret = set_migratetype_isolate(page, migratetype,
+							skip_hwpoisoned_pages,
+							enforce_migratetype);
+			if (ret) {
+				undo_pfn = pfn;
+				goto undo;
+			}
 		}
 	}
-	return 0;
+	return ret;
 undo:
 	for (pfn = start_pfn;
 	     pfn < undo_pfn;
@@ -215,7 +235,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 		unset_migratetype_isolate(page, migratetype);
 	}
 
-	return -EBUSY;
+	return ret;
 }
 
 /*
-- 
2.13.6
