Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42B8D6B0038
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 06:54:33 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 96so9208436wrk.7
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 03:54:33 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id a64si7697823wma.216.2017.12.18.03.54.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 03:54:31 -0800 (PST)
Message-Id: <20171218115253.910945187@linutronix.de>
Date: Mon, 18 Dec 2017 12:42:19 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V163 04/51] arch: Allow arch_dup_mmap() to fail
References: <20171218114215.239543034@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=arch--Allow_arch_dup_mmap--_to_fail.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, linux-mm@kvack.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com

From: Thomas Gleixner <tglx@linutronix.de>

In order to sanitize the LDT initialization on x86 arch_dup_mmap() must be
allowed to fail. Fix up all instances.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: Juergen Gross <jgross@suse.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: aliguori@amazon.com
Cc: Brian Gerst <brgerst@gmail.com>
Cc: linux-mm@kvack.org
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: hughd@google.com
Cc: Will Deacon <will.deacon@arm.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Andy Lutomirsky <luto@kernel.org>
Cc: keescook@google.com
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bpetkov@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dan.j.williams@intel.com
Cc: kirill.shutemov@linux.intel.com

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
