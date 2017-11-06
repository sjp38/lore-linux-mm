Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 037E6280246
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:58:54 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id h9so6589649qtc.2
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:58:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13sor8174010qtk.13.2017.11.06.00.58.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 00:58:53 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 12/51] powerpc: ability to associate pkey to a vma
Date: Mon,  6 Nov 2017 00:57:04 -0800
Message-Id: <1509958663-18737-13-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

arch-independent code expects the arch to  map
a  pkey  into the vma's protection bit setting.
The patch provides that ability.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/mman.h  |    7 ++++++-
 arch/powerpc/include/asm/pkeys.h |   11 +++++++++++
 arch/powerpc/mm/pkeys.c          |    8 ++++++++
 3 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/asm/mman.h b/arch/powerpc/include/asm/mman.h
index 30922f6..2999478 100644
--- a/arch/powerpc/include/asm/mman.h
+++ b/arch/powerpc/include/asm/mman.h
@@ -13,6 +13,7 @@
 
 #include <asm/cputable.h>
 #include <linux/mm.h>
+#include <linux/pkeys.h>
 #include <asm/cpu_has_feature.h>
 
 /*
@@ -22,7 +23,11 @@
 static inline unsigned long arch_calc_vm_prot_bits(unsigned long prot,
 		unsigned long pkey)
 {
-	return (prot & PROT_SAO) ? VM_SAO : 0;
+#ifdef CONFIG_PPC_MEM_KEYS
+	return (((prot & PROT_SAO) ? VM_SAO : 0) | pkey_to_vmflag_bits(pkey));
+#else
+	return ((prot & PROT_SAO) ? VM_SAO : 0);
+#endif
 }
 #define arch_calc_vm_prot_bits(prot, pkey) arch_calc_vm_prot_bits(prot, pkey)
 
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 20d1f0e..1bd41ef 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -41,6 +41,17 @@
 #define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | \
 			    VM_PKEY_BIT3 | VM_PKEY_BIT4)
 
+/* Override any generic PKEY permission defines */
+#define PKEY_DISABLE_EXECUTE   0x4
+#define PKEY_ACCESS_MASK       (PKEY_DISABLE_ACCESS | \
+				PKEY_DISABLE_WRITE  | \
+				PKEY_DISABLE_EXECUTE)
+
+static inline u64 pkey_to_vmflag_bits(u16 pkey)
+{
+	return (((u64)pkey << VM_PKEY_SHIFT) & ARCH_VM_PKEY_FLAGS);
+}
+
 #define arch_max_pkey() pkeys_total
 
 #define pkey_alloc_mask(pkey) (0x1 << pkey)
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 5da94fe..4d704ea 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -39,6 +39,14 @@ void __init pkey_initialize(void)
 		     (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
 
 	/*
+	 * pkey_to_vmflag_bits() assumes that the pkey bits are contiguous
+	 * in the vmaflag. Make sure that is really the case.
+	 */
+	BUILD_BUG_ON(__builtin_clzl(ARCH_VM_PKEY_FLAGS >> VM_PKEY_SHIFT) +
+		     __builtin_popcountl(ARCH_VM_PKEY_FLAGS >> VM_PKEY_SHIFT)
+				!= (sizeof(u64) * BITS_PER_BYTE));
+
+	/*
 	 * Disable the pkey system till everything is in place. A subsequent
 	 * patch will enable it.
 	 */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
