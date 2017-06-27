Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C63DD6B0311
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 06:12:30 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z22so10028350qka.4
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:12:30 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id q186si2324386qkf.59.2017.06.27.03.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 03:12:29 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id c20so3171418qte.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:12:29 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v4 07/17] powerpc: make the hash functions protection-key aware
Date: Tue, 27 Jun 2017 03:11:49 -0700
Message-Id: <1498558319-32466-8-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
References: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

Prepare the hash functions to be aware of protection keys.
This key will later be used to program the HPTE.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hash.h     |  2 +-
 arch/powerpc/include/asm/book3s/64/mmu-hash.h | 14 ++++++-----
 arch/powerpc/mm/hash64_4k.c                   |  4 ++--
 arch/powerpc/mm/hash64_64k.c                  |  8 +++----
 arch/powerpc/mm/hash_utils_64.c               | 34 ++++++++++++++++++---------
 arch/powerpc/mm/hugepage-hash64.c             |  4 ++--
 arch/powerpc/mm/hugetlbpage-hash64.c          |  5 ++--
 arch/powerpc/mm/mem.c                         |  1 +
 arch/powerpc/mm/mmu_decl.h                    |  5 +++-
 9 files changed, 48 insertions(+), 29 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
index 4e957b0..3c1ef01 100644
--- a/arch/powerpc/include/asm/book3s/64/hash.h
+++ b/arch/powerpc/include/asm/book3s/64/hash.h
@@ -92,7 +92,7 @@ static inline int hash__pgd_bad(pgd_t pgd)
 
 extern void hpte_need_flush(struct mm_struct *mm, unsigned long addr,
 			    pte_t *ptep, unsigned long pte, int huge);
