Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA3C6B025F
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:34:48 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id r20so12401009wrg.23
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:34:48 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g1si13140795wrh.117.2017.12.12.09.34.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 09:34:47 -0800 (PST)
Message-Id: <20171212173333.351928931@linutronix.de>
Date: Tue, 12 Dec 2017 18:32:22 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 01/16] arch: Allow arch_dup_mmap() to fail
References: <20171212173221.496222173@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=arch--Allow-arch_dup_mmap---to-fail.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

From: Thomas Gleixner <tglx@linutronix.de>

In order to sanitize the LDT initialization on x86 arch_dup_mmap() must be
allowed to fail. Fix up all instances.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
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
@@ -114,9 +114,10 @@ static inline void enter_lazy_tlb(struct
 #endif
 }
 
-static inline void arch_dup_mmap(struct mm_struct *oldmm,
-				 struct mm_struct *mm)
+static inline int arch_dup_mmap(struct mm_struct *oldmm,
+				struct mm_struct *mm)
 {
+	return 0;
 }
 
 static inline void arch_exit_mmap(struct mm_struct *mm)
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
