Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DD2106007E1
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 09:13:35 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v3 04/12] Add "handle page fault" PV helper.
Date: Tue,  5 Jan 2010 16:12:46 +0200
Message-Id: <1262700774-1808-5-git-send-email-gleb@redhat.com>
In-Reply-To: <1262700774-1808-1-git-send-email-gleb@redhat.com>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Allow paravirtualized guest to do special handling for some page faults.

The patch adds one 'if' to do_page_fault() function. The call is patched
out when running on physical HW. I ran kernbech on the kernel with and
without that additional 'if' and result were rawly the same:

With 'if':                            Without 'if':
Average Half load -j 8 Run (std deviation):
Elapsed Time 338.122 (0.869207)       Elapsed Time 336.404 (1.69196)
User Time 2025.49 (4.11097)           User Time 2028.17 (1.34199)
System Time 218.098 (0.826632)        System Time 219.022 (0.978581)
Percent CPU 663 (2.12132)             Percent CPU 667.4 (3.20936)
Context Switches 140903 (2655.99)     Context Switches 138476 (3408.49)
Sleeps 836103 (1594.93)               Sleeps 836048 (2597.78)

Average Optimal load -j 16 Run (std deviation):
Elapsed Time 255.32 (1.28328)         Elapsed Time 255.144 (1.09674)
User Time 2342.93 (334.625)           User Time 2343.7 (332.612)
System Time 248.722 (32.2921)         System Time 250.06 (32.7329)
Percent CPU 906.9 (257.13)            Percent CPU 909.6 (255.326)
Context Switches 294395 (161817)      Context Switches 293186 (163124)
Sleeps 890162 (57019.2)               Sleeps 890534 (57494.5)

Average Custom load -j 32 Run (std deviation):
Elapsed Time 236.318 (1.56739)        Elapsed Time 236.018 (1.32215)
User Time 2528.19 (381.49)            User Time 2530.75 (382.228)
System Time 264.739 (34.9425)         System Time 266.082 (35.1991)
Percent CPU 1055.2 (299.438)          Percent CPU 1058.6 (299.153)
Context Switches 445730 (256736)      Context Switches 446093 (259253)
Sleeps 939835 (85894.1)               Sleeps 939638 (85396.9)

This is how the 'if' affects generated assembly:

With 'if':                     Without 'if':
do_page_fault:                 do_page_fault:
 push   %rbp                    push   %rbp
 mov    %rsp,%rbp               mov    %rsp,%rbp
 push   %r15                    push   %r15
 push   %r14                    push   %r14
 push   %r13                    push   %r13
 push   %r12                    push   %r12
 push   %rbx                    push   %rbx
 sub    $0x28,%rsp              sub    $0x18,%rsp
 callq  ffffffff81002a80        callq  ffffffff81002a80
 mov    %rdi,%r14               mov    %gs:0xb540,%r15
 mov    %rsi,%r13               mov    0x270(%r15),%rax
 callq  *0xffffffff816ab308     mov    %rdi,%r14
 test   %eax,%eax               mov    %rsi,%r13
 jne    ffffffff813f10cb
 mov    %gs:0xb540,%r15
 mov    0x270(%r15),%rax

And this is how the code looks like at runtime after patching:

Running on kvm:                   Running on phys HW:
do_page_fault:                    do_page_fault:
 push   %rbp                       push   %rbp
 mov    %rsp,%rbp                  mov    %rsp,%rbp
 push   %r15                       push   %r15
 push   %r14                       push   %r14
 push   %r13                       push   %r13
 push   %r12                       push   %r12
 push   %rbx                       push   %rbx
 sub    $0x28,%rsp                 sub    $0x28,%rsp
 callq  0xffffffff81002a80         callq  0xffffffff81002a80
 mov    %rdi,%r14                  mov    %rdi,%r14
 mov    %rsi,%r13                  mov    %rsi,%r13
 callq  0xffffffff8102417e         xor    %rax,%rax
 xchg   %ax,%ax                    nopl   0x0(%rax)
 test   %eax,%eax                  test   %eax,%eax
 jne    0xffffffff813f10cb         jne    0xffffffff813f10cb
 mov    %gs:0xb540,%r15            mov    %gs:0xb540,%r15

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_para.h       |    3 +
 arch/x86/include/asm/paravirt.h       |   11 ++-
 arch/x86/include/asm/paravirt_types.h |    4 +
 arch/x86/kernel/kvm.c                 |  162 +++++++++++++++++++++++++++++++++
 arch/x86/kernel/paravirt.c            |    8 ++
 arch/x86/kernel/paravirt_patch_32.c   |    8 ++
 arch/x86/kernel/paravirt_patch_64.c   |    7 ++
 arch/x86/mm/fault.c                   |    3 +
 8 files changed, 204 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index 56ca41b..98edaa9 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -51,6 +51,9 @@ struct kvm_mmu_op_release_pt {
 	__u64 pt_phys;
 };
 
