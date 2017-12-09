Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id C246D6B0033
	for <linux-mm@kvack.org>; Sat,  9 Dec 2017 16:16:42 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id t18so6445149oie.5
        for <linux-mm@kvack.org>; Sat, 09 Dec 2017 13:16:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p18si3413511oie.339.2017.12.09.13.16.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Dec 2017 13:16:41 -0800 (PST)
From: Florian Weimer <fweimer@redhat.com>
Subject: pkeys: Support setting access rights for signal handlers
Message-ID: <5fee976a-42d4-d469-7058-b78ad8897219@redhat.com>
Date: Sat, 9 Dec 2017 22:16:37 +0100
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------3BBB5215DB760A84E4F7B4B6"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, x86@kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

This is a multi-part message in MIME format.
--------------3BBB5215DB760A84E4F7B4B6
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

The attached patch addresses a problem with the current x86 pkey 
implementation, which makes default-readable pkeys unusable from signal 
handlers because the default init_pkru value blocks access.

With this patch, the following program:

#include <sys/syscall.h>
#include <unistd.h>
#include <stdio.h>
#include <err.h>
#include <signal.h>

#define PKEY_ALLOC_SETSIGNAL 1

#define PKEY_DISABLE_WRITE 2

static inline unsigned int
pkey_read (void)
{
   unsigned int result;
   __asm__ volatile (".byte 0x0f, 0x01, 0xee"
                     : "=a" (result) : "c" (0) : "rdx");
   return result;
}

static void
print_pkru (const char *where)
{
   printf ("PKRU (%s): %08x\n", where, pkey_read ());
}

static void
sigusr1 (int signo)
{
   print_pkru ("signal handler");
}

int
main (void)
{
   if (signal (SIGUSR1, sigusr1) == SIG_ERR)
     err (1, "signal");
   print_pkru ("main");
   raise (SIGUSR1);

   puts ("allocating key 1");
   int key1 = syscall (SYS_pkey_alloc, 0, 0);
   if (key1 < 0)
     err (1, "pkey_alloc");
   print_pkru ("main");
   raise (SIGUSR1);

   puts ("allocating key 2");
   int key2 = syscall (SYS_pkey_alloc, PKEY_ALLOC_SETSIGNAL, 0);
   if (key2 < 0)
     err (1, "pkey_alloc");
   print_pkru ("main");
   raise (SIGUSR1);

   puts ("allocating key 3");
   int key3 = syscall (SYS_pkey_alloc, PKEY_ALLOC_SETSIGNAL, 
PKEY_DISABLE_WRITE);
   if (key3 < 0)
     err (1, "pkey_alloc");
   print_pkru ("main");
   raise (SIGUSR1);

   puts ("freeing key 3");
   if (syscall (SYS_pkey_free, key3) < 0)
     err (1, "pkey_free");
   print_pkru ("main");
   raise (SIGUSR1);

   puts ("freeing key 2");
   if (syscall (SYS_pkey_free, key2) < 0)
     err (1, "pkey_free");
   print_pkru ("main");
   raise (SIGUSR1);

   return 0;
}

prints this:

PKRU (main): 55555554
PKRU (signal handler): 55555554
allocating key 1
PKRU (main): 55555550
PKRU (signal handler): 55555554
allocating key 2
PKRU (main): 55555540
PKRU (signal handler): 55555544
allocating key 3
PKRU (main): 55555580
PKRU (signal handler): 55555584
freeing key 3
PKRU (main): 55555580
PKRU (signal handler): 55555544
freeing key 2
PKRU (main): 55555580
PKRU (signal handler): 55555554

Something like this is required before we can use memory protection keys 
in glibc for mostly-read-only data structures which need to be 
accessible from signal handlers.

I'm not sure if I got the locking for mm->context right.  Please check 
carefully.

Thanks,
Florian

--------------3BBB5215DB760A84E4F7B4B6
Content-Type: text/x-patch;
 name="pkeys-setsignal.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="pkeys-setsignal.patch"

commit 21ff3eaed8565e9b130380abf084e761f20e6fea
Author: Florian Weimer <fweimer@redhat.com>
Date:   Sat Dec 9 22:03:26 2017 +0100

    pkeys: Support setting access rights for signal handlers
    
    The new pkey_alloc flag PKEY_ALLOC_SETSIGNAL requests that the
    kernel uses the specified access rights as the default when the
    a signal handler is entered, instead of the access rights
    specified by init_pkru.
    
    This leads to a divergence in the FPU initialization for signal
    handlers and for exeve, so a for_signal flag is added to fpu__clear.
    
    Signed-off-by: Florian Weimer <fweimer@redhat.com>

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index 2dbdf59258d9..343251fed6fc 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -72,6 +72,8 @@
 /* compatibility flags */
 #define MAP_FILE	0
 
