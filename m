Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA436B0272
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:31:19 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f5-v6so13261917plf.18
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 15:31:19 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id e6-v6si18699657pfa.217.2018.07.10.15.31.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 15:31:18 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v2 22/27] x86/cet/ibt: User-mode indirect branch tracking support
Date: Tue, 10 Jul 2018 15:26:34 -0700
Message-Id: <20180710222639.8241-23-yu-cheng.yu@intel.com>
In-Reply-To: <20180710222639.8241-1-yu-cheng.yu@intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Add user-mode indirect branch tracking enabling/disabling
and supporting routines.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cet.h               |  8 +++
 arch/x86/include/asm/disabled-features.h |  8 ++-
 arch/x86/kernel/cet.c                    | 73 ++++++++++++++++++++++++
 arch/x86/kernel/cpu/common.c             | 20 ++++++-
 arch/x86/kernel/elf.c                    | 16 +++++-
 arch/x86/kernel/process.c                |  1 +
 6 files changed, 123 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
index d9ae3d86cdd7..71da2cccba16 100644
--- a/arch/x86/include/asm/cet.h
+++ b/arch/x86/include/asm/cet.h
@@ -12,7 +12,10 @@ struct task_struct;
 struct cet_status {
 	unsigned long	shstk_base;
 	unsigned long	shstk_size;
+	unsigned long	ibt_bitmap_addr;
+	unsigned long	ibt_bitmap_size;
 	unsigned int	shstk_enabled:1;
+	unsigned int	ibt_enabled:1;
 };
 
 #ifdef CONFIG_X86_INTEL_CET
@@ -21,6 +24,9 @@ void cet_disable_shstk(void);
 void cet_disable_free_shstk(struct task_struct *p);
 int cet_restore_signal(unsigned long ssp);
 int cet_setup_signal(bool ia32, unsigned long rstor, unsigned long *new_ssp);
+int cet_setup_ibt(void);
+int cet_setup_ibt_bitmap(void);
+void cet_disable_ibt(void);
 #else
 static inline int cet_setup_shstk(void) { return 0; }
 static inline void cet_disable_shstk(void) {}
@@ -28,6 +34,8 @@ static inline void cet_disable_free_shstk(struct task_struct *p) {}
 static inline int cet_restore_signal(unsigned long ssp) { return 0; }
 static inline int cet_setup_signal(bool ia32, unsigned long rstor,
 				   unsigned long *new_ssp) { return 0; }
+static inline int cet_setup_ibt(void) { return 0; }
+static inline void cet_disable_ibt(void) {}
 #endif
 
 #endif /* __ASSEMBLY__ */
diff --git a/arch/x86/include/asm/disabled-features.h b/arch/x86/include/asm/disabled-features.h
index 3624a11e5ba6..ce5bdaf0f1ff 100644
--- a/arch/x86/include/asm/disabled-features.h
+++ b/arch/x86/include/asm/disabled-features.h
@@ -62,6 +62,12 @@
 #define DISABLE_SHSTK	(1<<(X86_FEATURE_SHSTK & 31))
 #endif
 
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+#define DISABLE_IBT	0
+#else
+#define DISABLE_IBT	(1<<(X86_FEATURE_IBT & 31))
+#endif
+
 /*
  * Make sure to add features to the correct mask
  */
@@ -72,7 +78,7 @@
 #define DISABLED_MASK4	(DISABLE_PCID)
 #define DISABLED_MASK5	0
 #define DISABLED_MASK6	0
-#define DISABLED_MASK7	(DISABLE_PTI)
+#define DISABLED_MASK7	(DISABLE_PTI|DISABLE_IBT)
 #define DISABLED_MASK8	0
 #define DISABLED_MASK9	(DISABLE_MPX)
 #define DISABLED_MASK10	0
diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
index 4eba7790c4e4..8bbd63e1a2ba 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -12,6 +12,8 @@
 #include <linux/slab.h>
 #include <linux/uaccess.h>
 #include <linux/sched/signal.h>
+#include <linux/vmalloc.h>
+#include <linux/bitops.h>
 #include <asm/msr.h>
 #include <asm/user.h>
 #include <asm/fpu/xstate.h>
@@ -241,3 +243,74 @@ int cet_setup_signal(bool ia32, unsigned long rstor_addr,
 	set_shstk_ptr(ssp);
 	return 0;
 }
