Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C85136B026D
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:31:17 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f31-v6so5560211plb.10
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 15:31:17 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q88-v6si19303975pfj.51.2018.07.10.15.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 15:31:16 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v2 18/27] x86/cet/shstk: Introduce WRUSS instruction
Date: Tue, 10 Jul 2018 15:26:30 -0700
Message-Id: <20180710222639.8241-19-yu-cheng.yu@intel.com>
In-Reply-To: <20180710222639.8241-1-yu-cheng.yu@intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
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
 arch/x86/include/asm/special_insns.h          | 45 +++++++++++++++++++
 arch/x86/lib/x86-opcode-map.txt               |  2 +-
 arch/x86/mm/fault.c                           | 13 +++++-
 tools/objtool/arch/x86/lib/x86-opcode-map.txt |  2 +-
 4 files changed, 59 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/special_insns.h b/arch/x86/include/asm/special_insns.h
index 317fc59b512c..c69d8d6b457f 100644
--- a/arch/x86/include/asm/special_insns.h
+++ b/arch/x86/include/asm/special_insns.h
@@ -237,6 +237,51 @@ static inline void clwb(volatile void *__p)
 		: [pax] "a" (p));
 }
 
+#ifdef CONFIG_X86_INTEL_CET
+
+#if defined(CONFIG_IA32_EMULATION) || defined(CONFIG_X86_X32)
+static inline int write_user_shstk_32(unsigned long addr, unsigned int val)
+{
+	int err;
+
+	asm volatile("1: wrussd %[val], (%[addr])\n"
+		     "xor %[err], %[err]\n"
+		     "2:\n"
+		     ".section .fixup,\"ax\"\n"
+		     "3: mov $-1, %[err]; jmp 2b\n"
+		     ".previous\n"
+		     _ASM_EXTABLE(1b, 3b)
+		     : [err] "=a" (err)
+		     : [val] "S" (val), [addr] "D" (addr));
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
+	asm volatile("1: wrussq %[val], (%[addr])\n"
+		     "xor %[err], %[err]\n"
+		     "2:\n"
+		     ".section .fixup,\"ax\"\n"
+		     "3: mov $-1, %[err]; jmp 2b\n"
+		     ".previous\n"
+		     _ASM_EXTABLE(1b, 3b)
+		     : [err] "=a" (err)
+		     : [val] "S" (val), [addr] "D" (addr));
+
+	return err;
+}
+#endif /* CONFIG_X86_INTEL_CET */
+
 #define nop() asm volatile ("nop")
 
 
diff --git a/arch/x86/lib/x86-opcode-map.txt b/arch/x86/lib/x86-opcode-map.txt
index e0b85930dd77..72bb7c48a7df 100644
--- a/arch/x86/lib/x86-opcode-map.txt
+++ b/arch/x86/lib/x86-opcode-map.txt
@@ -789,7 +789,7 @@ f0: MOVBE Gy,My | MOVBE Gw,Mw (66) | CRC32 Gd,Eb (F2) | CRC32 Gd,Eb (66&F2)
 f1: MOVBE My,Gy | MOVBE Mw,Gw (66) | CRC32 Gd,Ey (F2) | CRC32 Gd,Ew (66&F2)
 f2: ANDN Gy,By,Ey (v)
 f3: Grp17 (1A)
-f5: BZHI Gy,Ey,By (v) | PEXT Gy,By,Ey (F3),(v) | PDEP Gy,By,Ey (F2),(v)
+f5: BZHI Gy,Ey,By (v) | PEXT Gy,By,Ey (F3),(v) | PDEP Gy,By,Ey (F2),(v) | WRUSS Pq,Qq (66),REX.W
 f6: ADCX Gy,Ey (66) | ADOX Gy,Ey (F3) | MULX By,Gy,rDX,Ey (F2),(v)
 f7: BEXTR Gy,Ey,By (v) | SHLX Gy,Ey,By (66),(v) | SARX Gy,Ey,By (F3),(v) | SHRX Gy,Ey,By (F2),(v)
 EndTable
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index fcd5739151f9..92f178b8b598 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -641,6 +641,17 @@ static int is_f00f_bug(struct pt_regs *regs, unsigned long address)
 	return 0;
 }
 
+/*
+ * WRUSS is a kernel instrcution and but writes to user
+ * shadow stack memory.  When a fault occurs, both
+ * X86_PF_USER and X86_PF_SHSTK are set.
+ */
+static int is_wruss(struct pt_regs *regs, unsigned long error_code)
+{
+	return (((error_code & (X86_PF_USER | X86_PF_SHSTK)) ==
+		(X86_PF_USER | X86_PF_SHSTK)) && !user_mode(regs));
+}
+
 static void
 show_fault_oops(struct pt_regs *regs, unsigned long error_code,
 		unsigned long address)
@@ -848,7 +859,7 @@ __bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
 	struct task_struct *tsk = current;
 
 	/* User mode accesses just cause a SIGSEGV */
-	if (error_code & X86_PF_USER) {
+	if ((error_code & X86_PF_USER) && !is_wruss(regs, error_code)) {
 		/*
 		 * It's possible to have interrupts off here:
 		 */
diff --git a/tools/objtool/arch/x86/lib/x86-opcode-map.txt b/tools/objtool/arch/x86/lib/x86-opcode-map.txt
index e0b85930dd77..72bb7c48a7df 100644
--- a/tools/objtool/arch/x86/lib/x86-opcode-map.txt
+++ b/tools/objtool/arch/x86/lib/x86-opcode-map.txt
@@ -789,7 +789,7 @@ f0: MOVBE Gy,My | MOVBE Gw,Mw (66) | CRC32 Gd,Eb (F2) | CRC32 Gd,Eb (66&F2)
 f1: MOVBE My,Gy | MOVBE Mw,Gw (66) | CRC32 Gd,Ey (F2) | CRC32 Gd,Ew (66&F2)
 f2: ANDN Gy,By,Ey (v)
 f3: Grp17 (1A)
-f5: BZHI Gy,Ey,By (v) | PEXT Gy,By,Ey (F3),(v) | PDEP Gy,By,Ey (F2),(v)
+f5: BZHI Gy,Ey,By (v) | PEXT Gy,By,Ey (F3),(v) | PDEP Gy,By,Ey (F2),(v) | WRUSS Pq,Qq (66),REX.W
 f6: ADCX Gy,Ey (66) | ADOX Gy,Ey (F3) | MULX By,Gy,rDX,Ey (F2),(v)
 f7: BEXTR Gy,Ey,By (v) | SHLX Gy,Ey,By (66),(v) | SARX Gy,Ey,By (F3),(v) | SHRX Gy,Ey,By (F2),(v)
 EndTable
-- 
2.17.1
