Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4BA828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 11:51:22 -0500 (EST)
Received: by mail-qk0-f172.google.com with SMTP id s68so20546723qkh.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 08:51:22 -0800 (PST)
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com. [129.33.205.209])
        by mx.google.com with ESMTPS id k65si53730653qgf.53.2016.02.18.08.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Feb 2016 08:51:21 -0800 (PST)
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 18 Feb 2016 11:51:21 -0500
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id B0C74C90070
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 11:51:15 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1IGpHnZ30408756
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 16:51:17 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1IGpHCD017023
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 11:51:17 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V3 01/30] mm: Make vm_get_page_prot arch specific.
Date: Thu, 18 Feb 2016 22:20:25 +0530
Message-Id: <1455814254-10226-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

With next generation power processor, we are having a new mmu model
[1] that require us to maintain a different linux page table format.

Inorder to support both current and future ppc64 systems with a single
kernel we need to make sure kernel can select between different page
table format at runtime. With the new MMU (radix MMU) added, we will
have to dynamically switch between different protection map. Hence
override vm_get_page_prot instead of using arch_vm_get_page_prot. We
also drop arch_vm_get_page_prot since only powerpc used it.

[1] http://ibm.biz/power-isa3 (Needs registration).

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hash.h |  3 +++
 arch/powerpc/include/asm/mman.h           |  6 ------
 arch/powerpc/mm/hash_utils_64.c           | 19 +++++++++++++++++++
 include/linux/mman.h                      |  4 ----
 mm/mmap.c                                 |  9 ++++++---
 5 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
index 8d1c8162f0c1..650f7e7b5410 100644
--- a/arch/powerpc/include/asm/book3s/64/hash.h
+++ b/arch/powerpc/include/asm/book3s/64/hash.h
@@ -530,6 +530,9 @@ static inline pgprot_t pgprot_writecombine(pgprot_t prot)
 	return pgprot_noncached_wc(prot);
 }
 
+extern pgprot_t vm_get_page_prot(unsigned long vm_flags);
+#define vm_get_page_prot vm_get_page_prot
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern void hpte_do_hugepage_flush(struct mm_struct *mm, unsigned long addr,
 				   pmd_t *pmdp, unsigned long old_pmd);
diff --git a/arch/powerpc/include/asm/mman.h b/arch/powerpc/include/asm/mman.h
index 8565c254151a..9f48698af024 100644
--- a/arch/powerpc/include/asm/mman.h
+++ b/arch/powerpc/include/asm/mman.h
@@ -24,12 +24,6 @@ static inline unsigned long arch_calc_vm_prot_bits(unsigned long prot)
 }
 #define arch_calc_vm_prot_bits(prot) arch_calc_vm_prot_bits(prot)
 
-static inline pgprot_t arch_vm_get_page_prot(unsigned long vm_flags)
-{
-	return (vm_flags & VM_SAO) ? __pgprot(_PAGE_SAO) : __pgprot(0);
-}
-#define arch_vm_get_page_prot(vm_flags) arch_vm_get_page_prot(vm_flags)
-
 static inline int arch_validate_prot(unsigned long prot)
 {
 	if (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM | PROT_SAO))
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index ba59d5977f34..3199bbc654c5 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -1564,3 +1564,22 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
 	/* Finally limit subsequent allocations */
 	memblock_set_current_limit(ppc64_rma_size);
 }
+
+static pgprot_t hash_protection_map[16] = {
+	__P000, __P001, __P010, __P011, __P100,
+	__P101, __P110, __P111, __S000, __S001,
+	__S010, __S011, __S100, __S101, __S110, __S111
+};
+
+pgprot_t vm_get_page_prot(unsigned long vm_flags)
+{
+	pgprot_t prot_soa = __pgprot(0);
+
+	if (vm_flags & VM_SAO)
+		prot_soa = __pgprot(_PAGE_SAO);
+
+	return __pgprot(pgprot_val(hash_protection_map[vm_flags &
+				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]) |
+			pgprot_val(prot_soa));
+}
+EXPORT_SYMBOL(vm_get_page_prot);
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 16373c8f5f57..d44abea464e2 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -38,10 +38,6 @@ static inline void vm_unacct_memory(long pages)
 #define arch_calc_vm_prot_bits(prot) 0
 #endif
 
-#ifndef arch_vm_get_page_prot
-#define arch_vm_get_page_prot(vm_flags) __pgprot(0)
-#endif
-
 #ifndef arch_validate_prot
 /*
  * This is called from mprotect().  PROT_GROWSDOWN and PROT_GROWSUP have
diff --git a/mm/mmap.c b/mm/mmap.c
index 2f2415a7a688..69cfacc94f9b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -92,6 +92,10 @@ static void unmap_region(struct mm_struct *mm,
  *		x: (no) no	x: (no) yes	x: (no) yes	x: (yes) yes
  *
  */
+/*
+ * Give arch an option to override the below in dynamic matter
+ */
+#ifndef vm_get_page_prot
 pgprot_t protection_map[16] = {
 	__P000, __P001, __P010, __P011, __P100, __P101, __P110, __P111,
 	__S000, __S001, __S010, __S011, __S100, __S101, __S110, __S111
@@ -99,11 +103,10 @@ pgprot_t protection_map[16] = {
 
 pgprot_t vm_get_page_prot(unsigned long vm_flags)
 {
-	return __pgprot(pgprot_val(protection_map[vm_flags &
-				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]) |
-			pgprot_val(arch_vm_get_page_prot(vm_flags)));
+	return protection_map[vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)];
 }
 EXPORT_SYMBOL(vm_get_page_prot);
+#endif
 
 static pgprot_t vm_pgprot_modify(pgprot_t oldprot, unsigned long vm_flags)
 {
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
