Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D41056B0274
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 09:18:33 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w145-v6so2090442wmw.1
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 06:18:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v1-v6si2766123wrs.310.2018.07.04.06.18.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 06:18:32 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w64D9qjo070514
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 09:18:31 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0wbx4d1p-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 09:18:30 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 14:18:29 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 3/3] nios2: switch to NO_BOOTMEM
Date: Wed,  4 Jul 2018 16:18:15 +0300
In-Reply-To: <1530710295-10774-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1530710295-10774-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1530710295-10774-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ley Foon Tan <lftan@altera.com>
Cc: Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Michal Hocko <mhocko@kernel.org>, nios2-dev@lists.rocketboards.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Remove bootmem bitmap initialization and replace reserve_bootmem() with
memblock_reserve().

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/nios2/Kconfig        |  2 ++
 arch/nios2/kernel/prom.c  |  7 -------
 arch/nios2/kernel/setup.c | 37 +++++--------------------------------
 3 files changed, 7 insertions(+), 39 deletions(-)

diff --git a/arch/nios2/Kconfig b/arch/nios2/Kconfig
index 5db8fa1..661f7f9 100644
--- a/arch/nios2/Kconfig
+++ b/arch/nios2/Kconfig
@@ -20,6 +20,8 @@ config NIOS2
 	select USB_ARCH_HAS_HCD if USB_SUPPORT
 	select CPU_NO_EFFICIENT_FFS
 	select HAVE_MEMBLOCK
+	select ARCH_DISCARD_MEMBLOCK
+	select NO_BOOTMEM
 
 config GENERIC_CSUM
 	def_bool y
diff --git a/arch/nios2/kernel/prom.c b/arch/nios2/kernel/prom.c
index ba96a49..a6d4f75 100644
--- a/arch/nios2/kernel/prom.c
+++ b/arch/nios2/kernel/prom.c
@@ -32,13 +32,6 @@
 
 #include <asm/sections.h>
 
-int __init early_init_dt_reserve_memory_arch(phys_addr_t base, phys_addr_t size,
-					     bool nomap)
-{
-	reserve_bootmem(base, size, BOOTMEM_DEFAULT);
-	return 0;
-}
-
 void __init early_init_devtree(void *params)
 {
 	__be32 *dtb = (u32 *)__dtb_start;
diff --git a/arch/nios2/kernel/setup.c b/arch/nios2/kernel/setup.c
index 0946840..2d0011d 100644
--- a/arch/nios2/kernel/setup.c
+++ b/arch/nios2/kernel/setup.c
@@ -144,10 +144,11 @@ asmlinkage void __init nios2_boot_init(unsigned r4, unsigned r5, unsigned r6,
 
 void __init setup_arch(char **cmdline_p)
 {
-	int bootmap_size;
+	int dram_start;
 
 	console_verbose();
 
+	dram_start = memblock_start_of_DRAM();
 	memory_size = memblock_phys_mem_size();
 	memory_start = PAGE_ALIGN((unsigned long)__pa(_end));
 	memory_end = (unsigned long) CONFIG_NIOS2_MEM_BASE + memory_size;
@@ -165,39 +166,11 @@ void __init setup_arch(char **cmdline_p)
 	max_low_pfn = PFN_DOWN(memory_end);
 	max_mapnr = max_low_pfn;
 
-	/*
-	 * give all the memory to the bootmap allocator,  tell it to put the
-	 * boot mem_map at the start of memory
-	 */
-	pr_debug("init_bootmem_node(?,%#lx, %#x, %#lx)\n",
-		min_low_pfn, PFN_DOWN(PHYS_OFFSET), max_low_pfn);
-	bootmap_size = init_bootmem_node(NODE_DATA(0),
-					min_low_pfn, PFN_DOWN(PHYS_OFFSET),
-					max_low_pfn);
-
-	/*
-	 * free the usable memory,  we have to make sure we do not free
-	 * the bootmem bitmap so we then reserve it after freeing it :-)
-	 */
-	pr_debug("free_bootmem(%#lx, %#lx)\n",
-		memory_start, memory_end - memory_start);
-	free_bootmem(memory_start, memory_end - memory_start);
-
-	/*
-	 * Reserve the bootmem bitmap itself as well. We do this in two
-	 * steps (first step was init_bootmem()) because this catches
-	 * the (very unlikely) case of us accidentally initializing the
-	 * bootmem allocator with an invalid RAM area.
-	 *
-	 * Arguments are start, size
-	 */
-	pr_debug("reserve_bootmem(%#lx, %#x)\n", memory_start, bootmap_size);
-	reserve_bootmem(memory_start, bootmap_size, BOOTMEM_DEFAULT);
-
+	memblock_reserve(dram_start, memory_start - dram_start);
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (initrd_start) {
-		reserve_bootmem(virt_to_phys((void *)initrd_start),
-				initrd_end - initrd_start, BOOTMEM_DEFAULT);
+		memblock_reserve(virt_to_phys((void *)initrd_start),
+				initrd_end - initrd_start);
 	}
 #endif /* CONFIG_BLK_DEV_INITRD */
 
-- 
2.7.4
