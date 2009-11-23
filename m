Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C8CE36B0078
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 09:09:26 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v2 04/12] Add "handle page fault" PV helper.
Date: Mon, 23 Nov 2009 16:05:59 +0200
Message-Id: <1258985167-29178-5-git-send-email-gleb@redhat.com>
In-Reply-To: <1258985167-29178-1-git-send-email-gleb@redhat.com>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Allow paravirtualized guest to do special handling for some page faults.

Ingo's concerns not yet addressed here. What was the conclusion of previous
discussion? 

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/paravirt.h       |    7 +++++++
 arch/x86/include/asm/paravirt_types.h |    4 ++++
 arch/x86/kernel/paravirt.c            |    8 ++++++++
 arch/x86/kernel/paravirt_patch_32.c   |    8 ++++++++
 arch/x86/kernel/paravirt_patch_64.c   |    7 +++++++
 arch/x86/mm/fault.c                   |    3 +++
 6 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index efb3899..5203da1 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -6,6 +6,7 @@
 #ifdef CONFIG_PARAVIRT
 #include <asm/pgtable_types.h>
 #include <asm/asm.h>
+#include <asm/ptrace.h>
 
 #include <asm/paravirt_types.h>
 
@@ -710,6 +711,12 @@ static inline void arch_end_context_switch(struct task_struct *next)
 	PVOP_VCALL1(pv_cpu_ops.end_context_switch, next);
 }
 
