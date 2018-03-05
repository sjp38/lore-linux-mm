Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 09ADE6B0023
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:26:29 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id x6-v6so8289140plr.7
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:26:29 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id p12-v6si7098404plk.295.2018.03.05.08.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 08:26:27 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH 06/22] x86/mm: Decouple dynamic __PHYSICAL_MASK from AMD SME
Date: Mon,  5 Mar 2018 19:25:54 +0300
Message-Id: <20180305162610.37510-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

AMD SME claims one bit from physical address to indicate whether the
page is encrypted or not. To achieve that we clear out the bit from
__PHYSICAL_MASK.

The capability to adjust __PHYSICAL_MASK is required beyond AMD SME.
For instance for upcoming Intel Multi-Key Total Memory Encryption.

Let's factor it out into separate feature with own Kconfig handle.

It also helps with overhead of AMD SME. It saves more than 3k in .text
on defconfig + AMD_MEM_ENCRYPT:

	add/remove: 3/2 grow/shrink: 5/110 up/down: 189/-3753 (-3564)

We would need to return to this once we have infrastructure to patch
constants in code. That's good candidate for it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig                    | 4 ++++
 arch/x86/boot/compressed/kaslr_64.c | 3 +++
 arch/x86/include/asm/page_types.h   | 8 +++++++-
 arch/x86/mm/mem_encrypt_identity.c  | 3 +++
 arch/x86/mm/pgtable.c               | 5 +++++
 5 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index bdfd503065d3..99aecb2caed3 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -332,6 +332,9 @@ config ARCH_SUPPORTS_UPROBES
 config FIX_EARLYCON_MEM
 	def_bool y
 
+config DYNAMIC_PHYSICAL_MASK
+	bool
+
 config PGTABLE_LEVELS
 	int
 	default 5 if X86_5LEVEL
@@ -1513,6 +1516,7 @@ config ARCH_HAS_MEM_ENCRYPT
 config AMD_MEM_ENCRYPT
 	bool "AMD Secure Memory Encryption (SME) support"
 	depends on X86_64 && CPU_SUP_AMD
+	select DYNAMIC_PHYSICAL_MASK
 	---help---
 	  Say yes to enable support for the encryption of system memory.
 	  This requires an AMD processor that supports Secure Memory
diff --git a/arch/x86/boot/compressed/kaslr_64.c b/arch/x86/boot/compressed/kaslr_64.c
index b5e5e02f8cde..4318ac0af815 100644
--- a/arch/x86/boot/compressed/kaslr_64.c
+++ b/arch/x86/boot/compressed/kaslr_64.c
@@ -16,6 +16,9 @@
 #define __pa(x)  ((unsigned long)(x))
 #define __va(x)  ((void *)((unsigned long)(x)))
 
+/* No need in adjustable __PHYSICAL_MASK during decompresssion phase */
+#undef CONFIG_DYNAMIC_PHYSICAL_MASK
+
 /*
  * The pgtable.h and mm/ident_map.c includes make use of the SME related
  * information which is not used in the compressed image support. Un-define
diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
index 1e53560a84bb..c85e15010f48 100644
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -17,7 +17,6 @@
 #define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
 #define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
 
-#define __PHYSICAL_MASK		((phys_addr_t)(__sme_clr((1ULL << __PHYSICAL_MASK_SHIFT) - 1)))
 #define __VIRTUAL_MASK		((1UL << __VIRTUAL_MASK_SHIFT) - 1)
 
 /* Cast *PAGE_MASK to a signed type so that it is sign-extended if
@@ -55,6 +54,13 @@
 
 #ifndef __ASSEMBLY__
 
+#ifdef CONFIG_DYNAMIC_PHYSICAL_MASK
+extern phys_addr_t physical_mask;
+#define __PHYSICAL_MASK		physical_mask
+#else
+#define __PHYSICAL_MASK		((phys_addr_t)((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
+#endif
+
 extern int devmem_is_allowed(unsigned long pagenr);
 
 extern unsigned long max_low_pfn_mapped;
diff --git a/arch/x86/mm/mem_encrypt_identity.c b/arch/x86/mm/mem_encrypt_identity.c
index 1b2197d13832..7ae36868aed2 100644
--- a/arch/x86/mm/mem_encrypt_identity.c
+++ b/arch/x86/mm/mem_encrypt_identity.c
@@ -527,6 +527,7 @@ void __init sme_enable(struct boot_params *bp)
 		/* SEV state cannot be controlled by a command line option */
 		sme_me_mask = me_mask;
 		sev_enabled = true;
+		physical_mask &= ~sme_me_mask;
 		return;
 	}
 
@@ -561,4 +562,6 @@ void __init sme_enable(struct boot_params *bp)
 		sme_me_mask = 0;
 	else
 		sme_me_mask = active_by_default ? me_mask : 0;
+
+	physical_mask &= ~sme_me_mask;
 }
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 004abf9ebf12..a4dfe85f2fd8 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -7,6 +7,11 @@
 #include <asm/fixmap.h>
 #include <asm/mtrr.h>
 
+#ifdef CONFIG_DYNAMIC_PHYSICAL_MASK
+phys_addr_t physical_mask __ro_after_init = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
+EXPORT_SYMBOL(physical_mask);
+#endif
+
 #define PGALLOC_GFP (GFP_KERNEL_ACCOUNT | __GFP_ZERO)
 
 #ifdef CONFIG_HIGHPTE
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
