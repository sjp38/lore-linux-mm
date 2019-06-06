Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 003E6C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D904208CA
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D904208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 627786B02AF; Thu,  6 Jun 2019 16:15:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DA176B02B1; Thu,  6 Jun 2019 16:15:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47C096B02B2; Thu,  6 Jun 2019 16:15:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 037716B02AF
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:36 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g38so2275826pgl.22
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=clcsm5axWe8+hZG2s5xT0CCWLgJnsuYEYwCwmIqgIZ0=;
        b=iVkMzjN06wN4a0t6zh3StQqRDdGgRa8R40OroeMNFUkSbocwSAjTw69tpkqlZRhgK6
         EePnmmwTBMvF+mwbSdUSsOZCT1RK4fH8Oh+RmGb2sD92eP2tBKC2do+ygcjmXnHeB5OC
         d7EnbdKO7S0yes8GsE3492i4KY4GLRDm3uIHEWakBr+05TQ5zHgVveF4hdWcYgJ4efl4
         DlDj/x94PK8fM4CI4hMNsYaGdBY8gRR8umvI6A5ogra1m8UpnAHL1xy6d9f3LGpKUNhs
         DMy0le9xnG8QYX2FROgDQBOIxKKGxDqAg82D4uFOQCJcKXt5Mr2zjlIS5J/C+cqq9r1o
         4dAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW4nCC8WIxRs6o2VES1qkUWnyjwNFy4s8E4lqVYpf/LTgURZ2EW
	TKnzXfKlnXn57AlJ/R4A3MwyOr8YyvVM4zFHNbF8eXF8dVPl18MtYzZl+L8z+CUEvccaZW3szO9
	3z5pi77UnTtiWmui90aE8xCErClvhIHbvtK7o5YOqGVzSIHSCYopkyeGzwzPdU8HRFA==
X-Received: by 2002:a17:902:b70b:: with SMTP id d11mr53038053pls.84.1559852135631;
        Thu, 06 Jun 2019 13:15:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwz6QlsgGHnxqsrsnwryWEjL8wdaRq2HlgkXY59vtBfZCwqO6YNrNnkQWUmfLG/gjYUZgDE
X-Received: by 2002:a17:902:b70b:: with SMTP id d11mr53037948pls.84.1559852133959;
        Thu, 06 Jun 2019 13:15:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852133; cv=none;
        d=google.com; s=arc-20160816;
        b=C8CvqoJWjfrRW4btg2jyYnpddLlM5Iu3GvXxslqhNIvWi/NVUv4ze6xN1NPsSndXWo
         fjmKZINuh2aBspBHqT8cxiWT8AR/PI0NTsSdsAiamwUgwNdAaXSFYtx4AA6pVpy1vCOF
         SM9CC7znJAXeQx6qx4L91XuDuL1ku8FONKKx75z11JilUpb9iinMeBKCqrx9+Am1YXNJ
         uhU0cdtjFOG0reqCG1Ex5uyflqjTaGDVg6hF+8xmOs6Mr21S6IBO/vSOUdoRsAaFNcLd
         mMF+k+dUzT6BLVEkBV6Fz/+HQLzlZsGPz7wp2Z4gsdwbTUDGO9hdRcusxm1lIB7wnIrG
         85+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=clcsm5axWe8+hZG2s5xT0CCWLgJnsuYEYwCwmIqgIZ0=;
        b=USLyz5LGBwRu41rKiJ7l1uFhSar/hmp6cnrUU6bHwWPCm/nBHHVzlcKUvux34LEWd3
         Yvi4gKGcDZ9cixq1MstjzEuRJJ1wPUEe1zPEGZDfoxLaFs0/6vel7fgot+ApdzaKVYGZ
         rSduwrAwrZwgOm0/wHtadh25bggrsYobz+BGKeG5HKu7JE86gBEq4hMkZom74QKXr1QV
         OowC0lPDCuxvOsop2rornUDMIptQHwnnu2ThVN762vEtpU7nfsbFk2C+YttRtSKCcoRP
         Br9dM5ABogQX70jYZaUaCnk/0Kl8NXDzfbs+HWuqrHrIFF06Q636B6MtmMNqcW9FJZfV
         HskQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:33 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:32 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v7 19/27] x86/cet/shstk: User-mode shadow stack support
