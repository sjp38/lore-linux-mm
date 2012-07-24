Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 773C26B004D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 11:12:51 -0400 (EDT)
Date: Tue, 24 Jul 2012 11:12:22 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm] remove __GFP_NO_KSWAPD
Message-ID: <20120724111222.2c5e6b30@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>

When transparent huge pages were introduced, memory compaction and
swap storms were an issue, and the kernel had to be careful to not
make THP allocations cause pageout or compaction.

Now that we have working compaction deferral, kswapd is smart enough
to invoke compaction and the quadratic behaviour around isolate_free_pages
has been fixed, it should be safe to remove __GFP_NO_KSWAPD.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
This has been running fine on my system for a while, but my system
only has 12GB and moderate memory pressure. I propose we keep this
in -mm and -next for a while, and merge it for 3.7 if nobody complains.

 include/linux/gfp.h |    5 +----
 mm/page_alloc.c     |    7 +++----
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 581e74b..4f3d4d2 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -34,7 +34,6 @@ struct vm_area_struct;
 #else
 #define ___GFP_NOTRACK		0
 #endif
-#define ___GFP_NO_KSWAPD	0x400000u
 #define ___GFP_OTHER_NODE	0x800000u
 #define ___GFP_WRITE		0x1000000u
 
@@ -84,7 +83,6 @@ struct vm_area_struct;
 #define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE) /* Page is reclaimable */
 #define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)  /* Don't track with kmemcheck */
 
-#define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
 #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
 #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
 
@@ -114,8 +112,7 @@ struct vm_area_struct;
 				 __GFP_MOVABLE)
 #define GFP_IOFS	(__GFP_IO | __GFP_FS)
 #define GFP_TRANSHUGE	(GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
-			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN | \
-			 __GFP_NO_KSWAPD)
+			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN)
 
 #ifdef CONFIG_NUMA
 #define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a13ded1..87b7721 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2217,9 +2217,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 
 restart:
-	if (!(gfp_mask & __GFP_NO_KSWAPD))
-		wake_all_kswapd(order, zonelist, high_zoneidx,
-						zone_idx(preferred_zone));
+	wake_all_kswapd(order, zonelist, high_zoneidx,
+					zone_idx(preferred_zone));
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
@@ -2286,7 +2285,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * has requested the system not be heavily disrupted, fail the
 	 * allocation now instead of entering direct reclaim
 	 */
-	if (deferred_compaction && (gfp_mask & __GFP_NO_KSWAPD))
+	if (deferred_compaction)
 		goto nopage;
 
 	/* Try direct reclaim and then allocating */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