+#define KVM_PV_REASON_PAGE_NOT_PRESENT 1
+#define KVM_PV_REASON_PAGE_READY 2
+
 struct kvm_vcpu_pv_apf_data {
 	__u32 reason;
 	__u32 enabled;
diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index dd59a85..0c3e95b 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -6,6 +6,7 @@
 #ifdef CONFIG_PARAVIRT
 #include <asm/pgtable_types.h>
 #include <asm/asm.h>
+#include <asm/ptrace.h>
 
 #include <asm/paravirt_types.h>
 
@@ -699,15 +700,21 @@ static inline void pmd_clear(pmd_t *pmdp)
 }
 #endif	/* CONFIG_X86_PAE */
 
+static inline void arch_end_context_switch(struct task_struct *next)
+{
+	PVOP_VCALL1(pv_cpu_ops.end_context_switch, next);
+}
+
 #define  __HAVE_ARCH_START_CONTEXT_SWITCH
 static inline void arch_start_context_switch(struct task_struct *prev)
 {
 	PVOP_VCALL1(pv_cpu_ops.start_context_switch, prev);
 }
 
-static inline void arch_end_context_switch(struct task_struct *next)
+static inline int handle_page_fault(struct pt_regs *regs,
+				    unsigned long error_code)
 {
-	PVOP_VCALL1(pv_cpu_ops.end_context_switch, next);
+	return PVOP_CALL2(int, pv_cpu_ops.handle_pf, regs, error_code);
 }
 
 #define  __HAVE_ARCH_ENTER_LAZY_MMU_MODE
diff --git a/arch/x86/include/asm/paravirt_types.h b/arch/x86/include/asm/paravirt_types.h
index b1e70d5..1aec9b5 100644
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
diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index 001222c..2245f35 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -29,6 +29,8 @@
 #include <linux/hardirq.h>
 #include <linux/notifier.h>
 #include <linux/reboot.h>
+#include <linux/hash.h>
+#include <linux/sched.h>
 #include <asm/timer.h>
 #include <asm/cpu.h>
 
@@ -54,6 +56,159 @@ static void kvm_io_delay(void)
 {
 }
 
