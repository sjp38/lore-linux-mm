Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 772266B026A
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:43:42 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y62so4500367pfd.3
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:43:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o4si2849830pgf.8.2017.12.14.03.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:43:35 -0800 (PST)
Message-Id: <20171214113851.248131745@infradead.org>
Date: Thu, 14 Dec 2017 12:27:29 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH v2 03/17] arch: Allow arch_dup_mmap() to fail
References: <20171214112726.742649793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=arch--Allow-arch_dup_mmap---to-fail.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

From: Thomas Gleixner <tglx@linutronix.de>

In order to sanitize the LDT initialization on x86 arch_dup_mmap() must be
allowed to fail. Fix up all instances.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/powerpc/include/asm/mmu_context.h   |    5 +++--
 arch/um/include/asm/mmu_context.h        |    3 ++-
 arch/unicore32/include/asm/mmu_context.h |    5 +++--
 arch/x86/include/asm/mmu_context.h       |    4 ++--
 include/asm-generic/mm_hooks.h           |    5 +++--
 kernel/fork.c                            |    3 +--
 6 files changed, 14 insertions(+), 11 deletions(-)

--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -160,9 +160,10 @@ static inline void enter_lazy_tlb(struct
 #endif
 }
 
-static inline void arch_dup_mmap(struct mm_struct *oldmm,
-				 struct mm_struct *mm)
+static inline int arch_dup_mmap(struct mm_struct *oldmm,
+				struct mm_struct *mm)
 {
+	return 0;
 }
 
 #ifndef CONFIG_PPC_BOOK3S_64
--- a/arch/um/include/asm/mmu_context.h
+++ b/arch/um/include/asm/mmu_context.h
@@ -15,9 +15,10 @@ extern void uml_setup_stubs(struct mm_st
 /*
  * Needed since we do not use the asm-generic/mm_hooks.h:
  */
-static inline void arch_dup_mmap(struct mm_struct *oldmm, struct mm_struct *mm)
+static inline int arch_dup_mmap(struct mm_struct *oldmm, struct mm_struct *mm)
 {
 	uml_setup_stubs(mm);
+	return 0;
 }
 extern void arch_exit_mmap(struct mm_struct *mm);
 static inline void arch_unmap(struct mm_struct *mm,
--- a/arch/unicore32/include/asm/mmu_context.h
+++ b/arch/unicore32/include/asm/mmu_context.h
@@ -81,9 +81,10 @@ do { \
 	} \
 } while (0)
 
-static inline void arch_dup_mmap(struct mm_struct *oldmm,
-				 struct mm_struct *mm)
+static inline int arch_dup_mmap(struct mm_struct *oldmm,
+				struct mm_struct *mm)
 {
+	return 0;
 }
 
 static inline void arch_unmap(struct mm_struct *mm,
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -176,10 +176,10 @@ do {						\
 } while (0)
 #endif
 
-static inline void arch_dup_mmap(struct mm_struct *oldmm,
-				 struct mm_struct *mm)
+static inline int arch_dup_mmap(struct mm_struct *oldmm, struct mm_struct *mm)
 {
 	paravirt_arch_dup_mmap(oldmm, mm);
+	return 0;
 }
 
 static inline void arch_exit_mmap(struct mm_struct *mm)
--- a/include/asm-generic/mm_hooks.h
+++ b/include/asm-generic/mm_hooks.h
@@ -7,9 +7,10 @@
 #ifndef _ASM_GENERIC_MM_HOOKS_H
 #define _ASM_GENERIC_MM_HOOKS_H
 
-static inline void arch_dup_mmap(struct mm_struct *oldmm,
-				 struct mm_struct *mm)
+static inline int arch_dup_mmap(struct mm_struct *oldmm,
+				struct mm_struct *mm)
 {
+	return 0;
 }
 
 static inline void arch_exit_mmap(struct mm_struct *mm)
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -721,8 +721,7 @@ static __latent_entropy int dup_mmap(str
 			goto out;
 	}
 	/* a new mm has just been created */
-	arch_dup_mmap(oldmm, mm);
-	retval = 0;
+	retval = arch_dup_mmap(oldmm, mm);
 out:
 	up_write(&mm->mmap_sem);
 	flush_tlb_mm(oldmm);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