+static inline int arch_handle_page_fault(struct pt_regs *regs,
+					 unsigned long error_code)
+{
+	return PVOP_CALL2(int, pv_cpu_ops.handle_pf, regs, error_code);
+}
+
 #define  __HAVE_ARCH_ENTER_LAZY_MMU_MODE
 static inline void arch_enter_lazy_mmu_mode(void)
 {
diff --git a/arch/x86/include/asm/paravirt_types.h b/arch/x86/include/asm/paravirt_types.h
index 9357473..bcc39b3 100644
--- a/arch/x86/include/asm/paravirt_types.h
+++ b/arch/x86/include/asm/paravirt_types.h
@@ -186,6 +186,7 @@ struct pv_cpu_ops {
 
 	void (*start_context_switch)(struct task_struct *prev);
 	void (*end_context_switch)(struct task_struct *next);
+	int (*handle_pf)(struct pt_regs *regs, unsigned long error_code);
 };
 
 struct pv_irq_ops {
@@ -385,6 +386,7 @@ extern struct pv_lock_ops pv_lock_ops;
 unsigned paravirt_patch_nop(void);
 unsigned paravirt_patch_ident_32(void *insnbuf, unsigned len);
 unsigned paravirt_patch_ident_64(void *insnbuf, unsigned len);
+unsigned paravirt_patch_ret_0(void *insnbuf, unsigned len);
 unsigned paravirt_patch_ignore(unsigned len);
 unsigned paravirt_patch_call(void *insnbuf,
 			     const void *target, u16 tgt_clobbers,
@@ -676,8 +678,10 @@ void paravirt_leave_lazy_mmu(void);
 void _paravirt_nop(void);
 u32 _paravirt_ident_32(u32);
 u64 _paravirt_ident_64(u64);
+unsigned long _paravirt_ret_0(void);
 
 #define paravirt_nop	((void *)_paravirt_nop)
+#define paravirt_ret_0  ((void *)_paravirt_ret_0)
 
 /* These all sit in the .parainstructions section to tell us what to patch. */
 struct paravirt_patch_site {
diff --git a/arch/x86/kernel/paravirt.c b/arch/x86/kernel/paravirt.c
index 1b1739d..7d8f37b 100644
--- a/arch/x86/kernel/paravirt.c
+++ b/arch/x86/kernel/paravirt.c
@@ -54,6 +54,11 @@ u64 _paravirt_ident_64(u64 x)
 	return x;
 }
 
+unsigned long _paravirt_ret_0(void)
+{
+	return 0;
+}
+
 void __init default_banner(void)
 {
 	printk(KERN_INFO "Booting paravirtualized kernel on %s\n",
@@ -154,6 +159,8 @@ unsigned paravirt_patch_default(u8 type, u16 clobbers, void *insnbuf,
 		ret = paravirt_patch_ident_32(insnbuf, len);
 	else if (opfunc == _paravirt_ident_64)
 		ret = paravirt_patch_ident_64(insnbuf, len);
+	else if (opfunc == _paravirt_ret_0)
+		ret = paravirt_patch_ret_0(insnbuf, len);
 
 	else if (type == PARAVIRT_PATCH(pv_cpu_ops.iret) ||
 		 type == PARAVIRT_PATCH(pv_cpu_ops.irq_enable_sysexit) ||
@@ -380,6 +387,7 @@ struct pv_cpu_ops pv_cpu_ops = {
 
 	.start_context_switch = paravirt_nop,
 	.end_context_switch = paravirt_nop,
+	.handle_pf = paravirt_ret_0,
 };
 
 struct pv_apic_ops pv_apic_ops = {
diff --git a/arch/x86/kernel/paravirt_patch_32.c b/arch/x86/kernel/paravirt_patch_32.c
index d9f32e6..de006b1 100644
--- a/arch/x86/kernel/paravirt_patch_32.c
+++ b/arch/x86/kernel/paravirt_patch_32.c
@@ -12,6 +12,8 @@ DEF_NATIVE(pv_mmu_ops, read_cr3, "mov %cr3, %eax");
 DEF_NATIVE(pv_cpu_ops, clts, "clts");
 DEF_NATIVE(pv_cpu_ops, read_tsc, "rdtsc");
 
+DEF_NATIVE(, mov0, "xor %eax, %eax");
+
 unsigned paravirt_patch_ident_32(void *insnbuf, unsigned len)
 {
 	/* arg in %eax, return in %eax */
@@ -24,6 +26,12 @@ unsigned paravirt_patch_ident_64(void *insnbuf, unsigned len)
 	return 0;
 }
 
+unsigned paravirt_patch_ret_0(void *insnbuf, unsigned len)
+{
+	return paravirt_patch_insns(insnbuf, len,
+				    start__mov0, end__mov0);
+}
+
 unsigned native_patch(u8 type, u16 clobbers, void *ibuf,
 		      unsigned long addr, unsigned len)
 {
diff --git a/arch/x86/kernel/paravirt_patch_64.c b/arch/x86/kernel/paravirt_patch_64.c
index 3f08f34..d685e7d 100644
--- a/arch/x86/kernel/paravirt_patch_64.c
+++ b/arch/x86/kernel/paravirt_patch_64.c
@@ -21,6 +21,7 @@ DEF_NATIVE(pv_cpu_ops, swapgs, "swapgs");
 
 DEF_NATIVE(, mov32, "mov %edi, %eax");
 DEF_NATIVE(, mov64, "mov %rdi, %rax");
+DEF_NATIVE(, mov0, "xor %rax, %rax");
 
 unsigned paravirt_patch_ident_32(void *insnbuf, unsigned len)
 {
@@ -34,6 +35,12 @@ unsigned paravirt_patch_ident_64(void *insnbuf, unsigned len)
 				    start__mov64, end__mov64);
 }
 
+unsigned paravirt_patch_ret_0(void *insnbuf, unsigned len)
+{
+	return paravirt_patch_insns(insnbuf, len,
+				    start__mov0, end__mov0);
+}
+
 unsigned native_patch(u8 type, u16 clobbers, void *ibuf,
 		      unsigned long addr, unsigned len)
 {
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index f4cee90..14707dc 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -952,6 +952,9 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	int write;
 	int fault;
 
+	if (arch_handle_page_fault(regs, error_code))
+		return;
+
 	tsk = current;
 	mm = tsk->mm;
 
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
