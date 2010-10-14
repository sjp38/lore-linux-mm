From: y@redhat.com
Subject: [PATCH v7 10/12] Handle async PF in non preemptable context
Date: Thu, 14 Oct 2010 11:17:08 +0200
Message-ID: <3720.46990455619$1287047986@news.gmane.org>
References: <1287047830-2120-1-git-send-email-y>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1287047830-2120-1-git-send-email-y>
Sender: linux-kernel-owner@vger.kernel.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-Id: linux-mm.kvack.org

From: Gleb Natapov <gleb@redhat.com>

If async page fault is received by idle task or when preemp_count is
not zero guest cannot reschedule, so do sti; hlt and wait for page to be
ready. vcpu can still process interrupts while it waits for the page to
be ready.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/kernel/kvm.c |   40 ++++++++++++++++++++++++++++++++++------
 1 files changed, 34 insertions(+), 6 deletions(-)

diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index d564063..47ea93e 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -37,6 +37,7 @@
 #include <asm/cpu.h>
 #include <asm/traps.h>
 #include <asm/desc.h>
+#include <asm/tlbflush.h>
 
 #define MMU_QUEUE_SIZE 1024
 
@@ -78,6 +79,8 @@ struct kvm_task_sleep_node {
 	wait_queue_head_t wq;
 	u32 token;
 	int cpu;
+	bool halted;
+	struct mm_struct *mm;
 };
 
 static struct kvm_task_sleep_head {
@@ -106,6 +109,11 @@ void kvm_async_pf_task_wait(u32 token)
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
@@ -119,19 +127,33 @@ void kvm_async_pf_task_wait(u32 token)
 
 	n.token = token;
 	n.cpu = smp_processor_id();
+	n.mm = current->active_mm;
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
-		local_irq_enable();
-		schedule();
-		local_irq_disable();
+
+		if (!n.halted) {
+			local_irq_enable();
+			schedule();
+			local_irq_disable();
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
@@ -140,7 +162,12 @@ EXPORT_SYMBOL_GPL(kvm_async_pf_task_wait);
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
 
@@ -193,6 +220,7 @@ again:
 		}
 		n->token = token;
 		n->cpu = smp_processor_id();
+		n->mm = NULL;
 		init_waitqueue_head(&n->wq);
 		hlist_add_head(&n->link, &b->list);
 	} else
-- 
1.7.1