Date: Thu,  6 Jun 2019 13:06:38 -0700
Message-Id: <20190606200646.3951-20-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds basic shadow stack enabling/disabling routines.
A task's shadow stack is allocated from memory with VM_SHSTK flag set
and read-only protection.  It has a fixed size of RLIMIT_STACK.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cet.h                    |  34 +++++
 arch/x86/include/asm/disabled-features.h      |   8 +-
 arch/x86/include/asm/msr-index.h              |  18 +++
 arch/x86/include/asm/processor.h              |   5 +
 arch/x86/kernel/Makefile                      |   2 +
 arch/x86/kernel/cet.c                         | 116 ++++++++++++++++++
 arch/x86/kernel/cpu/common.c                  |  25 ++++
 arch/x86/kernel/process.c                     |   1 +
 .../arch/x86/include/asm/disabled-features.h  |   8 +-
 9 files changed, 215 insertions(+), 2 deletions(-)
 create mode 100644 arch/x86/include/asm/cet.h
 create mode 100644 arch/x86/kernel/cet.c

diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
new file mode 100644
index 000000000000..c952a2ec65fe
--- /dev/null
+++ b/arch/x86/include/asm/cet.h
@@ -0,0 +1,34 @@
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
+struct cet_status {
+	unsigned long	shstk_base;
+	unsigned long	shstk_size;
+	unsigned int	shstk_enabled:1;
+};
+
+#ifdef CONFIG_X86_INTEL_CET
+int cet_setup_shstk(void);
+void cet_disable_shstk(void);
+void cet_disable_free_shstk(struct task_struct *p);
+#else
+static inline int cet_setup_shstk(void) { return -EINVAL; }
+static inline void cet_disable_shstk(void) {}
+static inline void cet_disable_free_shstk(struct task_struct *p) {}
+#endif
+
+#define cpu_x86_cet_enabled() \
+	(cpu_feature_enabled(X86_FEATURE_SHSTK) || \
+	 cpu_feature_enabled(X86_FEATURE_IBT))
+
+#endif /* __ASSEMBLY__ */
+
+#endif /* _ASM_X86_CET_H */
diff --git a/arch/x86/include/asm/disabled-features.h b/arch/x86/include/asm/disabled-features.h
index a5ea841cc6d2..06323ebed643 100644
--- a/arch/x86/include/asm/disabled-features.h
+++ b/arch/x86/include/asm/disabled-features.h
@@ -62,6 +62,12 @@
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
@@ -81,7 +87,7 @@
 #define DISABLED_MASK13	0
 #define DISABLED_MASK14	0
 #define DISABLED_MASK15	0
-#define DISABLED_MASK16	(DISABLE_PKU|DISABLE_OSPKE|DISABLE_LA57|DISABLE_UMIP)
+#define DISABLED_MASK16	(DISABLE_PKU|DISABLE_OSPKE|DISABLE_LA57|DISABLE_UMIP|DISABLE_SHSTK)
 #define DISABLED_MASK17	0
 #define DISABLED_MASK18	0
 #define DISABLED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 19)
diff --git a/arch/x86/include/asm/msr-index.h b/arch/x86/include/asm/msr-index.h
index 979ef971cc78..30e9107974fa 100644
--- a/arch/x86/include/asm/msr-index.h
+++ b/arch/x86/include/asm/msr-index.h
@@ -839,4 +839,22 @@
 #define MSR_VM_IGNNE                    0xc0010115
 #define MSR_VM_HSAVE_PA                 0xc0010117
 
