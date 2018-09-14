Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 66A218E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:13:30 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id p1-v6so3506743oti.18
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:13:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k2-v6si3550170oia.251.2018.09.14.05.13.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 05:13:28 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EC4YaF096347
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:13:28 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mgay24xhp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:13:27 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 13:13:24 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 23/30] memblock: replace free_bootmem{_node} with memblock_free
Date: Fri, 14 Sep 2018 15:10:38 +0300
In-Reply-To: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536927045-23536-24-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jonas Bonn <jonas@southpole.se>, Jonathan Corbet <corbet@lwn.net>, Ley Foon Tan <lftan@altera.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, Mike Rapoport <rppt@linux.vnet.ibm.com>

The free_bootmem and free_bootmem_node are merely wrappers for
memblock_free. Replace their usage with a call to memblock_free using the
following semantic patch:

@@
expression e1, e2, e3;
@@
(
- free_bootmem(e1, e2)
+ memblock_free(e1, e2)
|
- free_bootmem_node(e1, e2, e3)
+ memblock_free(e2, e3)
)

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 arch/alpha/kernel/core_irongate.c |  3 +--
 arch/arm64/mm/init.c              |  2 +-
 arch/mips/kernel/setup.c          |  2 +-
 arch/powerpc/kernel/setup_64.c    |  2 +-
 arch/sparc/kernel/smp_64.c        |  2 +-
 arch/um/kernel/mem.c              |  3 ++-
 arch/unicore32/mm/init.c          |  2 +-
 arch/x86/kernel/setup_percpu.c    |  3 ++-
 arch/x86/kernel/tce_64.c          |  3 ++-
 arch/x86/xen/p2m.c                |  3 ++-
 drivers/macintosh/smu.c           |  2 +-
 drivers/usb/early/xhci-dbc.c      | 11 ++++++-----
 drivers/xen/swiotlb-xen.c         |  4 +++-
 include/linux/bootmem.h           |  4 ----
 mm/nobootmem.c                    | 30 ------------------------------
 15 files changed, 24 insertions(+), 52 deletions(-)

diff --git a/arch/alpha/kernel/core_irongate.c b/arch/alpha/kernel/core_irongate.c
index f709866..35572be 100644
--- a/arch/alpha/kernel/core_irongate.c
+++ b/arch/alpha/kernel/core_irongate.c
@@ -234,8 +234,7 @@ albacore_init_arch(void)
 			unsigned long size;
 
 			size = initrd_end - initrd_start;
-			free_bootmem_node(NODE_DATA(0), __pa(initrd_start),
-					  PAGE_ALIGN(size));
+			memblock_free(__pa(initrd_start), PAGE_ALIGN(size));
 			if (!move_initrd(pci_mem))
 				printk("irongate_init_arch: initrd too big "
 				       "(%ldK)\ndisabling initrd\n",
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 787e279..e335452 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -538,7 +538,7 @@ static inline void free_memmap(unsigned long start_pfn, unsigned long end_pfn)
 	 * memmap array.
 	 */
 	if (pg < pgend)
-		free_bootmem(pg, pgend - pg);
+		memblock_free(pg, pgend - pg);
 }
 
 /*
diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
index a6bc2f6..86c9eda 100644
--- a/arch/mips/kernel/setup.c
+++ b/arch/mips/kernel/setup.c
@@ -561,7 +561,7 @@ static void __init bootmem_init(void)
 		extern void show_kernel_relocation(const char *level);
 
 		offset = __pa_symbol(_text) - __pa_symbol(VMLINUX_LOAD_ADDRESS);
-		free_bootmem(__pa_symbol(VMLINUX_LOAD_ADDRESS), offset);
+		memblock_free(__pa_symbol(VMLINUX_LOAD_ADDRESS), offset);
 
 #if defined(CONFIG_DEBUG_KERNEL) && defined(CONFIG_DEBUG_INFO)
 		/*
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index 6add560..e564b27 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -765,7 +765,7 @@ static void * __init pcpu_fc_alloc(unsigned int cpu, size_t size, size_t align)
 
 static void __init pcpu_fc_free(void *ptr, size_t size)
 {
-	free_bootmem(__pa(ptr), size);
+	memblock_free(__pa(ptr), size);
 }
 
 static int pcpu_cpu_distance(unsigned int from, unsigned int to)
diff --git a/arch/sparc/kernel/smp_64.c b/arch/sparc/kernel/smp_64.c
index 337febd..a087a6a 100644
--- a/arch/sparc/kernel/smp_64.c
+++ b/arch/sparc/kernel/smp_64.c
@@ -1607,7 +1607,7 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, size_t size,
 
 static void __init pcpu_free_bootmem(void *ptr, size_t size)
 {
-	free_bootmem(__pa(ptr), size);
+	memblock_free(__pa(ptr), size);
 }
 
 static int __init pcpu_cpu_distance(unsigned int from, unsigned int to)
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 185f6bb..3555c13 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -6,6 +6,7 @@
 #include <linux/stddef.h>
 #include <linux/module.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/highmem.h>
 #include <linux/mm.h>
 #include <linux/swap.h>
@@ -46,7 +47,7 @@ void __init mem_init(void)
 	 */
 	brk_end = (unsigned long) UML_ROUND_UP(sbrk(0));
 	map_memory(brk_end, __pa(brk_end), uml_reserved - brk_end, 1, 1, 0);
