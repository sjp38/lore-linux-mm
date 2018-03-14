Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 53C026B0005
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 01:01:12 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f3-v6so909398plf.1
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 22:01:12 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id b15si1261167pga.552.2018.03.13.22.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 22:01:10 -0700 (PDT)
Subject: [PATCH] x86, memremap: fix altmap accounting at free
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 13 Mar 2018 21:52:04 -0700
Message-ID: <152100312423.27180.6073263768072550564.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jane Chu <jane.chu@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit 24b6d4164348 "mm: pass the vmem_altmap to vmemmap_free" converted
the vmemmap_free() path to pass the altmap argument all the way through
the call chain rather than looking it up based on the page.
Unfortunately that ends up over freeing altmap allocated pages in some
cases since free_pagetable() is used to free both memmap space and pte
space, where only the memmap stored in huge pages uses altmap
allocations.

Given that altmap allocations for memmap space are special cased in
vmemmap_populate_hugepages() add a symmetric / special case
free_hugepage_table() to handle altmap freeing, and cleanup the unneeded
passing of altmap to leaf functions that do not require it.

Without this change the sanity check accounting in
devm_memremap_pages_release() will throw a warning with the following
signature.

 nd_pmem pfn10.1: devm_memremap_pages_release: failed to free all reserved pages
 WARNING: CPU: 44 PID: 3539 at kernel/memremap.c:310 devm_memremap_pages_release+0x1c7/0x220
 CPU: 44 PID: 3539 Comm: ndctl Tainted: G             L   4.16.0-rc1-linux-stable #7
 RIP: 0010:devm_memremap_pages_release+0x1c7/0x220
 [..]
 Call Trace:
  release_nodes+0x225/0x270
  device_release_driver_internal+0x15d/0x210
  bus_remove_device+0xe2/0x160
  device_del+0x130/0x310
  ? klist_release+0x56/0x100
  ? nd_region_notify+0xc0/0xc0 [libnvdimm]
  device_unregister+0x16/0x60

This was missed in testing since not all configurations will trigger
this warning.

Fixes: 24b6d4164348 ("mm: pass the vmem_altmap to vmemmap_free")
Reported-by: Jane Chu <jane.chu@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/init_64.c |   60 +++++++++++++++++++++++--------------------------
 1 file changed, 28 insertions(+), 32 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 8b72923f1d35..af11a2890235 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -800,17 +800,11 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 
 #define PAGE_INUSE 0xFD
 
-static void __meminit free_pagetable(struct page *page, int order,
-		struct vmem_altmap *altmap)
+static void __meminit free_pagetable(struct page *page, int order)
 {
 	unsigned long magic;
 	unsigned int nr_pages = 1 << order;
 
-	if (altmap) {
-		vmem_altmap_free(altmap, nr_pages);
-		return;
-	}
-
 	/* bootmem page has reserved flag */
 	if (PageReserved(page)) {
 		__ClearPageReserved(page);
@@ -826,9 +820,17 @@ static void __meminit free_pagetable(struct page *page, int order,
 		free_pages((unsigned long)page_address(page), order);
 }
 
-static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd,
+static void __meminit free_hugepage_table(struct page *page,
 		struct vmem_altmap *altmap)
 {
+	if (altmap)
+		vmem_altmap_free(altmap, PMD_SIZE / PAGE_SIZE);
+	else
+		free_pagetable(page, get_order(PMD_SIZE));
+}
+
+static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd)
+{
 	pte_t *pte;
 	int i;
 
@@ -839,14 +841,13 @@ static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd,
 	}
 
 	/* free a pte talbe */
-	free_pagetable(pmd_page(*pmd), 0, altmap);
+	free_pagetable(pmd_page(*pmd), 0);
 	spin_lock(&init_mm.page_table_lock);
 	pmd_clear(pmd);
 	spin_unlock(&init_mm.page_table_lock);
 }
 
-static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud,
-		struct vmem_altmap *altmap)
+static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud)
 {
 	pmd_t *pmd;
 	int i;
@@ -858,14 +859,13 @@ static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud,
 	}
 
 	/* free a pmd talbe */
-	free_pagetable(pud_page(*pud), 0, altmap);
+	free_pagetable(pud_page(*pud), 0);
 	spin_lock(&init_mm.page_table_lock);
 	pud_clear(pud);
 	spin_unlock(&init_mm.page_table_lock);
 }
 
