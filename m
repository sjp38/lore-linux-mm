Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 16D556B031B
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 09:59:30 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id s11so502471pfh.23
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 06:59:30 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id c2si1028756pgp.310.2018.02.07.06.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 06:59:28 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC 2/3] x86/mm/encrypt: Convert __PHYSICAL_MASK to patchable constant
Date: Wed,  7 Feb 2018 17:59:12 +0300
Message-Id: <20180207145913.2703-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180207145913.2703-1-kirill.shutemov@linux.intel.com>
References: <20180207145913.2703-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Tom Lendacky <thomas.lendacky@amd.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

AMD SME claims one bit from physical memory address to indicate that the
page is encrypted. This bit has to be mask out from __PHYSICAL_MASK.

As an alternative, we can replace __PHYSICAL_MASK with patchable
constant and adjust it directly at boot time.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig                  |  1 +
 arch/x86/include/asm/page_types.h | 11 ++++++++++-
 arch/x86/kernel/patchable_const.c |  3 +++
 arch/x86/mm/mem_encrypt.c         |  5 +++++
 4 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 78fc28e4f643..2f791aaac1a8 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1471,6 +1471,7 @@ config ARCH_HAS_MEM_ENCRYPT
 config AMD_MEM_ENCRYPT
 	bool "AMD Secure Memory Encryption (SME) support"
 	depends on X86_64 && CPU_SUP_AMD
+	select PATCHABLE_CONST
 	---help---
 	  Say yes to enable support for the encryption of system memory.
 	  This requires an AMD processor that supports Secure Memory
diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
index 1e53560a84bb..8ff82468c9af 100644
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -5,6 +5,7 @@
 #include <linux/const.h>
 #include <linux/types.h>
 #include <linux/mem_encrypt.h>
+#include <asm/patchable_const.h>
 
 /* PAGE_SHIFT determines the page size */
 #define PAGE_SHIFT		12
@@ -17,7 +18,8 @@
 #define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
 #define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
 
-#define __PHYSICAL_MASK		((phys_addr_t)(__sme_clr((1ULL << __PHYSICAL_MASK_SHIFT) - 1)))
+#define __PHYSICAL_MASK_DEFAULT	((_AC(1, ULL) << __PHYSICAL_MASK_SHIFT) - 1)
+
 #define __VIRTUAL_MASK		((1UL << __VIRTUAL_MASK_SHIFT) - 1)
 
 /* Cast *PAGE_MASK to a signed type so that it is sign-extended if
@@ -55,6 +57,13 @@
 
 #ifndef __ASSEMBLY__
 
+#ifdef CONFIG_AMD_MEM_ENCRYPT
+DECLARE_PATCHABLE_CONST_U64(__PHYSICAL_MASK);
+#define __PHYSICAL_MASK		__PHYSICAL_MASK_READ()
+#else
+#define __PHYSICAL_MASK		((phys_addr_t)__PHYSICAL_MASK_DEFAULT)
+#endif
+
 extern int devmem_is_allowed(unsigned long pagenr);
 
 extern unsigned long max_low_pfn_mapped;
diff --git a/arch/x86/kernel/patchable_const.c b/arch/x86/kernel/patchable_const.c
index d44d91cafee2..8d48c4c101ca 100644
--- a/arch/x86/kernel/patchable_const.c
+++ b/arch/x86/kernel/patchable_const.c
@@ -89,9 +89,12 @@ int patch_const_u64(unsigned long **start, unsigned long **stop,
 	return -EFAULT;
 }
 
+PATCHABLE_CONST_U64(__PHYSICAL_MASK);
+
 #ifdef CONFIG_MODULES
 /* Add an entry for a constant here if it expected to be seen in the modules */
 static const struct const_u64_table const_u64_table[] = {
+	{"__PHYSICAL_MASK", __PHYSICAL_MASK_DEFAULT, &__PHYSICAL_MASK_CURRENT},
 };
 
 __init_or_module __nostackprotector
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 1a53071e2e17..5135b59ce6a5 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -1033,4 +1033,9 @@ void __init __nostackprotector sme_enable(struct boot_params *bp)
 		sme_me_mask = 0;
 	else
 		sme_me_mask = active_by_default ? me_mask : 0;
+
+	if (__PHYSICAL_MASK_SET(__PHYSICAL_MASK & ~sme_me_mask)) {
+		/* Can we handle it? */
+		BUG();
+	}
 }
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
