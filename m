Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC8816B02F3
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 17:28:23 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id n125so28451180vke.3
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 14:28:23 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 193si2344061vkh.331.2017.08.09.14.28.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 14:28:22 -0700 (PDT)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v7 2/9] mm, swap: Add infrastructure for saving page metadata on swap
Date: Wed,  9 Aug 2017 15:25:55 -0600
Message-Id: <87ff7a44c45bd6a146102c6e6033ee7810d9ebb5.1502219353.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1502219353.git.khalid.aziz@oracle.com>
References: <cover.1502219353.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1502219353.git.khalid.aziz@oracle.com>
References: <cover.1502219353.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, davem@davemloft.net, dave.hansen@linux.intel.com, arnd@arndb.de
Cc: Khalid Aziz <khalid.aziz@oracle.com>, kirill.shutemov@linux.intel.com, mhocko@suse.com, jack@suse.cz, ross.zwisler@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, dave.jiang@intel.com, willy@infradead.org, hughd@google.com, minchan@kernel.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, shli@fb.com, mingo@kernel.org, jmarchan@redhat.com, lstoakes@gmail.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>


If a processor supports special metadata for a page, for example ADI
version tags on SPARC M7, this metadata must be saved when the page is
swapped out. The same metadata must be restored when the page is swapped
back in. This patch adds two new architecture specific functions -
arch_do_swap_page() to be called when a page is swapped in, and
arch_unmap_one() to be called when a page is being unmapped for swap
out. These architecture hooks allow page metadata to be saved if the
architecture supports it.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
---
v6:
	- Updated parameter list for arch_do_swap_page() and
	  arch_unmap_one()
v5:
	- Replaced set_swp_pte() function with new architecture
	  functions arch_do_swap_page() and arch_unmap_one()

 include/asm-generic/pgtable.h | 36 ++++++++++++++++++++++++++++++++++++
 mm/memory.c                   |  1 +
 mm/rmap.c                     | 13 +++++++++++++
 3 files changed, 50 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 7dfa767dc680..15668c2470b4 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -392,6 +392,42 @@ static inline int pud_same(pud_t pud_a, pud_t pud_b)
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
+#ifndef __HAVE_ARCH_DO_SWAP_PAGE
+/*
+ * Some architectures support metadata associated with a page. When a
+ * page is being swapped out, this metadata must be saved so it can be
+ * restored when the page is swapped back in. SPARC M7 and newer
+ * processors support an ADI (Application Data Integrity) tag for the
+ * page as metadata for the page. arch_do_swap_page() can restore this
+ * metadata when a page is swapped back in.
+ */
+static inline void arch_do_swap_page(struct mm_struct *mm,
+				     struct vm_area_struct *vma,
+				     unsigned long addr,
+				     pte_t pte, pte_t oldpte)
+{
+
+}
+#endif
+
+#ifndef __HAVE_ARCH_UNMAP_ONE
+/*
+ * Some architectures support metadata associated with a page. When a
+ * page is being swapped out, this metadata must be saved so it can be
+ * restored when the page is swapped back in. SPARC M7 and newer
+ * processors support an ADI (Application Data Integrity) tag for the
+ * page as metadata for the page. arch_unmap_one() can save this
+ * metadata on a swap-out of a page.
+ */
+static inline int arch_unmap_one(struct mm_struct *mm,
+				  struct vm_area_struct *vma,
+				  unsigned long addr,
+				  pte_t orig_pte)
+{
+	return 0;
+}
+#endif
+
 #ifndef __HAVE_ARCH_PGD_OFFSET_GATE
 #define pgd_offset_gate(mm, addr)	pgd_offset(mm, addr)
 #endif
diff --git a/mm/memory.c b/mm/memory.c
index bb11c474857e..eb92e4f94d3b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2798,6 +2798,7 @@ int do_swap_page(struct vm_fault *vmf)
 	if (pte_swp_soft_dirty(vmf->orig_pte))
 		pte = pte_mksoft_dirty(pte);
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
+	arch_do_swap_page(vma->vm_mm, vma, vmf->address, pte, vmf->orig_pte);
 	vmf->orig_pte = pte;
 	if (page == swapcache) {
 		do_page_add_anon_rmap(page, vma, vmf->address, exclusive);
diff --git a/mm/rmap.c b/mm/rmap.c
index d405f0e0ee96..5ff2a7943c57 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1399,6 +1399,12 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				(flags & TTU_MIGRATION)) {
 			swp_entry_t entry;
 			pte_t swp_pte;
+
+			if (arch_unmap_one(mm, vma, address, pteval) < 0) {
+				set_pte_at(mm, address, pvmw.pte, pteval);
+				ret = false;
+				page_vma_mapped_walk_done(&pvmw);
+				break;
 			/*
 			 * Store the pfn of the page in a special migration
 			 * pte. do_swap_page() will wait until the migration
@@ -1410,6 +1416,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
 			set_pte_at(mm, address, pvmw.pte, swp_pte);
+			}
 		} else if (PageAnon(page)) {
 			swp_entry_t entry = { .val = page_private(subpage) };
 			pte_t swp_pte;
@@ -1448,6 +1455,12 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				page_vma_mapped_walk_done(&pvmw);
 				break;
 			}
+			if (arch_unmap_one(mm, vma, address, pteval) < 0) {
+				set_pte_at(mm, address, pvmw.pte, pteval);
+				ret = false;
+				page_vma_mapped_walk_done(&pvmw);
+				break;
+			}
 			if (list_empty(&mm->mmlist)) {
 				spin_lock(&mmlist_lock);
 				if (list_empty(&mm->mmlist))
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
