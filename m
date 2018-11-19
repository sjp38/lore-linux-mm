Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 378826B1CB1
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 16:54:57 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s27so6449629pgm.4
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:54:57 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id s8si4586261plq.345.2018.11.19.13.54.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 13:54:55 -0800 (PST)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v6 02/11] x86/cet/ibt: User-mode indirect branch tracking support
Date: Mon, 19 Nov 2018 13:49:25 -0800
Message-Id: <20181119214934.6174-3-yu-cheng.yu@intel.com>
In-Reply-To: <20181119214934.6174-1-yu-cheng.yu@intel.com>
References: <20181119214934.6174-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Add user-mode indirect branch tracking enabling/disabling and
supporting routines.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cet.h                    |  7 +++++
 arch/x86/include/asm/disabled-features.h      |  8 ++++-
 arch/x86/kernel/cet.c                         | 31 +++++++++++++++++++
 arch/x86/kernel/cpu/common.c                  | 17 ++++++++++
 arch/x86/kernel/process.c                     |  1 +
 .../arch/x86/include/asm/disabled-features.h  |  8 ++++-
 6 files changed, 70 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
index 29d88e4d8d5d..810d3e386fdb 100644
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
@@ -25,6 +28,8 @@ void cet_disable_shstk(void);
 void cet_disable_free_shstk(struct task_struct *p);
 int cet_restore_signal(unsigned long ssp);
 int cet_setup_signal(bool ia32, unsigned long rstor, unsigned long *new_ssp);
+int cet_setup_ibt(void);
+void cet_disable_ibt(void);
 #else
 static inline int prctl_cet(int option, unsigned long arg2) { return -EINVAL; }
 static inline int cet_setup_shstk(void) { return -EINVAL; }
@@ -35,6 +40,8 @@ static inline void cet_disable_free_shstk(struct task_struct *p) {}
 static inline int cet_restore_signal(unsigned long ssp) { return -EINVAL; }
 static inline int cet_setup_signal(bool ia32, unsigned long rstor,
 				   unsigned long *new_ssp) { return -EINVAL; }
+static inline int cet_setup_ibt(void) { return -EINVAL; }
+static inline void cet_disable_ibt(void) {}
 #endif
 
 #define cpu_x86_cet_enabled() \
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
index 1b5d1ce4df8f..fd157a6208c3 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -13,6 +13,8 @@
 #include <linux/uaccess.h>
 #include <linux/sched/signal.h>
 #include <linux/compat.h>
+#include <linux/vmalloc.h>
+#include <linux/bitops.h>
 #include <asm/msr.h>
 #include <asm/user.h>
 #include <asm/fpu/xstate.h>
@@ -302,3 +304,32 @@ int cet_setup_signal(bool ia32, unsigned long rstor_addr,
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
+	       MSR_IA32_CET_NO_TRACK_EN | MSR_IA32_CET_BITMAP_MASK);
+	wrmsrl(MSR_IA32_U_CET, r);
+	current->thread.cet.ibt_enabled = 0;
+}
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 795e195bf2fe..16bcc85d3819 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -435,6 +435,23 @@ static __init int setup_disable_shstk(char *s)
 __setup("no_cet_shstk", setup_disable_shstk);
 #endif
 
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+static __init int setup_disable_ibt(char *s)
+{
+	/* require an exact match without trailing characters */
+	if (s[0] != '\0')
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
index f240fce2b20f..f44c26bf6d28 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -137,6 +137,7 @@ void flush_thread(void)
 	memset(tsk->thread.tls_array, 0, sizeof(tsk->thread.tls_array));
 
 	cet_disable_shstk();
+	cet_disable_ibt();
 	fpu__clear(&tsk->thread.fpu);
 }
 
diff --git a/tools/arch/x86/include/asm/disabled-features.h b/tools/arch/x86/include/asm/disabled-features.h
index 3624a11e5ba6..ce5bdaf0f1ff 100644
--- a/tools/arch/x86/include/asm/disabled-features.h
+++ b/tools/arch/x86/include/asm/disabled-features.h
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
-- 
2.17.1
