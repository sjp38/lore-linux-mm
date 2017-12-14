Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3F366B026C
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:43:42 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id 14so7679397itm.6
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:43:42 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id u10si3187558ita.114.2017.12.14.03.43.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:43:42 -0800 (PST)
Message-Id: <20171214113851.498681375@infradead.org>
Date: Thu, 14 Dec 2017 12:27:34 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH v2 08/17] mm/x86: Allow special mappings with user access cleared
References: <20171214112726.742649793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=mm--Allow-special-mappings-with-user-access-cleared.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

From: Peter Zijstra <peterz@infradead.org>

In order to create VMAs that are not accessible to userspace create a new
VM_NOUSER flag. This can be used in conjunction with
install_special_mapping() to inject 'kernel' data into the userspace map.

Similar to how arch_vm_get_page_prot() allows adding _PAGE_flags to
pgprot_t, introduce arch_vm_get_page_prot_excl() which masks
_PAGE_flags from pgprot_t and use this to implement VM_NOUSER for x86.

get_user_page() will allow things like FOLL_POPULATE but will fail
FOLL_GET (with or without FOLL_WRITE).

Signed-off-by: Peter Zijstra <peterz@infradead.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/uapi/asm/mman.h |    4 ++++
 include/linux/mm.h               |    2 ++
 include/linux/mman.h             |    4 ++++
 mm/mmap.c                        |   12 ++++++++++--
 4 files changed, 20 insertions(+), 2 deletions(-)

--- a/arch/x86/include/uapi/asm/mman.h
+++ b/arch/x86/include/uapi/asm/mman.h
@@ -26,6 +26,10 @@
 		((key) & 0x8 ? VM_PKEY_BIT3 : 0))
 #endif
 
+#define arch_vm_get_page_prot_excl(vm_flags) __pgprot(		\
+		((vm_flags) & VM_NOUSER ? _PAGE_USER : 0)	\
+		)
+
 #include <asm-generic/mman.h>
 
 #endif /* _ASM_X86_MMAN_H */
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -193,6 +193,7 @@ extern unsigned int kobjsize(const void
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
 #define VM_WIPEONFORK	0x02000000	/* Wipe VMA contents in child. */
 #define VM_DONTDUMP	0x04000000	/* Do not include in the core dump */
+#define VM_ARCH_0	0x08000000	/* Architecture-specific flag */
 
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 #define VM_HUGEPAGE	0x20000000	/* MADV_HUGEPAGE marked this vma */
@@ -224,6 +225,7 @@ extern unsigned int kobjsize(const void
 #endif
 
 #if defined(CONFIG_X86)
+# define VM_NOUSER	VM_ARCH_0	/* Not accessible by userspace */
 # define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
 #if defined (CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS)
 # define VM_PKEY_SHIFT	VM_HIGH_ARCH_BIT_0
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -43,6 +43,10 @@ static inline void vm_unacct_memory(long
 #define arch_vm_get_page_prot(vm_flags) __pgprot(0)
 #endif
 
+#ifndef arch_vm_get_page_prot_excl
+#define arch_vm_get_page_prot_excl(vm_flags) __pgprot(0)
+#endif
+
 #ifndef arch_validate_prot
 /*
  * This is called from mprotect().  PROT_GROWSDOWN and PROT_GROWSUP have
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -102,9 +102,17 @@ pgprot_t protection_map[16] __ro_after_i
 
 pgprot_t vm_get_page_prot(unsigned long vm_flags)
 {
-	return __pgprot(pgprot_val(protection_map[vm_flags &
-				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]) |
+	pgprot_t prot;
+
+	prot = protection_map[vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)];
+
+	prot = __pgprot(pgprot_val(prot) |
 			pgprot_val(arch_vm_get_page_prot(vm_flags)));
+
+	prot = __pgprot(pgprot_val(prot) &
+			~pgprot_val(arch_vm_get_page_prot_excl(vm_flags)));
+
+	return prot;
 }
 EXPORT_SYMBOL(vm_get_page_prot);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