-static void __meminit free_pud_table(pud_t *pud_start, p4d_t *p4d,
-		struct vmem_altmap *altmap)
+static void __meminit free_pud_table(pud_t *pud_start, p4d_t *p4d)
 {
 	pud_t *pud;
 	int i;
@@ -877,7 +877,7 @@ static void __meminit free_pud_table(pud_t *pud_start, p4d_t *p4d,
 	}
 
 	/* free a pud talbe */
-	free_pagetable(p4d_page(*p4d), 0, altmap);
+	free_pagetable(p4d_page(*p4d), 0);
 	spin_lock(&init_mm.page_table_lock);
 	p4d_clear(p4d);
 	spin_unlock(&init_mm.page_table_lock);
@@ -885,7 +885,7 @@ static void __meminit free_pud_table(pud_t *pud_start, p4d_t *p4d,
 
 static void __meminit
 remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
-		 struct vmem_altmap *altmap, bool direct)
+		 bool direct)
 {
 	unsigned long next, pages = 0;
 	pte_t *pte;
@@ -916,7 +916,7 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 			 * freed when offlining, or simplely not in use.
 			 */
 			if (!direct)
-				free_pagetable(pte_page(*pte), 0, altmap);
+				free_pagetable(pte_page(*pte), 0);
 
 			spin_lock(&init_mm.page_table_lock);
 			pte_clear(&init_mm, addr, pte);
@@ -939,7 +939,7 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 
 			page_addr = page_address(pte_page(*pte));
 			if (!memchr_inv(page_addr, PAGE_INUSE, PAGE_SIZE)) {
-				free_pagetable(pte_page(*pte), 0, altmap);
+				free_pagetable(pte_page(*pte), 0);
 
 				spin_lock(&init_mm.page_table_lock);
 				pte_clear(&init_mm, addr, pte);
@@ -974,9 +974,8 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 			if (IS_ALIGNED(addr, PMD_SIZE) &&
 			    IS_ALIGNED(next, PMD_SIZE)) {
 				if (!direct)
-					free_pagetable(pmd_page(*pmd),
-						       get_order(PMD_SIZE),
-						       altmap);
+					free_hugepage_table(pmd_page(*pmd),
+							    altmap);
 
 				spin_lock(&init_mm.page_table_lock);
 				pmd_clear(pmd);
@@ -989,9 +988,8 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 				page_addr = page_address(pmd_page(*pmd));
 				if (!memchr_inv(page_addr, PAGE_INUSE,
 						PMD_SIZE)) {
-					free_pagetable(pmd_page(*pmd),
-						       get_order(PMD_SIZE),
-						       altmap);
+					free_hugepage_table(pmd_page(*pmd),
+							    altmap);
 
 					spin_lock(&init_mm.page_table_lock);
 					pmd_clear(pmd);
@@ -1003,8 +1001,8 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 		}
 
 		pte_base = (pte_t *)pmd_page_vaddr(*pmd);
-		remove_pte_table(pte_base, addr, next, altmap, direct);
-		free_pte_table(pte_base, pmd, altmap);
+		remove_pte_table(pte_base, addr, next, direct);
+		free_pte_table(pte_base, pmd);
 	}
 
 	/* Call free_pmd_table() in remove_pud_table(). */
@@ -1033,8 +1031,7 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 			    IS_ALIGNED(next, PUD_SIZE)) {
 				if (!direct)
 					free_pagetable(pud_page(*pud),
-						       get_order(PUD_SIZE),
-						       altmap);
+						       get_order(PUD_SIZE));
 
 				spin_lock(&init_mm.page_table_lock);
 				pud_clear(pud);
@@ -1048,8 +1045,7 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 				if (!memchr_inv(page_addr, PAGE_INUSE,
 						PUD_SIZE)) {
 					free_pagetable(pud_page(*pud),
-						       get_order(PUD_SIZE),
-						       altmap);
+						       get_order(PUD_SIZE));
 
 					spin_lock(&init_mm.page_table_lock);
 					pud_clear(pud);
@@ -1062,7 +1058,7 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 
 		pmd_base = pmd_offset(pud, 0);
 		remove_pmd_table(pmd_base, addr, next, direct, altmap);
-		free_pmd_table(pmd_base, pud, altmap);
+		free_pmd_table(pmd_base, pud);
 	}
 
 	if (direct)
@@ -1094,7 +1090,7 @@ remove_p4d_table(p4d_t *p4d_start, unsigned long addr, unsigned long end,
 		 * to adapt for boot-time switching between 4 and 5 level page tables.
 		 */
 		if (CONFIG_PGTABLE_LEVELS == 5)
-			free_pud_table(pud_base, p4d, altmap);
+			free_pud_table(pud_base, p4d);
 	}
 
 	if (direct)
