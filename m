Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5C46B03ED
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:23:23 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id w12so611639qta.8
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:23 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id d5si95511qtf.393.2017.07.05.14.23.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:23:22 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id v143so181346qkb.3
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:22 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 22/38] powerpc: map vma key-protection bits to pte key bits.
Date: Wed,  5 Jul 2017 14:21:59 -0700
Message-Id: <1499289735-14220-23-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

map the pkey bits in the pte  from the key protection
bits of the vma.

The pte bits used for pkey are 3,4,5,6 and 57. The first
four bits are the same four bits that were freed up initially
in this patch series. remember? :-) Without those four bits
this patch would'nt be possible.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h |   20 +++++++++++++++++++-
 arch/powerpc/include/asm/mman.h              |    8 ++++++++
 arch/powerpc/include/asm/pkeys.h             |    9 +++++++++
 3 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 435d6a7..d9c87c4 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -37,6 +37,7 @@
 #define _RPAGE_RSV2		0x0800000000000000UL
 #define _RPAGE_RSV3		0x0400000000000000UL
 #define _RPAGE_RSV4		0x0200000000000000UL
+#define _RPAGE_RSV5		0x00040UL
 
 #define _PAGE_PTE		0x4000000000000000UL	/* distinguishes PTEs from pointers */
 #define _PAGE_PRESENT		0x8000000000000000UL	/* pte contains a translation */
@@ -56,6 +57,20 @@
 /* Max physical address bit as per radix table */
 #define _RPAGE_PA_MAX		57
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+#define H_PAGE_PKEY_BIT0	_RPAGE_RSV1
+#define H_PAGE_PKEY_BIT1	_RPAGE_RSV2
+#define H_PAGE_PKEY_BIT2	_RPAGE_RSV3
+#define H_PAGE_PKEY_BIT3	_RPAGE_RSV4
+#define H_PAGE_PKEY_BIT4	_RPAGE_RSV5
+#else /*  CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+#define H_PAGE_PKEY_BIT0	0
+#define H_PAGE_PKEY_BIT1	0
+#define H_PAGE_PKEY_BIT2	0
+#define H_PAGE_PKEY_BIT3	0
+#define H_PAGE_PKEY_BIT4	0
+#endif /*  CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 /*
  * Max physical address bit we will use for now.
  *
@@ -116,13 +131,16 @@
 #define _PAGE_CHG_MASK	(PTE_RPN_MASK | _PAGE_HPTEFLAGS | _PAGE_DIRTY | \
 			 _PAGE_ACCESSED | _PAGE_SPECIAL | _PAGE_PTE |	\
 			 _PAGE_SOFT_DIRTY)
+
+#define H_PAGE_PKEY  (H_PAGE_PKEY_BIT0 | H_PAGE_PKEY_BIT1 | H_PAGE_PKEY_BIT2 | \
+			H_PAGE_PKEY_BIT3 | H_PAGE_PKEY_BIT4)
 /*
  * Mask of bits returned by pte_pgprot()
  */
 #define PAGE_PROT_BITS  (_PAGE_SAO | _PAGE_NON_IDEMPOTENT | _PAGE_TOLERANT | \
 			 H_PAGE_4K_PFN | _PAGE_PRIVILEGED | _PAGE_ACCESSED | \
 			 _PAGE_READ | _PAGE_WRITE |  _PAGE_DIRTY | _PAGE_EXEC | \
-			 _PAGE_SOFT_DIRTY)
+			 _PAGE_SOFT_DIRTY | H_PAGE_PKEY)
 /*
  * We define 2 sets of base prot bits, one for basic pages (ie,
  * cacheable kernel and user pages) and one for non cacheable
diff --git a/arch/powerpc/include/asm/mman.h b/arch/powerpc/include/asm/mman.h
index 067eec2..3f7220f 100644
--- a/arch/powerpc/include/asm/mman.h
+++ b/arch/powerpc/include/asm/mman.h
@@ -32,12 +32,20 @@ static inline unsigned long arch_calc_vm_prot_bits(unsigned long prot,
 }
 #define arch_calc_vm_prot_bits(prot, pkey) arch_calc_vm_prot_bits(prot, pkey)
 
+
 static inline pgprot_t arch_vm_get_page_prot(unsigned long vm_flags)
 {
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	return (vm_flags & VM_SAO) ?
+		__pgprot(_PAGE_SAO | vmflag_to_page_pkey_bits(vm_flags)) :
+		__pgprot(0 | vmflag_to_page_pkey_bits(vm_flags));
+#else
 	return (vm_flags & VM_SAO) ? __pgprot(_PAGE_SAO) : __pgprot(0);
+#endif
 }
 #define arch_vm_get_page_prot(vm_flags) arch_vm_get_page_prot(vm_flags)
 
+
 static inline bool arch_validate_prot(unsigned long prot)
 {
 	if (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM | PROT_SAO))
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 20846c2..c681de9 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -13,6 +13,15 @@ static inline u64 pkey_to_vmflag_bits(u16 pkey)
 		((pkey & 0x10UL) ? VM_PKEY_BIT4 : 0x0UL));
 }
 
+static inline u64 vmflag_to_page_pkey_bits(u64 vm_flags)
+{
+	return (((vm_flags & VM_PKEY_BIT0) ? H_PAGE_PKEY_BIT4 : 0x0UL) |
+		((vm_flags & VM_PKEY_BIT1) ? H_PAGE_PKEY_BIT3 : 0x0UL) |
+		((vm_flags & VM_PKEY_BIT2) ? H_PAGE_PKEY_BIT2 : 0x0UL) |
+		((vm_flags & VM_PKEY_BIT3) ? H_PAGE_PKEY_BIT1 : 0x0UL) |
+		((vm_flags & VM_PKEY_BIT4) ? H_PAGE_PKEY_BIT0 : 0x0UL));
+}
+
 static inline int vma_pkey(struct vm_area_struct *vma)
 {
 	return (vma->vm_flags & ARCH_VM_PKEY_FLAGS) >> VM_PKEY_SHIFT;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