+#define PKEY_ALLOC_SETSIGNAL 0x1
+
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index 606e02ca4b6c..be1677e31899 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -99,6 +99,8 @@
 /* compatibility flags */
 #define MAP_FILE	0
 
+#define PKEY_ALLOC_SETSIGNAL 0x1
+
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index 80510ba44c08..2fc9d1bf98eb 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -69,6 +69,8 @@
 #define MAP_FILE	0
 #define MAP_VARIABLE	0
 
+#define PKEY_ALLOC_SETSIGNAL 0x1
+
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/arch/x86/include/asm/fpu/internal.h b/arch/x86/include/asm/fpu/internal.h
index a38bf5a1e37a..5a7a72dd589c 100644
--- a/arch/x86/include/asm/fpu/internal.h
+++ b/arch/x86/include/asm/fpu/internal.h
@@ -32,7 +32,7 @@ extern void fpu__restore(struct fpu *fpu);
 extern int  fpu__restore_sig(void __user *buf, int ia32_frame);
 extern void fpu__drop(struct fpu *fpu);
 extern int  fpu__copy(struct fpu *dst_fpu, struct fpu *src_fpu);
-extern void fpu__clear(struct fpu *fpu);
+extern void fpu__clear(struct fpu *fpu, bool for_signal);
 extern int  fpu__exception_code(struct fpu *fpu, int trap_nr);
 extern int  dump_fpu(struct pt_regs *ptregs, struct user_i387_struct *fpstate);
 
diff --git a/arch/x86/include/asm/mmu.h b/arch/x86/include/asm/mmu.h
index 9ea26f167497..0f041ed10c83 100644
--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -47,6 +47,13 @@ typedef struct {
 	 */
 	u16 pkey_allocation_map;
 	s16 execute_only_pkey;
+
+	/*
+	 * Used to derive the PKRU register value from init_pkru in a
+	 * signal handler.
+	 */
+	u32 pkey_signal_mask;
+	u32 pkey_signal_value;
 #endif
 #ifdef CONFIG_X86_INTEL_MPX
 	/* address of the bounds directory */
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 6d16d15d09a0..d402496714ad 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -141,6 +141,7 @@ static inline int init_new_context(struct task_struct *tsk,
 		mm->context.pkey_allocation_map = 0x1;
 		/* -1 means unallocated or invalid */
 		mm->context.execute_only_pkey = -1;
+		mm->context.pkey_signal_mask = ~0U;
 	}
 	#endif
 	return init_new_context_ldt(tsk, mm);
diff --git a/arch/x86/include/asm/pkeys.h b/arch/x86/include/asm/pkeys.h
index a0ba1ffda0df..a9e20e4f6bb2 100644
--- a/arch/x86/include/asm/pkeys.h
+++ b/arch/x86/include/asm/pkeys.h
@@ -7,6 +7,10 @@
 extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
 
+extern void arch_set_pkey_signal_default(struct mm_struct *mm,
+		int pkey, u32 rights);
+extern void arch_reset_pkey_signal_default(struct mm_struct *mm, int pkey);
+
 /*
  * Try to dedicate one of the protection keys to be used as an
  * execute-only protection key.
@@ -104,6 +108,6 @@ extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
 extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
-extern void copy_init_pkru_to_fpregs(void);
+extern void copy_init_pkru_to_fpregs(bool for_signal);
 
 #endif /*_ASM_X86_PKEYS_H */
diff --git a/arch/x86/kernel/fpu/core.c b/arch/x86/kernel/fpu/core.c
index f92a6593de1e..970e5b01ade4 100644
--- a/arch/x86/kernel/fpu/core.c
+++ b/arch/x86/kernel/fpu/core.c
@@ -362,7 +362,7 @@ void fpu__drop(struct fpu *fpu)
  * Clear FPU registers by setting them up from
  * the init fpstate:
  */
-static inline void copy_init_fpstate_to_fpregs(void)
+static inline void copy_init_fpstate_to_fpregs(bool for_signal)
 {
 	if (use_xsave())
 		copy_kernel_to_xregs(&init_fpstate.xsave, -1);
@@ -372,7 +372,7 @@ static inline void copy_init_fpstate_to_fpregs(void)
 		copy_kernel_to_fregs(&init_fpstate.fsave);
 
 	if (boot_cpu_has(X86_FEATURE_OSPKE))
-		copy_init_pkru_to_fpregs();
+		copy_init_pkru_to_fpregs(for_signal);
 }
 
 /*
@@ -381,7 +381,7 @@ static inline void copy_init_fpstate_to_fpregs(void)
  * Called by sys_execve(), by the signal handler code and by various
  * error paths.
  */
-void fpu__clear(struct fpu *fpu)
+void fpu__clear(struct fpu *fpu, bool for_signal)
 {
 	WARN_ON_FPU(fpu != &current->thread.fpu); /* Almost certainly an anomaly */
 
@@ -394,7 +394,7 @@ void fpu__clear(struct fpu *fpu)
 		preempt_disable();
 		fpu__initialize(fpu);
 		user_fpu_begin();
-		copy_init_fpstate_to_fpregs();
+		copy_init_fpstate_to_fpregs(for_signal);
 		preempt_enable();
 	}
 }
