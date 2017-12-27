Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 209456B0273
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 11:49:32 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id o16so10008154wmf.4
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 08:49:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q1si19871585wre.202.2017.12.27.08.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 08:49:28 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 14/74] arch, mm: Allow arch_dup_mmap() to fail
Date: Wed, 27 Dec 2017 17:45:47 +0100
Message-Id: <20171227164614.681423295@linuxfoundation.org>
In-Reply-To: <20171227164614.109898944@linuxfoundation.org>
References: <20171227164614.109898944@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Borislav Petkov <bpetkov@suse.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, dan.j.williams@intel.com, hughd@google.com, keescook@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Thomas Gleixner <tglx@linutronix.de>

commit c10e83f598d08046dd1ebc8360d4bb12d802d51b upstream.

In order to sanitize the LDT initialization on x86 arch_dup_mmap() must be
allowed to fail. Fix up all instances.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Andy Lutomirsky <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Borislav Petkov <bpetkov@suse.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: dan.j.williams@intel.com
Cc: hughd@google.com
Cc: keescook@google.com
Cc: kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

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
