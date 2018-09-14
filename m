Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 39B3E8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:12:59 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id r10-v6so3538274oti.19
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:12:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m24-v6si983953otf.149.2018.09.14.05.12.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 05:12:57 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EC5BNA010130
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:12:57 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mgamuw7sx-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:12:56 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 13:12:54 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 18/30] memblock: replace alloc_bootmem_low_pages with memblock_alloc_low
Date: Fri, 14 Sep 2018 15:10:33 +0300
In-Reply-To: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536927045-23536-19-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jonas Bonn <jonas@southpole.se>, Jonathan Corbet <corbet@lwn.net>, Ley Foon Tan <lftan@altera.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, Mike Rapoport <rppt@linux.vnet.ibm.com>

The alloc_bootmem_low_pages() function allocates PAGE_SIZE aligned regions
from low memory. memblock_alloc_low() with alignment set to PAGE_SIZE does
exactly the same thing.

The conversion is done using the following semantic patch:

@@
expression e;
@@
- alloc_bootmem_low_pages(e)
+ memblock_alloc_low(e, PAGE_SIZE)

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 arch/arc/mm/highmem.c                |  2 +-
 arch/m68k/atari/stram.c              |  3 ++-
 arch/m68k/mm/motorola.c              |  5 +++--
 arch/mips/cavium-octeon/dma-octeon.c |  2 +-
 arch/mips/mm/init.c                  |  3 ++-
 arch/um/kernel/mem.c                 | 10 ++++++----
 arch/xtensa/mm/mmu.c                 |  2 +-
 7 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/arch/arc/mm/highmem.c b/arch/arc/mm/highmem.c
index 77ff64a..f582dc8 100644
--- a/arch/arc/mm/highmem.c
+++ b/arch/arc/mm/highmem.c
@@ -123,7 +123,7 @@ static noinline pte_t * __init alloc_kmap_pgtable(unsigned long kvaddr)
 	pud_k = pud_offset(pgd_k, kvaddr);
 	pmd_k = pmd_offset(pud_k, kvaddr);
 
-	pte_k = (pte_t *)alloc_bootmem_low_pages(PAGE_SIZE);
+	pte_k = (pte_t *)memblock_alloc_low(PAGE_SIZE, PAGE_SIZE);
 	pmd_populate_kernel(&init_mm, pmd_k, pte_k);
 	return pte_k;
 }
