Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        id j4D7RSwV014206 for <linux-mm@kvack.org>; Fri, 13 May 2005 16:27:28 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id j4D7RR2C023942 for <linux-mm@kvack.org>; Fri, 13 May 2005 16:27:27 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp (localhost [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CCE3515362F
	for <linux-mm@kvack.org>; Fri, 13 May 2005 16:27:27 +0900 (JST)
Received: from fjm502.ms.jp.fujitsu.com (fjm502.ms.jp.fujitsu.com [10.56.99.74])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 827A515362D
	for <linux-mm@kvack.org>; Fri, 13 May 2005 16:27:27 +0900 (JST)
Received: from [10.124.100.220] (fjmscan501.ms.jp.fujitsu.com [10.56.99.141])by fjm502.ms.jp.fujitsu.com with ESMTP id j4D7R12U010780
	for <linux-mm@kvack.org>; Fri, 13 May 2005 16:27:01 +0900
Date: Fri, 13 May 2005 16:27:00 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH/RFC 2/2] Remove pgdat list
Message-Id: <20050513160619.5227.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is moving NODE_DATA()'s definition in include/linux/mmzone.h
to use for_each_pgdat or for_each_zone.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
---

 pgdat_link-goto/include/linux/mmzone.h |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff -puN include/linux/mmzone.h~move_node_data include/linux/mmzone.h
--- pgdat_link/include/linux/mmzone.h~move_node_data	2005-05-13 12:09:34.996172040 +0900
+++ pgdat_link-goto/include/linux/mmzone.h	2005-05-13 12:13:33.006988896 +0900
@@ -304,6 +304,20 @@ unsigned long __init node_memmap_size_by
  */
 #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
 
+#ifndef CONFIG_NEED_MULTIPLE_NODES
+
+extern struct pglist_data contig_page_data;
+#define NODE_DATA(nid)		(&contig_page_data)
+#define NODE_MEM_MAP(nid)	mem_map
+#define MAX_NODES_SHIFT		1
+#define pfn_to_nid(pfn)		(0)
+
+#else /* CONFIG_NEED_MULTIPLE_NODES */
+
+#include <asm/mmzone.h>
+
+#endif /* !CONFIG_NEED_MULTIPLE_NODES */
+
 #define first_online_pgdat() NODE_DATA(first_online_node())
 #define next_online_pgdat(pgdat)				\
 	((next_online_node((pgdat)->node_id) != MAX_NUMNODES) ?	\
@@ -403,20 +417,6 @@ int lowmem_reserve_ratio_sysctl_handler(
 /* Returns the number of the current Node. */
 #define numa_node_id()		(cpu_to_node(_smp_processor_id()))
 
-#ifndef CONFIG_NEED_MULTIPLE_NODES
-
-extern struct pglist_data contig_page_data;
-#define NODE_DATA(nid)		(&contig_page_data)
-#define NODE_MEM_MAP(nid)	mem_map
-#define MAX_NODES_SHIFT		1
-#define pfn_to_nid(pfn)		(0)
-
-#else /* CONFIG_NEED_MULTIPLE_NODES */
-
-#include <asm/mmzone.h>
-
-#endif /* !CONFIG_NEED_MULTIPLE_NODES */
-
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>
 #endif
_

-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
