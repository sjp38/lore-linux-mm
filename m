Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 151C96B0070
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 06:02:51 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so223122pdj.13
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 03:02:50 -0700 (PDT)
Received: from am1outboundpool.messaging.microsoft.com (am1ehsobe005.messaging.microsoft.com. [213.199.154.208])
        by mx.google.com with ESMTPS id pc9si6456721pac.312.2014.03.25.03.02.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Mar 2014 03:02:49 -0700 (PDT)
From: Emil Medve <Emilian.Medve@Freescale.com>
Subject: [PATCH 2/3] memblock: Use for_each_memblock()
Date: Tue, 25 Mar 2014 04:31:04 -0500
Message-ID: <1395739864-19276-1-git-send-email-Emilian.Medve@Freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: Emil Medve <Emilian.Medve@Freescale.com>

Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
---

This is a small cleanup

 mm/memblock.c   | 24 +++++++++++-------------
 mm/page_alloc.c | 10 +++++-----
 2 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 39a31e7..2b2aaf8 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1271,16 +1271,14 @@ phys_addr_t __init_memblock memblock_end_of_DRAM(void)
 
 void __init memblock_enforce_memory_limit(phys_addr_t limit)
 {
-	unsigned long i;
 	phys_addr_t max_addr = (phys_addr_t)ULLONG_MAX;
+	struct memblock_region *r;
 
 	if (!limit)
 		return;
 
 	/* find out max address */
-	for (i = 0; i < memblock.memory.cnt; i++) {
-		struct memblock_region *r = &memblock.memory.regions[i];
-
+	for_each_memblock(memory, r) {
 		if (limit <= r->size) {
 			max_addr = r->base + limit;
 			break;
@@ -1379,13 +1377,12 @@ int __init_memblock memblock_is_region_reserved(phys_addr_t base, phys_addr_t si
 
 void __init_memblock memblock_trim_memory(phys_addr_t align)
 {
-	int i;
 	phys_addr_t start, end, orig_start, orig_end;
-	struct memblock_type *mem = &memblock.memory;
+	struct memblock_region *r;
 
-	for (i = 0; i < mem->cnt; i++) {
-		orig_start = mem->regions[i].base;
-		orig_end = mem->regions[i].base + mem->regions[i].size;
+	for_each_memblock(memory, r) {
+		orig_start = r->base;
+		orig_end = r->base + r->size;
 		start = round_up(orig_start, align);
 		end = round_down(orig_end, align);
 
@@ -1393,11 +1390,12 @@ void __init_memblock memblock_trim_memory(phys_addr_t align)
 			continue;
 
 		if (start < end) {
-			mem->regions[i].base = start;
-			mem->regions[i].size = end - start;
+			r->base = start;
+			r->size = end - start;
 		} else {
-			memblock_remove_region(mem, i);
-			i--;
+			memblock_remove_region(&memblock.memory,
+					       r - memblock.memory.regions);
+			r--;
 		}
 	}
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e3758a0..b3727ef 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5050,7 +5050,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	nodemask_t saved_node_state = node_states[N_MEMORY];
 	unsigned long totalpages = early_calculate_totalpages();
 	int usable_nodes = nodes_weight(node_states[N_MEMORY]);
-	struct memblock_type *type = &memblock.memory;
+	struct memblock_region *r;
 
 	/* Need to find movable_zone earlier when movable_node is specified. */
 	find_usable_zone_for_movable();
@@ -5060,13 +5060,13 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	 * options.
 	 */
 	if (movable_node_is_enabled()) {
-		for (i = 0; i < type->cnt; i++) {
-			if (!memblock_is_hotpluggable(&type->regions[i]))
+		for_each_memblock(memory, r) {
+			if (!memblock_is_hotpluggable(r))
 				continue;
 
-			nid = type->regions[i].nid;
+			nid = r->nid;
 
-			usable_startpfn = PFN_DOWN(type->regions[i].base);
+			usable_startpfn = PFN_DOWN(r->base);
 			zone_movable_pfn[nid] = zone_movable_pfn[nid] ?
 				min(usable_startpfn, zone_movable_pfn[nid]) :
 				usable_startpfn;
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
