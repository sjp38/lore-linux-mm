Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8749B6B006A
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 06:56:34 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH 03/11] Handle asynchronous page fault in a PV guest.
Date: Sun,  1 Nov 2009 13:56:22 +0200
Message-Id: <1257076590-29559-4-git-send-email-gleb@redhat.com>
In-Reply-To: <1257076590-29559-1-git-send-email-gleb@redhat.com>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Asynchronous page fault notifies vcpu that page it is trying to access
is swapped out by a host. In response guest puts a task that caused the
fault to sleep until page is swapped in again. When missing page is
brought back into the memory guest is notified and task resumes execution.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_para.h |    3 +
 arch/x86/kernel/kvm.c           |  120 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 120 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index 90708b7..61e2aa3 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -52,6 +52,9 @@ struct kvm_mmu_op_release_pt {
 
 #define KVM_PV_SHM_FEATURES_ASYNC_PF		(1 << 0)
 
+#define KVM_PV_REASON_PAGE_NP 1
+#define KVM_PV_REASON_PAGE_READY 2
+
 struct kvm_vcpu_pv_shm {
 	__u64 features;
 	__u64 reason;
diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index d03f33c..79d291f 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -30,6 +30,8 @@
 #include <linux/bootmem.h>
 #include <linux/notifier.h>
 #include <linux/reboot.h>
+#include <linux/hash.h>
+#include <linux/sched.h>
 #include <asm/timer.h>
 #include <asm/cpu.h>
 
@@ -55,15 +57,121 @@ static void kvm_io_delay(void)
 {
 }
 
-static void kvm_end_context_switch(struct task_struct *next)
+#define KVM_TASK_SLEEP_HASHBITS 8
+#define KVM_TASK_SLEEP_HASHSIZE (1<<KVM_TASK_SLEEP_HASHBITS)
+
+struct kvm_task_sleep_node {
+	struct hlist_node link;
+	wait_queue_head_t wq;
+	u64 token;
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
+static void apf_task_wait(struct task_struct *tsk, u64 token)
 {
+	u64 key = hash_64(token, KVM_TASK_SLEEP_HASHBITS);
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
+static void apf_task_wake(u64 token)
+{
+	u64 key = hash_64(token, KVM_TASK_SLEEP_HASHBITS);
+	struct kvm_task_sleep_head *b = &async_pf_sleepers[key];
+	struct kvm_task_sleep_node *n;
+
+	spin_lock(&b->lock);
+	n = _find_apf_task(b, token);
+	if (!n) {
+		/* PF was not yet handled. Add dummy entry for the token */
+		n = kmalloc(sizeof(*n), GFP_ATOMIC);
+		if (!n) {
+			printk(KERN_EMERG"async PF can't allocate memory\n");
+		} else {
+			n->token = token;
+			hlist_add_head(&n->link, &b->list);
+		}
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
+	u64 reason, token;
 	struct kvm_vcpu_pv_shm *pv_shm =
 		per_cpu(kvm_vcpu_pv_shm, smp_processor_id());
 
 	if (!pv_shm)
-		return;
+		return 0;
+
+	reason = pv_shm->reason;
+	pv_shm->reason = 0;
+
+	token = pv_shm->param;
+
+	switch (reason) {
+	default:
+		return 0;
+	case KVM_PV_REASON_PAGE_NP:
+		/* real page is missing. */
+		apf_task_wait(current, token);
+		break;
+	case KVM_PV_REASON_PAGE_READY:
+		apf_task_wake(token);
+		break;
+	}
 
-	pv_shm->current_task = (u64)next;
+	return 1;
 }
 
 static void kvm_mmu_op(void *buffer, unsigned len)
@@ -219,6 +327,9 @@ static void __init paravirt_ops_setup(void)
 	if (kvm_para_has_feature(KVM_FEATURE_NOP_IO_DELAY))
 		pv_cpu_ops.io_delay = kvm_io_delay;
 
+	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF))
+		pv_cpu_ops.handle_pf = kvm_handle_pf;
+
 	if (kvm_para_has_feature(KVM_FEATURE_MMU_OP)) {
 		pv_mmu_ops.set_pte = kvm_set_pte;
 		pv_mmu_ops.set_pte_at = kvm_set_pte_at;
@@ -272,11 +383,14 @@ static struct notifier_block kvm_pv_reboot_nb = {
 
 void __init kvm_guest_init(void)
 {
+	int i;
 	if (!kvm_para_available())
 		return;
 
 	paravirt_ops_setup();
 	register_reboot_notifier(&kvm_pv_reboot_nb);
+	for (i = 0; i < KVM_TASK_SLEEP_HASHSIZE; i++)
+		spin_lock_init(&async_pf_sleepers[i].lock);
 }
 
 void __cpuinit kvm_guest_cpu_init(void)
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
