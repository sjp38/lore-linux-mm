Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 647096B002C
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 19:04:42 -0500 (EST)
Received: by eekb57 with SMTP id b57so188657eek.2
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 16:04:40 -0800 (PST)
Subject: [PATCH] mm: print physical addresses consistently with other parts of
	kernel
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Mon, 13 Feb 2012 17:04:39 -0700
Message-ID: <20120214000439.32466.65882.stgit@bhelgaas.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Print physical address info in a style consistent with the %pR style used
elsewhere in the kernel.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 mm/memory_hotplug.c |   14 ++++++++------
 mm/page_alloc.c     |   19 +++++++++++--------
 2 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6629faf..453006c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -74,8 +74,7 @@ static struct resource *register_memory_resource(u64 start, u64 size)
 	res->end = start + size - 1;
 	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
 	if (request_resource(&iomem_resource, res) < 0) {
-		printk("System RAM resource %llx - %llx cannot be added\n",
-		(unsigned long long)res->start, (unsigned long long)res->end);
+		printk("System RAM resource %pR cannot be added\n", res);
 		kfree(res);
 		res = NULL;
 	}
@@ -502,8 +501,10 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 		online_pages_range);
 	if (ret) {
 		mutex_unlock(&zonelists_mutex);
-		printk(KERN_DEBUG "online_pages %lx at %lx failed\n",
-			nr_pages, pfn);
+		printk(KERN_DEBUG "online_pages [mem %#010llx-%#010llx] failed\n",
+		       (unsigned long long) pfn << PAGE_SHIFT,
+		       (((unsigned long long) pfn + nr_pages)
+			    << PAGE_SHIFT) - 1);
 		memory_notify(MEM_CANCEL_ONLINE, &arg);
 		unlock_memory_hotplug();
 		return ret;
@@ -977,8 +978,9 @@ repeat:
 	return 0;
 
 failed_removal:
-	printk(KERN_INFO "memory offlining %lx to %lx failed\n",
-		start_pfn, end_pfn);
+	printk(KERN_INFO "memory offlining [mem %#010llx-%#010llx] failed\n",
+	       (unsigned long long) start_pfn << PAGE_SHIFT,
+	       ((unsigned long long) end_pfn << PAGE_SHIFT) - 1);
 	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 	/* pushback to free area */
 	undo_isolate_page_range(start_pfn, end_pfn);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d2186ec..1cc56d1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4716,7 +4716,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 	find_zone_movable_pfns_for_nodes(zone_movable_pfn);
 
 	/* Print out the zone ranges */
-	printk("Zone PFN ranges:\n");
+	printk("Zone ranges:\n");
 	for (i = 0; i < MAX_NR_ZONES; i++) {
 		if (i == ZONE_MOVABLE)
 			continue;
@@ -4725,22 +4725,25 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 				arch_zone_highest_possible_pfn[i])
 			printk("empty\n");
 		else
-			printk("%0#10lx -> %0#10lx\n",
-				arch_zone_lowest_possible_pfn[i],
-				arch_zone_highest_possible_pfn[i]);
+			printk("[mem %0#10lx-%0#10lx]\n",
+				arch_zone_lowest_possible_pfn[i] << PAGE_SHIFT,
+				(arch_zone_highest_possible_pfn[i]
+					<< PAGE_SHIFT) - 1);
 	}
 
 	/* Print out the PFNs ZONE_MOVABLE begins at in each node */
-	printk("Movable zone start PFN for each node\n");
+	printk("Movable zone start for each node\n");
 	for (i = 0; i < MAX_NUMNODES; i++) {
 		if (zone_movable_pfn[i])
-			printk("  Node %d: %lu\n", i, zone_movable_pfn[i]);
+			printk("  Node %d: %#010lx\n", i,
+			       zone_movable_pfn[i] << PAGE_SHIFT);
 	}
 
 	/* Print out the early_node_map[] */
-	printk("Early memory PFN ranges\n");
+	printk("Early memory node ranges\n");
 	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
-		printk("  %3d: %0#10lx -> %0#10lx\n", nid, start_pfn, end_pfn);
+		printk("  node %3d: [mem %#010lx-%#010lx]\n", nid,
+		       start_pfn << PAGE_SHIFT, (end_pfn << PAGE_SHIFT) - 1);
 
 	/* Initialise every node */
 	mminit_verify_pageflags_layout();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