+#define KVM_TASK_SLEEP_HASHBITS 8
+#define KVM_TASK_SLEEP_HASHSIZE (1<<KVM_TASK_SLEEP_HASHBITS)
+
+struct kvm_task_sleep_node {
+	struct hlist_node link;
+	wait_queue_head_t wq;
+	u32 token;
+	int cpu;
+};
+
+static struct kvm_task_sleep_head {
+	spinlock_t lock;
+	struct hlist_head list;
+} async_pf_sleepers[KVM_TASK_SLEEP_HASHSIZE];
+
+static struct kvm_task_sleep_node *_find_apf_task(struct kvm_task_sleep_head *b,
+						  u64 token)
+{
+	struct hlist_node *p;
+
+	hlist_for_each(p, &b->list) {
+		struct kvm_task_sleep_node *n =
+			hlist_entry(p, typeof(*n), link);
+		if (n->token == token)
+			return n;
+	}
+
+	return NULL;
+}
+
+static void apf_task_wait(struct task_struct *tsk, u32 token)
+{
+	u32 key = hash_32(token, KVM_TASK_SLEEP_HASHBITS);
+	struct kvm_task_sleep_head *b = &async_pf_sleepers[key];
+	struct kvm_task_sleep_node n, *e;
+	DEFINE_WAIT(wait);
+
+	spin_lock(&b->lock);
+	e = _find_apf_task(b, token);
+	if (e) {
+		/* dummy entry exist -> wake up was delivered ahead of PF */
+		hlist_del(&e->link);
+		kfree(e);
+		spin_unlock(&b->lock);
+		return;
+	}
+
+	n.token = token;
+	n.cpu = smp_processor_id();
+	init_waitqueue_head(&n.wq);
+	hlist_add_head(&n.link, &b->list);
+	spin_unlock(&b->lock);
+
+	for (;;) {
+		prepare_to_wait(&n.wq, &wait, TASK_UNINTERRUPTIBLE);
+		if (hlist_unhashed(&n.link))
+			break;
+		schedule();
+	}
+	finish_wait(&n.wq, &wait);
+
+	return;
+}
+
+static void apf_task_wake_one(struct kvm_task_sleep_node *n)
+{
+	hlist_del_init(&n->link);
+	if (waitqueue_active(&n->wq))
+		wake_up(&n->wq);
+}
+
+static void apf_task_wake(u32 token)
+{
+	u32 key = hash_32(token, KVM_TASK_SLEEP_HASHBITS);
+	struct kvm_task_sleep_head *b = &async_pf_sleepers[key];
+	struct kvm_task_sleep_node *n;
+
+again:
+	spin_lock(&b->lock);
+	n = _find_apf_task(b, token);
+	if (!n) {
+		/*
+		 * async PF was not yet handled.
+		 * Add dummy entry for the token.
+		 */
+		n = kmalloc(sizeof(*n), GFP_ATOMIC);
+		if (!n) {
+			/*
+			 * Allocation failed! Busy wait while other vcpu
+			 * handles async PF.
+			 */
+			spin_unlock(&b->lock);
+			cpu_relax();
+			goto again;
+		}
+		n->token = token;
+		n->cpu = smp_processor_id();
+		init_waitqueue_head(&n->wq);
+		hlist_add_head(&n->link, &b->list);
+	} else
+		apf_task_wake_one(n);
+	spin_unlock(&b->lock);
+	return;
+}
+
+static void apf_task_wake_all(void)
+{
+	int i;
+
+	for (i = 0; i < KVM_TASK_SLEEP_HASHSIZE; i++) {
+		struct hlist_node *p, *next;
+		struct kvm_task_sleep_head *b = &async_pf_sleepers[i];
+		spin_lock(&b->lock);
+		hlist_for_each_safe(p, next, &b->list) {
+			struct kvm_task_sleep_node *n =
+				hlist_entry(p, typeof(*n), link);
+			if (n->cpu == smp_processor_id())
+				apf_task_wake_one(n);
+		}
+		spin_unlock(&b->lock);
+	}
+}
+
+int kvm_handle_pf(struct pt_regs *regs, unsigned long error_code)
+{
+	u32 reason, token;
+
+	if (!__get_cpu_var(apf_reason).enabled)
+		return 0;
+
+	reason = __get_cpu_var(apf_reason).reason;
+	__get_cpu_var(apf_reason).reason = 0;
+
+	token = (u32)read_cr2();
+
+	switch (reason) {
+	default:
+		return 0;
+	case KVM_PV_REASON_PAGE_NOT_PRESENT:
+		/* page is swapped out by the host. */
+		apf_task_wait(current, token);
+		break;
+	case KVM_PV_REASON_PAGE_READY:
+		if (unlikely(token == ~0))
+			apf_task_wake_all();
+		else
+			apf_task_wake(token);
+		break;
+	}
+
+	return 1;
+}
+
 static void kvm_mmu_op(void *buffer, unsigned len)
 {
 	int r;
@@ -207,6 +362,9 @@ static void __init paravirt_ops_setup(void)
 	if (kvm_para_has_feature(KVM_FEATURE_NOP_IO_DELAY))
 		pv_cpu_ops.io_delay = kvm_io_delay;
 
+	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF))
+		pv_cpu_ops.handle_pf = kvm_handle_pf;
+
 	if (kvm_para_has_feature(KVM_FEATURE_MMU_OP)) {
 		pv_mmu_ops.set_pte = kvm_set_pte;
 		pv_mmu_ops.set_pte_at = kvm_set_pte_at;
@@ -270,11 +428,15 @@ static void __init kvm_smp_prepare_boot_cpu(void)
 
 void __init kvm_guest_init(void)
 {
+	int i;
+
 	if (!kvm_para_available())
 		return;
 
 	paravirt_ops_setup();
 	register_reboot_notifier(&kvm_pv_reboot_nb);
+	for (i = 0; i < KVM_TASK_SLEEP_HASHSIZE; i++)
+		spin_lock_init(&async_pf_sleepers[i].lock);
 #ifdef CONFIG_SMP
 	smp_ops.smp_prepare_boot_cpu = kvm_smp_prepare_boot_cpu;
 #else
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
index f627779..7abc3ee 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -953,6 +953,9 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	int write;
 	int fault;
 
+	if (handle_page_fault(regs, error_code))
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
