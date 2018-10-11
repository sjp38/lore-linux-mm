Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 321B16B02A6
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 11:22:09 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id v4-v6so6505802plz.21
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 08:22:09 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a28-v6si14382557pfc.106.2018.10.11.08.22.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 08:22:08 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v5 06/11] x86/cet/ibt: Add arch_prctl functions for IBT
Date: Thu, 11 Oct 2018 08:16:49 -0700
Message-Id: <20181011151654.27221-7-yu-cheng.yu@intel.com>
In-Reply-To: <20181011151654.27221-1-yu-cheng.yu@intel.com>
References: <20181011151654.27221-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Update ARCH_X86_CET_STATUS and ARCH_X86_CET_DISABLE to include
Indirect Branch Tracking features.

Introduce:

arch_prctl(ARCH_X86_CET_GET_LEGACY_BITMAP, unsigned long *addr)
    Enable the Indirect Branch Tracking legacy code bitmap.
    Allocate the bitmap if the task does not have one.

    The parameter 'addr' is a pointer to a user buffer.
    On returning to the caller, the kernel fills the following:

    *addr = IBT bitmap base address
    *(addr + 1) = IBT bitmap size

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/uapi/asm/prctl.h |  1 +
 arch/x86/kernel/cet_prctl.c       | 35 +++++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+)

diff --git a/arch/x86/include/uapi/asm/prctl.h b/arch/x86/include/uapi/asm/prctl.h
index d962f0ec9ccf..fd4eae92c733 100644
--- a/arch/x86/include/uapi/asm/prctl.h
+++ b/arch/x86/include/uapi/asm/prctl.h
@@ -18,5 +18,6 @@
 #define ARCH_X86_CET_DISABLE		0x3002
 #define ARCH_X86_CET_LOCK		0x3003
 #define ARCH_X86_CET_ALLOC_SHSTK	0x3004
+#define ARCH_X86_CET_GET_LEGACY_BITMAP	0x3005
 
 #endif /* _ASM_X86_PRCTL_H */
diff --git a/arch/x86/kernel/cet_prctl.c b/arch/x86/kernel/cet_prctl.c
index 320dbb620d61..dc7e9785f5e7 100644
--- a/arch/x86/kernel/cet_prctl.c
+++ b/arch/x86/kernel/cet_prctl.c
@@ -21,6 +21,8 @@ static int handle_get_status(unsigned long arg2)
 
 	if (current->thread.cet.shstk_enabled)
 		features |= GNU_PROPERTY_X86_FEATURE_1_SHSTK;
+	if (current->thread.cet.ibt_enabled)
+		features |= GNU_PROPERTY_X86_FEATURE_1_IBT;
 
 	shstk_base = current->thread.cet.shstk_base;
 	shstk_size = current->thread.cet.shstk_size;
@@ -56,6 +58,31 @@ static int handle_alloc_shstk(unsigned long arg2)
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
 	if (!cpu_x86_cet_enabled())
@@ -70,6 +97,8 @@ int prctl_cet(int option, unsigned long arg2)
 			return -EPERM;
 		if (arg2 & GNU_PROPERTY_X86_FEATURE_1_SHSTK)
 			cet_disable_free_shstk(current);
+		if (arg2 & GNU_PROPERTY_X86_FEATURE_1_IBT)
+			cet_disable_ibt();
 
 		return 0;
 
@@ -80,6 +109,12 @@ int prctl_cet(int option, unsigned long arg2)
 	case ARCH_X86_CET_ALLOC_SHSTK:
 		return handle_alloc_shstk(arg2);
 
+	/*
+	 * Allocate legacy bitmap and return address & size to user.
+	 */
+	case ARCH_X86_CET_GET_LEGACY_BITMAP:
+		return handle_bitmap(arg2);
+
 	default:
 		return -EINVAL;
 	}
-- 
2.17.1