-extern unsigned long htab_convert_pte_flags(unsigned long pteflags);
+extern unsigned long htab_convert_pte_flags(unsigned long pteflags, int pkey);
 /* Atomic PTE updates */
 static inline unsigned long hash__pte_update(struct mm_struct *mm,
 					 unsigned long addr,
diff --git a/arch/powerpc/include/asm/book3s/64/mmu-hash.h b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
index 6981a52..aa3c299 100644
--- a/arch/powerpc/include/asm/book3s/64/mmu-hash.h
+++ b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
@@ -430,11 +430,11 @@ static inline unsigned long hpt_hash(unsigned long vpn,
 #define HPTE_NOHPTE_UPDATE	0x2
 
 extern int __hash_page_4K(unsigned long ea, unsigned long access,
-			  unsigned long vsid, pte_t *ptep, unsigned long trap,
-			  unsigned long flags, int ssize, int subpage_prot);
+		  unsigned long vsid, pte_t *ptep, unsigned long trap,
+		  unsigned long flags, int ssize, int subpage_prot, int pkey);
 extern int __hash_page_64K(unsigned long ea, unsigned long access,
 			   unsigned long vsid, pte_t *ptep, unsigned long trap,
-			   unsigned long flags, int ssize);
+			   unsigned long flags, int ssize, int pkey);
 struct mm_struct;
 unsigned int hash_page_do_lazy_icache(unsigned int pp, pte_t pte, int trap);
 extern int hash_page_mm(struct mm_struct *mm, unsigned long ea,
@@ -444,16 +444,18 @@ extern int hash_page(unsigned long ea, unsigned long access, unsigned long trap,
 		     unsigned long dsisr);
 int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 		     pte_t *ptep, unsigned long trap, unsigned long flags,
-		     int ssize, unsigned int shift, unsigned int mmu_psize);
+		     int ssize, unsigned int shift, unsigned int mmu_psize,
+		     int pkey);
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern int __hash_page_thp(unsigned long ea, unsigned long access,
 			   unsigned long vsid, pmd_t *pmdp, unsigned long trap,
-			   unsigned long flags, int ssize, unsigned int psize);
+			   unsigned long flags, int ssize, unsigned int psize,
+			   int pkey);
 #else
 static inline int __hash_page_thp(unsigned long ea, unsigned long access,
 				  unsigned long vsid, pmd_t *pmdp,
 				  unsigned long trap, unsigned long flags,
-				  int ssize, unsigned int psize)
+				  int ssize, unsigned int psize, int pkey)
 {
 	BUG();
 	return -1;
diff --git a/arch/powerpc/mm/hash64_4k.c b/arch/powerpc/mm/hash64_4k.c
index 6fa450c..6765ba2 100644
--- a/arch/powerpc/mm/hash64_4k.c
+++ b/arch/powerpc/mm/hash64_4k.c
@@ -18,7 +18,7 @@
 
 int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 		   pte_t *ptep, unsigned long trap, unsigned long flags,
-		   int ssize, int subpg_prot)
+		   int ssize, int subpg_prot, int pkey)
 {
 	unsigned long hpte_group;
 	unsigned long rflags, pa;
@@ -53,7 +53,7 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 	 * PP bits. _PAGE_USER is already PP bit 0x2, so we only
 	 * need to add in 0x1 if it's a read-only user page
 	 */
-	rflags = htab_convert_pte_flags(new_pte);
+	rflags = htab_convert_pte_flags(new_pte, pkey);
 
 	if (cpu_has_feature(CPU_FTR_NOEXECUTE) &&
 	    !cpu_has_feature(CPU_FTR_COHERENT_ICACHE))
diff --git a/arch/powerpc/mm/hash64_64k.c b/arch/powerpc/mm/hash64_64k.c
index 1a68cb1..9ce4d7b 100644
--- a/arch/powerpc/mm/hash64_64k.c
+++ b/arch/powerpc/mm/hash64_64k.c
@@ -47,7 +47,7 @@ static unsigned long mark_subptegroup_valid(unsigned long ptev, unsigned long in
 
 int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 		   pte_t *ptep, unsigned long trap, unsigned long flags,
-		   int ssize, int subpg_prot)
+		   int ssize, int subpg_prot, int pkey)
 {
 	real_pte_t rpte;
 	unsigned long *hidxp;
@@ -85,7 +85,7 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 	 * Handle the subpage protection bits
 	 */
 	subpg_pte = new_pte & ~subpg_prot;
-	rflags = htab_convert_pte_flags(subpg_pte);
+	rflags = htab_convert_pte_flags(subpg_pte, pkey);
 
 	if (cpu_has_feature(CPU_FTR_NOEXECUTE) &&
 	    !cpu_has_feature(CPU_FTR_COHERENT_ICACHE)) {
@@ -219,7 +219,7 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 
 int __hash_page_64K(unsigned long ea, unsigned long access,
 		    unsigned long vsid, pte_t *ptep, unsigned long trap,
-		    unsigned long flags, int ssize)
+		    unsigned long flags, int ssize, int pkey)
 {
 	unsigned long hpte_group;
 	unsigned long rflags, pa;
@@ -256,7 +256,7 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 			new_pte |= _PAGE_DIRTY;
 	} while (!pte_xchg(ptep, __pte(old_pte), __pte(new_pte)));
 
-	rflags = htab_convert_pte_flags(new_pte);
+	rflags = htab_convert_pte_flags(new_pte, pkey);
 
 	if (cpu_has_feature(CPU_FTR_NOEXECUTE) &&
 	    !cpu_has_feature(CPU_FTR_COHERENT_ICACHE))
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index f2095ce..2254ff0 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -35,6 +35,7 @@
 #include <linux/memblock.h>
 #include <linux/context_tracking.h>
 #include <linux/libfdt.h>
+#include <linux/pkeys.h>
 
 #include <asm/debugfs.h>
 #include <asm/processor.h>
@@ -176,7 +177,7 @@
  *    - We make sure R is always set and never lost
  *    - C is _PAGE_DIRTY, and *should* always be set for a writeable mapping
  */
-unsigned long htab_convert_pte_flags(unsigned long pteflags)
+unsigned long htab_convert_pte_flags(unsigned long pteflags, int pkey)
 {
 	unsigned long rflags = 0;
 
@@ -244,7 +245,7 @@ int htab_bolt_mapping(unsigned long vstart, unsigned long vend,
 	shift = mmu_psize_defs[psize].shift;
 	step = 1 << shift;
 
-	prot = htab_convert_pte_flags(prot);
+	prot = htab_convert_pte_flags(prot, 0);
 
 	DBG("htab_bolt_mapping(%lx..%lx -> %lx (%lx,%d,%d)\n",
 	    vstart, vend, pstart, prot, psize, ssize);
@@ -1228,7 +1229,7 @@ int hash_page_mm(struct mm_struct *mm, unsigned long ea,
 	unsigned hugeshift;
 	const struct cpumask *tmp;
 	int rc, user_region = 0;
-	int psize, ssize;
+	int psize, ssize, pkey = 0;
 
 	DBG_LOW("hash_page(ea=%016lx, access=%lx, trap=%lx\n",
 		ea, access, trap);
@@ -1317,11 +1318,13 @@ int hash_page_mm(struct mm_struct *mm, unsigned long ea,
 	if (hugeshift) {
 		if (is_thp)
 			rc = __hash_page_thp(ea, access, vsid, (pmd_t *)ptep,
-					     trap, flags, ssize, psize);
+					     trap, flags, ssize, psize,
+					     pkey);
 #ifdef CONFIG_HUGETLB_PAGE
 		else
 			rc = __hash_page_huge(ea, access, vsid, ptep, trap,
-					      flags, ssize, hugeshift, psize);
+					      flags, ssize, hugeshift, psize,
+					      pkey);
 #else
 		else {
 			/*
@@ -1381,7 +1384,8 @@ int hash_page_mm(struct mm_struct *mm, unsigned long ea,
 #ifdef CONFIG_PPC_64K_PAGES
 	if (psize == MMU_PAGE_64K)
 		rc = __hash_page_64K(ea, access, vsid, ptep, trap,
-				     flags, ssize);
+				     flags, ssize,
+				     pkey);
 	else
 #endif /* CONFIG_PPC_64K_PAGES */
 	{
@@ -1390,7 +1394,8 @@ int hash_page_mm(struct mm_struct *mm, unsigned long ea,
 			rc = -2;
 		else
 			rc = __hash_page_4K(ea, access, vsid, ptep, trap,
-					    flags, ssize, spp);
+						flags, ssize, spp,
+						pkey);
 	}
 
 	/* Dump some info in case of hash insertion failure, they should
@@ -1486,8 +1491,9 @@ static bool should_hash_preload(struct mm_struct *mm, unsigned long ea)
 }
 #endif
 
-void hash_preload(struct mm_struct *mm, unsigned long ea,
-		  unsigned long access, unsigned long trap)
+void hash_preload_pkey(struct mm_struct *mm, unsigned long ea,
+		  unsigned long access, unsigned long trap,
+		  int pkey)
 {
 	int hugepage_shift;
 	unsigned long vsid;
@@ -1548,11 +1554,11 @@ void hash_preload(struct mm_struct *mm, unsigned long ea,
 #ifdef CONFIG_PPC_64K_PAGES
 	if (mm->context.user_psize == MMU_PAGE_64K)
 		rc = __hash_page_64K(ea, access, vsid, ptep, trap,
-				     update_flags, ssize);
+				     update_flags, ssize, pkey);
 	else
 #endif /* CONFIG_PPC_64K_PAGES */
 		rc = __hash_page_4K(ea, access, vsid, ptep, trap, update_flags,
-				    ssize, subpage_protection(mm, ea));
+				    ssize, subpage_protection(mm, ea), pkey);
 
 	/* Dump some info in case of hash insertion failure, they should
 	 * never happen so it is really useful to know if/when they do
@@ -1566,6 +1572,12 @@ void hash_preload(struct mm_struct *mm, unsigned long ea,
 	local_irq_restore(flags);
 }
 
+void hash_preload(struct mm_struct *mm, unsigned long ea,
+		  unsigned long access, unsigned long trap)
+{
+	hash_preload_pkey(mm, ea, access, trap, 0);
+}
+
 #ifdef CONFIG_PPC_TRANSACTIONAL_MEM
 static inline void tm_flush_hash_page(int local)
 {
diff --git a/arch/powerpc/mm/hugepage-hash64.c b/arch/powerpc/mm/hugepage-hash64.c
index f20d16f..cc4855e 100644
--- a/arch/powerpc/mm/hugepage-hash64.c
+++ b/arch/powerpc/mm/hugepage-hash64.c
@@ -20,7 +20,7 @@
 
 int __hash_page_thp(unsigned long ea, unsigned long access, unsigned long vsid,
 		    pmd_t *pmdp, unsigned long trap, unsigned long flags,
-		    int ssize, unsigned int psize)
+		    int ssize, unsigned int psize, int pkey)
 {
 	unsigned int index, valid;
 	unsigned char *hpte_slot_array;
@@ -51,7 +51,7 @@ int __hash_page_thp(unsigned long ea, unsigned long access, unsigned long vsid,
 			new_pmd |= _PAGE_DIRTY;
 	} while (!pmd_xchg(pmdp, __pmd(old_pmd), __pmd(new_pmd)));
 
-	rflags = htab_convert_pte_flags(new_pmd);
+	rflags = htab_convert_pte_flags(new_pmd, pkey);
 
 #if 0
 	if (!cpu_has_feature(CPU_FTR_COHERENT_ICACHE)) {
diff --git a/arch/powerpc/mm/hugetlbpage-hash64.c b/arch/powerpc/mm/hugetlbpage-hash64.c
index a84bb44..fe7d671 100644
--- a/arch/powerpc/mm/hugetlbpage-hash64.c
+++ b/arch/powerpc/mm/hugetlbpage-hash64.c
@@ -20,7 +20,8 @@ extern long hpte_insert_repeating(unsigned long hash, unsigned long vpn,
 
 int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 		     pte_t *ptep, unsigned long trap, unsigned long flags,
-		     int ssize, unsigned int shift, unsigned int mmu_psize)
+		     int ssize, unsigned int shift, unsigned int mmu_psize,
+		     int pkey)
 {
 	unsigned long vpn;
 	unsigned long old_pte, new_pte;
@@ -60,7 +61,7 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 			new_pte |= _PAGE_DIRTY;
 	} while(!pte_xchg(ptep, __pte(old_pte), __pte(new_pte)));
 
-	rflags = htab_convert_pte_flags(new_pte);
+	rflags = htab_convert_pte_flags(new_pte, pkey);
 
 	sz = ((1UL) << shift);
 	if (!cpu_has_feature(CPU_FTR_COHERENT_ICACHE))
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 9ee536e..ec890d3 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -36,6 +36,7 @@
 #include <linux/hugetlb.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
+#include <linux/pkeys.h>
 
 #include <asm/pgalloc.h>
 #include <asm/prom.h>
diff --git a/arch/powerpc/mm/mmu_decl.h b/arch/powerpc/mm/mmu_decl.h
index f988db6..e425c27 100644
--- a/arch/powerpc/mm/mmu_decl.h
+++ b/arch/powerpc/mm/mmu_decl.h
@@ -82,10 +82,13 @@ static inline void _tlbivax_bcast(unsigned long address, unsigned int pid,
 
 #else /* CONFIG_PPC_MMU_NOHASH */
 
+extern void hash_preload_pkey(struct mm_struct *mm, unsigned long ea,
+			 unsigned long access, unsigned long trap,
+			 int pkey);
+
 extern void hash_preload(struct mm_struct *mm, unsigned long ea,
 			 unsigned long access, unsigned long trap);
 
-
 extern void _tlbie(unsigned long address);
 extern void _tlbia(void);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
