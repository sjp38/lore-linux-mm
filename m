Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 48B466B5241
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:44:45 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id e8-v6so4064219plt.4
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:44:45 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id v8-v6si7022512pgq.458.2018.08.30.07.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 07:44:44 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v3 4/8] x86/cet/ibt: Add arch_prctl functions for IBT
Date: Thu, 30 Aug 2018 07:40:05 -0700
Message-Id: <20180830144009.3314-5-yu-cheng.yu@intel.com>
In-Reply-To: <20180830144009.3314-1-yu-cheng.yu@intel.com>
References: <20180830144009.3314-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Update ARCH_CET_STATUS and ARCH_CET_DISABLE to include Indirect
Branch Tracking features.

Introduce:

arch_prctl(ARCH_CET_LEGACY_BITMAP, unsigned long *addr)
    Enable the Indirect Branch Tracking legacy code bitmap.

    The parameter 'addr' is a pointer to a user buffer.
    On returning to the caller, the kernel fills the following:

    *addr = IBT bitmap base address
    *(addr + 1) = IBT bitmap size

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/uapi/asm/prctl.h |  1 +
 arch/x86/kernel/cet_prctl.c       | 38 ++++++++++++++++++++++++++++++-
 arch/x86/kernel/process.c         |  1 +
 3 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/uapi/asm/prctl.h b/arch/x86/include/uapi/asm/prctl.h
index 3aec1088e01d..31d2465f9caf 100644
--- a/arch/x86/include/uapi/asm/prctl.h
+++ b/arch/x86/include/uapi/asm/prctl.h
@@ -18,5 +18,6 @@
 #define ARCH_CET_DISABLE	0x3002
 #define ARCH_CET_LOCK		0x3003
 #define ARCH_CET_ALLOC_SHSTK	0x3004
+#define ARCH_CET_LEGACY_BITMAP	0x3005
 
 #endif /* _ASM_X86_PRCTL_H */
diff --git a/arch/x86/kernel/cet_prctl.c b/arch/x86/kernel/cet_prctl.c
index c4b7c19f5040..df47b5ebc3f4 100644
--- a/arch/x86/kernel/cet_prctl.c
+++ b/arch/x86/kernel/cet_prctl.c
@@ -20,6 +20,8 @@ static int handle_get_status(unsigned long arg2)
 
 	if (current->thread.cet.shstk_enabled)
 		features |= GNU_PROPERTY_X86_FEATURE_1_SHSTK;
+	if (current->thread.cet.ibt_enabled)
+		features |= GNU_PROPERTY_X86_FEATURE_1_IBT;
 
 	shstk_base = current->thread.cet.shstk_base;
 	shstk_size = current->thread.cet.shstk_size;
@@ -49,9 +51,35 @@ static int handle_alloc_shstk(unsigned long arg2)
 	return 0;
 }
 
+static int handle_bitmap(unsigned long arg2)
+{
+	unsigned long addr, size;
+
+	if (current->thread.cet.ibt_enabled) {
+		int err;
+
+		err  = cet_setup_ibt_bitmap();
+		if (err)
+			return err;
+
+		addr = current->thread.cet.ibt_bitmap_addr;
+		size = current->thread.cet.ibt_bitmap_size;
+	} else {
+		addr = 0;
+		size = 0;
+	}
+
+	if (put_user(addr, (unsigned long __user *)arg2) ||
+	    put_user(size, (unsigned long __user *)arg2 + 1))
+		return -EFAULT;
+
+	return 0;
+}
+
 int prctl_cet(int option, unsigned long arg2)
 {
-	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
+	if (!cpu_feature_enabled(X86_FEATURE_SHSTK) &&
+	    !cpu_feature_enabled(X86_FEATURE_IBT))
 		return -EINVAL;
 
 	switch (option) {
@@ -63,6 +91,8 @@ int prctl_cet(int option, unsigned long arg2)
 			return -EPERM;
 		if (arg2 & GNU_PROPERTY_X86_FEATURE_1_SHSTK)
 			cet_disable_free_shstk(current);
+		if (arg2 & GNU_PROPERTY_X86_FEATURE_1_IBT)
+			cet_disable_ibt();
 
 		return 0;
 
@@ -73,6 +103,12 @@ int prctl_cet(int option, unsigned long arg2)
 	case ARCH_CET_ALLOC_SHSTK:
 		return handle_alloc_shstk(arg2);
 
+	/*
+	 * Allocate legacy bitmap and return address & size to user.
+	 */
+	case ARCH_CET_LEGACY_BITMAP:
+		return handle_bitmap(arg2);
+
 	default:
 		return -EINVAL;
 	}
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index ac0ea9c7e89f..aea15a9b6a3e 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -797,6 +797,7 @@ long do_arch_prctl_common(struct task_struct *task, int option,
 	case ARCH_CET_DISABLE:
 	case ARCH_CET_LOCK:
 	case ARCH_CET_ALLOC_SHSTK:
+	case ARCH_CET_LEGACY_BITMAP:
 		return prctl_cet(option, cpuid_enabled);
 	}
 
-- 
2.17.1
