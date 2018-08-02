Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2AF6B000C
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 07:54:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b25-v6so718789eds.17
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 04:54:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v2-v6si1781675edm.144.2018.08.02.04.54.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 04:54:12 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w72BsA93132023
	for <linux-mm@kvack.org>; Thu, 2 Aug 2018 07:54:10 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2kkx7h8g0n-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Aug 2018 07:54:10 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 2 Aug 2018 12:54:03 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/2] sparc32: switch to NO_BOOTMEM
Date: Thu,  2 Aug 2018 14:53:52 +0300
In-Reply-To: <1533210833-14748-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1533210833-14748-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1533210833-14748-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>, Michal Hocko <mhocko@kernel.org>, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Each populated sparc_phys_bank is added to memblock.memory. The
reserve_bootmem() calls are replaced with memblock_reserve(), and the
bootmem bitmap initialization is droppped.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/sparc/Kconfig      |  4 +--
 arch/sparc/mm/init_32.c | 74 ++++++++++++++-----------------------------------
 2 files changed, 23 insertions(+), 55 deletions(-)

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 0f535de..0a874c8 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -45,6 +45,8 @@ config SPARC
 	select LOCKDEP_SMALL if LOCKDEP
 	select NEED_DMA_MAP_STATE
 	select NEED_SG_DMA_LENGTH
+	select HAVE_MEMBLOCK
+	select NO_BOOTMEM
 
 config SPARC32
 	def_bool !64BIT
@@ -60,7 +62,6 @@ config SPARC64
 	select HAVE_KRETPROBES
 	select HAVE_KPROBES
 	select HAVE_RCU_TABLE_FREE if SMP
-	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	select HAVE_DYNAMIC_FTRACE
@@ -79,7 +80,6 @@ config SPARC64
 	select IRQ_PREFLOW_FASTEOI
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select HAVE_C_RECORDMCOUNT
-	select NO_BOOTMEM
 	select HAVE_ARCH_AUDITSYSCALL
 	select ARCH_SUPPORTS_ATOMIC_RMW
 	select HAVE_NMI
diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index 95fe4f0..5117a5e 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -23,6 +23,7 @@
 #include <linux/init.h>
 #include <linux/highmem.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/pagemap.h>
 #include <linux/poison.h>
 #include <linux/gfp.h>
@@ -103,11 +104,15 @@ static unsigned long calc_max_low_pfn(void)
 
 unsigned long __init bootmem_init(unsigned long *pages_avail)
 {
-	unsigned long bootmap_size, start_pfn;
+	unsigned long start_pfn;
 	unsigned long end_of_phys_memory = 0UL;
-	unsigned long bootmap_pfn, bytes_avail, size;
+	unsigned long bytes_avail, size;
+	unsigned long high_pages = 0UL;
 	int i;
 
+	memblock_set_bottom_up(true);
+	memblock_allow_resize();
+
 	bytes_avail = 0UL;
 	for (i = 0; sp_banks[i].num_bytes != 0; i++) {
 		end_of_phys_memory = sp_banks[i].base_addr +
@@ -124,12 +129,15 @@ unsigned long __init bootmem_init(unsigned long *pages_avail)
 				if (sp_banks[i].num_bytes == 0) {
 					sp_banks[i].base_addr = 0xdeadbeef;
 				} else {
+					memblock_add(sp_banks[i].base_addr,
+						     sp_banks[i].num_bytes);
 					sp_banks[i+1].num_bytes = 0;
 					sp_banks[i+1].base_addr = 0xdeadbeef;
 				}
 				break;
 			}
 		}
+		memblock_add(sp_banks[i].base_addr, sp_banks[i].num_bytes);
 	}
 
 	/* Start with page aligned address of last symbol in kernel
@@ -140,8 +148,6 @@ unsigned long __init bootmem_init(unsigned long *pages_avail)
 	/* Now shift down to get the real physical page frame number. */
 	start_pfn >>= PAGE_SHIFT;
 
-	bootmap_pfn = start_pfn;
-
 	max_pfn = end_of_phys_memory >> PAGE_SHIFT;
 
 	max_low_pfn = max_pfn;
