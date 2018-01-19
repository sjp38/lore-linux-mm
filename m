Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 22B586B0270
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 20:52:25 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id r23so338265qte.13
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 17:52:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z25sor5732686qtg.140.2018.01.18.17.52.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 17:52:24 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 14/27] powerpc: map vma key-protection bits to pte key bits.
Date: Thu, 18 Jan 2018 17:50:35 -0800
Message-Id: <1516326648-22775-15-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
References: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

Map  the  key  protection  bits of the vma to the pkey bits in
the PTE.

The PTE  bits used  for pkey  are  3,4,5,6  and 57. The  first
four bits are the same four bits that were freed up  initially
in this patch series. remember? :-) Without those four bits
this patch wouldn't be possible.

BUT, on 4k kernel, bit 3, and 4 could not be freed up. remember?
Hence we have to be satisfied with 5, 6 and 7.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h |   25 ++++++++++++++++++++++++-
 arch/powerpc/include/asm/mman.h              |    6 ++++++
 arch/powerpc/include/asm/pkeys.h             |   12 ++++++++++++
 3 files changed, 42 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 4469781..e1a8bb6 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -39,6 +39,7 @@
 #define _RPAGE_RSV2		0x0800000000000000UL
 #define _RPAGE_RSV3		0x0400000000000000UL
 #define _RPAGE_RSV4		0x0200000000000000UL
+#define _RPAGE_RSV5		0x00040UL
 
 #define _PAGE_PTE		0x4000000000000000UL	/* distinguishes PTEs from pointers */
 #define _PAGE_PRESENT		0x8000000000000000UL	/* pte contains a translation */
@@ -58,6 +59,25 @@
 /* Max physical address bit as per radix table */
 #define _RPAGE_PA_MAX		57
 
+#ifdef CONFIG_PPC_MEM_KEYS
+#ifdef CONFIG_PPC_64K_PAGES
+#define H_PTE_PKEY_BIT0	_RPAGE_RSV1
+#define H_PTE_PKEY_BIT1	_RPAGE_RSV2
+#else /* CONFIG_PPC_64K_PAGES */
+#define H_PTE_PKEY_BIT0	0 /* _RPAGE_RSV1 is not available */
+#define H_PTE_PKEY_BIT1	0 /* _RPAGE_RSV2 is not available */
+#endif /* CONFIG_PPC_64K_PAGES */
+#define H_PTE_PKEY_BIT2	_RPAGE_RSV3
+#define H_PTE_PKEY_BIT3	_RPAGE_RSV4
+#define H_PTE_PKEY_BIT4	_RPAGE_RSV5
+#else /*  CONFIG_PPC_MEM_KEYS */
+#define H_PTE_PKEY_BIT0	0
+#define H_PTE_PKEY_BIT1	0
+#define H_PTE_PKEY_BIT2	0
+#define H_PTE_PKEY_BIT3	0
+#define H_PTE_PKEY_BIT4	0
+#endif /*  CONFIG_PPC_MEM_KEYS */
+
 /*
  * Max physical address bit we will use for now.
  *
@@ -121,13 +141,16 @@
 #define _PAGE_CHG_MASK	(PTE_RPN_MASK | _PAGE_HPTEFLAGS | _PAGE_DIRTY | \
 			 _PAGE_ACCESSED | _PAGE_SPECIAL | _PAGE_PTE |	\
 			 _PAGE_SOFT_DIRTY)
+
+#define H_PTE_PKEY  (H_PTE_PKEY_BIT0 | H_PTE_PKEY_BIT1 | H_PTE_PKEY_BIT2 | \
+		     H_PTE_PKEY_BIT3 | H_PTE_PKEY_BIT4)
 /*
  * Mask of bits returned by pte_pgprot()
  */
 #define PAGE_PROT_BITS  (_PAGE_SAO | _PAGE_NON_IDEMPOTENT | _PAGE_TOLERANT | \
 			 H_PAGE_4K_PFN | _PAGE_PRIVILEGED | _PAGE_ACCESSED | \
 			 _PAGE_READ | _PAGE_WRITE |  _PAGE_DIRTY | _PAGE_EXEC | \
-			 _PAGE_SOFT_DIRTY)
+			 _PAGE_SOFT_DIRTY | H_PTE_PKEY)
 /*
  * We define 2 sets of base prot bits, one for basic pages (ie,
  * cacheable kernel and user pages) and one for non cacheable
diff --git a/arch/powerpc/include/asm/mman.h b/arch/powerpc/include/asm/mman.h
index 2999478..07e3f54 100644
--- a/arch/powerpc/include/asm/mman.h
+++ b/arch/powerpc/include/asm/mman.h
@@ -33,7 +33,13 @@ static inline unsigned long arch_calc_vm_prot_bits(unsigned long prot,
 
 static inline pgprot_t arch_vm_get_page_prot(unsigned long vm_flags)
 {
+#ifdef CONFIG_PPC_MEM_KEYS
+	return (vm_flags & VM_SAO) ?
+		__pgprot(_PAGE_SAO | vmflag_to_pte_pkey_bits(vm_flags)) :
+		__pgprot(0 | vmflag_to_pte_pkey_bits(vm_flags));
+#else
 	return (vm_flags & VM_SAO) ? __pgprot(_PAGE_SAO) : __pgprot(0);
+#endif
 }
 #define arch_vm_get_page_prot(vm_flags) arch_vm_get_page_prot(vm_flags)
 
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 0a643b8..f65dedd 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -52,6 +52,18 @@ static inline u64 pkey_to_vmflag_bits(u16 pkey)
 	return (((u64)pkey << VM_PKEY_SHIFT) & ARCH_VM_PKEY_FLAGS);
 }
 
+static inline u64 vmflag_to_pte_pkey_bits(u64 vm_flags)
+{
+	if (static_branch_likely(&pkey_disabled))
+		return 0x0UL;
+
+	return (((vm_flags & VM_PKEY_BIT0) ? H_PTE_PKEY_BIT4 : 0x0UL) |
+		((vm_flags & VM_PKEY_BIT1) ? H_PTE_PKEY_BIT3 : 0x0UL) |
+		((vm_flags & VM_PKEY_BIT2) ? H_PTE_PKEY_BIT2 : 0x0UL) |
+		((vm_flags & VM_PKEY_BIT3) ? H_PTE_PKEY_BIT1 : 0x0UL) |
+		((vm_flags & VM_PKEY_BIT4) ? H_PTE_PKEY_BIT0 : 0x0UL));
+}
+
 static inline int vma_pkey(struct vm_area_struct *vma)
 {
 	if (static_branch_likely(&pkey_disabled))
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
