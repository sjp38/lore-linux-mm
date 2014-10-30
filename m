Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7214090008B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 20:42:30 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so3988271pde.22
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 17:42:30 -0700 (PDT)
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com. [209.85.220.43])
        by mx.google.com with ESMTPS id rt8si5104526pbc.249.2014.10.29.17.42.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 17:42:29 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id eu11so4273615pac.16
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 17:42:29 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [RFC 2/6] x86,vdso: Use special mapping tracking for the vdso
Date: Wed, 29 Oct 2014 17:42:12 -0700
Message-Id: <089d2f6471cfbeb6af0fa3de540b34071da45d11.1414629045.git.luto@amacapital.net>
In-Reply-To: <cover.1414629045.git.luto@amacapital.net>
References: <cover.1414629045.git.luto@amacapital.net>
In-Reply-To: <cover.1414629045.git.luto@amacapital.net>
References: <cover.1414629045.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>

This should give full support for mremap on the vdso except for
sysenter return.  It will also enable future vvar twiddling on
already-started processes.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 arch/x86/ia32/ia32_signal.c | 11 ++++-------
 arch/x86/include/asm/elf.h  | 26 ++++++++-----------------
 arch/x86/include/asm/mmu.h  |  4 +++-
 arch/x86/include/asm/vdso.h | 16 +++++++++++++++
 arch/x86/kernel/signal.c    |  9 +++------
 arch/x86/vdso/vma.c         | 47 ++++++++++++++++++++++++++++++++++++++-------
 6 files changed, 74 insertions(+), 39 deletions(-)

