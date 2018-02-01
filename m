Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 271786B0008
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 13:02:32 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id l2so11098132vki.18
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 10:02:32 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 34si57739uav.162.2018.02.01.10.02.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 10:02:31 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v11 02/10] mm, swap: Add infrastructure for saving page metadata on swap
Date: Thu,  1 Feb 2018 11:01:10 -0700
Message-Id: <c7cdd0eccb1c1ea10cf0a145e4854364686a1e82.1517497017.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1517497017.git.khalid.aziz@oracle.com>
References: <cover.1517497017.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1517497017.git.khalid.aziz@oracle.com>
References: <cover.1517497017.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, davem@davemloft.net, dave.hansen@linux.intel.com, arnd@arndb.de
Cc: Khalid Aziz <khalid.aziz@oracle.com>, kirill.shutemov@linux.intel.com, mhocko@suse.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, mgorman@techsingularity.net, willy@infradead.org, hughd@google.com, minchan@kernel.org, hannes@cmpxchg.org, shli@fb.com, mingo@kernel.org, jglisse@redhat.com, me@tobin.cc, anthony.yznaga@oracle.com, hillf.zj@alibaba-inc.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

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
Reviewed-by: Anthony Yznaga <anthony.yznaga@oracle.com>
---
v8:
	- Fixed an erroneous "}"
v6:
	- Updated parameter list for arch_do_swap_page() and
	  arch_unmap_one()
v5:
	- Replaced set_swp_pte() function with new architecture
	  functions arch_do_swap_page() and arch_unmap_one()

 include/asm-generic/pgtable.h | 36 ++++++++++++++++++++++++++++++++++++
 mm/memory.c                   |  1 +
 mm/rmap.c                     | 14 ++++++++++++++
 3 files changed, 51 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 868e68561f91..5530cfc72ef8 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -393,6 +393,42 @@ static inline int pud_same(pud_t pud_a, pud_t pud_b)
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
index 793004608332..4e9bd81aa6f5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3017,6 +3017,7 @@ int do_swap_page(struct vm_fault *vmf)
 	if (pte_swp_soft_dirty(vmf->orig_pte))
 		pte = pte_mksoft_dirty(pte);
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
+	arch_do_swap_page(vma->vm_mm, vma, vmf->address, pte, vmf->orig_pte);
 	vmf->orig_pte = pte;
 
 	/* ksm created a completely new copy */
diff --git a/mm/rmap.c b/mm/rmap.c
index 47db27f8049e..144c66e688a9 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1497,6 +1497,14 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				(flags & (TTU_MIGRATION|TTU_SPLIT_FREEZE))) {
 			swp_entry_t entry;
 			pte_t swp_pte;
+
+			if (arch_unmap_one(mm, vma, address, pteval) < 0) {
+				set_pte_at(mm, address, pvmw.pte, pteval);
+				ret = false;
+				page_vma_mapped_walk_done(&pvmw);
+				break;
+			}
+
 			/*
 			 * Store the pfn of the page in a special migration
 			 * pte. do_swap_page() will wait until the migration
@@ -1556,6 +1564,12 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
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
