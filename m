Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE5F830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:44 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id xk3so144736428obc.2
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:44 -0800 (PST)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id sb6si15173018oec.15.2016.02.08.01.21.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:40 -0800 (PST)
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:40 -0700
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 12E451FF0042
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:09:48 -0700 (MST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189LbCF31457430
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 09:21:37 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189Lbps018094
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 04:21:37 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 21/29] powerpc/mm: Hash linux abstraction for functions in pgtable-hash.c
Date: Mon,  8 Feb 2016 14:50:33 +0530
Message-Id: <1454923241-6681-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We will later make the generic functions do conditial radix or hash
page table access. This patch doesn't do hugepage api update yet.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/32/pgtable.h | 13 ++++++++
 arch/powerpc/include/asm/book3s/64/hash.h    | 12 ++++++-
 arch/powerpc/include/asm/book3s/64/pgtable.h | 47 +++++++++++++++++++++++++++-
 arch/powerpc/include/asm/book3s/pgtable.h    |  4 ---
 arch/powerpc/include/asm/nohash/64/pgtable.h |  4 ++-
 arch/powerpc/include/asm/nohash/pgtable.h    | 11 +++++++
 arch/powerpc/include/asm/pgtable.h           | 13 --------
 arch/powerpc/mm/init_64.c                    |  3 --
 arch/powerpc/mm/pgtable-hash64.c             | 34 ++++++++++----------
 9 files changed, 101 insertions(+), 40 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/32/pgtable.h b/arch/powerpc/include/asm/book3s/32/pgtable.h
index 38b33dcfcc9d..539609c8a77b 100644
--- a/arch/powerpc/include/asm/book3s/32/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/32/pgtable.h
@@ -102,6 +102,9 @@ extern unsigned long ioremap_bot;
 #define pte_clear(mm, addr, ptep) \
 	do { pte_update(ptep, ~_PAGE_HASHPTE, 0); } while (0)
 
+extern void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
+		       pte_t pte);
+
 #define pmd_none(pmd)		(!pmd_val(pmd))
 #define	pmd_bad(pmd)		(pmd_val(pmd) & _PMD_BAD)
 #define	pmd_present(pmd)	(pmd_val(pmd) & _PMD_PRESENT_MASK)
@@ -477,6 +480,16 @@ static inline pgprot_t pgprot_writecombine(pgprot_t prot)
 	return pgprot_noncached_wc(prot);
 }
 
+/*
+ * This gets called at the end of handling a page fault, when
+ * the kernel has put a new PTE into the page table for the process.
+ * We use it to ensure coherency between the i-cache and d-cache
+ * for the page which has just been mapped in.
+ * On machines which use an MMU hash table, we use this to put a
+ * corresponding HPTE into the hash table ahead of time, instead of
+ * waiting for the inevitable extra hash-table miss exception.
+ */
+extern void update_mmu_cache(struct vm_area_struct *, unsigned long, pte_t *);
 #endif /* !__ASSEMBLY__ */
 
 #endif /*  _ASM_POWERPC_BOOK3S_32_PGTABLE_H */
diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
index d80c4c7fa6c1..551daeee6870 100644
--- a/arch/powerpc/include/asm/book3s/64/hash.h
+++ b/arch/powerpc/include/asm/book3s/64/hash.h
@@ -589,7 +589,17 @@ static inline void hpte_do_hugepage_flush(struct mm_struct *mm,
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
-extern int map_kernel_page(unsigned long ea, unsigned long pa, int flags);
+extern int hlmap_kernel_page(unsigned long ea, unsigned long pa, int flags);
+extern void hlpgtable_cache_init(void);
+extern void __meminit hlvmemmap_create_mapping(unsigned long start,
+					       unsigned long page_size,
+					       unsigned long phys);
+extern void hlvmemmap_remove_mapping(unsigned long start,
+				     unsigned long page_size);
+extern void set_hlpte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
+			 pte_t pte);
+extern void hlupdate_mmu_cache(struct vm_area_struct *vma, unsigned long address,
+			       pte_t *ptep);
 #endif /* !__ASSEMBLY__ */
 #endif /* __KERNEL__ */
 #endif /* _ASM_POWERPC_BOOK3S_64_HASH_H */
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 658a09b320f0..dd5a2344342a 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -320,6 +320,12 @@ static inline int pte_present(pte_t pte)
 	return hlpte_present(pte);
 }
 