@@ -150,12 +156,16 @@ unsigned long __init bootmem_init(unsigned long *pages_avail)
 	if (max_low_pfn > pfn_base + (SRMMU_MAXMEM >> PAGE_SHIFT)) {
 		highstart_pfn = pfn_base + (SRMMU_MAXMEM >> PAGE_SHIFT);
 		max_low_pfn = calc_max_low_pfn();
+		high_pages = calc_highpages();
 		printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
-		    calc_highpages() >> (20 - PAGE_SHIFT));
+		    high_pages >> (20 - PAGE_SHIFT));
 	}
 
 #ifdef CONFIG_BLK_DEV_INITRD
-	/* Now have to check initial ramdisk, so that bootmap does not overwrite it */
+	/*
+	 * Now have to check initial ramdisk, so that it won't pass
+	 * the end of memory
+	 */
 	if (sparc_ramdisk_image) {
 		if (sparc_ramdisk_image >= (unsigned long)&_end - 2 * PAGE_SIZE)
 			sparc_ramdisk_image -= KERNBASE;
@@ -167,67 +177,25 @@ unsigned long __init bootmem_init(unsigned long *pages_avail)
 			       initrd_end, end_of_phys_memory);
 			initrd_start = 0;
 		}
-		if (initrd_start) {
-			if (initrd_start >= (start_pfn << PAGE_SHIFT) &&
-			    initrd_start < (start_pfn << PAGE_SHIFT) + 2 * PAGE_SIZE)
-				bootmap_pfn = PAGE_ALIGN (initrd_end) >> PAGE_SHIFT;
-		}
 	}
-#endif	
-	/* Initialize the boot-time allocator. */
-	bootmap_size = init_bootmem_node(NODE_DATA(0), bootmap_pfn, pfn_base,
-					 max_low_pfn);
-
-	/* Now register the available physical memory with the
-	 * allocator.
-	 */
-	*pages_avail = 0;
-	for (i = 0; sp_banks[i].num_bytes != 0; i++) {
-		unsigned long curr_pfn, last_pfn;
-
-		curr_pfn = sp_banks[i].base_addr >> PAGE_SHIFT;
-		if (curr_pfn >= max_low_pfn)
-			break;
-
-		last_pfn = (sp_banks[i].base_addr + sp_banks[i].num_bytes) >> PAGE_SHIFT;
-		if (last_pfn > max_low_pfn)
-			last_pfn = max_low_pfn;
-
-		/*
-		 * .. finally, did all the rounding and playing
-		 * around just make the area go away?
-		 */
-		if (last_pfn <= curr_pfn)
-			continue;
+#endif
 
-		size = (last_pfn - curr_pfn) << PAGE_SHIFT;
-		*pages_avail += last_pfn - curr_pfn;
-
-		free_bootmem(sp_banks[i].base_addr, size);
-	}
+	*pages_avail = (memblock_phys_mem_size() >> PAGE_SHIFT) - high_pages;
 
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (initrd_start) {
 		/* Reserve the initrd image area. */
 		size = initrd_end - initrd_start;
-		reserve_bootmem(initrd_start, size, BOOTMEM_DEFAULT);
+		memblock_reserve(initrd_start, size);
 		*pages_avail -= PAGE_ALIGN(size) >> PAGE_SHIFT;
 
 		initrd_start = (initrd_start - phys_base) + PAGE_OFFSET;
-		initrd_end = (initrd_end - phys_base) + PAGE_OFFSET;		
+		initrd_end = (initrd_end - phys_base) + PAGE_OFFSET;
 	}
 #endif
 	/* Reserve the kernel text/data/bss. */
 	size = (start_pfn << PAGE_SHIFT) - phys_base;
-	reserve_bootmem(phys_base, size, BOOTMEM_DEFAULT);
-	*pages_avail -= PAGE_ALIGN(size) >> PAGE_SHIFT;
-
-	/* Reserve the bootmem map.   We do not account for it
-	 * in pages_avail because we will release that memory
-	 * in free_all_bootmem.
-	 */
-	size = bootmap_size;
-	reserve_bootmem((bootmap_pfn << PAGE_SHIFT), size, BOOTMEM_DEFAULT);
+	memblock_reserve(phys_base, size);
 	*pages_avail -= PAGE_ALIGN(size) >> PAGE_SHIFT;
 
 	return max_pfn;
-- 
2.7.4
