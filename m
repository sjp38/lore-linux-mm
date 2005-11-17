From: Con Kolivas <kernel@kolivas.org>
Subject: [PATCH] mm: is_dma_zone
Date: Fri, 18 Nov 2005 00:59:50 +1100
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <200511180059.51211.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux kernel mailing list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Add a simple is_dma helper function to remain consistent with respect to
avoiding the use of ZONE_* outside the headers.

Signed-off-by: Con Kolivas <kernel@kolivas.org>

 include/linux/mmzone.h |    5 +++++
 mm/swap_prefetch.c     |    2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

---

Index: linux-2.6.14-mm2/include/linux/mmzone.h
===================================================================
--- linux-2.6.14-mm2.orig/include/linux/mmzone.h
+++ linux-2.6.14-mm2/include/linux/mmzone.h
@@ -425,6 +425,11 @@ static inline int is_normal(struct zone 
 	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
 }
 
+static inline int is_dma(struct zone *zone)
+{
+	return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
+}
+
 /* These two functions are used to setup the per zone pages min values */
 struct ctl_table;
 struct file;
Index: linux-2.6.14-mm2/mm/swap_prefetch.c
===================================================================
--- linux-2.6.14-mm2.orig/mm/swap_prefetch.c
+++ linux-2.6.14-mm2/mm/swap_prefetch.c
@@ -180,7 +180,7 @@ static struct page *prefetch_get_page(vo
 			continue;
 
 		/* We don't prefetch into DMA */
-		if (zone_idx(z) == ZONE_DMA)
+		if (is_dma(z))
 			continue;
 
 		free = z->free_pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