+static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
+			      pte_t *ptep, pte_t pte)
+{
+	return set_hlpte_at(mm, addr, ptep, pte);
+}
+
 static inline void pmd_set(pmd_t *pmdp, unsigned long val)
 {
 	*pmdp = __pmd(val);
@@ -462,7 +468,46 @@ extern struct page *pgd_page(pgd_t pgd);
 	pr_err("%s:%d: bad pgd %08lx.\n", __FILE__, __LINE__, pgd_val(e))
 
 void pgtable_cache_add(unsigned shift, void (*ctor)(void *));
-void pgtable_cache_init(void);
+static inline void pgtable_cache_init(void)
+{
+	return hlpgtable_cache_init();
+}
+
+static inline int map_kernel_page(unsigned long ea, unsigned long pa,
+				  unsigned long flags)
+{
+	return hlmap_kernel_page(ea, pa, flags);
+}
+
+static inline void __meminit vmemmap_create_mapping(unsigned long start,
+						    unsigned long page_size,
+						    unsigned long phys)
+{
+	return hlvmemmap_create_mapping(start, page_size, phys);
+}
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+static inline void vmemmap_remove_mapping(unsigned long start,
+					  unsigned long page_size)
+{
+	return hlvmemmap_remove_mapping(start, page_size);
+}
+#endif
+
+/*
+ * This gets called at the end of handling a page fault, when
+ * the kernel has put a new PTE into the page table for the process.
+ * We use it to ensure coherency between the i-cache and d-cache
+ * for the page which has just been mapped in.
+ * On machines which use an MMU hash table, we use this to put a
+ * corresponding HPTE into the hash table ahead of time, instead of
+ * waiting for the inevitable extra hash-table miss exception.
+ */
+static inline void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
+				    pte_t *ptep)
+{
+	return hlupdate_mmu_cache(vma, address, ptep);
+}
 
 struct page *realmode_pfn_to_page(unsigned long pfn);
 
diff --git a/arch/powerpc/include/asm/book3s/pgtable.h b/arch/powerpc/include/asm/book3s/pgtable.h
index 8b0f4a29259a..620f8b6e1ba2 100644
--- a/arch/powerpc/include/asm/book3s/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/pgtable.h
@@ -12,10 +12,6 @@
 /* Insert a PTE, top-level function is out of line. It uses an inline
  * low level function in the respective pgtable-* files
  */
-extern void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
-		       pte_t pte);
-
-
 #define __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 extern int ptep_set_access_flags(struct vm_area_struct *vma, unsigned long address,
 				 pte_t *ptep, pte_t entry, int dirty);
diff --git a/arch/powerpc/include/asm/nohash/64/pgtable.h b/arch/powerpc/include/asm/nohash/64/pgtable.h
index a68e809d7739..7010d95cbedf 100644
--- a/arch/powerpc/include/asm/nohash/64/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/64/pgtable.h
@@ -360,7 +360,9 @@ static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
 void pgtable_cache_add(unsigned shift, void (*ctor)(void *));
 void pgtable_cache_init(void);
 extern int map_kernel_page(unsigned long ea, unsigned long pa, int flags);
-
+extern void __meminit vmemmap_create_mapping(unsigned long start,
+					     unsigned long page_size,
+					     unsigned long phys);
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_POWERPC_NOHASH_64_PGTABLE_H */
diff --git a/arch/powerpc/include/asm/nohash/pgtable.h b/arch/powerpc/include/asm/nohash/pgtable.h
index 1263c22d60d8..d86467288fc7 100644
--- a/arch/powerpc/include/asm/nohash/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/pgtable.h
@@ -248,5 +248,16 @@ static inline int pgd_huge(pgd_t pgd)
 #define is_hugepd(hpd)		(hugepd_ok(hpd))
 #endif
 
+/*
+ * This gets called at the end of handling a page fault, when
+ * the kernel has put a new PTE into the page table for the process.
+ * We use it to ensure coherency between the i-cache and d-cache
+ * for the page which has just been mapped in.
+ * On machines which use an MMU hash table, we use this to put a
+ * corresponding HPTE into the hash table ahead of time, instead of
+ * waiting for the inevitable extra hash-table miss exception.
+ */
+extern void update_mmu_cache(struct vm_area_struct *, unsigned long, pte_t *);
+
 #endif /* __ASSEMBLY__ */
 #endif
diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index ac9fb114e25d..dcd2b0d85d48 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -47,19 +47,6 @@ extern void paging_init(void);
 #define kern_addr_valid(addr)	(1)
 
 #include <asm-generic/pgtable.h>
-
-
-/*
- * This gets called at the end of handling a page fault, when
- * the kernel has put a new PTE into the page table for the process.
- * We use it to ensure coherency between the i-cache and d-cache
- * for the page which has just been mapped in.
- * On machines which use an MMU hash table, we use this to put a
- * corresponding HPTE into the hash table ahead of time, instead of
- * waiting for the inevitable extra hash-table miss exception.
- */
-extern void update_mmu_cache(struct vm_area_struct *, unsigned long, pte_t *);
-
 extern int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
 		       unsigned long end, int write,
 		       struct page **pages, int *nr);
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 05b025a0efe6..b3dd5ad68e53 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -194,9 +194,6 @@ static __meminit void vmemmap_list_populate(unsigned long phys,
 	vmemmap_list = vmem_back;
 }
 