+/* Control-flow Enforcement Technology MSRs */
+#define MSR_IA32_U_CET		0x6a0 /* user mode cet setting */
+#define MSR_IA32_S_CET		0x6a2 /* kernel mode cet setting */
+#define MSR_IA32_PL0_SSP	0x6a4 /* kernel shstk pointer */
+#define MSR_IA32_PL1_SSP	0x6a5 /* ring-1 shstk pointer */
+#define MSR_IA32_PL2_SSP	0x6a6 /* ring-2 shstk pointer */
+#define MSR_IA32_PL3_SSP	0x6a7 /* user shstk pointer */
+#define MSR_IA32_INT_SSP_TAB	0x6a8 /* exception shstk table */
+
+/* MSR_IA32_U_CET and MSR_IA32_S_CET bits */
+#define MSR_IA32_CET_SHSTK_EN		0x0000000000000001ULL
+#define MSR_IA32_CET_WRSS_EN		0x0000000000000002ULL
+#define MSR_IA32_CET_ENDBR_EN		0x0000000000000004ULL
+#define MSR_IA32_CET_LEG_IW_EN		0x0000000000000008ULL
+#define MSR_IA32_CET_NO_TRACK_EN	0x0000000000000010ULL
+#define MSR_IA32_CET_WAIT_ENDBR	0x00000000000000800UL
+#define MSR_IA32_CET_BITMAP_MASK	0xfffffffffffff000ULL
+
 #endif /* _ASM_X86_MSR_INDEX_H */
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index c34a35c78618..2ae7c1bf4e43 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -24,6 +24,7 @@ struct vm86;
 #include <asm/special_insns.h>
 #include <asm/fpu/types.h>
 #include <asm/unwind_hints.h>
+#include <asm/cet.h>
 
 #include <linux/personality.h>
 #include <linux/cache.h>
