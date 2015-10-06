Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 299596B0038
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 18:13:30 -0400 (EDT)
Received: by qgez77 with SMTP id z77so188297108qge.1
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 15:13:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i78si17089450qkh.10.2015.10.06.15.13.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 15:13:29 -0700 (PDT)
Date: Tue, 06 Oct 2015 15:13:28 -0700
From: akpm@linux-foundation.org
Subject: [patch 1/1] mm/vmstat.c: uninline node_page_state()
Message-ID: <56144788.RD/yrs/8D4zm1CBk%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/vmstat.c: uninline node_page_state()

With x86_64 (config http://ozlabs.org/~akpm/config-akpm2.txt) and old gcc
(4.4.4), drivers/base/node.c:node_read_meminfo() is using 2344 bytes of
stack.  Uninlining node_page_state() reduces this to 440 bytes.

The stack consumption issue is fixed by newer gcc (4.8.4) however with
that compiler this patch reduces the node.o text size from 7314 bytes to
4578.

Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/vmstat.h |   24 +-----------------------
 mm/vmstat.c            |   24 ++++++++++++++++++++++++
 2 files changed, 25 insertions(+), 23 deletions(-)

diff -puN include/linux/vmstat.h~mm-vmstatc-uninline-node_page_state include/linux/vmstat.h
--- a/include/linux/vmstat.h~mm-vmstatc-uninline-node_page_state
+++ a/include/linux/vmstat.h
@@ -161,30 +161,8 @@ static inline unsigned long zone_page_st
 }
 
 #ifdef CONFIG_NUMA
-/*
- * Determine the per node value of a stat item. This function
- * is called frequently in a NUMA machine, so try to be as
- * frugal as possible.
- */
-static inline unsigned long node_page_state(int node,
-				 enum zone_stat_item item)
-{
-	struct zone *zones = NODE_DATA(node)->node_zones;
-
-	return
-#ifdef CONFIG_ZONE_DMA
-		zone_page_state(&zones[ZONE_DMA], item) +
-#endif
-#ifdef CONFIG_ZONE_DMA32
-		zone_page_state(&zones[ZONE_DMA32], item) +
-#endif
-#ifdef CONFIG_HIGHMEM
-		zone_page_state(&zones[ZONE_HIGHMEM], item) +
-#endif
-		zone_page_state(&zones[ZONE_NORMAL], item) +
-		zone_page_state(&zones[ZONE_MOVABLE], item);
-}
 
+extern unsigned long node_page_state(int node, enum zone_stat_item item);
 extern void zone_statistics(struct zone *, struct zone *, gfp_t gfp);
 
 #else
diff -puN mm/vmstat.c~mm-vmstatc-uninline-node_page_state mm/vmstat.c
--- a/mm/vmstat.c~mm-vmstatc-uninline-node_page_state
+++ a/mm/vmstat.c
@@ -591,6 +591,30 @@ void zone_statistics(struct zone *prefer
 	else
 		__inc_zone_state(z, NUMA_OTHER);
 }
+
+/*
+ * Determine the per node value of a stat item. This function
+ * is called frequently in a NUMA machine, so try to be as
+ * frugal as possible.
+ */
+unsigned long node_page_state(int node, enum zone_stat_item item)
+{
+	struct zone *zones = NODE_DATA(node)->node_zones;
+
+	return
+#ifdef CONFIG_ZONE_DMA
+		zone_page_state(&zones[ZONE_DMA], item) +
+#endif
+#ifdef CONFIG_ZONE_DMA32
+		zone_page_state(&zones[ZONE_DMA32], item) +
+#endif
+#ifdef CONFIG_HIGHMEM
+		zone_page_state(&zones[ZONE_HIGHMEM], item) +
+#endif
+		zone_page_state(&zones[ZONE_NORMAL], item) +
+		zone_page_state(&zones[ZONE_MOVABLE], item);
+}
+
 #endif
 
 #ifdef CONFIG_COMPACTION
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
