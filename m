Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 895FA6B033C
	for <linux-mm@kvack.org>; Thu, 25 May 2017 16:35:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j28so241430741pfk.14
        for <linux-mm@kvack.org>; Thu, 25 May 2017 13:35:01 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m3si29217947pld.61.2017.05.25.13.35.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 13:35:00 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv1, RFC 7/8] x86/mm: Hacks for boot-time switching between 4- and 5-level paging
Date: Thu, 25 May 2017 23:33:33 +0300
Message-Id: <20170525203334.867-8-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

There're bunch of workaround to make switching between 4- and 5-level
paging compile.

All of them need to be addressed properly before upstreaming.

Not-yet-signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig          | 4 ++--
 arch/x86/entry/entry_64.S | 5 +++++
 arch/x86/kernel/head_64.S | 6 ++++--
 arch/x86/xen/Kconfig      | 2 +-
 4 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 0bf81e837cbf..c795207d8a3c 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -100,7 +100,7 @@ config X86
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_HUGE_VMAP		if X86_64 || X86_PAE
 	select HAVE_ARCH_JUMP_LABEL
-	select HAVE_ARCH_KASAN			if X86_64 && SPARSEMEM_VMEMMAP
+	select HAVE_ARCH_KASAN			if X86_64 && SPARSEMEM_VMEMMAP && !X86_5LEVEL
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_KMEMCHECK
 	select HAVE_ARCH_MMAP_RND_BITS		if MMU
@@ -1980,7 +1980,7 @@ config RELOCATABLE
 
 config RANDOMIZE_BASE
 	bool "Randomize the address of the kernel image (KASLR)"
-	depends on RELOCATABLE
+	depends on RELOCATABLE && !X86_5LEVEL
 	default y
 	---help---
 	  In support of Kernel Address Space Layout Randomization (KASLR),
diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
index edec30584eb8..9e868fd6d792 100644
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -269,6 +269,11 @@ return_from_SYSCALL_64:
 	 * Change top bits to match most significant bit (47th or 56th bit
 	 * depending on paging mode) in the address.
 	 */
+#ifdef CONFIG_X86_5LEVEL
+#warning FIXME
+#undef __VIRTUAL_MASK_SHIFT
+#define __VIRTUAL_MASK_SHIFT 56
+#endif
 	shl	$(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
 	sar	$(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
 
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 2009d9849e98..9dcf7a4d8612 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -37,11 +37,13 @@
  *
  */
 
-#define p4d_index(x)	(((x) >> P4D_SHIFT) & (PTRS_PER_P4D-1))
 #define pud_index(x)	(((x) >> PUD_SHIFT) & (PTRS_PER_PUD-1))
 
-PGD_PAGE_OFFSET = pgd_index(__PAGE_OFFSET_BASE)
+#ifdef CONFIG_XEN
+/* FIXME */
+PGD_PAGE_OFFSET = pgd_index(__PAGE_OFFSET_BASE48)
 PGD_START_KERNEL = pgd_index(__START_KERNEL_map)
+#endif
 L3_START_KERNEL = pud_index(__START_KERNEL_map)
 
 	.text
diff --git a/arch/x86/xen/Kconfig b/arch/x86/xen/Kconfig
index 1be9667bd476..c1714cac7595 100644
--- a/arch/x86/xen/Kconfig
+++ b/arch/x86/xen/Kconfig
@@ -4,7 +4,7 @@
 
 config XEN
 	bool "Xen guest support"
-	depends on PARAVIRT
+	depends on PARAVIRT && !X86_5LEVEL
 	select PARAVIRT_CLOCK
 	depends on X86_64 || (X86_32 && X86_PAE)
 	depends on X86_LOCAL_APIC && X86_TSC
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
