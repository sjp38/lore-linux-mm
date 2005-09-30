Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8UG5oBt018293
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 12:05:50 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8UG7ReE138398
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 10:07:27 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8UG7RwN020053
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 10:07:27 -0600
Subject: Re: [PATCH]Remove pgdat list ver.2 [1/2]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050930205919.7019.Y-GOTO@jp.fujitsu.com>
References: <20050930205919.7019.Y-GOTO@jp.fujitsu.com>
Content-Type: multipart/mixed; boundary="=-3h7T//jpab1Af9qtgb8B"
Date: Fri, 30 Sep 2005 09:07:25 -0700
Message-Id: <1128096445.6145.36.camel@localhost>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--=-3h7T//jpab1Af9qtgb8B
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This works around my compile problem for now.  But, it might cause some
more issues.  Can you take a closer look?



-- Dave

--=-3h7T//jpab1Af9qtgb8B
Content-Disposition: attachment; filename=no-pgdat-list-fix.patch
Content-Type: text/x-patch; name=no-pgdat-list-fix.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit



---

 memhotplug-dave/include/linux/mmzone.h |  104 ++++++++++++++++-----------------
 1 files changed, 53 insertions(+), 51 deletions(-)

diff -puN include/linux/mmzone.h~no-pgdat-list-fix include/linux/mmzone.h
--- memhotplug/include/linux/mmzone.h~no-pgdat-list-fix	2005-09-30 08:59:56.000000000 -0700
+++ memhotplug-dave/include/linux/mmzone.h	2005-09-30 09:06:10.000000000 -0700
@@ -15,6 +15,7 @@
 #include <linux/init.h>
 #include <linux/seqlock.h>
 #include <asm/atomic.h>
+#include <asm/mmzone.h>
 #include <asm/semaphore.h>
 
 /* Free memory management - zoned buddy allocator.  */
@@ -342,6 +343,58 @@ static inline void memory_present(int ni
 unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 #endif
 
+static inline int is_highmem_idx(int idx)
+{
+	return (idx == ZONE_HIGHMEM);
+}
+
+static inline int is_normal_idx(int idx)
+{
+	return (idx == ZONE_NORMAL);
+}
+/**
+ * is_highmem - helper function to quickly check if a struct zone is a 
+ *              highmem zone or not.  This is an attempt to keep references
+ *              to ZONE_{DMA/NORMAL/HIGHMEM/etc} in general code to a minimum.
+ * @zone - pointer to struct zone variable
+ */
+static inline int is_highmem(struct zone *zone)
+{
+	return zone == zone->zone_pgdat->node_zones + ZONE_HIGHMEM;
+}
+
+static inline int is_normal(struct zone *zone)
+{
+	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
+}
+
+/* These two functions are used to setup the per zone pages min values */
+struct ctl_table;
+struct file;
+int min_free_kbytes_sysctl_handler(struct ctl_table *, int, struct file *, 
+					void __user *, size_t *, loff_t *);
+extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
+int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int, struct file *,
+					void __user *, size_t *, loff_t *);
+
+#include <linux/topology.h>
+/* Returns the number of the current Node. */
+#define numa_node_id()		(cpu_to_node(raw_smp_processor_id()))
+
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
 /*
  * zone_idx() returns 0 for the ZONE_DMA zone, 1 for the ZONE_NORMAL zone, etc.
  */
@@ -408,57 +461,6 @@ static inline struct zone *next_zone(str
 	for (zone = first_online_pgdat()->node_zones;	\
 	     zone; zone = next_zone(zone))
 
-static inline int is_highmem_idx(int idx)
-{
-	return (idx == ZONE_HIGHMEM);
-}
-
-static inline int is_normal_idx(int idx)
-{
-	return (idx == ZONE_NORMAL);
-}
-/**
- * is_highmem - helper function to quickly check if a struct zone is a 
- *              highmem zone or not.  This is an attempt to keep references
- *              to ZONE_{DMA/NORMAL/HIGHMEM/etc} in general code to a minimum.
- * @zone - pointer to struct zone variable
- */
-static inline int is_highmem(struct zone *zone)
-{
-	return zone == zone->zone_pgdat->node_zones + ZONE_HIGHMEM;
-}
-
-static inline int is_normal(struct zone *zone)
-{
-	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
-}
-
-/* These two functions are used to setup the per zone pages min values */
-struct ctl_table;
-struct file;
-int min_free_kbytes_sysctl_handler(struct ctl_table *, int, struct file *, 
-					void __user *, size_t *, loff_t *);
-extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
-int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int, struct file *,
-					void __user *, size_t *, loff_t *);
-
-#include <linux/topology.h>
-/* Returns the number of the current Node. */
-#define numa_node_id()		(cpu_to_node(raw_smp_processor_id()))
-
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
 
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>
_

--=-3h7T//jpab1Af9qtgb8B--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
