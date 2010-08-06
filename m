Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8C448600044
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:35 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FPje029482
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:25 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FWQf872502
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FVpu016347
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 12/43] memblock/arm: Use new accessors
Date: Fri,  6 Aug 2010 15:14:53 +1000
Message-Id: <1281071724-28740-13-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Russell King <linux@arm.linux.org.uk>
List-ID: <linux-mm.kvack.org>

CC: Russell King <linux@arm.linux.org.uk>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/arm/mm/init.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index e739223..8504906 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -150,6 +150,7 @@ static void __init find_limits(struct meminfo *mi,
 static void __init arm_bootmem_init(struct meminfo *mi,
 	unsigned long start_pfn, unsigned long end_pfn)
 {
+	struct memblock_region *reg;
 	unsigned int boot_pages;
 	phys_addr_t bitmap;
 	pg_data_t *pgdat;
@@ -180,13 +181,13 @@ static void __init arm_bootmem_init(struct meminfo *mi,
 	/*
 	 * Reserve the memblock reserved regions in bootmem.
 	 */
-	for (i = 0; i < memblock.reserved.cnt; i++) {
-		phys_addr_t start = memblock_start_pfn(&memblock.reserved, i);
-		if (start >= start_pfn &&
-		    memblock_end_pfn(&memblock.reserved, i) <= end_pfn)
+	for_each_memblock(reserved, reg) {
+		phys_addr_t start = memblock_region_base_pfn(reg);
+		phys_addr_t end = memblock_region_end_pfn(reg);
+		if (start >= start_pfn && end <= end_pfn)
 			reserve_bootmem_node(pgdat, __pfn_to_phys(start),
-				memblock_size_bytes(&memblock.reserved, i),
-				BOOTMEM_DEFAULT);
+					     (end - start) << PAGE_SHIFT,
+					     BOOTMEM_DEFAULT);
 	}
 }
 
@@ -247,10 +248,12 @@ static void arm_memory_present(void)
 #else
 static void arm_memory_present(void)
 {
+	struct memblock_region *reg;
 	int i;
-	for (i = 0; i < memblock.memory.cnt; i++)
-		memory_present(0, memblock_start_pfn(&memblock.memory, i),
-				  memblock_end_pfn(&memblock.memory, i));
+
+	for_each_memblock(memory, reg) {
+		memory_present(0, memblock_region_base_pfn(reg),
+			       memblock_region_end_pfn(reg));
 }
 #endif
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
