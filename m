Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4FB086B0035
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 13:29:06 -0400 (EDT)
Received: by mail-oi0-f43.google.com with SMTP id x69so2079364oia.30
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 10:29:05 -0700 (PDT)
Received: from mail.cora.nwra.com (mercury.cora.nwra.com. [4.28.99.165])
        by mx.google.com with ESMTPS id ki2si20364469oeb.90.2014.09.29.10.29.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Sep 2014 10:29:05 -0700 (PDT)
Message-ID: <542996DB.8000502@cora.nwra.com>
Date: Mon, 29 Sep 2014 11:28:59 -0600
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
Subject: [PATCH 001/001] mm: Use KERN_INFO log level for memory configuration
 boot messages
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

From: Orion Poplawski <orion@cora.nwra.com>

While trying look at just "warning" or stronger messages with "journalctl --priority 0..4" I keep
seeing:

Sep 29 07:10:29 barry kernel: Zone ranges:
Sep 29 07:10:29 barry kernel:   DMA      [mem 0x00001000-0x00ffffff]
Sep 29 07:10:29 barry kernel:   DMA32    [mem 0x01000000-0xffffffff]
Sep 29 07:10:29 barry kernel:   Normal   [mem 0x100000000-0x61fffffff]
Sep 29 07:10:29 barry kernel: Movable zone start for each node
Sep 29 07:10:29 barry kernel: Early memory node ranges
Sep 29 07:10:29 barry kernel:   node   0: [mem 0x00001000-0x0009dfff]
Sep 29 07:10:29 barry kernel:   node   0: [mem 0x00100000-0xdfdf8fff]
Sep 29 07:10:29 barry kernel:   node   0: [mem 0x100000000-0x61fffffff]
Sep 29 07:10:29 barry kernel: Built 1 zonelists in Zone order, mobility grouping on.  Total pages
Sep 29 07:10:29 barry kernel: Policy zone: Normal
Sep 29 07:10:29 barry kernel: Memory: 24673284K/25163352K available (7245K kernel code, 1127K rwd

which strike me as purely informational.  This patch sets the level of these messages accordingly.
This is to current git master.

Signed-off-by: Orion Poplawski <orion@cora.nwra.com>

---
 mm/page_alloc.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18cee0d..b8205e8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3899,14 +3899,14 @@ void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
        else
                page_group_by_mobility_disabled = 0;

-       printk("Built %i zonelists in %s order, mobility grouping %s.  "
+       printk(KERN_INFO "Built %i zonelists in %s order, mobility grouping %s.  "
                "Total pages: %ld\n",
                        nr_online_nodes,
                        zonelist_order_name[current_zonelist_order],
                        page_group_by_mobility_disabled ? "off" : "on",
                        vm_total_pages);
 #ifdef CONFIG_NUMA
-       printk("Policy zone: %s\n", zone_names[policy_zone]);
+       printk(KERN_INFO "Policy zone: %s\n", zone_names[policy_zone]);
 #endif
 }

@@ -5338,7 +5338,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
        find_zone_movable_pfns_for_nodes();

        /* Print out the zone ranges */
-       printk("Zone ranges:\n");
+       printk(KERN_INFO "Zone ranges:\n");
        for (i = 0; i < MAX_NR_ZONES; i++) {
                if (i == ZONE_MOVABLE)
                        continue;
@@ -5354,17 +5354,17 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
        }

        /* Print out the PFNs ZONE_MOVABLE begins at in each node */
-       printk("Movable zone start for each node\n");
+       printk(KERN_INFO "Movable zone start for each node\n");
        for (i = 0; i < MAX_NUMNODES; i++) {
                if (zone_movable_pfn[i])
-                       printk("  Node %d: %#010lx\n", i,
+                       printk(KERN_INFO "  Node %d: %#010lx\n", i,
                               zone_movable_pfn[i] << PAGE_SHIFT);
        }

        /* Print out the early node map */
-       printk("Early memory node ranges\n");
+       printk(KERN_INFO "Early memory node ranges\n");
        for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
-               printk("  node %3d: [mem %#010lx-%#010lx]\n", nid,
+               printk(KERN_INFO "  node %3d: [mem %#010lx-%#010lx]\n", nid,
                       start_pfn << PAGE_SHIFT, (end_pfn << PAGE_SHIFT) - 1);

        /* Initialise every node */
@@ -5500,7 +5500,7 @@ void __init mem_init_print_info(const char *str)

 #undef adj_init_size

-       printk("Memory: %luK/%luK available "
+       printk(KERN_INFO "Memory: %luK/%luK available "
               "(%luK kernel code, %luK rwdata, %luK rodata, "
               "%luK init, %luK bss, %luK reserved"
 #ifdef CONFIG_HIGHMEM
--
1.9.3


-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder/CoRA Office             FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
