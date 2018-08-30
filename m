Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7726B522A
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:43:48 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 90-v6so4014452pla.18
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:43:48 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id j11-v6si6596431pll.234.2018.08.30.07.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 07:43:46 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v3 19/24] x86/cet/shstk: Introduce WRUSS instruction
Date: Thu, 30 Aug 2018 07:38:59 -0700
Message-Id: <20180830143904.3168-20-yu-cheng.yu@intel.com>
In-Reply-To: <20180830143904.3168-1-yu-cheng.yu@intel.com>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

WRUSS is a new kernel-mode instruction but writes directly
to user shadow stack memory.  This is used to construct
a return address on the shadow stack for the signal
handler.

This instruction can fault if the user shadow stack is
invalid shadow stack memory.  In that case, the kernel does
fixup.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/special_insns.h | 37 ++++++++++++++++++++++++++++
 arch/x86/mm/extable.c                | 11 +++++++++
 arch/x86/mm/fault.c                  |  9 +++++++
 3 files changed, 57 insertions(+)

diff --git a/arch/x86/include/asm/special_insns.h b/arch/x86/include/asm/special_insns.h
index 317fc59b512c..9f609e802c5c 100644
--- a/arch/x86/include/asm/special_insns.h
+++ b/arch/x86/include/asm/special_insns.h
@@ -237,6 +237,43 @@ static inline void clwb(volatile void *__p)
 		: [pax] "a" (p));
 }
 
+#ifdef CONFIG_X86_INTEL_CET
+
+#if defined(CONFIG_IA32_EMULATION) || defined(CONFIG_X86_X32)
+static inline int write_user_shstk_32(unsigned long addr, unsigned int val)
+{
+	int err = 0;
+
+	asm volatile("1: wrussd %1, (%0)\n"
+		     "2:\n"
+		     _ASM_EXTABLE_HANDLE(1b, 2b, ex_handler_wruss)
+		     :
+		     : "r" (addr), "r" (val));
+
+	return err;
+}
+#else
+static inline int write_user_shstk_32(unsigned long addr, unsigned int val)
+{
+	BUG();
+	return 0;
+}
+#endif
+
+static inline int write_user_shstk_64(unsigned long addr, unsigned long val)
+{
+	int err = 0;
+
+	asm volatile("1: wrussq %1, (%0)\n"
+		     "2:\n"
+		     _ASM_EXTABLE_HANDLE(1b, 2b, ex_handler_wruss)
+		     :
+		     : "r" (addr), "r" (val));
+
+	return err;
+}
+#endif /* CONFIG_X86_INTEL_CET */
+
 #define nop() asm volatile ("nop")
 
 
diff --git a/arch/x86/mm/extable.c b/arch/x86/mm/extable.c
index 45f5d6cf65ae..e06ff851b671 100644
--- a/arch/x86/mm/extable.c
+++ b/arch/x86/mm/extable.c
@@ -157,6 +157,17 @@ __visible bool ex_handler_clear_fs(const struct exception_table_entry *fixup,
 }
 EXPORT_SYMBOL(ex_handler_clear_fs);
 
+#ifdef CONFIG_X86_INTEL_CET
+__visible bool ex_handler_wruss(const struct exception_table_entry *fixup,
+				struct pt_regs *regs, int trapnr)
+{
+	regs->ip = ex_fixup_addr(fixup);
+	regs->ax = -1;
+	return true;
+}
+EXPORT_SYMBOL(ex_handler_wruss);
+#endif
+
 __visible bool ex_has_fault_handler(unsigned long ip)
 {
 	const struct exception_table_entry *e;
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 3842353fb4a3..10dbb5c9aaef 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1305,6 +1305,15 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		error_code |= X86_PF_USER;
 		flags |= FAULT_FLAG_USER;
 	} else {
+		/*
+		 * WRUSS is a kernel instrcution and but writes
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
