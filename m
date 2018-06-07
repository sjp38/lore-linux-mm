Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 429E96B027D
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:41:31 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b31-v6so5520199plb.5
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:41:31 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i74-v6si8716254pgc.188.2018.06.07.07.41.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:41:29 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 01/10] x86/cet: User-mode shadow stack support
Date: Thu,  7 Jun 2018 07:37:58 -0700
Message-Id: <20180607143807.3611-2-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143807.3611-1-yu-cheng.yu@intel.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

This patch adds basic shadow stack enabling/disabling routines.
A task's shadow stack is allocated from memory with VM_SHSTK
flag set and read-only protection.  The shadow stack is
allocated to a fixed size and that can be changed by the system
admin.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cet.h               |  32 ++++++++
 arch/x86/include/asm/disabled-features.h |   8 +-
 arch/x86/include/asm/msr-index.h         |  14 ++++
 arch/x86/include/asm/processor.h         |   5 ++
 arch/x86/kernel/Makefile                 |   2 +
 arch/x86/kernel/cet.c                    | 123 +++++++++++++++++++++++++++++++
 arch/x86/kernel/cpu/common.c             |  24 ++++++
 arch/x86/kernel/process.c                |   2 +
 fs/proc/task_mmu.c                       |   3 +
 9 files changed, 212 insertions(+), 1 deletion(-)
 create mode 100644 arch/x86/include/asm/cet.h
 create mode 100644 arch/x86/kernel/cet.c

diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
new file mode 100644
index 000000000000..9d5bc1efc9b7
--- /dev/null
+++ b/arch/x86/include/asm/cet.h
@@ -0,0 +1,32 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _ASM_X86_CET_H
+#define _ASM_X86_CET_H
+
+#ifndef __ASSEMBLY__
+#include <linux/types.h>
+
+struct task_struct;
+/*
+ * Per-thread CET status
+ */
+struct cet_stat {
+	unsigned long	shstk_base;
+	unsigned long	shstk_size;
+	unsigned int	shstk_enabled:1;
+};
+
+#ifdef CONFIG_X86_INTEL_CET
+unsigned long cet_get_shstk_ptr(void);
+int cet_setup_shstk(void);
+void cet_disable_shstk(void);
+void cet_disable_free_shstk(struct task_struct *p);
+#else
+static inline unsigned long cet_get_shstk_ptr(void) { return 0; }
+static inline int cet_setup_shstk(void) { return 0; }
+static inline void cet_disable_shstk(void) {}
+static inline void cet_disable_free_shstk(struct task_struct *p) {}
+#endif
+
+#endif /* __ASSEMBLY__ */
+
+#endif /* _ASM_X86_CET_H */
diff --git a/arch/x86/include/asm/disabled-features.h b/arch/x86/include/asm/disabled-features.h
index 33833d1909af..3624a11e5ba6 100644
--- a/arch/x86/include/asm/disabled-features.h
+++ b/arch/x86/include/asm/disabled-features.h
@@ -56,6 +56,12 @@
 # define DISABLE_PTI		(1 << (X86_FEATURE_PTI & 31))
 #endif
 
+#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+#define DISABLE_SHSTK	0
+#else
+#define DISABLE_SHSTK	(1<<(X86_FEATURE_SHSTK & 31))
+#endif
+
 /*
  * Make sure to add features to the correct mask
  */
@@ -75,7 +81,7 @@
 #define DISABLED_MASK13	0
 #define DISABLED_MASK14	0
 #define DISABLED_MASK15	0
-#define DISABLED_MASK16	(DISABLE_PKU|DISABLE_OSPKE|DISABLE_LA57|DISABLE_UMIP)
+#define DISABLED_MASK16	(DISABLE_PKU|DISABLE_OSPKE|DISABLE_LA57|DISABLE_UMIP|DISABLE_SHSTK)
 #define DISABLED_MASK17	0
 #define DISABLED_MASK18	0
 #define DISABLED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 19)
diff --git a/arch/x86/include/asm/msr-index.h b/arch/x86/include/asm/msr-index.h
index fda2114197b3..428d13828ba9 100644
--- a/arch/x86/include/asm/msr-index.h
+++ b/arch/x86/include/asm/msr-index.h
@@ -770,4 +770,18 @@
 #define MSR_VM_IGNNE                    0xc0010115
 #define MSR_VM_HSAVE_PA                 0xc0010117
 