diff --git a/arch/m68k/atari/stram.c b/arch/m68k/atari/stram.c
index c83d664..1089d67 100644
--- a/arch/m68k/atari/stram.c
+++ b/arch/m68k/atari/stram.c
@@ -95,7 +95,8 @@ void __init atari_stram_reserve_pages(void *start_mem)
 {
 	if (kernel_in_stram) {
 		pr_debug("atari_stram pool: kernel in ST-RAM, using alloc_bootmem!\n");
-		stram_pool.start = (resource_size_t)alloc_bootmem_low_pages(pool_size);
+		stram_pool.start = (resource_size_t)memblock_alloc_low(pool_size,
+								       PAGE_SIZE);
 		stram_pool.end = stram_pool.start + pool_size - 1;
 		request_resource(&iomem_resource, &stram_pool);
 		stram_virt_offset = 0;
diff --git a/arch/m68k/mm/motorola.c b/arch/m68k/mm/motorola.c
index 4e17ecb..8bcf57e 100644
--- a/arch/m68k/mm/motorola.c
+++ b/arch/m68k/mm/motorola.c
@@ -55,7 +55,7 @@ static pte_t * __init kernel_page_table(void)
 {
 	pte_t *ptablep;
 
-	ptablep = (pte_t *)alloc_bootmem_low_pages(PAGE_SIZE);
+	ptablep = (pte_t *)memblock_alloc_low(PAGE_SIZE, PAGE_SIZE);
 
 	clear_page(ptablep);
 	__flush_page_to_ram(ptablep);
@@ -95,7 +95,8 @@ static pmd_t * __init kernel_ptr_table(void)
 
 	last_pgtable += PTRS_PER_PMD;
 	if (((unsigned long)last_pgtable & ~PAGE_MASK) == 0) {
-		last_pgtable = (pmd_t *)alloc_bootmem_low_pages(PAGE_SIZE);
+		last_pgtable = (pmd_t *)memblock_alloc_low(PAGE_SIZE,
+							   PAGE_SIZE);
 
 		clear_page(last_pgtable);
 		__flush_page_to_ram(last_pgtable);
diff --git a/arch/mips/cavium-octeon/dma-octeon.c b/arch/mips/cavium-octeon/dma-octeon.c
index 236833b..c44c1a6 100644
--- a/arch/mips/cavium-octeon/dma-octeon.c
+++ b/arch/mips/cavium-octeon/dma-octeon.c
@@ -244,7 +244,7 @@ void __init plat_swiotlb_setup(void)
 	swiotlb_nslabs = ALIGN(swiotlb_nslabs, IO_TLB_SEGSIZE);
 	swiotlbsize = swiotlb_nslabs << IO_TLB_SHIFT;
 
-	octeon_swiotlb = alloc_bootmem_low_pages(swiotlbsize);
+	octeon_swiotlb = memblock_alloc_low(swiotlbsize, PAGE_SIZE);
 
 	if (swiotlb_init_with_tbl(octeon_swiotlb, swiotlb_nslabs, 1) == -ENOMEM)
 		panic("Cannot allocate SWIOTLB buffer");
diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index 400676c..a010fba7 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -244,7 +244,8 @@ void __init fixrange_init(unsigned long start, unsigned long end,
 			pmd = (pmd_t *)pud;
 			for (; (k < PTRS_PER_PMD) && (vaddr < end); pmd++, k++) {
 				if (pmd_none(*pmd)) {
-					pte = (pte_t *) alloc_bootmem_low_pages(PAGE_SIZE);
+					pte = (pte_t *) memblock_alloc_low(PAGE_SIZE,
+									   PAGE_SIZE);
 					set_pmd(pmd, __pmd((unsigned long)pte));
 					BUG_ON(pte != pte_offset_kernel(pmd, 0));
 				}
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 3c0e470..185f6bb 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -64,7 +64,8 @@ void __init mem_init(void)
 static void __init one_page_table_init(pmd_t *pmd)
 {
 	if (pmd_none(*pmd)) {
-		pte_t *pte = (pte_t *) alloc_bootmem_low_pages(PAGE_SIZE);
+		pte_t *pte = (pte_t *) memblock_alloc_low(PAGE_SIZE,
+							  PAGE_SIZE);
 		set_pmd(pmd, __pmd(_KERNPG_TABLE +
 					   (unsigned long) __pa(pte)));
 		if (pte != pte_offset_kernel(pmd, 0))
@@ -75,7 +76,7 @@ static void __init one_page_table_init(pmd_t *pmd)
 static void __init one_md_table_init(pud_t *pud)
 {
 #ifdef CONFIG_3_LEVEL_PGTABLES
-	pmd_t *pmd_table = (pmd_t *) alloc_bootmem_low_pages(PAGE_SIZE);
+	pmd_t *pmd_table = (pmd_t *) memblock_alloc_low(PAGE_SIZE, PAGE_SIZE);
 	set_pud(pud, __pud(_KERNPG_TABLE + (unsigned long) __pa(pmd_table)));
 	if (pmd_table != pmd_offset(pud, 0))
 		BUG();
@@ -124,7 +125,7 @@ static void __init fixaddr_user_init( void)
 		return;
 
 	fixrange_init( FIXADDR_USER_START, FIXADDR_USER_END, swapper_pg_dir);
-	v = (unsigned long) alloc_bootmem_low_pages(size);
+	v = (unsigned long) memblock_alloc_low(size, PAGE_SIZE);
 	memcpy((void *) v , (void *) FIXADDR_USER_START, size);
 	p = __pa(v);
 	for ( ; size > 0; size -= PAGE_SIZE, vaddr += PAGE_SIZE,
@@ -143,7 +144,8 @@ void __init paging_init(void)
 	unsigned long zones_size[MAX_NR_ZONES], vaddr;
 	int i;
 
-	empty_zero_page = (unsigned long *) alloc_bootmem_low_pages(PAGE_SIZE);
+	empty_zero_page = (unsigned long *) memblock_alloc_low(PAGE_SIZE,
+							       PAGE_SIZE);
 	for (i = 0; i < ARRAY_SIZE(zones_size); i++)
 		zones_size[i] = 0;
 
diff --git a/arch/xtensa/mm/mmu.c b/arch/xtensa/mm/mmu.c
index 9d1ecfc..f33a1ff 100644
--- a/arch/xtensa/mm/mmu.c
+++ b/arch/xtensa/mm/mmu.c
@@ -31,7 +31,7 @@ static void * __init init_pmd(unsigned long vaddr, unsigned long n_pages)
 	pr_debug("%s: vaddr: 0x%08lx, n_pages: %ld\n",
 		 __func__, vaddr, n_pages);
 
-	pte = alloc_bootmem_low_pages(n_pages * sizeof(pte_t));
+	pte = memblock_alloc_low(n_pages * sizeof(pte_t), PAGE_SIZE);
 
 	for (i = 0; i < n_pages; ++i)
 		pte_clear(NULL, 0, pte + i);
-- 
2.7.4
