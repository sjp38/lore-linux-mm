Date: Wed, 05 Apr 2006 20:01:41 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch:003/004] wait_table and zonelist initializing for memory hotadd (wait_table initialization)
In-Reply-To: <20060405192737.3C3F.Y-GOTO@jp.fujitsu.com>
References: <20060405192737.3C3F.Y-GOTO@jp.fujitsu.com>
Message-Id: <20060405195913.3C45.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Wait_table is initialized according to zone size at boot time.
But, we cannot know the maixmum zone size when memory hotplug is enabled.
It can be changed.... And resizing of wait_table is hard.

So kernel allocate and initialzie wait_table as its maximum size.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 mm/page_alloc.c |   45 +++++++++++++++++++++++++++++++++++++++------
 1 files changed, 39 insertions(+), 6 deletions(-)

Index: pgdat10/mm/page_alloc.c
===================================================================
--- pgdat10.orig/mm/page_alloc.c	2006-04-05 16:04:22.000000000 +0900
+++ pgdat10/mm/page_alloc.c	2006-04-05 16:10:17.000000000 +0900
@@ -1785,6 +1785,7 @@ void __init build_all_zonelists(void)
  */
 #define PAGES_PER_WAITQUEUE	256
 
+#ifdef CONFIG_MEMORY_HOTPLUG
 static inline unsigned long wait_table_size(unsigned long pages)
 {
 	unsigned long size = 1;
@@ -1803,6 +1804,17 @@ static inline unsigned long wait_table_s
 
 	return max(size, 4UL);
 }
+#else
+/*
+ * XXX: Because zone size might be changed by hot-add,
+ *      It is hard to determin suitable size for wait_table as traditional.
+ *      So, we use maximum size now.
+ */
+static inline unsigned long wait_table_size(unsigned long pages)
+{
+	return 4096UL;
+}
+#endif
 
 /*
  * This is an integer logarithm so that shifts can be used later
@@ -2071,10 +2083,11 @@ void __init setup_per_cpu_pageset(void)
 #endif
 
 static __meminit
-void zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
+int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 {
 	int i;
 	struct pglist_data *pgdat = zone->zone_pgdat;
+	size_t alloc_size;
 
 	/*
 	 * The per-page waitqueue mechanism uses hashed waitqueues
@@ -2082,12 +2095,30 @@ void zone_wait_table_init(struct zone *z
 	 */
 	zone->wait_table_size = wait_table_size(zone_size_pages);
 	zone->wait_table_bits =	wait_table_bits(zone->wait_table_size);
-	zone->wait_table = (wait_queue_head_t *)
-		alloc_bootmem_node(pgdat, zone->wait_table_size
-					* sizeof(wait_queue_head_t));
+	alloc_size = zone->wait_table_size * sizeof(wait_queue_head_t);
+
+	if (system_state == SYSTEM_BOOTING) {
+		zone->wait_table = (wait_queue_head_t *)
+			alloc_bootmem_node(pgdat, alloc_size);
+	} else {
+		/*
+		 * XXX: This case means that a zone whose size was 0 gets new
+		 *      memory by memory hot-add.
+		 *      But, this may be the case that "new node" is hotadded.
+		 * 	If its case, vmalloc() will not get this new node's
+		 *      memory. Because this wait_table must be initialized
+		 *      to use this new node itself too.
+		 *      To use this new node's memory, further consideration
+		 *      will be necessary.
+		 */
+		zone->wait_table = (wait_queue_head_t *)vmalloc(alloc_size);
+	}
+	if (!zone->wait_table)
+		return -ENOMEM;
 
 	for(i = 0; i < zone->wait_table_size; ++i)
 		init_waitqueue_head(zone->wait_table + i);
+	return 0;
 }
 
 static __meminit void zone_pcp_init(struct zone *zone)
@@ -2114,8 +2145,10 @@ __meminit int init_currently_empty_zone(
 					unsigned long size)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
-
-	zone_wait_table_init(zone, size);
+	int ret;
+	ret = zone_wait_table_init(zone, size);
+	if (ret)
+		return ret;
 	pgdat->nr_zones = zone_idx(zone) + 1;
 
 	zone->zone_start_pfn = zone_start_pfn;

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
