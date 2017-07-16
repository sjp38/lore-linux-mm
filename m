Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 04C786B065D
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:59:06 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v125so19409048qkd.6
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:59:06 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id s46si1080308qtc.383.2017.07.15.20.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:59:05 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id m54so14728759qtb.1
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:59:05 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 26/62] powerpc: Program HPTE key protection bits
Date: Sat, 15 Jul 2017 20:56:28 -0700
Message-Id: <1500177424-13695-27-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Map the PTE protection key bits to the HPTE key protection bits,
while creating HPTE  entries.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/mmu-hash.h |    5 +++++
 arch/powerpc/include/asm/pkeys.h              |   12 ++++++++++++
 arch/powerpc/mm/hash_utils_64.c               |    4 ++++
 3 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/mmu-hash.h b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
index 6981a52..f7a6ed3 100644
--- a/arch/powerpc/include/asm/book3s/64/mmu-hash.h
+++ b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
@@ -90,6 +90,8 @@
 #define HPTE_R_PP0		ASM_CONST(0x8000000000000000)
 #define HPTE_R_TS		ASM_CONST(0x4000000000000000)
 #define HPTE_R_KEY_HI		ASM_CONST(0x3000000000000000)
+#define HPTE_R_KEY_BIT0		ASM_CONST(0x2000000000000000)
+#define HPTE_R_KEY_BIT1		ASM_CONST(0x1000000000000000)
 #define HPTE_R_RPN_SHIFT	12
 #define HPTE_R_RPN		ASM_CONST(0x0ffffffffffff000)
 #define HPTE_R_RPN_3_0		ASM_CONST(0x01fffffffffff000)
@@ -104,6 +106,9 @@
 #define HPTE_R_C		ASM_CONST(0x0000000000000080)
 #define HPTE_R_R		ASM_CONST(0x0000000000000100)
 #define HPTE_R_KEY_LO		ASM_CONST(0x0000000000000e00)
+#define HPTE_R_KEY_BIT2		ASM_CONST(0x0000000000000800)
+#define HPTE_R_KEY_BIT3		ASM_CONST(0x0000000000000400)
+#define HPTE_R_KEY_BIT4		ASM_CONST(0x0000000000000200)
 
 #define HPTE_V_1TB_SEG		ASM_CONST(0x4000000000000000)
 #define HPTE_V_VRMA_MASK	ASM_CONST(0x4001ffffff000000)
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index ad39db0..bbb5d85 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -41,6 +41,18 @@ static inline u64 vmflag_to_page_pkey_bits(u64 vm_flags)
 		((vm_flags & VM_PKEY_BIT4) ? H_PAGE_PKEY_BIT0 : 0x0UL));
 }
 
+static inline u64 pte_to_hpte_pkey_bits(u64 pteflags)
+{
+	if (!pkey_inited)
+		return 0x0UL;
+
+	return (((pteflags & H_PAGE_PKEY_BIT0) ? HPTE_R_KEY_BIT0 : 0x0UL) |
+		((pteflags & H_PAGE_PKEY_BIT1) ? HPTE_R_KEY_BIT1 : 0x0UL) |
+		((pteflags & H_PAGE_PKEY_BIT2) ? HPTE_R_KEY_BIT2 : 0x0UL) |
+		((pteflags & H_PAGE_PKEY_BIT3) ? HPTE_R_KEY_BIT3 : 0x0UL) |
+		((pteflags & H_PAGE_PKEY_BIT4) ? HPTE_R_KEY_BIT4 : 0x0UL));
+}
+
 static inline int vma_pkey(struct vm_area_struct *vma)
 {
 	if (!pkey_inited)
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index f88423b..1e74529 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -231,6 +231,10 @@ unsigned long htab_convert_pte_flags(unsigned long pteflags)
 		 */
 		rflags |= HPTE_R_M;
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	rflags |= pte_to_hpte_pkey_bits(pteflags);
+#endif
+
 	return rflags;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