diff --git a/arch/x86/kernel/fpu/signal.c b/arch/x86/kernel/fpu/signal.c
index 23f1691670b6..8e9709c1270b 100644
--- a/arch/x86/kernel/fpu/signal.c
+++ b/arch/x86/kernel/fpu/signal.c
@@ -277,7 +277,7 @@ static int __fpu__restore_sig(void __user *buf, void __user *buf_fx, int size)
 			 IS_ENABLED(CONFIG_IA32_EMULATION));
 
 	if (!buf) {
-		fpu__clear(fpu);
+		fpu__clear(fpu, false);
 		return 0;
 	}
 
@@ -358,7 +358,7 @@ static int __fpu__restore_sig(void __user *buf, void __user *buf_fx, int size)
 		 */
 		user_fpu_begin();
 		if (copy_user_to_fpregs_zeroing(buf_fx, xfeatures, fx_only)) {
-			fpu__clear(fpu);
+			fpu__clear(fpu, false);
 			return -1;
 		}
 	}
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index bb988a24db92..36d59d8c684a 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -129,7 +129,7 @@ void flush_thread(void)
 	flush_ptrace_hw_breakpoint(tsk);
 	memset(tsk->thread.tls_array, 0, sizeof(tsk->thread.tls_array));
 
-	fpu__clear(&tsk->thread.fpu);
+	fpu__clear(&tsk->thread.fpu, false);
 }
 
 void disable_TSC(void)
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index b9e00e8f1c9b..86e7cf5d38e9 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -757,7 +757,7 @@ handle_signal(struct ksignal *ksig, struct pt_regs *regs)
 		 * Ensure the signal handler starts with the new fpu state.
 		 */
 		if (fpu->initialized)
-			fpu__clear(fpu);
+			fpu__clear(fpu, true);
 	}
 	signal_setup_done(failed, ksig, stepping);
 }
diff --git a/arch/x86/mm/pkeys.c b/arch/x86/mm/pkeys.c
index d7bc0eea20a5..f7447512833c 100644
--- a/arch/x86/mm/pkeys.c
+++ b/arch/x86/mm/pkeys.c
@@ -19,6 +19,26 @@
 #include <asm/cpufeature.h>             /* boot_cpu_has, ...            */
 #include <asm/mmu_context.h>            /* vma_pkey()                   */
 
