Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id D25596B006C
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 10:14:40 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/7] mm: remove __GFP_NO_KSWAPD
Date: Fri, 17 Aug 2012 15:14:30 +0100
Message-Id: <1345212873-22447-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1345212873-22447-1-git-send-email-mgorman@suse.de>
References: <1345212873-22447-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

When transparent huge pages were introduced, memory compaction and swap
storms were an issue, and the kernel had to be careful to not make THP
allocations cause pageout or compaction.

Now that we have working compaction deferral, kswapd is smart enough to
invoke compaction and the quadratic behaviour around isolate_free_pages
has been fixed, it should be safe to remove __GFP_NO_KSWAPD.

[minchan@kernel.org: Comment fix]
[mgorman@suse.de: Avoid direct reclaim for deferred compaction]
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 drivers/mtd/mtdcore.c           |    6 ++----
 include/linux/gfp.h             |    5 +----
 include/trace/events/gfpflags.h |    1 -
 mm/page_alloc.c                 |    7 +++----
 4 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/mtd/mtdcore.c b/drivers/mtd/mtdcore.c
index ec794a7..374c46d 100644
--- a/drivers/mtd/mtdcore.c
+++ b/drivers/mtd/mtdcore.c
@@ -1077,8 +1077,7 @@ EXPORT_SYMBOL_GPL(mtd_writev);
  * until the request succeeds or until the allocation size falls below
  * the system page size. This attempts to make sure it does not adversely
  * impact system performance, so when allocating more than one page, we
- * ask the memory allocator to avoid re-trying, swapping, writing back
- * or performing I/O.
+ * ask the memory allocator to avoid re-trying.
  *
  * Note, this function also makes sure that the allocated buffer is aligned to
  * the MTD device's min. I/O unit, i.e. the "mtd->writesize" value.
@@ -1092,8 +1091,7 @@ EXPORT_SYMBOL_GPL(mtd_writev);
  */
 void *mtd_kmalloc_up_to(const struct mtd_info *mtd, size_t *size)
 {
-	gfp_t flags = __GFP_NOWARN | __GFP_WAIT |
-		       __GFP_NORETRY | __GFP_NO_KSWAPD;
+	gfp_t flags = __GFP_NOWARN | __GFP_WAIT | __GFP_NORETRY;
 	size_t min_alloc = max_t(size_t, mtd->writesize, PAGE_SIZE);
 	void *kbuf;
 
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 4883f39..f9bc873 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -35,7 +35,6 @@ struct vm_area_struct;
 #else
 #define ___GFP_NOTRACK		0
 #endif
-#define ___GFP_NO_KSWAPD	0x400000u
 #define ___GFP_OTHER_NODE	0x800000u
 #define ___GFP_WRITE		0x1000000u
 
@@ -90,7 +89,6 @@ struct vm_area_struct;
 #define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE) /* Page is reclaimable */
 #define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)  /* Don't track with kmemcheck */
 
-#define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
 #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
 #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
 
@@ -120,8 +118,7 @@ struct vm_area_struct;
 				 __GFP_MOVABLE)
 #define GFP_IOFS	(__GFP_IO | __GFP_FS)
 #define GFP_TRANSHUGE	(GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
-			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN | \
-			 __GFP_NO_KSWAPD)
+			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN)
 
 #ifdef CONFIG_NUMA
 #define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
index d6fd8e5..9391706 100644
--- a/include/trace/events/gfpflags.h
+++ b/include/trace/events/gfpflags.h
@@ -36,7 +36,6 @@
 	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
 	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"},		\
 	{(unsigned long)__GFP_NOTRACK,		"GFP_NOTRACK"},		\
-	{(unsigned long)__GFP_NO_KSWAPD,	"GFP_NO_KSWAPD"},	\
 	{(unsigned long)__GFP_OTHER_NODE,	"GFP_OTHER_NODE"}	\
 	) : "GFP_NOWAIT"
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0a71d32..b83199b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2350,9 +2350,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 
 restart:
-	if (!(gfp_mask & __GFP_NO_KSWAPD))
-		wake_all_kswapd(order, zonelist, high_zoneidx,
-						zone_idx(preferred_zone));
+	wake_all_kswapd(order, zonelist, high_zoneidx,
+					zone_idx(preferred_zone));
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
@@ -2437,7 +2436,7 @@ rebalance:
 	 * system then fail the allocation instead of entering direct reclaim.
 	 */
 	if ((deferred_compaction || contended_compaction) &&
-						(gfp_mask & __GFP_NO_KSWAPD))
+	    (gfp_mask & (__GFP_MOVABLE|__GFP_REPEAT)) == __GFP_MOVABLE)
 		goto nopage;
 
 	/* Try direct reclaim and then allocating */
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
