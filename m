Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id CC9FB830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:12 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id is5so143991636obc.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:12 -0800 (PST)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id lk2si15296785obb.96.2016.02.08.01.21.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:12 -0800 (PST)
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:11 -0700
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 528111FF0041
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:09:19 -0700 (MST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189L9cW26738762
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 09:21:09 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189L8tA010928
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 04:21:08 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 07/29] mm: Make vm_get_page_prot arch specific.
Date: Mon,  8 Feb 2016 14:50:19 +0530
Message-Id: <1454923241-6681-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
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

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hash.h |  3 +++
 arch/powerpc/include/asm/mman.h           |  6 ------
 arch/powerpc/mm/hash_utils_64.c           | 19 +++++++++++++++++++
 include/linux/mman.h                      |  4 ----
 mm/mmap.c                                 |  9 ++++++---
 5 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
index 6aae0b0b649b..c568eaa1c26d 100644
--- a/arch/powerpc/include/asm/book3s/64/hash.h
+++ b/arch/powerpc/include/asm/book3s/64/hash.h
@@ -538,6 +538,9 @@ static inline pgprot_t pgprot_writecombine(pgprot_t prot)
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
index cfc0cdca421e..aa2e901029d0 100644
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