+/* Control-flow Enforcement Technology MSRs */
+#define MSR_IA32_U_CET		0x6a0
+#define MSR_IA32_S_CET		0x6a2
+#define MSR_IA32_PL0_SSP	0x6a4
+#define MSR_IA32_PL3_SSP	0x6a7
+#define MSR_IA32_INT_SSP_TAB	0x6a8
+
+/* MSR_IA32_U_CET and MSR_IA32_S_CET bits */
+#define MSR_IA32_CET_SHSTK_EN		0x0000000000000001
+#define MSR_IA32_CET_WRSS_EN		0x0000000000000002
+#define MSR_IA32_CET_ENDBR_EN		0x0000000000000004
+#define MSR_IA32_CET_LEG_IW_EN		0x0000000000000008
+#define MSR_IA32_CET_NO_TRACK_EN	0x0000000000000010
+
 #endif /* _ASM_X86_MSR_INDEX_H */
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 21a114914ba4..e632dd7adaac 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -24,6 +24,7 @@ struct vm86;
 #include <asm/special_insns.h>
 #include <asm/fpu/types.h>
 #include <asm/unwind_hints.h>
+#include <asm/cet.h>
 
 #include <linux/personality.h>
 #include <linux/cache.h>
@@ -507,6 +508,10 @@ struct thread_struct {
 	unsigned int		sig_on_uaccess_err:1;
 	unsigned int		uaccess_err:1;	/* uaccess failed */
 
+#ifdef CONFIG_X86_INTEL_CET
+	struct cet_stat		cet;
+#endif
+
 	/* Floating point and extended processor state */
 	struct fpu		fpu;
 	/*
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 02d6f5cf4e70..7ea5e099d558 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -138,6 +138,8 @@ obj-$(CONFIG_UNWINDER_ORC)		+= unwind_orc.o
 obj-$(CONFIG_UNWINDER_FRAME_POINTER)	+= unwind_frame.o
 obj-$(CONFIG_UNWINDER_GUESS)		+= unwind_guess.o
 
+obj-$(CONFIG_X86_INTEL_CET)		+= cet.o
+
 ###
 # 64 bit specific files
 ifeq ($(CONFIG_X86_64),y)
diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
new file mode 100644
index 000000000000..8abbfd44322a
--- /dev/null
+++ b/arch/x86/kernel/cet.c
@@ -0,0 +1,123 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * cet.c - Control Flow Enforcement (CET)
+ *
+ * Copyright (c) 2018, Intel Corporation.
+ * Yu-cheng Yu <yu-cheng.yu@intel.com>
+ */
+
+#include <linux/types.h>
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+#include <linux/sched/signal.h>
+#include <asm/msr.h>
+#include <asm/user.h>
+#include <asm/fpu/xstate.h>
+#include <asm/fpu/types.h>
+#include <asm/cet.h>
+
+#define SHSTK_SIZE (0x8000 * (test_thread_flag(TIF_IA32) ? 4 : 8))
+
+static inline int cet_set_shstk_ptr(unsigned long addr)
+{
+	u64 r;
+
+	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
+		return -1;
+
+	if ((addr >= TASK_SIZE) || (!IS_ALIGNED(addr, 4)))
+		return -1;
+
+	rdmsrl(MSR_IA32_U_CET, r);
+	wrmsrl(MSR_IA32_U_CET, r | MSR_IA32_CET_SHSTK_EN);
+	wrmsrl(MSR_IA32_PL3_SSP, addr);
+	return 0;
+}
+
+unsigned long cet_get_shstk_ptr(void)
+{
+	unsigned long ptr;
+
+	if (!current->thread.cet.shstk_enabled)
+		return 0;
+
+	rdmsrl(MSR_IA32_PL3_SSP, ptr);
+	return ptr;
+}
+
+static unsigned long shstk_mmap(unsigned long addr, unsigned long len)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long populate;
+
+	down_write(&mm->mmap_sem);
+	addr = do_mmap(NULL, addr, len, PROT_READ,
+		       MAP_ANONYMOUS | MAP_PRIVATE, VM_SHSTK,
+		       0, &populate, NULL);
+	up_write(&mm->mmap_sem);
+
+	if (populate)
+		mm_populate(addr, populate);
+
+	return addr;
+}
+
+int cet_setup_shstk(void)
+{
+	unsigned long addr, size;
+
+	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
+		return -EOPNOTSUPP;
+
+	size = SHSTK_SIZE;
+	addr = shstk_mmap(0, size);
+
+	if (addr >= TASK_SIZE)
+		return -ENOMEM;
+
+	cet_set_shstk_ptr(addr + size - sizeof(void *));
+	current->thread.cet.shstk_base = addr;
+	current->thread.cet.shstk_size = size;
+	current->thread.cet.shstk_enabled = 1;
+	return 0;
+}
+
+void cet_disable_shstk(void)
+{
+	u64 r;
+
+	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
+		return;
+
+	rdmsrl(MSR_IA32_U_CET, r);
+	r &= ~(MSR_IA32_CET_SHSTK_EN);
+	wrmsrl(MSR_IA32_U_CET, r);
+	wrmsrl(MSR_IA32_PL3_SSP, 0);
+	current->thread.cet.shstk_enabled = 0;
+}
+
+void cet_disable_free_shstk(struct task_struct *tsk)
+{
+	if (!cpu_feature_enabled(X86_FEATURE_SHSTK) ||
+	    !tsk->thread.cet.shstk_enabled)
+		return;
+
+	if (tsk == current)
+		cet_disable_shstk();
+
+	/*
+	 * Free only when tsk is current or shares mm
+	 * with current but has its own shstk.
+	 */
+	if (tsk->mm && (tsk->mm == current->mm) &&
+	    (tsk->thread.cet.shstk_base)) {
+		vm_munmap(tsk->thread.cet.shstk_base,
+			  tsk->thread.cet.shstk_size);
+		tsk->thread.cet.shstk_base = 0;
+		tsk->thread.cet.shstk_size = 0;
+	}
+
+	tsk->thread.cet.shstk_enabled = 0;
+}
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 38276f58d3bf..f54fabdaef60 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -401,6 +401,29 @@ static __init int setup_disable_pku(char *arg)
 __setup("nopku", setup_disable_pku);
 #endif /* CONFIG_X86_64 */
 