-	free_bootmem(__pa(brk_end), uml_reserved - brk_end);
+	memblock_free(__pa(brk_end), uml_reserved - brk_end);
 	uml_reserved = brk_end;
 
 	/* this will put all low memory onto the freelists */
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index 44ccc15..4c572ab 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -241,7 +241,7 @@ free_memmap(unsigned long start_pfn, unsigned long end_pfn)
 	 * free the section of the memmap array.
 	 */
 	if (pg < pgend)
-		free_bootmem(pg, pgend - pg);
+		memblock_free(pg, pgend - pg);
 }
 
 /*
diff --git a/arch/x86/kernel/setup_percpu.c b/arch/x86/kernel/setup_percpu.c
index 041663a..a006f1b 100644
--- a/arch/x86/kernel/setup_percpu.c
+++ b/arch/x86/kernel/setup_percpu.c
@@ -5,6 +5,7 @@
 #include <linux/export.h>
 #include <linux/init.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/percpu.h>
 #include <linux/kexec.h>
 #include <linux/crash_dump.h>
@@ -135,7 +136,7 @@ static void * __init pcpu_fc_alloc(unsigned int cpu, size_t size, size_t align)
 
 static void __init pcpu_fc_free(void *ptr, size_t size)
 {
-	free_bootmem(__pa(ptr), size);
+	memblock_free(__pa(ptr), size);
 }
 
 static int __init pcpu_cpu_distance(unsigned int from, unsigned int to)
diff --git a/arch/x86/kernel/tce_64.c b/arch/x86/kernel/tce_64.c
index 54c9b5a..75730ce 100644
--- a/arch/x86/kernel/tce_64.c
+++ b/arch/x86/kernel/tce_64.c
@@ -31,6 +31,7 @@
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <asm/tce.h>
 #include <asm/calgary.h>
 #include <asm/proto.h>
@@ -186,5 +187,5 @@ void __init free_tce_table(void *tbl)
 	size = table_size_to_number_of_entries(specified_table_size);
 	size *= TCE_ENTRY_SIZE;
 
-	free_bootmem(__pa(tbl), size);
+	memblock_free(__pa(tbl), size);
 }
diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
index 5de761b..b3e11af 100644
--- a/arch/x86/xen/p2m.c
+++ b/arch/x86/xen/p2m.c
@@ -68,6 +68,7 @@
 #include <linux/sched.h>
 #include <linux/seq_file.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 
@@ -190,7 +191,7 @@ static void * __ref alloc_p2m_page(void)
 static void __ref free_p2m_page(void *p)
 {
 	if (unlikely(!slab_is_available())) {
-		free_bootmem((unsigned long)p, PAGE_SIZE);
+		memblock_free((unsigned long)p, PAGE_SIZE);
 		return;
 	}
 
diff --git a/drivers/macintosh/smu.c b/drivers/macintosh/smu.c
index 332fcca..0069f90 100644
--- a/drivers/macintosh/smu.c
+++ b/drivers/macintosh/smu.c
@@ -569,7 +569,7 @@ int __init smu_init (void)
 fail_db_node:
 	of_node_put(smu->db_node);
 fail_bootmem:
-	free_bootmem(__pa(smu), sizeof(struct smu_device));
+	memblock_free(__pa(smu), sizeof(struct smu_device));
 	smu = NULL;
 fail_np:
 	of_node_put(np);
diff --git a/drivers/usb/early/xhci-dbc.c b/drivers/usb/early/xhci-dbc.c
index 16df968..4411404 100644
--- a/drivers/usb/early/xhci-dbc.c
+++ b/drivers/usb/early/xhci-dbc.c
@@ -13,6 +13,7 @@
 #include <linux/pci_regs.h>
 #include <linux/pci_ids.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/io.h>
 #include <asm/pci-direct.h>
 #include <asm/fixmap.h>
@@ -191,7 +192,7 @@ static void __init xdbc_free_ring(struct xdbc_ring *ring)
 	if (!seg)
 		return;
 
-	free_bootmem(seg->dma, PAGE_SIZE);
+	memblock_free(seg->dma, PAGE_SIZE);
 	ring->segment = NULL;
 }
 
@@ -675,10 +676,10 @@ int __init early_xdbc_setup_hardware(void)
 		xdbc_free_ring(&xdbc.in_ring);
 
 		if (xdbc.table_dma)
-			free_bootmem(xdbc.table_dma, PAGE_SIZE);
+			memblock_free(xdbc.table_dma, PAGE_SIZE);
 
 		if (xdbc.out_dma)
-			free_bootmem(xdbc.out_dma, PAGE_SIZE);
+			memblock_free(xdbc.out_dma, PAGE_SIZE);
 
 		xdbc.table_base = NULL;
 		xdbc.out_buf = NULL;
@@ -1000,8 +1001,8 @@ static int __init xdbc_init(void)
 	xdbc_free_ring(&xdbc.evt_ring);
 	xdbc_free_ring(&xdbc.out_ring);
 	xdbc_free_ring(&xdbc.in_ring);
-	free_bootmem(xdbc.table_dma, PAGE_SIZE);
-	free_bootmem(xdbc.out_dma, PAGE_SIZE);
+	memblock_free(xdbc.table_dma, PAGE_SIZE);
+	memblock_free(xdbc.out_dma, PAGE_SIZE);
 	writel(0, &xdbc.xdbc_reg->control);
 	early_iounmap(xdbc.xhci_base, xdbc.xhci_length);
 
diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index 8d849b4..6c13ff4 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -36,6 +36,7 @@
 #define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
 
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/dma-direct.h>
 #include <linux/export.h>
 #include <xen/swiotlb-xen.h>
@@ -248,7 +249,8 @@ int __ref xen_swiotlb_init(int verbose, bool early)
 			       xen_io_tlb_nslabs);
 	if (rc) {
 		if (early)
-			free_bootmem(__pa(xen_io_tlb_start), PAGE_ALIGN(bytes));
+			memblock_free(__pa(xen_io_tlb_start),
+				      PAGE_ALIGN(bytes));
 		else {
 			free_pages((unsigned long)xen_io_tlb_start, order);
 			xen_io_tlb_start = NULL;
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 73f1272..706cf8e 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -30,10 +30,6 @@ extern unsigned long free_all_bootmem(void);
 extern void reset_node_managed_pages(pg_data_t *pgdat);
 extern void reset_all_zones_managed_pages(void);
 
-extern void free_bootmem_node(pg_data_t *pgdat,
-			      unsigned long addr,
-			      unsigned long size);
-extern void free_bootmem(unsigned long physaddr, unsigned long size);
 extern void free_bootmem_late(unsigned long physaddr, unsigned long size);
 
 /* We are using top down, so it is safe to use 0 here */
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index bc38e56..85e1822 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -150,33 +150,3 @@ unsigned long __init free_all_bootmem(void)
 
 	return pages;
 }
-
-/**
- * free_bootmem_node - mark a page range as usable
- * @pgdat: node the range resides on
- * @physaddr: starting physical address of the range
- * @size: size of the range in bytes
- *
- * Partial pages will be considered reserved and left as they are.
- *
- * The range must reside completely on the specified node.
- */
-void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
-			      unsigned long size)
-{
-	memblock_free(physaddr, size);
-}
-
-/**
- * free_bootmem - mark a page range as usable
- * @addr: starting physical address of the range
- * @size: size of the range in bytes
- *
- * Partial pages will be considered reserved and left as they are.
- *
- * The range must be contiguous but may span node boundaries.
- */
-void __init free_bootmem(unsigned long addr, unsigned long size)
-{
-	memblock_free(addr, size);
-}
-- 
2.7.4
