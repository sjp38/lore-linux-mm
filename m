Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE7266B0285
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 11:21:00 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j9-v6so2615062plt.3
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 08:21:00 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id y62-v6si29748088pfy.139.2018.10.11.08.20.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 08:20:59 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v5 21/27] x86/cet/shstk: Introduce WRUSS instruction
Date: Thu, 11 Oct 2018 08:15:17 -0700
Message-Id: <20181011151523.27101-22-yu-cheng.yu@intel.com>
In-Reply-To: <20181011151523.27101-1-yu-cheng.yu@intel.com>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

WRUSS is a new kernel-mode instruction but writes directly to user
shadow stack memory.  This is used to construct a return address on
the shadow stack for the signal handler.

This instruction can fault if the user shadow stack is invalid shadow
stack memory.  In that case, the kernel does a fixup.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/special_insns.h | 32 ++++++++++++++++++++++++++++
 arch/x86/mm/fault.c                  |  9 ++++++++
 2 files changed, 41 insertions(+)

diff --git a/arch/x86/include/asm/special_insns.h b/arch/x86/include/asm/special_insns.h
index 317fc59b512c..37f16269747d 100644
--- a/arch/x86/include/asm/special_insns.h
+++ b/arch/x86/include/asm/special_insns.h
@@ -237,6 +237,38 @@ static inline void clwb(volatile void *__p)
 		: [pax] "a" (p));
 }
 
+#ifdef CONFIG_X86_INTEL_CET
+#if defined(CONFIG_IA32_EMULATION) || defined(CONFIG_X86_X32)
+static inline int write_user_shstk_32(unsigned long addr, unsigned int val)
+{
+	asm_volatile_goto("1: wrussd %1, (%0)\n"
+			  _ASM_EXTABLE(1b, %l[fail])
+			  :: "r" (addr), "r" (val)
+			  :: fail);
+	return 0;
+fail:
+	return -EPERM;
+}
+#else
+static inline int write_user_shstk_32(unsigned long addr, unsigned int val)
+{
+	WARN_ONCE(1, "%s used but not supported.\n", __func__);
+	return -EFAULT;
+}
+#endif
+
+static inline int write_user_shstk_64(unsigned long addr, unsigned long val)
+{
+	asm_volatile_goto("1: wrussq %1, (%0)\n"
+			  _ASM_EXTABLE(1b, %l[fail])
+			  :: "r" (addr), "r" (val)
+			  :: fail);
+	return 0;
+fail:
+	return -EPERM;
+}
+#endif /* CONFIG_X86_INTEL_CET */
+
 #define nop() asm volatile ("nop")
 
 
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 7c3877a982f4..b91fc008f33a 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1305,6 +1305,15 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		error_code |= X86_PF_USER;
 		flags |= FAULT_FLAG_USER;
 	} else {
+		/*
+		 * WRUSS is a kernel instruction and but writes
+		 * to user shadow stack.  When a fault occurs,
+		 * both X86_PF_USER and X86_PF_SHSTK are set.
+		 * Clear X86_PF_USER here.
+		 */
+		if ((error_code & (X86_PF_USER | X86_PF_SHSTK)) ==
+		    (X86_PF_USER | X86_PF_SHSTK))
+			error_code &= ~X86_PF_USER;
 		if (regs->flags & X86_EFLAGS_IF)
 			local_irq_enable();
 	}
-- 
2.17.1
