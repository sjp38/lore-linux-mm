Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 5D6C66B0034
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 04:08:53 -0400 (EDT)
Message-ID: <52283BAA.8080807@huawei.com>
Date: Thu, 5 Sep 2013 16:07:06 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] mm: use pgdat_end_pfn() to simplify the code in others
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>

Use "pgdat_end_pfn()" instead of "pgdat->node_start_pfn + pgdat->node_spanned_pages".
Simplify the code, no functional change.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 fs/proc/kcore.c     |    3 +--
 mm/bootmem.c        |    2 +-
 mm/memory_hotplug.c |    9 ++++-----
 3 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/fs/proc/kcore.c b/fs/proc/kcore.c
index 06ea155..a5b4412 100644
--- a/fs/proc/kcore.c
+++ b/fs/proc/kcore.c
@@ -255,8 +255,7 @@ static int kcore_update_ram(void)
 	end_pfn = 0;
 	for_each_node_state(nid, N_MEMORY) {
 		unsigned long node_end;
-		node_end  = NODE_DATA(nid)->node_start_pfn +
-			NODE_DATA(nid)->node_spanned_pages;
+		node_end = node_end_pfn(nid);
 		if (end_pfn < node_end)
 			end_pfn = node_end;
 	}
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 6ab7744..95b528c 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -784,7 +784,7 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
 	/* update goal according ...MAX_DMA32_PFN */
-	end_pfn = pgdat->node_start_pfn + pgdat->node_spanned_pages;
+	end_pfn = pgdat_end_pfn(pgdat);
 
 	if (end_pfn > MAX_DMA32_PFN + (128 >> (20 - PAGE_SHIFT)) &&
 	    (goal >> PAGE_SHIFT) < MAX_DMA32_PFN) {
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ca1dd3a..0ca2c8d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -368,8 +368,7 @@ out_fail:
 static void grow_pgdat_span(struct pglist_data *pgdat, unsigned long start_pfn,
 			    unsigned long end_pfn)
 {
-	unsigned long old_pgdat_end_pfn =
-		pgdat->node_start_pfn + pgdat->node_spanned_pages;
+	unsigned long old_pgdat_end_pfn = pgdat_end_pfn(pgdat);
 
 	if (!pgdat->node_spanned_pages || start_pfn < pgdat->node_start_pfn)
 		pgdat->node_start_pfn = start_pfn;
@@ -581,9 +580,9 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 static void shrink_pgdat_span(struct pglist_data *pgdat,
 			      unsigned long start_pfn, unsigned long end_pfn)
 {
-	unsigned long pgdat_start_pfn =  pgdat->node_start_pfn;
-	unsigned long pgdat_end_pfn =
-		pgdat->node_start_pfn + pgdat->node_spanned_pages;
+	unsigned long pgdat_start_pfn = pgdat->node_start_pfn;
+	unsigned long p = pgdat_end_pfn(pgdat); /* pgdat_end_pfn namespace clash */
+	unsigned long pgdat_end_pfn = p;
 	unsigned long pfn;
 	struct mem_section *ms;
 	int nid = pgdat->node_id;
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
