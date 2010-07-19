Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B2A60600805
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 11:31:24 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v5 04/12] Provide special async page fault handler when async PF capability is detected
Date: Mon, 19 Jul 2010 18:30:54 +0300
Message-Id: <1279553462-7036-5-git-send-email-gleb@redhat.com>
In-Reply-To: <1279553462-7036-1-git-send-email-gleb@redhat.com>
References: <1279553462-7036-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

When async PF capability is detected hook up special page fault handler
that will handle async page fault events and bypass other page faults to
regular page fault handler.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_para.h |    3 +
 arch/x86/include/asm/traps.h    |    1 +
 arch/x86/kernel/entry_32.S      |   10 +++
 arch/x86/kernel/entry_64.S      |    3 +
 arch/x86/kernel/kvm.c           |  170 +++++++++++++++++++++++++++++++++++++++
 5 files changed, 187 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index f1662d7..edf07cf 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -65,6 +65,9 @@ struct kvm_mmu_op_release_pt {
 	__u64 pt_phys;
 };
 
+#define KVM_PV_REASON_PAGE_NOT_PRESENT 1
+#define KVM_PV_REASON_PAGE_READY 2
+
 struct kvm_vcpu_pv_apf_data {
 	__u32 reason;
 	__u32 enabled;
diff --git a/arch/x86/include/asm/traps.h b/arch/x86/include/asm/traps.h
index f66cda5..0310da6 100644
--- a/arch/x86/include/asm/traps.h
+++ b/arch/x86/include/asm/traps.h
@@ -30,6 +30,7 @@ asmlinkage void segment_not_present(void);
 asmlinkage void stack_segment(void);
 asmlinkage void general_protection(void);
 asmlinkage void page_fault(void);
+asmlinkage void async_page_fault(void);
 asmlinkage void spurious_interrupt_bug(void);
 asmlinkage void coprocessor_error(void);
 asmlinkage void alignment_check(void);
diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
index cd49141..95e13da 100644
--- a/arch/x86/kernel/entry_32.S
+++ b/arch/x86/kernel/entry_32.S
@@ -1494,6 +1494,16 @@ ENTRY(general_protection)
 	CFI_ENDPROC
 END(general_protection)
 
+#ifdef CONFIG_KVM_GUEST
+ENTRY(async_page_fault)
+	RING0_EC_FRAME
+	pushl $do_async_page_fault
+	CFI_ADJUST_CFA_OFFSET 4
+	jmp error_code
+	CFI_ENDPROC
+END(apf_page_fault)
+#endif
+
 /*
  * End of kprobes section
  */
diff --git a/arch/x86/kernel/entry_64.S b/arch/x86/kernel/entry_64.S
index 0697ff1..65c3eb6 100644
--- a/arch/x86/kernel/entry_64.S
+++ b/arch/x86/kernel/entry_64.S
@@ -1346,6 +1346,9 @@ errorentry xen_stack_segment do_stack_segment
 #endif
 errorentry general_protection do_general_protection
 errorentry page_fault do_page_fault
+#ifdef CONFIG_KVM_GUEST
+errorentry async_page_fault do_async_page_fault
+#endif
 #ifdef CONFIG_X86_MCE
 paranoidzeroentry machine_check *machine_check_vector(%rip)
 #endif
diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index 5177dd1..a6db92e 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -29,8 +29,14 @@
 #include <linux/hardirq.h>
 #include <linux/notifier.h>
 #include <linux/reboot.h>
+#include <linux/hash.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/kprobes.h>
 #include <asm/timer.h>
 #include <asm/cpu.h>
+#include <asm/traps.h>
+#include <asm/desc.h>
 
 #define MMU_QUEUE_SIZE 1024
 
@@ -54,6 +60,158 @@ static void kvm_io_delay(void)
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
+dotraplinkage void __kprobes
+do_async_page_fault(struct pt_regs *regs, unsigned long error_code)
+{
+	u32 reason = 0, token;
+
+	if (__get_cpu_var(apf_reason).enabled) {
+		reason = __get_cpu_var(apf_reason).reason;
+		__get_cpu_var(apf_reason).reason = 0;
+
+		token = (u32)read_cr2();
+	}
+
+	switch (reason) {
+	default:
+		do_page_fault(regs, error_code);
+		break;
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
+}
+
 static void kvm_mmu_op(void *buffer, unsigned len)
 {
 	int r;
@@ -303,13 +461,25 @@ static struct notifier_block __cpuinitdata kvm_cpu_notifier = {
 };
 #endif
 
+static void __init kvm_apf_trap_init(void)
+{
+	set_intr_gate(14, &async_page_fault);
+}
+
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
+	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF))
+		x86_init.irqs.trap_init = kvm_apf_trap_init;
+
 #ifdef CONFIG_SMP
 	smp_ops.smp_prepare_boot_cpu = kvm_smp_prepare_boot_cpu;
 	register_cpu_notifier(&kvm_cpu_notifier);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
