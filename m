Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id F35B66B006C
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 03:14:58 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/5] vmscan: Fix obsolete comment of balance_pgdat
Date: Wed, 22 Aug 2012 16:15:13 +0900
Message-Id: <1345619717-5322-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1345619717-5322-1-git-send-email-minchan@kernel.org>
References: <1345619717-5322-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Nick Piggin <npiggin@kernel.dk>

This patch correct obsolete comment caused by [1] and [2].

[1] 7ac6218, kswapd lockup fix
[2] 32a4330, mm: prevent kswapd from freeing excessive amounts of lowmem

Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Nick Piggin <npiggin@kernel.dk>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8d01243..f015d92 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2472,16 +2472,17 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
  * This can happen if the pages are all mlocked, or if they are all used by
  * device drivers (say, ZONE_DMA).  Or if they are all in use by hugetlb.
  * What we do is to detect the case where all pages in the zone have been
- * scanned twice and there has been zero successful reclaim.  Mark the zone as
- * dead and from now on, only perform a short scan.  Basically we're polling
- * the zone for when the problem goes away.
+ * scanned above 6 times of the number of reclaimable pages and there has
+ * been zero successful reclaim.  Mark the zone as dead and from now on,
+ * only perform a short scan. Basically we're polling the zone for when
+ * the problem goes away.
  *
  * kswapd scans the zones in the highmem->normal->dma direction.  It skips
  * zones which have free_pages > high_wmark_pages(zone), but once a zone is
- * found to have free_pages <= high_wmark_pages(zone), we scan that zone and the
- * lower zones regardless of the number of free pages in the lower zones. This
- * interoperates with the page allocator fallback scheme to ensure that aging
- * of pages is balanced across the zones.
+ * found to have free_pages <= high_wmark_pages(zone), we scan that zone and
+ * lower zones which don't have too many pages free. This interoperates with
+ * the page allocator fallback scheme to ensure that aging of pages is balanced
+ * across the zones.
  */
 static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 							int *classzone_idx)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