+void arch_set_pkey_signal_default(struct mm_struct *mm, int pkey, u32 rights)
+{
+	int shift = pkey * PKRU_BITS_PER_PKEY;
+	u32 mask = ~(3U << shift);
+	u32 value = rights << shift;
+
+	mm->context.pkey_signal_mask &= mask;
+	mm->context.pkey_signal_value =
+		(mm->context.pkey_signal_value & mask) | value;
+}
+
+void arch_reset_pkey_signal_default(struct mm_struct *mm, int pkey)
+{
+	int shift = pkey * PKRU_BITS_PER_PKEY;
+	u32 mask = 3U << shift;
+
+	mm->context.pkey_signal_mask |= mask;
+	mm->context.pkey_signal_value &= ~mask;
+}
+
 int __execute_only_pkey(struct mm_struct *mm)
 {
 	bool need_to_set_mm_pkey = false;
@@ -142,21 +162,30 @@ u32 init_pkru_value = PKRU_AD_KEY( 1) | PKRU_AD_KEY( 2) | PKRU_AD_KEY( 3) |
  * we know the FPU regstiers are safe for use and we can use PKRU
  * directly.
  */
-void copy_init_pkru_to_fpregs(void)
+void copy_init_pkru_to_fpregs(bool for_signal)
 {
 	u32 init_pkru_value_snapshot = READ_ONCE(init_pkru_value);
+	u32 desired_pkru;
+
+	if (for_signal)
+		desired_pkru = (init_pkru_value_snapshot
+				& current->mm->context.pkey_signal_mask)
+			| current->mm->context.pkey_signal_value;
+	else
+		desired_pkru = init_pkru_value_snapshot;
+
 	/*
 	 * Any write to PKRU takes it out of the XSAVE 'init
 	 * state' which increases context switch cost.  Avoid
 	 * writing 0 when PKRU was already 0.
 	 */
-	if (!init_pkru_value_snapshot && !read_pkru())
+	if (!desired_pkru && !read_pkru())
 		return;
 	/*
 	 * Override the PKRU state that came from 'init_fpstate'
 	 * with the baseline from the process.
 	 */
-	write_pkru(init_pkru_value_snapshot);
+	write_pkru(desired_pkru);
 }
 
 static ssize_t init_pkru_read_file(struct file *file, char __user *user_buf,
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index 3e9d01ada81f..5abb66526e3e 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -111,6 +111,8 @@
 /* compatibility flags */
 #define MAP_FILE	0
 
+#define PKEY_ALLOC_SETSIGNAL 0x1
+
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/include/linux/pkeys.h b/include/linux/pkeys.h
index 0794ca78c379..0ab73297b752 100644
--- a/include/linux/pkeys.h
+++ b/include/linux/pkeys.h
@@ -29,13 +29,23 @@ static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
 	return -EINVAL;
 }
 
+static inline void arch_set_pkey_signal_default(struct mm_struct *mm,
+			int pkey, u32 rights)
+{
+}
+
+static inline void arch_reset_pkey_signal_default(struct mm_struct *mm,
+			int pkey)
+{
+}
+
 static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 			unsigned long init_val)
 {
 	return 0;
 }
 
-static inline void copy_init_pkru_to_fpregs(void)
+static inline void copy_init_pkru_to_fpregs(bool for_signal)
 {
 }
 
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index f8b134f5608f..78772266e3cd 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -66,6 +66,8 @@
 /* compatibility flags */
 #define MAP_FILE	0
 
+#define PKEY_ALLOC_SETSIGNAL 0x1
+
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/mm/mprotect.c b/mm/mprotect.c
index ec39f730a0bf..021f1d465649 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -523,14 +523,17 @@ SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
 	return do_mprotect_pkey(start, len, prot, pkey);
 }
 
+#define PKEY_ALLOC_FLAGS ((unsigned long) (PKEY_ALLOC_SETSIGNAL))
+
 SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 {
 	int pkey;
 	int ret;
 
-	/* No flags supported yet. */
-	if (flags)
+	/* check for unsupported flags */
+	if (flags & ~PKEY_ALLOC_FLAGS)
 		return -EINVAL;
+
 	/* check for unsupported init values */
 	if (init_val & ~PKEY_ACCESS_MASK)
 		return -EINVAL;
@@ -547,6 +550,10 @@ SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 		mm_pkey_free(current->mm, pkey);
 		goto out;
 	}
+
+	if (flags & PKEY_ALLOC_SETSIGNAL)
+		arch_set_pkey_signal_default(current->mm, pkey, init_val);
+
 	ret = pkey;
 out:
 	up_write(&current->mm->mmap_sem);
@@ -559,6 +566,8 @@ SYSCALL_DEFINE1(pkey_free, int, pkey)
 
 	down_write(&current->mm->mmap_sem);
 	ret = mm_pkey_free(current->mm, pkey);
+	if (!ret)
+		arch_reset_pkey_signal_default(current->mm, pkey);
 	up_write(&current->mm->mmap_sem);
 
 	/*
diff --git a/tools/include/uapi/asm-generic/mman-common.h b/tools/include/uapi/asm-generic/mman-common.h
index f8b134f5608f..78772266e3cd 100644
--- a/tools/include/uapi/asm-generic/mman-common.h
+++ b/tools/include/uapi/asm-generic/mman-common.h
@@ -66,6 +66,8 @@
 /* compatibility flags */
 #define MAP_FILE	0
 
+#define PKEY_ALLOC_SETSIGNAL 0x1
+
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/tools/testing/selftests/x86/protection_keys.c b/tools/testing/selftests/x86/protection_keys.c
index bc1b0735bb50..ea161916e378 100644
--- a/tools/testing/selftests/x86/protection_keys.c
+++ b/tools/testing/selftests/x86/protection_keys.c
@@ -421,6 +421,8 @@ void dumpit(char *f)
 	close(fd);
 }
 
+#define PKEY_ALLOC_SETSIGNAL 0x1
+
 #define PKEY_DISABLE_ACCESS    0x1
 #define PKEY_DISABLE_WRITE     0x2
 

--------------3BBB5215DB760A84E4F7B4B6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
