Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id B20446B0253
	for <linux-mm@kvack.org>; Thu,  5 May 2016 03:54:30 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id gw7so106152131pac.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 00:54:30 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id ya3si9937867pab.2.2016.05.05.00.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 00:54:29 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id zy2so8591459pac.2
        for <linux-mm@kvack.org>; Thu, 05 May 2016 00:54:29 -0700 (PDT)
From: Oliver O'Halloran <oohall@gmail.com>
Subject: [PATCH v2 1/2] powerpc/mm: define TOP_ZONE as a constant
Date: Thu,  5 May 2016 17:54:08 +1000
Message-Id: <1462434849-14935-1-git-send-email-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Oliver O'Halloran <oohall@gmail.com>, linux-mm@kvack.org

The zone that contains the top of memory will be either ZONE_NORMAL
or ZONE_HIGHMEM depending on the kernel config. There are two functions
that require this information and both of them use an #ifdef to set
a local variable (top_zone). This is a little silly so lets just make it
a constant.

Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
Cc: linux-mm@kvack.org
---
 arch/powerpc/mm/mem.c | 17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index ac79dbde1015..8f4c19789a38 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -68,12 +68,15 @@ pte_t *kmap_pte;
 EXPORT_SYMBOL(kmap_pte);
 pgprot_t kmap_prot;
 EXPORT_SYMBOL(kmap_prot);
+#define TOP_ZONE ZONE_HIGHMEM
 
 static inline pte_t *virt_to_kpte(unsigned long vaddr)
 {
 	return pte_offset_kernel(pmd_offset(pud_offset(pgd_offset_k(vaddr),
 			vaddr), vaddr), vaddr);
 }
+#else
+#define TOP_ZONE ZONE_NORMAL
 #endif
 
 int page_is_ram(unsigned long pfn)
@@ -267,14 +270,9 @@ void __init limit_zone_pfn(enum zone_type zone, unsigned long pfn_limit)
  */
 int dma_pfn_limit_to_zone(u64 pfn_limit)
 {
-	enum zone_type top_zone = ZONE_NORMAL;
 	int i;
 
-#ifdef CONFIG_HIGHMEM
-	top_zone = ZONE_HIGHMEM;
-#endif
-
-	for (i = top_zone; i >= 0; i--) {
+	for (i = TOP_ZONE; i >= 0; i--) {
 		if (max_zone_pfns[i] <= pfn_limit)
 			return i;
 	}
@@ -289,7 +287,6 @@ void __init paging_init(void)
 {
 	unsigned long long total_ram = memblock_phys_mem_size();
 	phys_addr_t top_of_ram = memblock_end_of_DRAM();
-	enum zone_type top_zone;
 
 #ifdef CONFIG_PPC32
 	unsigned long v = __fix_to_virt(__end_of_fixed_addresses - 1);
@@ -313,13 +310,9 @@ void __init paging_init(void)
 	       (long int)((top_of_ram - total_ram) >> 20));
 
 #ifdef CONFIG_HIGHMEM
-	top_zone = ZONE_HIGHMEM;
 	limit_zone_pfn(ZONE_NORMAL, lowmem_end_addr >> PAGE_SHIFT);
-#else
-	top_zone = ZONE_NORMAL;
 #endif
-
-	limit_zone_pfn(top_zone, top_of_ram >> PAGE_SHIFT);
+	limit_zone_pfn(TOP_ZONE, top_of_ram >> PAGE_SHIFT);
 	zone_limits_final = true;
 	free_area_init_nodes(max_zone_pfns);
 
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
