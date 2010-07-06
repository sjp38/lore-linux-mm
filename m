Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1AD976B024D
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 12:25:15 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v4 10/12] Handle async PF in non preemptable context
Date: Tue,  6 Jul 2010 19:24:58 +0300
Message-Id: <1278433500-29884-11-git-send-email-gleb@redhat.com>
In-Reply-To: <1278433500-29884-1-git-send-email-gleb@redhat.com>
References: <1278433500-29884-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

If async page fault is received by idle task or when preemp_count is
not zero guest cannot reschedule, so do sti; hlt and wait for page to be
ready. vcpu can still process interrupts while it waits for the page to
be ready.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/kernel/kvm.c |   36 ++++++++++++++++++++++++++++++++----
 1 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index fa9f520..f4d87b3 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -37,6 +37,7 @@
 #include <asm/cpu.h>
 #include <asm/traps.h>
 #include <asm/desc.h>
+#include <asm/tlbflush.h>
 
 #define MMU_QUEUE_SIZE 1024
 
@@ -68,6 +69,8 @@ struct kvm_task_sleep_node {
 	wait_queue_head_t wq;
 	u32 token;
 	int cpu;
+	bool halted;
+	struct mm_struct *mm;
 };
 
 static struct kvm_task_sleep_head {
@@ -96,6 +99,11 @@ static void apf_task_wait(struct task_struct *tsk, u32 token)
 	struct kvm_task_sleep_head *b = &async_pf_sleepers[key];
 	struct kvm_task_sleep_node n, *e;
 	DEFINE_WAIT(wait);
+	int cpu, idle;
+
+	cpu = get_cpu();
+	idle = idle_cpu(cpu);
+	put_cpu();
 
 	spin_lock(&b->lock);
 	e = _find_apf_task(b, token);
@@ -109,17 +117,31 @@ static void apf_task_wait(struct task_struct *tsk, u32 token)
 
 	n.token = token;
 	n.cpu = smp_processor_id();
+	n.mm = percpu_read(cpu_tlbstate.active_mm);
+	n.halted = idle || preempt_count() > 1;
+	atomic_inc(&n.mm->mm_count);
 	init_waitqueue_head(&n.wq);
 	hlist_add_head(&n.link, &b->list);
 	spin_unlock(&b->lock);
 
 	for (;;) {
-		prepare_to_wait(&n.wq, &wait, TASK_UNINTERRUPTIBLE);
+		if (!n.halted)
+			prepare_to_wait(&n.wq, &wait, TASK_UNINTERRUPTIBLE);
 		if (hlist_unhashed(&n.link))
 			break;
-		schedule();
+
+		if (!n.halted) {
+			schedule();
+		} else {
+			/*
+			 * We cannot reschedule. So halt.
+			 */
+			native_safe_halt();
+			local_irq_disable();
+		}
 	}
-	finish_wait(&n.wq, &wait);
+	if (!n.halted)
+		finish_wait(&n.wq, &wait);
 
 	return;
 }
@@ -127,7 +149,12 @@ static void apf_task_wait(struct task_struct *tsk, u32 token)
 static void apf_task_wake_one(struct kvm_task_sleep_node *n)
 {
 	hlist_del_init(&n->link);
-	if (waitqueue_active(&n->wq))
+	if (!n->mm)
+		return;
+	mmdrop(n->mm);
+	if (n->halted)
+		smp_send_reschedule(n->cpu);
+	else if (waitqueue_active(&n->wq))
 		wake_up(&n->wq);
 }
 
@@ -157,6 +184,7 @@ again:
 		}
 		n->token = token;
 		n->cpu = smp_processor_id();
+		n->mm = NULL;
 		init_waitqueue_head(&n->wq);
 		hlist_add_head(&n->link, &b->list);
 	} else
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