diff --git a/arch/x86/ia32/ia32_signal.c b/arch/x86/ia32/ia32_signal.c
index f9e181aaba97..3b335c674059 100644
--- a/arch/x86/ia32/ia32_signal.c
+++ b/arch/x86/ia32/ia32_signal.c
@@ -381,11 +381,8 @@ int ia32_setup_frame(int sig, struct ksignal *ksig,
 	if (ksig->ka.sa.sa_flags & SA_RESTORER) {
 		restorer = ksig->ka.sa.sa_restorer;
 	} else {
-		/* Return stub is in 32bit vsyscall page */
-		if (current->mm->context.vdso)
-			restorer = current->mm->context.vdso +
-				selected_vdso32->sym___kernel_sigreturn;
-		else
+		restorer = VDSO_SYM_ADDR(current->mm, __kernel_sigreturn);
+		if (!restorer)
 			restorer = &frame->retcode;
 	}
 
@@ -462,8 +459,8 @@ int ia32_setup_rt_frame(int sig, struct ksignal *ksig,
 		if (ksig->ka.sa.sa_flags & SA_RESTORER)
 			restorer = ksig->ka.sa.sa_restorer;
 		else
-			restorer = current->mm->context.vdso +
-				selected_vdso32->sym___kernel_rt_sigreturn;
+			restorer = VDSO_SYM_ADDR(current->mm,
+						 __kernel_rt_sigreturn);
 		put_user_ex(ptr_to_compat(restorer), &frame->pretcode);
 
 		/*
diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index 1a055c81d864..05df8f03faa5 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -276,7 +276,7 @@ struct task_struct;
 
 #define	ARCH_DLINFO_IA32						\
 do {									\
-	if (vdso32_enabled) {						\
+	if (current->mm->context.vdso_image) {				\
 		NEW_AUX_ENT(AT_SYSINFO,	VDSO_ENTRY);			\
 		NEW_AUX_ENT(AT_SYSINFO_EHDR, VDSO_CURRENT_BASE);	\
 	}								\
@@ -295,26 +295,19 @@ do {									\
 /* 1GB for 64bit, 8MB for 32bit */
 #define STACK_RND_MASK (test_thread_flag(TIF_ADDR32) ? 0x7ff : 0x3fffff)
 
-#define ARCH_DLINFO							\
+#define ARCH_DLINFO_X86_64						\
 do {									\
-	if (vdso64_enabled)						\
-		NEW_AUX_ENT(AT_SYSINFO_EHDR,				\
-			    (unsigned long __force)current->mm->context.vdso); \
+	if (current->mm->context.vdso_image)				\
+		NEW_AUX_ENT(AT_SYSINFO_EHDR, VDSO_CURRENT_BASE);	\
 } while (0)
 
-/* As a historical oddity, the x32 and x86_64 vDSOs are controlled together. */
-#define ARCH_DLINFO_X32							\
-do {									\
-	if (vdso64_enabled)						\
-		NEW_AUX_ENT(AT_SYSINFO_EHDR,				\
-			    (unsigned long __force)current->mm->context.vdso); \
-} while (0)
+#define ARCH_DLINFO ARCH_DLINFO_X86_64
 
 #define AT_SYSINFO		32
 
 #define COMPAT_ARCH_DLINFO						\
 if (test_thread_flag(TIF_X32))						\
-	ARCH_DLINFO_X32;						\
+	ARCH_DLINFO_X86_64;						\
 else									\
 	ARCH_DLINFO_IA32
 
@@ -322,11 +315,8 @@ else									\
 
 #endif /* !CONFIG_X86_32 */
 
-#define VDSO_CURRENT_BASE	((unsigned long)current->mm->context.vdso)
-
-#define VDSO_ENTRY							\
-	((unsigned long)current->mm->context.vdso +			\
-	 selected_vdso32->sym___kernel_vsyscall)
+#define VDSO_CURRENT_BASE	((unsigned long)vdso_text_start(current->mm))
+#define VDSO_ENTRY ((unsigned long)VDSO_SYM_ADDR(current->mm, __kernel_vsyscall))
 
 struct linux_binprm;
 
diff --git a/arch/x86/include/asm/mmu.h b/arch/x86/include/asm/mmu.h
index 876e74e8eec7..bbba90ebd2c8 100644
--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -18,7 +18,9 @@ typedef struct {
 #endif
 
 	struct mutex lock;
-	void __user *vdso;
+
+	unsigned long vvar_vma_start;
+	const struct vdso_image *vdso_image;
 } mm_context_t;
 
 #ifdef CONFIG_SMP
diff --git a/arch/x86/include/asm/vdso.h b/arch/x86/include/asm/vdso.h
index 8021bd28c0f1..3aa1f830c551 100644
--- a/arch/x86/include/asm/vdso.h
+++ b/arch/x86/include/asm/vdso.h
@@ -49,6 +49,22 @@ extern const struct vdso_image *selected_vdso32;
 
 extern void __init init_vdso_image(const struct vdso_image *image);
 
+static inline void __user *vdso_text_start(const struct mm_struct *mm)
+{
+	if (!mm->context.vdso_image)
+		return NULL;
+
+	return (void __user *)ACCESS_ONCE(mm->context.vvar_vma_start) -
+		mm->context.vdso_image->sym_vvar_start;
+}
+
+#define VDSO_SYM_ADDR(mm, sym) (					\
+		(mm)->context.vdso_image ?				\
+		vdso_text_start((mm)) +					\
+			(mm)->context.vdso_image->sym_ ## sym		\
+		: NULL							\
+	)
+
 #endif /* __ASSEMBLER__ */
 
 #endif /* _ASM_X86_VDSO_H */
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index 2851d63c1202..d8b21e37e292 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -297,10 +297,8 @@ __setup_frame(int sig, struct ksignal *ksig, sigset_t *set,
 			return -EFAULT;
 	}
 
-	if (current->mm->context.vdso)
-		restorer = current->mm->context.vdso +
-			selected_vdso32->sym___kernel_sigreturn;
-	else
+	restorer = VDSO_SYM_ADDR(current->mm, __kernel_sigreturn);
+	if (!restorer)
 		restorer = &frame->retcode;
 	if (ksig->ka.sa.sa_flags & SA_RESTORER)
 		restorer = ksig->ka.sa.sa_restorer;
@@ -362,8 +360,7 @@ static int __setup_rt_frame(int sig, struct ksignal *ksig,
 		save_altstack_ex(&frame->uc.uc_stack, regs->sp);
 
 		/* Set up to return from userspace.  */
-		restorer = current->mm->context.vdso +
-			selected_vdso32->sym___kernel_rt_sigreturn;
+		restorer = VDSO_SYM_ADDR(current->mm, __kernel_rt_sigreturn);
 		if (ksig->ka.sa.sa_flags & SA_RESTORER)
 			restorer = ksig->ka.sa.sa_restorer;
 		put_user_ex(restorer, &frame->pretcode);
diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
index 970463b566cf..7f99c2ed1a3e 100644
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -89,6 +89,38 @@ static unsigned long vdso_addr(unsigned long start, unsigned len)
 #endif
 }
 
+static void vvar_start_set(struct vm_special_mapping *sm,
+			   struct mm_struct *mm, unsigned long start_addr)
+{
+	if (start_addr >= TASK_SIZE_MAX - mm->context.vdso_image->size) {
+		/*
+		 * We were just relocated out of bounds.  Malicious
+		 * user code can cause this by mremapping only the
+		 * first page of a multi-page vdso.
+		 *
+		 * We can't actually fail here, but it's not safe to
+		 * allow vdso symbols to resolve to potentially
+		 * non-canonical addresses.  Instead, just ignore
+		 * the update.
+		 */
+
+		return;
+	}
+
+	mm->context.vvar_vma_start = start_addr;
+
+	/*
+	 * If we're here as a result of an mremap call, there are two
+	 * major gotchas.  First, if that call came from the vdso, we're
+	 * about to crash (i.e. don't do that).  Second, if we have more
+	 * than one thread, this won't update the other threads.
+	 */
+	if (mm->context.vdso_image->sym_VDSO32_SYSENTER_RETURN)
+		current_thread_info()->sysenter_return =
+			VDSO_SYM_ADDR(current->mm, VDSO32_SYSENTER_RETURN);
+
+}
+
 static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 {
 	struct mm_struct *mm = current->mm;
@@ -99,6 +131,12 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 	static struct vm_special_mapping vvar_mapping = {
 		.name = "[vvar]",
 		.pages = no_pages,
+
+		/*
+		 * Tracking the vdso is roughly equivalent to tracking the
+		 * vvar area, and the latter is slightly easier.
+		 */
+		.start_addr_set = vvar_start_set,
 	};
 
 	if (calculate_addr) {
@@ -118,7 +156,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 	}
 
 	text_start = addr - image->sym_vvar_start;
-	current->mm->context.vdso = (void __user *)text_start;
+	current->mm->context.vdso_image = image;
 
 	/*
 	 * MAYWRITE to allow gdb to COW and set breakpoints
@@ -171,7 +209,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 
 up_fail:
 	if (ret)
-		current->mm->context.vdso = NULL;
+		current->mm->context.vdso_image = NULL;
 
 	up_write(&mm->mmap_sem);
 	return ret;
@@ -189,11 +227,6 @@ static int load_vdso32(void)
 	if (ret)
 		return ret;
 
-	if (selected_vdso32->sym_VDSO32_SYSENTER_RETURN)
-		current_thread_info()->sysenter_return =
-			current->mm->context.vdso +
-			selected_vdso32->sym_VDSO32_SYSENTER_RETURN;
-
 	return 0;
 }
 #endif
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