+
+static unsigned long ibt_mmap(unsigned long addr, unsigned long len)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long populate;
+
+	down_write(&mm->mmap_sem);
+	addr = do_mmap(NULL, addr, len, PROT_READ | PROT_WRITE,
+		       MAP_ANONYMOUS | MAP_PRIVATE,
+		       VM_DONTDUMP, 0, &populate, NULL);
+	up_write(&mm->mmap_sem);
+
+	if (populate)
+		mm_populate(addr, populate);
+
+	return addr;
+}
+
+int cet_setup_ibt(void)
+{
+	u64 r;
+
+	if (!cpu_feature_enabled(X86_FEATURE_IBT))
+		return -EOPNOTSUPP;
+
+	rdmsrl(MSR_IA32_U_CET, r);
+	r |= (MSR_IA32_CET_ENDBR_EN | MSR_IA32_CET_NO_TRACK_EN);
+	wrmsrl(MSR_IA32_U_CET, r);
+	current->thread.cet.ibt_enabled = 1;
+	return 0;
+}
+
+int cet_setup_ibt_bitmap(void)
+{
+	u64 r;
+	unsigned long bitmap;
+	unsigned long size;
+
+	if (!cpu_feature_enabled(X86_FEATURE_IBT))
+		return -EOPNOTSUPP;
+
+	size = TASK_SIZE_MAX / PAGE_SIZE / BITS_PER_BYTE;
+	bitmap = ibt_mmap(0, size);
+
+	if (bitmap >= TASK_SIZE_MAX)
+		return -ENOMEM;
+
+	bitmap &= PAGE_MASK;
+
+	rdmsrl(MSR_IA32_U_CET, r);
+	r |= (MSR_IA32_CET_LEG_IW_EN | bitmap);
+	wrmsrl(MSR_IA32_U_CET, r);
+
+	current->thread.cet.ibt_bitmap_addr = bitmap;
+	current->thread.cet.ibt_bitmap_size = size;
+	return 0;
+}
+
+void cet_disable_ibt(void)
+{
+	u64 r;
+
+	if (!cpu_feature_enabled(X86_FEATURE_IBT))
+		return;
+
+	rdmsrl(MSR_IA32_U_CET, r);
+	r &= ~(MSR_IA32_CET_ENDBR_EN | MSR_IA32_CET_LEG_IW_EN |
+	       MSR_IA32_CET_NO_TRACK_EN);
+	wrmsrl(MSR_IA32_U_CET, r);
+	current->thread.cet.ibt_enabled = 0;
+}
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 705467839ce8..c609c9ce5691 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -413,7 +413,8 @@ __setup("nopku", setup_disable_pku);
 
 static __always_inline void setup_cet(struct cpuinfo_x86 *c)
 {
-	if (cpu_feature_enabled(X86_FEATURE_SHSTK))
+	if (cpu_feature_enabled(X86_FEATURE_SHSTK) ||
+	    cpu_feature_enabled(X86_FEATURE_IBT))
 		cr4_set_bits(X86_CR4_CET);
 }
 
@@ -434,6 +435,23 @@ static __init int setup_disable_shstk(char *s)
 __setup("no_cet_shstk", setup_disable_shstk);
 #endif
 
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+static __init int setup_disable_ibt(char *s)
+{
+	/* require an exact match without trailing characters */
+	if (strlen(s))
+		return 0;
+
+	if (!boot_cpu_has(X86_FEATURE_IBT))
+		return 1;
+
+	setup_clear_cpu_cap(X86_FEATURE_IBT);
+	pr_info("x86: 'no_cet_ibt' specified, disabling Branch Tracking\n");
+	return 1;
+}
+__setup("no_cet_ibt", setup_disable_ibt);
+#endif
+
 /*
  * Some CPU features depend on higher CPUID levels, which may not always
  * be available due to CPUID level capping or broken virtualization
diff --git a/arch/x86/kernel/elf.c b/arch/x86/kernel/elf.c
index 233f6dad9c1f..42e08d3b573e 100644
--- a/arch/x86/kernel/elf.c
+++ b/arch/x86/kernel/elf.c
@@ -15,6 +15,7 @@
 #include <linux/fs.h>
 #include <linux/uaccess.h>
 #include <linux/string.h>
+#include <linux/compat.h>
 
 /*
  * The .note.gnu.property layout:
@@ -222,7 +223,8 @@ int arch_setup_features(void *ehdr_p, void *phdr_p,
 
 	struct elf64_hdr *ehdr64 = ehdr_p;
 
-	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
+	if (!cpu_feature_enabled(X86_FEATURE_SHSTK) &&
+	    !cpu_feature_enabled(X86_FEATURE_IBT))
 		return 0;
 
 	if (ehdr64->e_ident[EI_CLASS] == ELFCLASS64) {
@@ -250,6 +252,9 @@ int arch_setup_features(void *ehdr_p, void *phdr_p,
 	current->thread.cet.shstk_enabled = 0;
 	current->thread.cet.shstk_base = 0;
 	current->thread.cet.shstk_size = 0;
+	current->thread.cet.ibt_enabled = 0;
+	current->thread.cet.ibt_bitmap_addr = 0;
+	current->thread.cet.ibt_bitmap_size = 0;
 	if (cpu_feature_enabled(X86_FEATURE_SHSTK)) {
 		if (shstk) {
 			err = cet_setup_shstk();
@@ -257,6 +262,15 @@ int arch_setup_features(void *ehdr_p, void *phdr_p,
 				goto out;
 		}
 	}
+
+	if (cpu_feature_enabled(X86_FEATURE_IBT)) {
+		if (ibt) {
+			err = cet_setup_ibt();
+			if (err < 0)
+				goto out;
+		}
+	}
+
 out:
 	return err;
 }
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index b3b0b482983a..309ebb7f9d8d 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -138,6 +138,7 @@ void flush_thread(void)
 	memset(tsk->thread.tls_array, 0, sizeof(tsk->thread.tls_array));
 
 	cet_disable_shstk();
+	cet_disable_ibt();
 	fpu__clear(&tsk->thread.fpu);
 }
 
-- 
2.17.1
