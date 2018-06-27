Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E61A6B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:09:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id q19-v6so2479056wmq.8
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 05:09:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h3-v6si2292534wmi.179.2018.06.27.05.09.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 05:09:31 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5RC502M096735
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:09:29 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2jv9yyh1g7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:09:29 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 27 Jun 2018 13:09:28 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] c6x: switch to NO_BOOTMEM
Date: Wed, 27 Jun 2018 15:09:20 +0300
Message-Id: <1530101360-5768-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>, Aurelien Jacquiot <jacquiot.aurelien@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-c6x <linux-c6x-dev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The c6x is already using memblock and does most of early memory
reservations with it, so it was only a matter of removing the bootmem
initialization and handover of the memory from memblock to bootmem.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/c6x/Kconfig        |  1 +
 arch/c6x/kernel/setup.c | 26 +-------------------------
 2 files changed, 2 insertions(+), 25 deletions(-)

diff --git a/arch/c6x/Kconfig b/arch/c6x/Kconfig
index bf59855628ac..054c7c963180 100644
--- a/arch/c6x/Kconfig
+++ b/arch/c6x/Kconfig
@@ -14,6 +14,7 @@ config C6X
 	select GENERIC_IRQ_SHOW
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_MEMBLOCK
+	select NO_BOOTMEM
 	select SPARSE_IRQ
 	select IRQ_DOMAIN
 	select OF
diff --git a/arch/c6x/kernel/setup.c b/arch/c6x/kernel/setup.c
index 786e36e2f61d..cc74cb9d349b 100644
--- a/arch/c6x/kernel/setup.c
+++ b/arch/c6x/kernel/setup.c
@@ -296,7 +296,6 @@ notrace void __init machine_init(unsigned long dt_ptr)
 
 void __init setup_arch(char **cmdline_p)
 {
-	int bootmap_size;
 	struct memblock_region *reg;
 
 	printk(KERN_INFO "Initializing kernel\n");
@@ -353,16 +352,6 @@ void __init setup_arch(char **cmdline_p)
 	init_mm.end_data   = memory_start;
 	init_mm.brk        = memory_start;
 
-	/*
-	 * Give all the memory to the bootmap allocator,  tell it to put the
-	 * boot mem_map at the start of memory
-	 */
-	bootmap_size = init_bootmem_node(NODE_DATA(0),
-					 memory_start >> PAGE_SHIFT,
-					 PAGE_OFFSET >> PAGE_SHIFT,
-					 memory_end >> PAGE_SHIFT);
-	memblock_reserve(memory_start, bootmap_size);
-
 	unflatten_device_tree();
 
 	c6x_cache_init();
@@ -397,22 +386,9 @@ void __init setup_arch(char **cmdline_p)
 	/* Initialize the coherent memory allocator */
 	coherent_mem_init(dma_start, dma_size);
 
-	/*
-	 * Free all memory as a starting point.
-	 */
-	free_bootmem(PAGE_OFFSET, memory_end - PAGE_OFFSET);
-
-	/*
-	 * Then reserve memory which is already being used.
-	 */
-	for_each_memblock(reserved, reg) {
-		pr_debug("reserved - 0x%08x-0x%08x\n",
-			 (u32) reg->base, (u32) reg->size);
-		reserve_bootmem(reg->base, reg->size, BOOTMEM_DEFAULT);
-	}
-
 	max_low_pfn = PFN_DOWN(memory_end);
 	min_low_pfn = PFN_UP(memory_start);
+	max_pfn = max_low_pfn;
 	max_mapnr = max_low_pfn - min_low_pfn;
 
 	/* Get kmalloc into gear */
-- 
2.7.4
