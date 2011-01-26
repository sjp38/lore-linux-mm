Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3DB8D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 18:30:13 -0500 (EST)
From: Mandeep Singh Baines <msb@chromium.org>
Subject: [PATCH 1/6] mm/page_alloc: use appropriate printk priority level
Date: Wed, 26 Jan 2011 15:29:25 -0800
Message-Id: <1296084570-31453-2-git-send-email-msb@chromium.org>
In-Reply-To: <20110125235700.GR8008@google.com>
References: <20110125235700.GR8008@google.com>
Sender: owner-linux-mm@kvack.org
To: gregkh@suse.de, rjw@sisk.pl, mingo@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mandeep Singh Baines <msb@chromium.org>
List-ID: <linux-mm.kvack.org>

printk()s without a priority level default to KERN_WARNING. To reduce
noise at KERN_WARNING, this patch set the priority level appriopriately
for unleveled printks()s. This should be useful to folks that look at
dmesg warnings closely.

Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
---
 mm/page_alloc.c |   27 +++++++++++++++------------
 1 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 90c1439..234c704 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3129,14 +3129,14 @@ void build_all_zonelists(void *data)
 	else
 		page_group_by_mobility_disabled = 0;
 
-	printk("Built %i zonelists in %s order, mobility grouping %s.  "
-		"Total pages: %ld\n",
+	printk(KERN_INFO "Built %i zonelists in %s order, mobility grouping %s."
+		"  Total pages: %ld\n",
 			nr_online_nodes,
 			zonelist_order_name[current_zonelist_order],
 			page_group_by_mobility_disabled ? "off" : "on",
 			vm_total_pages);
 #ifdef CONFIG_NUMA
-	printk("Policy zone: %s\n", zone_names[policy_zone]);
+	printk(KERN_INFO "Policy zone: %s\n", zone_names[policy_zone]);
 #endif
 }
 
@@ -4700,33 +4700,36 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 	find_zone_movable_pfns_for_nodes(zone_movable_pfn);
 
 	/* Print out the zone ranges */
-	printk("Zone PFN ranges:\n");
+	printk(KERN_INFO "Zone PFN ranges:\n");
 	for (i = 0; i < MAX_NR_ZONES; i++) {
 		if (i == ZONE_MOVABLE)
 			continue;
-		printk("  %-8s ", zone_names[i]);
+		printk(KERN_INFO "  %-8s ", zone_names[i]);
 		if (arch_zone_lowest_possible_pfn[i] ==
 				arch_zone_highest_possible_pfn[i])
 			printk("empty\n");
 		else
-			printk("%0#10lx -> %0#10lx\n",
+			printk(KERN_INFO "%0#10lx -> %0#10lx\n",
 				arch_zone_lowest_possible_pfn[i],
 				arch_zone_highest_possible_pfn[i]);
 	}
 
 	/* Print out the PFNs ZONE_MOVABLE begins at in each node */
-	printk("Movable zone start PFN for each node\n");
+	printk(KERN_INFO "Movable zone start PFN for each node\n");
 	for (i = 0; i < MAX_NUMNODES; i++) {
 		if (zone_movable_pfn[i])
-			printk("  Node %d: %lu\n", i, zone_movable_pfn[i]);
+			printk(KERN_INFO "  Node %d: %lu\n", i,
+			       zone_movable_pfn[i]);
 	}
 
 	/* Print out the early_node_map[] */
-	printk("early_node_map[%d] active PFN ranges\n", nr_nodemap_entries);
+	printk(KERN_INFO "early_node_map[%d] active PFN ranges\n",
+	       nr_nodemap_entries);
 	for (i = 0; i < nr_nodemap_entries; i++)
-		printk("  %3d: %0#10lx -> %0#10lx\n", early_node_map[i].nid,
-						early_node_map[i].start_pfn,
-						early_node_map[i].end_pfn);
+		printk(KERN_INFO "  %3d: %0#10lx -> %0#10lx\n",
+		       early_node_map[i].nid,
+		       early_node_map[i].start_pfn,
+		       early_node_map[i].end_pfn);
 
 	/* Initialise every node */
 	mminit_verify_pageflags_layout();
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