+static __always_inline void setup_cet(struct cpuinfo_x86 *c)
+{
+	if (cpu_feature_enabled(X86_FEATURE_SHSTK))
+		cr4_set_bits(X86_CR4_CET);
+}
+
+#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+static __init int setup_disable_shstk(char *s)
+{
+	/* require an exact match without trailing characters */
+	if (strlen(s))
+		return 0;
+
+	if (!boot_cpu_has(X86_FEATURE_SHSTK))
+		return 1;
+
+	setup_clear_cpu_cap(X86_FEATURE_SHSTK);
+	pr_info("x86: 'noshstk' specified, disabling Shadow Stack\n");
+	return 1;
+}
+__setup("noshstk", setup_disable_shstk);
+#endif
+
 /*
  * Some CPU features depend on higher CPUID levels, which may not always
  * be available due to CPUID level capping or broken virtualization
@@ -1313,6 +1336,7 @@ static void identify_cpu(struct cpuinfo_x86 *c)
 	x86_init_rdrand(c);
 	x86_init_cache_qos(c);
 	setup_pku(c);
+	setup_cet(c);
 
 	/*
 	 * Clear/Set all flags overridden by options, need do it
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 30ca2d1a9231..b3b0b482983a 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -39,6 +39,7 @@
 #include <asm/desc.h>
 #include <asm/prctl.h>
 #include <asm/spec-ctrl.h>
+#include <asm/cet.h>
 
 /*
  * per-CPU TSS segments. Threads are completely 'soft' on Linux,
@@ -136,6 +137,7 @@ void flush_thread(void)
 	flush_ptrace_hw_breakpoint(tsk);
 	memset(tsk->thread.tls_array, 0, sizeof(tsk->thread.tls_array));
 
+	cet_disable_shstk();
 	fpu__clear(&tsk->thread.fpu);
 }
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index c486ad4b43f0..6aca93ecec0e 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -679,6 +679,9 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_PKEY_BIT1)]	= "",
 		[ilog2(VM_PKEY_BIT2)]	= "",
 		[ilog2(VM_PKEY_BIT3)]	= "",
+#endif
+#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+		[ilog2(VM_SHSTK)]	= "ss"
 #endif
 	};
 	size_t i;
-- 
2.15.1
