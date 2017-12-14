Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD916B0268
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:43:37 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id l14so3965199pgu.17
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:43:37 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 33si3016297ply.741.2017.12.14.03.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:43:35 -0800 (PST)
Message-Id: <20171214113851.449024759@infradead.org>
Date: Thu, 14 Dec 2017 12:27:33 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH v2 07/17] mm/softdirty: Move VM_SOFTDIRTY into high bits
References: <20171214112726.742649793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=mm-softdirty--Move-VM_SOFTDIRTY-into-high-bits.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

From: Peter Zijlstra <peterz@infradead.org>

Only 64bit architectures (x86_64, s390, PPC_BOOK3S_64) have support for
HAVE_ARCH_SOFT_DIRTY, so ensure they all select ARCH_USES_HIGH_VMA_FLAGS
and move the VM_SOFTDIRTY flag into the high flags.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/powerpc/platforms/Kconfig.cputype |    1 +
 arch/s390/Kconfig                      |    1 +
 include/linux/mm.h                     |   17 +++++++++++------
 3 files changed, 13 insertions(+), 6 deletions(-)

--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -76,6 +76,7 @@ config PPC_BOOK3S_64
 	select ARCH_SUPPORTS_NUMA_BALANCING
 	select IRQ_WORK
 	select HAVE_KERNEL_XZ
+	select ARCH_USES_HIGH_VMA_FLAGS
 
 config PPC_BOOK3E_64
 	bool "Embedded processors"
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -131,6 +131,7 @@ config S390
 	select CPU_NO_EFFICIENT_FFS if !HAVE_MARCH_Z9_109_FEATURES
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_SOFT_DIRTY
+	select ARCH_USES_HIGH_VMA_FLAGS
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	select HAVE_EBPF_JIT if PACK_STACK && HAVE_MARCH_Z196_FEATURES
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -194,12 +194,6 @@ extern unsigned int kobjsize(const void
 #define VM_WIPEONFORK	0x02000000	/* Wipe VMA contents in child. */
 #define VM_DONTDUMP	0x04000000	/* Do not include in the core dump */
 
-#ifdef CONFIG_MEM_SOFT_DIRTY
-# define VM_SOFTDIRTY	0x08000000	/* Not soft dirty clean area */
-#else
-# define VM_SOFTDIRTY	0
-#endif
-
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 #define VM_HUGEPAGE	0x20000000	/* MADV_HUGEPAGE marked this vma */
 #define VM_NOHUGEPAGE	0x40000000	/* MADV_NOHUGEPAGE marked this vma */
@@ -216,8 +210,19 @@ extern unsigned int kobjsize(const void
 #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
 #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
 #define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
+
+#define VM_HIGH_SOFTDIRTY_BIT	37	/* bit only usable on 64-bit architectures */
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
+#ifdef CONFIG_MEM_SOFT_DIRTY
+# ifndef CONFIG_ARCH_USES_HIGH_VMA_FLAGS
+#  error MEM_SOFT_DIRTY depends on ARCH_USES_HIGH_VMA_FLAGS
+# endif
+# define VM_SOFTDIRTY		BIT(VM_HIGH_SOFTDIRTY_BIT) /* Not soft dirty clean area */
+#else
+# define VM_SOFTDIRTY		VM_NONE
+#endif
+
 #if defined(CONFIG_X86)
 # define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
 #if defined (CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