@@ -487,6 +488,10 @@ struct thread_struct {
 	unsigned int		sig_on_uaccess_err:1;
 	unsigned int		uaccess_err:1;	/* uaccess failed */
 
+#ifdef CONFIG_X86_INTEL_CET
+	struct cet_status	cet;
+#endif
+
 	/* Floating point and extended processor state */
 	struct fpu		fpu;
 	/*
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index ce1b5cc360a2..584ed7e9a599 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -140,6 +140,8 @@ obj-$(CONFIG_UNWINDER_ORC)		+= unwind_orc.o
 obj-$(CONFIG_UNWINDER_FRAME_POINTER)	+= unwind_frame.o
 obj-$(CONFIG_UNWINDER_GUESS)		+= unwind_guess.o
 
+obj-$(CONFIG_X86_INTEL_CET)		+= cet.o
+
 ###
 # 64 bit specific files
 ifeq ($(CONFIG_X86_64),y)
diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
new file mode 100644
index 000000000000..2a48634aa6ce
--- /dev/null
+++ b/arch/x86/kernel/cet.c
@@ -0,0 +1,116 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * cet.c - Control-flow Enforcement (CET)
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
+#include <linux/compat.h>
+#include <asm/msr.h>
+#include <asm/user.h>
+#include <asm/fpu/internal.h>
+#include <asm/fpu/xstate.h>
+#include <asm/fpu/types.h>
+#include <asm/cet.h>
+
+static int set_shstk_ptr(unsigned long addr)
+{
+	u64 r;
+
+	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
+		return -1;
+
+	if ((addr >= TASK_SIZE_MAX) || (!IS_ALIGNED(addr, 4)))
+		return -1;
+
+	modify_fpu_regs_begin();
+	rdmsrl(MSR_IA32_U_CET, r);
+	wrmsrl(MSR_IA32_PL3_SSP, addr);
+	wrmsrl(MSR_IA32_U_CET, r | MSR_IA32_CET_SHSTK_EN);
+	modify_fpu_regs_end();
+	return 0;
+}
+
+static unsigned long get_shstk_addr(void)
+{
+	unsigned long ptr;
+
+	if (!current->thread.cet.shstk_enabled)
+		return 0;
+
+	modify_fpu_regs_begin();
+	rdmsrl(MSR_IA32_PL3_SSP, ptr);
+	modify_fpu_regs_end();
+	return ptr;
+}
+
+int cet_setup_shstk(void)
+{
+	unsigned long addr, size;
+
+	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
+		return -EOPNOTSUPP;
+
+	size = rlimit(RLIMIT_STACK);
+	addr = do_mmap_locked(0, size, PROT_READ,
+			      MAP_ANONYMOUS | MAP_PRIVATE, VM_SHSTK);
+
+	/*
+	 * Return actual error from do_mmap().
+	 */
+	if (addr >= TASK_SIZE_MAX)
+		return addr;
+
+	set_shstk_ptr(addr + size - sizeof(u64));
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
+	modify_fpu_regs_begin();
+	rdmsrl(MSR_IA32_U_CET, r);
+	r &= ~(MSR_IA32_CET_SHSTK_EN);
+	wrmsrl(MSR_IA32_U_CET, r);
+	wrmsrl(MSR_IA32_PL3_SSP, 0);
+	modify_fpu_regs_end();
+	current->thread.cet.shstk_enabled = 0;
+}
+
+void cet_disable_free_shstk(struct task_struct *tsk)
+{
+	if (!cpu_feature_enabled(X86_FEATURE_SHSTK) ||
+	    !tsk->thread.cet.shstk_enabled)
+		return;
+
+	if (tsk->mm && (tsk == current))
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
index 2c57fffebf9b..b0780fe8717e 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -53,6 +53,7 @@
 #include <asm/microcode_intel.h>
 #include <asm/intel-family.h>
 #include <asm/cpu_device_id.h>
+#include <asm/cet.h>
 
 #ifdef CONFIG_X86_LOCAL_APIC
 #include <asm/uv/uv.h>
@@ -417,6 +418,29 @@ static __init int setup_disable_pku(char *arg)
 __setup("nopku", setup_disable_pku);
 #endif /* CONFIG_X86_64 */
 
+static __always_inline void setup_cet(struct cpuinfo_x86 *c)
+{
+	if (cpu_x86_cet_enabled())
+		cr4_set_bits(X86_CR4_CET);
+}
+
+#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+static __init int setup_disable_shstk(char *s)
+{
+	/* require an exact match without trailing characters */
+	if (s[0] != '\0')
+		return 0;
+
+	if (!boot_cpu_has(X86_FEATURE_SHSTK))
+		return 1;
+
+	setup_clear_cpu_cap(X86_FEATURE_SHSTK);
+	pr_info("x86: 'no_cet_shstk' specified, disabling Shadow Stack\n");
+	return 1;
+}
+__setup("no_cet_shstk", setup_disable_shstk);
+#endif
+
 /*
  * Some CPU features depend on higher CPUID levels, which may not always
  * be available due to CPUID level capping or broken virtualization
@@ -1393,6 +1417,7 @@ static void identify_cpu(struct cpuinfo_x86 *c)
 	x86_init_rdrand(c);
 	x86_init_cache_qos(c);
 	setup_pku(c);
+	setup_cet(c);
 
 	/*
 	 * Clear/Set all flags overridden by options, need do it
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index d360bf4d696b..a4deb79b1089 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -42,6 +42,7 @@
 #include <asm/prctl.h>
 #include <asm/spec-ctrl.h>
 #include <asm/proto.h>
+#include <asm/cet.h>
 
 #include "process.h"
 
diff --git a/tools/arch/x86/include/asm/disabled-features.h b/tools/arch/x86/include/asm/disabled-features.h
index a5ea841cc6d2..06323ebed643 100644
--- a/tools/arch/x86/include/asm/disabled-features.h
+++ b/tools/arch/x86/include/asm/disabled-features.h
@@ -62,6 +62,12 @@
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
@@ -81,7 +87,7 @@
 #define DISABLED_MASK13	0
 #define DISABLED_MASK14	0
 #define DISABLED_MASK15	0
-#define DISABLED_MASK16	(DISABLE_PKU|DISABLE_OSPKE|DISABLE_LA57|DISABLE_UMIP)
+#define DISABLED_MASK16	(DISABLE_PKU|DISABLE_OSPKE|DISABLE_LA57|DISABLE_UMIP|DISABLE_SHSTK)
 #define DISABLED_MASK17	0
 #define DISABLED_MASK18	0
 #define DISABLED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 19)
-- 
2.17.1

