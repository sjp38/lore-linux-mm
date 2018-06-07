Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 042216B0295
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:42:32 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j10-v6so3577357pgv.6
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:42:31 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l22-v6si26243115pgu.353.2018.06.07.07.42.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:42:30 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 2/7] x86/cet: User-mode indirect branch tracking support
Date: Thu,  7 Jun 2018 07:38:50 -0700
Message-Id: <20180607143855.3681-3-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143855.3681-1-yu-cheng.yu@intel.com>
References: <20180607143855.3681-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Add user-mode indirect branch tracking enabling/disabling
and supporting routines.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cet.h               |  8 ++++
 arch/x86/include/asm/disabled-features.h |  8 +++-
 arch/x86/kernel/cet.c                    | 73 ++++++++++++++++++++++++++++++++
 arch/x86/kernel/cpu/common.c             | 20 ++++++++-
 arch/x86/kernel/elf.c                    | 15 ++++++-
 arch/x86/kernel/process.c                |  1 +
 6 files changed, 122 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
index a2a53fe4d5e6..d07bdeb27db4 100644
--- a/arch/x86/include/asm/cet.h
+++ b/arch/x86/include/asm/cet.h
@@ -13,7 +13,10 @@ struct cet_stat {
 	unsigned long	shstk_base;
 	unsigned long	shstk_size;
 	unsigned long	exec_shstk_size;
+	unsigned long	ibt_bitmap_addr;
+	unsigned long	ibt_bitmap_size;
 	unsigned int	shstk_enabled:1;
+	unsigned int	ibt_enabled:1;
 	unsigned int	locked:1;
 	unsigned int	exec_shstk:2;
 };
@@ -29,6 +32,9 @@ void cet_disable_shstk(void);
 void cet_disable_free_shstk(struct task_struct *p);
 int cet_restore_signal(unsigned long ssp);
 int cet_setup_signal(int ia32, unsigned long addr);
+int cet_setup_ibt(void);
+int cet_setup_ibt_bitmap(void);
+void cet_disable_ibt(void);
 #else
 static inline int prctl_cet(int option, unsigned long arg2) { return 0; }
 static inline unsigned long cet_get_shstk_ptr(void) { return 0; }
@@ -41,6 +47,8 @@ static inline void cet_disable_shstk(void) {}
 static inline void cet_disable_free_shstk(struct task_struct *p) {}
 static inline int cet_restore_signal(unsigned long ssp) { return 0; }
 static inline int cet_setup_signal(int ia32, unsigned long addr) { return 0; }
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
index 1b7089dcf1ea..4df4b583311f 100644
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
@@ -222,3 +224,74 @@ int cet_setup_signal(int ia32, unsigned long rstor_addr)
 
 	return cet_push_shstk(ia32, ssp, rstor_addr);
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
+	size = TASK_SIZE / PAGE_SIZE / BITS_PER_BYTE;
+	bitmap = ibt_mmap(0, size);
+
+	if (bitmap >= TASK_SIZE)
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
index f54fabdaef60..4041d6b94455 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -403,7 +403,8 @@ __setup("nopku", setup_disable_pku);
 
 static __always_inline void setup_cet(struct cpuinfo_x86 *c)
 {
-	if (cpu_feature_enabled(X86_FEATURE_SHSTK))
+	if (cpu_feature_enabled(X86_FEATURE_SHSTK) ||
+	    cpu_feature_enabled(X86_FEATURE_IBT))
 		cr4_set_bits(X86_CR4_CET);
 }
 
@@ -424,6 +425,23 @@ static __init int setup_disable_shstk(char *s)
 __setup("noshstk", setup_disable_shstk);
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
+	pr_info("x86: 'noibt' specified, disabling Branch Tracking\n");
+	return 1;
+}
+__setup("noibt", setup_disable_ibt);
+#endif
+
 /*
  * Some CPU features depend on higher CPUID levels, which may not always
  * be available due to CPUID level capping or broken virtualization
diff --git a/arch/x86/kernel/elf.c b/arch/x86/kernel/elf.c
index de08d41971f6..a3995c8c2fc2 100644
--- a/arch/x86/kernel/elf.c
+++ b/arch/x86/kernel/elf.c
@@ -18,6 +18,7 @@
 #include <linux/fs.h>
 #include <linux/uaccess.h>
 #include <linux/string.h>
+#include <linux/compat.h>
 
 #define ELF_NOTE_DESC_OFFSET(n, align) \
 	round_up(sizeof(*n) + n->n_namesz, (align))
@@ -183,7 +184,8 @@ int arch_setup_features(void *ehdr_p, void *phdr_p,
 
 	struct elf64_hdr *ehdr64 = ehdr_p;
 
-	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
+	if (!cpu_feature_enabled(X86_FEATURE_SHSTK) &&
+	    !cpu_feature_enabled(X86_FEATURE_IBT))
 		return 0;
 
 	if (ehdr64->e_ident[EI_CLASS] == ELFCLASS64) {
@@ -211,6 +213,9 @@ int arch_setup_features(void *ehdr_p, void *phdr_p,
 	current->thread.cet.shstk_enabled = 0;
 	current->thread.cet.shstk_base = 0;
 	current->thread.cet.shstk_size = 0;
+	current->thread.cet.ibt_enabled = 0;
+	current->thread.cet.ibt_bitmap_addr = 0;
+	current->thread.cet.ibt_bitmap_size = 0;
 	current->thread.cet.locked = 0;
 	if (cpu_feature_enabled(X86_FEATURE_SHSTK)) {
 		int exec = current->thread.cet.exec_shstk;
@@ -224,6 +229,14 @@ int arch_setup_features(void *ehdr_p, void *phdr_p,
 		}
 	}
 
+	if (cpu_feature_enabled(X86_FEATURE_IBT)) {
+		if (ibt) {
+			err = cet_setup_ibt();
+			if (err < 0)
+				goto out;
+		}
+	}
+
 	/*
 	 * Lockout CET features if no interpreter
 	 */
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 54ad1863c6d2..9bec164e7958 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -139,6 +139,7 @@ void flush_thread(void)
 	memset(tsk->thread.tls_array, 0, sizeof(tsk->thread.tls_array));
 
 	cet_disable_shstk();
+	cet_disable_ibt();
 	fpu__clear(&tsk->thread.fpu);
 }
 
-- 
2.15.1
