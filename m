Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E2F08E0002
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id m16so15290285pgd.0
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e68si15371744pfb.101.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Message-Id: <20181226133351.770245668@intel.com>
Date: Wed, 26 Dec 2018 21:14:58 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 12/21] x86/pgtable: allocate page table pages from DRAM
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0018-pgtable-force-pgtable-allocation-from-DRAM-node-0.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On rand read/writes on large data, we find near half memory accesses
caused by TLB misses, hence hit the page table pages. So better keep
page table pages in faster DRAM nodes.

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/include/asm/pgalloc.h |   10 +++++++---
 arch/x86/mm/pgtable.c          |   22 ++++++++++++++++++----
 2 files changed, 25 insertions(+), 7 deletions(-)

--- linux.orig/arch/x86/mm/pgtable.c	2018-12-26 19:41:57.494900885 +0800
+++ linux/arch/x86/mm/pgtable.c	2018-12-26 19:42:35.531621035 +0800
@@ -22,17 +22,30 @@ EXPORT_SYMBOL(physical_mask);
 #endif
 
 gfp_t __userpte_alloc_gfp = PGALLOC_GFP | PGALLOC_USER_GFP;
+nodemask_t all_node_mask = NODE_MASK_ALL;
+
+unsigned long __get_free_pgtable_pages(gfp_t gfp_mask,
+						     unsigned int order)
+{
+	struct page *page;
+
+	page = __alloc_pages_nodemask(gfp_mask, order, numa_node_id(), &all_node_mask);
+	if (!page)
+		return 0;
+	return (unsigned long) page_address(page);
+}
+EXPORT_SYMBOL(__get_free_pgtable_pages);
 
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	return (pte_t *)__get_free_page(PGALLOC_GFP & ~__GFP_ACCOUNT);
+	return (pte_t *)__get_free_pgtable_pages(PGALLOC_GFP & ~__GFP_ACCOUNT, 0);
 }
 
 pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *pte;
 
-	pte = alloc_pages(__userpte_alloc_gfp, 0);
+	pte = __alloc_pages_nodemask(__userpte_alloc_gfp, 0, numa_node_id(), &all_node_mask);
 	if (!pte)
 		return NULL;
 	if (!pgtable_page_ctor(pte)) {
@@ -241,7 +254,7 @@ static int preallocate_pmds(struct mm_st
 		gfp &= ~__GFP_ACCOUNT;
 
 	for (i = 0; i < count; i++) {
-		pmd_t *pmd = (pmd_t *)__get_free_page(gfp);
+		pmd_t *pmd = (pmd_t *)__get_free_pgtable_pages(gfp, 0);
 		if (!pmd)
 			failed = true;
 		if (pmd && !pgtable_pmd_page_ctor(virt_to_page(pmd))) {
@@ -422,7 +435,8 @@ static inline void _pgd_free(pgd_t *pgd)
 
 static inline pgd_t *_pgd_alloc(void)
 {
-	return (pgd_t *)__get_free_pages(PGALLOC_GFP, PGD_ALLOCATION_ORDER);
+	return (pgd_t *)__get_free_pgtable_pages(PGALLOC_GFP,
+						 PGD_ALLOCATION_ORDER);
 }
 
 static inline void _pgd_free(pgd_t *pgd)
--- linux.orig/arch/x86/include/asm/pgalloc.h	2018-12-26 19:40:12.992251270 +0800
+++ linux/arch/x86/include/asm/pgalloc.h	2018-12-26 19:42:35.531621035 +0800
@@ -96,10 +96,11 @@ static inline pmd_t *pmd_alloc_one(struc
 {
 	struct page *page;
 	gfp_t gfp = GFP_KERNEL_ACCOUNT | __GFP_ZERO;
+	nodemask_t all_node_mask = NODE_MASK_ALL;
 
 	if (mm == &init_mm)
 		gfp &= ~__GFP_ACCOUNT;
-	page = alloc_pages(gfp, 0);
+	page = __alloc_pages_nodemask(gfp, 0, numa_node_id(), &all_node_mask);
 	if (!page)
 		return NULL;
 	if (!pgtable_pmd_page_ctor(page)) {
@@ -141,13 +142,16 @@ static inline void p4d_populate(struct m
 	set_p4d(p4d, __p4d(_PAGE_TABLE | __pa(pud)));
 }
 
+extern unsigned long __get_free_pgtable_pages(gfp_t gfp_mask,
+					      unsigned int order);
+
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	gfp_t gfp = GFP_KERNEL_ACCOUNT;
 
 	if (mm == &init_mm)
 		gfp &= ~__GFP_ACCOUNT;
-	return (pud_t *)get_zeroed_page(gfp);
+	return (pud_t *)__get_free_pgtable_pages(gfp | __GFP_ZERO, 0);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
@@ -179,7 +183,7 @@ static inline p4d_t *p4d_alloc_one(struc
 
 	if (mm == &init_mm)
 		gfp &= ~__GFP_ACCOUNT;
-	return (p4d_t *)get_zeroed_page(gfp);
+	return (p4d_t *)__get_free_pgtable_pages(gfp | __GFP_ZERO, 0);
 }
 
 static inline void p4d_free(struct mm_struct *mm, p4d_t *p4d)
