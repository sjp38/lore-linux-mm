Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B92DA6002AE
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:36 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FPlO029498
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:25 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FWhD1339488
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FVWF021017
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:31 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 08/43] memblock/microblaze: Use new accessors
Date: Fri,  6 Aug 2010 15:14:49 +1000
Message-Id: <1281071724-28740-9-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michal Simek <monstr@monstr.eu>
List-ID: <linux-mm.kvack.org>

CC: Michal Simek <monstr@monstr.eu>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/microblaze/mm/init.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index afd6494..32a702b 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -70,16 +70,16 @@ static void __init paging_init(void)
 
 void __init setup_memory(void)
 {
-	int i;
 	unsigned long map_size;
+	struct memblock_region *reg;
+
 #ifndef CONFIG_MMU
 	u32 kernel_align_start, kernel_align_size;
 
 	/* Find main memory where is the kernel */
-	for (i = 0; i < memblock.memory.cnt; i++) {
-		memory_start = (u32) memblock.memory.regions[i].base;
-		memory_end = (u32) memblock.memory.regions[i].base
-				+ (u32) memblock.memory.region[i].size;
+	for_each_memblock(memory, reg) {
+		memory_start = (u32)reg->base;
+		memory_end = (u32) reg->base + reg->size;
 		if ((memory_start <= (u32)_text) &&
 					((u32)_text <= memory_end)) {
 			memory_size = memory_end - memory_start;
@@ -147,12 +147,10 @@ void __init setup_memory(void)
 	free_bootmem(memory_start, memory_size);
 
 	/* reserve allocate blocks */
-	for (i = 0; i < memblock.reserved.cnt; i++) {
-		pr_debug("reserved %d - 0x%08x-0x%08x\n", i,
-			(u32) memblock.reserved.region[i].base,
-			(u32) memblock_size_bytes(&memblock.reserved, i));
-		reserve_bootmem(memblock.reserved.region[i].base,
-			memblock_size_bytes(&memblock.reserved, i) - 1, BOOTMEM_DEFAULT);
+	for_each_memblock(reserved, reg) {
+		pr_debug("reserved - 0x%08x-0x%08x\n",
+			 (u32) reg->base, (u32) reg->size);
+		reserve_bootmem(reg->base, reg->size, BOOTMEM_DEFAULT);
 	}
 #ifdef CONFIG_MMU
 	init_bootmem_done = 1;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
