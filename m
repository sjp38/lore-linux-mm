Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1EFF28E0028
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:10:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d1-v6so6706815pfo.16
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 08:10:38 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g16-v6si2805450pgd.354.2018.09.21.08.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 08:10:28 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v4 2/9] x86/cet/ibt: User-mode indirect branch tracking support
Date: Fri, 21 Sep 2018 08:05:46 -0700
Message-Id: <20180921150553.21016-3-yu-cheng.yu@intel.com>
In-Reply-To: <20180921150553.21016-1-yu-cheng.yu@intel.com>
References: <20180921150553.21016-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Add user-mode indirect branch tracking enabling/disabling
and supporting routines.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cet.h               |  8 ++++++
 arch/x86/include/asm/disabled-features.h |  8 +++++-
 arch/x86/kernel/cet.c                    | 31 ++++++++++++++++++++++++
 arch/x86/kernel/cpu/common.c             | 20 ++++++++++++++-
 arch/x86/kernel/process.c                |  1 +
 5 files changed, 66 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
index 212bd68e31d3..1fea93fd436a 100644
--- a/arch/x86/include/asm/cet.h
+++ b/arch/x86/include/asm/cet.h
@@ -12,8 +12,11 @@ struct task_struct;
 struct cet_status {
 	unsigned long	shstk_base;
 	unsigned long	shstk_size;
+	unsigned long	ibt_bitmap_addr;
+	unsigned long	ibt_bitmap_size;
 	unsigned int	locked:1;
 	unsigned int	shstk_enabled:1;
+	unsigned int	ibt_enabled:1;
 };
 
 #ifdef CONFIG_X86_INTEL_CET
@@ -25,6 +28,9 @@ void cet_disable_shstk(void);
 void cet_disable_free_shstk(struct task_struct *p);
 int cet_restore_signal(unsigned long ssp);
 int cet_setup_signal(bool ia32, unsigned long rstor, unsigned long *new_ssp);
+int cet_setup_ibt(void);
+int cet_setup_ibt_bitmap(void);
+void cet_disable_ibt(void);
 #else
 static inline int prctl_cet(int option, unsigned long arg2) { return 0; }
 static inline int cet_setup_shstk(void) { return 0; }
@@ -35,6 +41,8 @@ static inline void cet_disable_free_shstk(struct task_struct *p) {}
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
index 1c2689738604..6adfe795d692 100644
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
@@ -283,3 +285,32 @@ int cet_setup_signal(bool ia32, unsigned long rstor_addr,
 	set_shstk_ptr(ssp);
 	return 0;
 }
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
+
+	current->thread.cet.ibt_enabled = 1;
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
index bffa9ef47832..230f65ee881e 100644
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
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 251b8714f9a3..ac0ea9c7e89f 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -137,6 +137,7 @@ void flush_thread(void)
 	memset(tsk->thread.tls_array, 0, sizeof(tsk->thread.tls_array));
 
 	cet_disable_shstk();
+	cet_disable_ibt();
 	fpu__clear(&tsk->thread.fpu);
 }
 
-- 
2.17.1
