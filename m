Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 432EB6B0008
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 01:30:10 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e23-v6so6586182oii.10
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 22:30:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o188-v6si9576992oib.135.2018.07.24.22.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 22:30:08 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6P5TTVd125703
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 01:30:08 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kehqkkcaf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 01:30:07 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 25 Jul 2018 06:30:04 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2] hexagon: switch to NO_BOOTMEM
Date: Wed, 25 Jul 2018 08:29:54 +0300
Message-Id: <1532496594-26353-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Kuo <rkuo@codeaurora.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-hexagon@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

This patch adds registration of the system memory with memblock, eliminates
bootmem initialization and converts early memory reservations from bootmem
to memblock.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
v2: fix calculation of the reserved memory size

 arch/hexagon/Kconfig   |  3 +++
 arch/hexagon/mm/init.c | 20 ++++++++------------
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/arch/hexagon/Kconfig b/arch/hexagon/Kconfig
index 37adb20..66fb2d5 100644
--- a/arch/hexagon/Kconfig
+++ b/arch/hexagon/Kconfig
@@ -28,6 +28,9 @@ config HEXAGON
 	select GENERIC_CLOCKEVENTS_BROADCAST
 	select MODULES_USE_ELF_RELA
 	select GENERIC_CPU_DEVICES
+	select HAVE_MEMBLOCK
+	select ARCH_DISCARD_MEMBLOCK
+	select NO_BOOTMEM
 	---help---
 	  Qualcomm Hexagon is a processor architecture designed for high
 	  performance and low power across a wide variety of applications.
diff --git a/arch/hexagon/mm/init.c b/arch/hexagon/mm/init.c
index 1495d45..d789b9c 100644
--- a/arch/hexagon/mm/init.c
+++ b/arch/hexagon/mm/init.c
@@ -21,6 +21,7 @@
 #include <linux/init.h>
 #include <linux/mm.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <asm/atomic.h>
 #include <linux/highmem.h>
 #include <asm/tlb.h>
@@ -176,7 +177,6 @@ size_t hexagon_coherent_pool_size = (size_t) (DMA_RESERVE << 22);
 
 void __init setup_arch_memory(void)
 {
-	int bootmap_size;
 	/*  XXX Todo: this probably should be cleaned up  */
 	u32 *segtable = (u32 *) &swapper_pg_dir[0];
 	u32 *segtable_end;
@@ -195,18 +195,22 @@ void __init setup_arch_memory(void)
 	bootmem_lastpg = PFN_DOWN((bootmem_lastpg << PAGE_SHIFT) &
 		~((BIG_KERNEL_PAGE_SIZE) - 1));
 
+	memblock_add(PHYS_OFFSET,
+		     (bootmem_lastpg - ARCH_PFN_OFFSET) << PAGE_SHIFT);
+
+	/* Reserve kernel text/data/bss */
+	memblock_reserve(PHYS_OFFSET,
+			 (bootmem_startpg - ARCH_PFN_OFFSET) << PAGE_SHIFT);
 	/*
 	 * Reserve the top DMA_RESERVE bytes of RAM for DMA (uncached)
 	 * memory allocation
 	 */
-
 	max_low_pfn = bootmem_lastpg - PFN_DOWN(DMA_RESERVED_BYTES);
 	min_low_pfn = ARCH_PFN_OFFSET;
-	bootmap_size =  init_bootmem_node(NODE_DATA(0), bootmem_startpg, min_low_pfn, max_low_pfn);
+	memblock_reserve(PFN_PHYS(max_low_pfn), DMA_RESERVED_BYTES);
 
 	printk(KERN_INFO "bootmem_startpg:  0x%08lx\n", bootmem_startpg);
 	printk(KERN_INFO "bootmem_lastpg:  0x%08lx\n", bootmem_lastpg);
-	printk(KERN_INFO "bootmap_size:  %d\n", bootmap_size);
 	printk(KERN_INFO "min_low_pfn:  0x%08lx\n", min_low_pfn);
 	printk(KERN_INFO "max_low_pfn:  0x%08lx\n", max_low_pfn);
 
@@ -257,14 +261,6 @@ void __init setup_arch_memory(void)
 #endif
 
 	/*
-	 * Free all the memory that wasn't taken up by the bootmap, the DMA
-	 * reserve, or kernel itself.
-	 */
-	free_bootmem(PFN_PHYS(bootmem_startpg) + bootmap_size,
-		     PFN_PHYS(bootmem_lastpg - bootmem_startpg) - bootmap_size -
-		     DMA_RESERVED_BYTES);
-
-	/*
 	 *  The bootmem allocator seemingly just lives to feed memory
 	 *  to the paging system
 	 */
-- 
2.7.4
