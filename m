Message-Id: <20080530194738.376975723@saeurebad.de>
References: <20080530194220.286976884@saeurebad.de>
Date: Fri, 30 May 2008 21:42:26 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH -mm 06/14] bootmem: revisit bootmem descriptor list handling
Content-Disposition: inline; filename=bootmem-revisit-bootmem-descriptor-list.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

link_bootmem handles an insertion of a new descriptor into the sorted
list in more or less three explicit branches; empty list, insert in
between and append.  These cases can be expressed implicite.

Also mark the sorted list as initdata as it can be thrown away after
boot as well.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---

 mm/bootmem.c |   23 ++++++++++-------------
 1 file changed, 10 insertions(+), 13 deletions(-)

--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -23,7 +23,6 @@ unsigned long max_low_pfn;
 unsigned long min_low_pfn;
 unsigned long max_pfn;
 
-static LIST_HEAD(bdata_list);
 #ifdef CONFIG_CRASH_DUMP
 /*
  * If we have booted due to a crash, max_pfn will be a very low value. We need
@@ -34,6 +33,8 @@ unsigned long saved_max_pfn;
 
 bootmem_data_t bootmem_node_data[MAX_NUMNODES] __initdata;
 
+static struct list_head bdata_list __initdata = LIST_HEAD_INIT(bdata_list);
+
 static int bootmem_debug;
 
 static int __init bootmem_debug_setup(char *buf)
@@ -73,20 +74,16 @@ unsigned long __init bootmem_bootmap_pag
  */
 static void __init link_bootmem(bootmem_data_t *bdata)
 {
-	bootmem_data_t *ent;
+	struct list_head *iter;
 
-	if (list_empty(&bdata_list)) {
-		list_add(&bdata->list, &bdata_list);
-		return;
-	}
-	/* insert in order */
-	list_for_each_entry(ent, &bdata_list, list) {
-		if (bdata->node_boot_start < ent->node_boot_start) {
-			list_add_tail(&bdata->list, &ent->list);
-			return;
-		}
+	list_for_each(iter, &bdata_list) {
+		bootmem_data_t *ent;
+
+		ent = list_entry(iter, bootmem_data_t, list);
+		if (bdata->node_boot_start < ent->node_boot_start)
+			break;
 	}
-	list_add_tail(&bdata->list, &bdata_list);
+	list_add_tail(&bdata->list, iter);
 }
 
 /*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
