Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC3B6B02A6
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:34 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FWKZ013733
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FVm61560624
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:31 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FVoI021008
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:31 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 06/43] memblock/arm: Use memblock_region_is_memory() for omap fb
Date: Fri,  6 Aug 2010 15:14:47 +1000
Message-Id: <1281071724-28740-7-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Instead of the deprecated memblock_find()

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/arm/plat-omap/fb.c    |    6 +-----
 drivers/video/omap2/vram.c |    8 ++------
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/arch/arm/plat-omap/fb.c b/arch/arm/plat-omap/fb.c
index 05bf228..441af2b 100644
--- a/arch/arm/plat-omap/fb.c
+++ b/arch/arm/plat-omap/fb.c
@@ -173,11 +173,7 @@ static int check_fbmem_region(int region_idx, struct omapfb_mem_region *rg,
 
 static int valid_sdram(unsigned long addr, unsigned long size)
 {
-	struct memblock_region res;
-
-	res.base = addr;
-	res.size = size;
-	return !memblock_find(&res) && res.base == addr && res.size == size;
+	return memblock_region_is_memory(addr, size);
 }
 
 static int reserve_sdram(unsigned long addr, unsigned long size)
diff --git a/drivers/video/omap2/vram.c b/drivers/video/omap2/vram.c
index 0f2532b..34514a8 100644
--- a/drivers/video/omap2/vram.c
+++ b/drivers/video/omap2/vram.c
@@ -554,12 +554,8 @@ void __init omap_vram_reserve_sdram_memblock(void)
 	size = PAGE_ALIGN(size);
 
 	if (paddr) {
-		struct memblock_region res;
-
-		res.base = paddr;
-		res.size = size;
-		if ((paddr & ~PAGE_MASK) || memblock_find(&res) ||
-		    res.base != paddr || res.size != size) {
+		if ((paddr & ~PAGE_MASK) ||
+		    !memblock_region_is_memory(paddr, size)) {
 			pr_err("Illegal SDRAM region for VRAM\n");
 			return;
 		}
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
