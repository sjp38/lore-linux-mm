Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C785E6B026D
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 15:59:28 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y8-v6so2018984edr.12
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 12:59:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x62-v6si2285545edc.151.2018.08.03.12.59.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 12:59:27 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w73Jx4Rt026815
	for <linux-mm@kvack.org>; Fri, 3 Aug 2018 15:59:25 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kmudxctg5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Aug 2018 15:59:25 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 3 Aug 2018 20:59:22 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 7/7] unicore32: switch to NO_BOOTMEM
Date: Fri,  3 Aug 2018 22:58:50 +0300
In-Reply-To: <1533326330-31677-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1533326330-31677-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1533326330-31677-8-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Kuo <rkuo@codeaurora.org>, Ley Foon Tan <lftan@altera.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@pku.edu.cn>, Michal Hocko <mhocko@kernel.org>, linux-hexagon@vger.kernel.org, nios2-dev@lists.rocketboards.org, linux-um@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The unicore32 already supports memblock and uses it for some early memory
reservations, e.g initrd and the page tables.

At some point unicore32 allocates the bootmem bitmap from the memblock and
then hands over the memory reservations from memblock to bootmem.

This patch removes the bootmem initialization and leaves memblock as the
only boot time memory manager for unicore32.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Guan Xuetao <gxt@pku.edu.cn>
---
 arch/unicore32/Kconfig   |  1 +
 arch/unicore32/mm/init.c | 54 +-----------------------------------------------
 2 files changed, 2 insertions(+), 53 deletions(-)

diff --git a/arch/unicore32/Kconfig b/arch/unicore32/Kconfig
index 03f991e..cff4b9d 100644
--- a/arch/unicore32/Kconfig
+++ b/arch/unicore32/Kconfig
@@ -5,6 +5,7 @@ config UNICORE32
 	select ARCH_MIGHT_HAVE_PC_PARPORT
 	select ARCH_MIGHT_HAVE_PC_SERIO
 	select HAVE_MEMBLOCK
+	select NO_BOOTMEM
 	select HAVE_GENERIC_DMA_COHERENT
 	select HAVE_KERNEL_GZIP
 	select HAVE_KERNEL_BZIP2
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index f4950fb..44ccc15 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -84,58 +84,6 @@ static void __init find_limits(unsigned long *min, unsigned long *max_low,
 	}
 }
 
-static void __init uc32_bootmem_init(unsigned long start_pfn,
-	unsigned long end_pfn)
-{
-	struct memblock_region *reg;
-	unsigned int boot_pages;
-	phys_addr_t bitmap;
-	pg_data_t *pgdat;
-
-	/*
-	 * Allocate the bootmem bitmap page.  This must be in a region
-	 * of memory which has already been mapped.
-	 */
-	boot_pages = bootmem_bootmap_pages(end_pfn - start_pfn);
-	bitmap = memblock_alloc_base(boot_pages << PAGE_SHIFT, L1_CACHE_BYTES,
-				__pfn_to_phys(end_pfn));
-
-	/*
-	 * Initialise the bootmem allocator, handing the
-	 * memory banks over to bootmem.
-	 */
-	node_set_online(0);
-	pgdat = NODE_DATA(0);
-	init_bootmem_node(pgdat, __phys_to_pfn(bitmap), start_pfn, end_pfn);
-
-	/* Free the lowmem regions from memblock into bootmem. */
-	for_each_memblock(memory, reg) {
-		unsigned long start = memblock_region_memory_base_pfn(reg);
-		unsigned long end = memblock_region_memory_end_pfn(reg);
-
-		if (end >= end_pfn)
-			end = end_pfn;
-		if (start >= end)
-			break;
-
-		free_bootmem(__pfn_to_phys(start), (end - start) << PAGE_SHIFT);
-	}
-
-	/* Reserve the lowmem memblock reserved regions in bootmem. */
-	for_each_memblock(reserved, reg) {
-		unsigned long start = memblock_region_reserved_base_pfn(reg);
-		unsigned long end = memblock_region_reserved_end_pfn(reg);
-
-		if (end >= end_pfn)
-			end = end_pfn;
-		if (start >= end)
-			break;
-
-		reserve_bootmem(__pfn_to_phys(start),
-			(end - start) << PAGE_SHIFT, BOOTMEM_DEFAULT);
-	}
-}
-
 static void __init uc32_bootmem_free(unsigned long min, unsigned long max_low,
 	unsigned long max_high)
 {
@@ -232,7 +180,7 @@ void __init bootmem_init(void)
 
 	find_limits(&min, &max_low, &max_high);
 
-	uc32_bootmem_init(min, max_low);
+	node_set_online(0);
 
 #ifdef CONFIG_SWIOTLB
 	swiotlb_init(1);
-- 
2.7.4