-extern void __meminit vmemmap_create_mapping(unsigned long start,
-					     unsigned long page_size,
-					     unsigned long phys);
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 {
 	unsigned long page_size = 1 << mmu_psize_defs[mmu_vmemmap_psize].shift;
diff --git a/arch/powerpc/mm/pgtable-hash64.c b/arch/powerpc/mm/pgtable-hash64.c
index 6a5f41c1dd33..0a7c73779771 100644
--- a/arch/powerpc/mm/pgtable-hash64.c
+++ b/arch/powerpc/mm/pgtable-hash64.c
@@ -52,7 +52,7 @@ static void pmd_ctor(void *addr)
 }
 
 
-void pgtable_cache_init(void)
+void hlpgtable_cache_init(void)
 {
 	pgtable_cache_add(H_PGD_INDEX_SIZE, pgd_ctor);
 	pgtable_cache_add(H_PMD_CACHE_INDEX, pmd_ctor);
@@ -75,9 +75,9 @@ void pgtable_cache_init(void)
  * On hash-based CPUs, the vmemmap is bolted in the hash table.
  *
  */
-void __meminit vmemmap_create_mapping(unsigned long start,
-				      unsigned long page_size,
-				      unsigned long phys)
+void __meminit hlvmemmap_create_mapping(unsigned long start,
+					unsigned long page_size,
+					unsigned long phys)
 {
 	int  mapped = htab_bolt_mapping(start, start + page_size, phys,
 					pgprot_val(H_PAGE_KERNEL),
@@ -87,8 +87,8 @@ void __meminit vmemmap_create_mapping(unsigned long start,
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-void vmemmap_remove_mapping(unsigned long start,
-			    unsigned long page_size)
+void hlvmemmap_remove_mapping(unsigned long start,
+			      unsigned long page_size)
 {
 	int mapped = htab_remove_mapping(start, start + page_size,
 					 mmu_vmemmap_psize,
@@ -98,8 +98,8 @@ void vmemmap_remove_mapping(unsigned long start,
 #endif
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
-void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
-		      pte_t *ptep)
+void hlupdate_mmu_cache(struct vm_area_struct *vma, unsigned long address,
+			pte_t *ptep)
 {
 	/*
 	 * We don't need to worry about _PAGE_PRESENT here because we are
@@ -133,7 +133,7 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
  * map_kernel_page adds an entry to the ioremap page table
  * and adds an entry to the HPT, possibly bolting it
  */
-int map_kernel_page(unsigned long ea, unsigned long pa, int flags)
+int hlmap_kernel_page(unsigned long ea, unsigned long pa, int flags)
 {
 	pgd_t *pgdp;
 	pud_t *pudp;
@@ -178,7 +178,7 @@ int map_kernel_page(unsigned long ea, unsigned long pa, int flags)
  * and we avoid _PAGE_SPECIAL and _PAGE_NO_CACHE. We also only do that
  * on userspace PTEs
  */
-static inline int pte_looks_normal(pte_t pte)
+static inline int hlpte_looks_normal(pte_t pte)
 {
 	return (pte_val(pte) & (H_PAGE_PRESENT | H_PAGE_SPECIAL |
 					H_PAGE_NO_CACHE | H_PAGE_USER)) ==
@@ -203,11 +203,11 @@ static struct page *maybe_pte_to_page(pte_t pte)
  * flush the cache for valid PTEs in set_pte. Embedded CPU without HW exec
  * support falls into the same category.
  */
-static pte_t set_pte_filter(pte_t pte)
+static pte_t set_hlpte_filter(pte_t pte)
 {
 	pte = __pte(pte_val(pte) & ~H_PAGE_HPTEFLAGS);
-	if (pte_looks_normal(pte) && !(cpu_has_feature(CPU_FTR_COHERENT_ICACHE) ||
-				       cpu_has_feature(CPU_FTR_NOEXECUTE))) {
+	if (hlpte_looks_normal(pte) && !(cpu_has_feature(CPU_FTR_COHERENT_ICACHE) ||
+					 cpu_has_feature(CPU_FTR_NOEXECUTE))) {
 		struct page *pg = maybe_pte_to_page(pte);
 
 		if (!pg)
@@ -223,8 +223,8 @@ static pte_t set_pte_filter(pte_t pte)
 /*
  * set_pte stores a linux PTE into the linux page table.
  */
-void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
-		pte_t pte)
+void set_hlpte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
+		  pte_t pte)
 {
 	/*
 	 * When handling numa faults, we already have the pte marked
@@ -243,10 +243,10 @@ void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
 	 * this context might not have been activated yet when this
 	 * is called.
 	 */
-	pte = set_pte_filter(pte);
+	pte = set_hlpte_filter(pte);
 
 	/* Perform the setting of the PTE */
-	__set_pte_at(mm, addr, ptep, pte, 0);
+	__set_hlpte_at(mm, addr, ptep, pte, 0);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
