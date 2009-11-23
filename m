Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3CCD76B0078
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 09:09:26 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v2 05/12] Handle asynchronous page fault in a PV guest.
Date: Mon, 23 Nov 2009 16:06:00 +0200
Message-Id: <1258985167-29178-6-git-send-email-gleb@redhat.com>
In-Reply-To: <1258985167-29178-1-git-send-email-gleb@redhat.com>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Asynchronous page fault notifies vcpu that page it is trying to access
is swapped out by a host. In response guest puts a task that caused the
fault to sleep until page is swapped in again. When missing page is
brought back into the memory guest is notified and task resumes execution.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_para.h |    3 +
 arch/x86/kernel/kvm.c           |  132 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 135 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index d7d7079..79bb7f2 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -49,6 +49,9 @@ struct kvm_mmu_op_release_pt {
 	__u64 pt_phys;
 };
 
+#define KVM_PV_REASON_PAGE_NOT_PRESENT 1
+#define KVM_PV_REASON_PAGE_READY 2
+
 struct kvm_vcpu_pv_apf_data {
 	__u32 reason;
 	__u32 enabled;
diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index fdd0b95..09444c9 100644
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
 
@@ -54,6 +56,130 @@ static void kvm_io_delay(void)
 {
 }
 
+#define KVM_TASK_SLEEP_HASHBITS 8
+#define KVM_TASK_SLEEP_HASHSIZE (1<<KVM_TASK_SLEEP_HASHBITS)
+
+struct kvm_task_sleep_node {
+	struct hlist_node link;
+	wait_queue_head_t wq;
+	u32 token;
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
+		hlist_add_head(&n->link, &b->list);
+	} else {
+		hlist_del_init(&n->link);
+		if (waitqueue_active(&n->wq))
+			wake_up(&n->wq);
+	}
+	spin_unlock(&b->lock);
+	return;
+}
+
+int kvm_handle_pf(struct pt_regs *regs, unsigned long error_code)
+{
+	u32 reason, token;
+
+	if (!per_cpu(apf_reason, smp_processor_id()).enabled)
+		return 0;
+
+	reason = per_cpu(apf_reason, smp_processor_id()).reason;
+	per_cpu(apf_reason, smp_processor_id()).reason = 0;
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
+		apf_task_wake(token);
+		break;
+	}
+
+	return 1;
+}
+
 static void kvm_mmu_op(void *buffer, unsigned len)
 {
 	int r;
@@ -207,6 +333,9 @@ static void __init paravirt_ops_setup(void)
 	if (kvm_para_has_feature(KVM_FEATURE_NOP_IO_DELAY))
 		pv_cpu_ops.io_delay = kvm_io_delay;
 
+	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF))
+		pv_cpu_ops.handle_pf = kvm_handle_pf;
+
 	if (kvm_para_has_feature(KVM_FEATURE_MMU_OP)) {
 		pv_mmu_ops.set_pte = kvm_set_pte;
 		pv_mmu_ops.set_pte_at = kvm_set_pte_at;
@@ -270,11 +399,14 @@ static void __init kvm_smp_prepare_boot_cpu(void)
 
 void __init kvm_guest_init(void)
 {
+	int i;
 	if (!kvm_para_available())
 		return;
 
 	paravirt_ops_setup();
 	register_reboot_notifier(&kvm_pv_reboot_nb);
+	for (i = 0; i < KVM_TASK_SLEEP_HASHSIZE; i++)
+		spin_lock_init(&async_pf_sleepers[i].lock);
 #ifdef CONFIG_SMP
 	smp_ops.smp_prepare_boot_cpu = kvm_smp_prepare_boot_cpu;
 #else
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
