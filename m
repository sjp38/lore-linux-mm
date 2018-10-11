Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8E9D6B0299
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 11:21:45 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k66-v6so6225699pga.21
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 08:21:45 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id w90-v6si28024425pfk.208.2018.10.11.08.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 08:21:44 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v5 03/11] x86/cet/ibt: Add IBT legacy code bitmap allocation function
Date: Thu, 11 Oct 2018 08:16:46 -0700
Message-Id: <20181011151654.27221-4-yu-cheng.yu@intel.com>
In-Reply-To: <20181011151654.27221-1-yu-cheng.yu@intel.com>
References: <20181011151654.27221-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Indirect branch tracking provides an optional legacy code bitmap
that indicates locations of non-IBT compatible code.  When set,
each bit in the bitmap represents a page in the linear address is
legacy code.

We allocate the bitmap only when the application requests it.
Most applications do not need the bitmap.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/kernel/cet.c | 47 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
index 40c4c08e5e31..77ae4eaa9dea 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -21,6 +21,7 @@
 #include <asm/compat.h>
 #include <asm/cet.h>
 #include <asm/special_insns.h>
+#include <asm/elf.h>
 
 static int set_shstk_ptr(unsigned long addr)
 {
@@ -327,3 +328,49 @@ void cet_disable_ibt(void)
 	wrmsrl(MSR_IA32_U_CET, r);
 	current->thread.cet.ibt_enabled = 0;
 }
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
+	if (!current->thread.cet.ibt_bitmap_addr) {
+		/*
+		 * Calculate size and put in thread header.
+		 * may_expand_vm() needs this information.
+		 */
+		size = in_compat_syscall() ? task_size_32bit() : task_size_64bit(1);
+		size = size / PAGE_SIZE / BITS_PER_BYTE;
+		current->thread.cet.ibt_bitmap_size = size;
+		bitmap = do_mmap_locked(0, size, PROT_READ | PROT_WRITE,
+					MAP_ANONYMOUS | MAP_PRIVATE,
+					VM_DONTDUMP);
+
+		if ((bitmap >= TASK_SIZE) || (bitmap < size)) {
+			current->thread.cet.ibt_bitmap_size = 0;
+			return -ENOMEM;
+		}
+
+		current->thread.cet.ibt_bitmap_addr = bitmap;
+
+		/*
+		 * Lower bits of MSR_IA32_CET_LEG_IW_EN are for IBT
+		 * settings.  Clear lower bits even bitmap is already
+		 * page-aligned.
+		 */
+		bitmap &= PAGE_MASK;
+
+		/*
+		 * Turn on IBT legacy bitmap.
+		 */
+		rdmsrl(MSR_IA32_U_CET, r);
+		r |= (MSR_IA32_CET_LEG_IW_EN | bitmap);
+		wrmsrl(MSR_IA32_U_CET, r);
+	}
+
+	return 0;
+}
-- 
2.17.1
