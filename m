Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2EE2C6B0092
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 09:09:49 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v2 11/12] Handle async PF in non preemptable context.
Date: Mon, 23 Nov 2009 16:06:06 +0200
Message-Id: <1258985167-29178-12-git-send-email-gleb@redhat.com>
In-Reply-To: <1258985167-29178-1-git-send-email-gleb@redhat.com>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

If async page fault is received by idle task or when preemp_count is
not zero guest cannot reschedule, so do sti; hlt and wait for page to be
ready. vcpu can still process interrupts while it waits for the page to
be ready.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/kernel/kvm.c |   31 +++++++++++++++++++++++++++----
 1 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index 09444c9..0836d9a 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -63,6 +63,7 @@ struct kvm_task_sleep_node {
 	struct hlist_node link;
 	wait_queue_head_t wq;
 	u32 token;
+	int cpu;
 };
 
 static struct kvm_task_sleep_head {
@@ -91,6 +92,11 @@ static void apf_task_wait(struct task_struct *tsk, u32 token)
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
@@ -105,15 +111,30 @@ static void apf_task_wait(struct task_struct *tsk, u32 token)
 	n.token = token;
 	init_waitqueue_head(&n.wq);
 	hlist_add_head(&n.link, &b->list);
+	if (idle || preempt_count() > 1)
+		n.cpu = smp_processor_id();
+	else
+		n.cpu = -1;
 	spin_unlock(&b->lock);
 
 	for (;;) {
-		prepare_to_wait(&n.wq, &wait, TASK_UNINTERRUPTIBLE);
+		if (n.cpu < 0)
+			prepare_to_wait(&n.wq, &wait, TASK_UNINTERRUPTIBLE);
 		if (hlist_unhashed(&n.link))
 			break;
-		schedule();
+
+		if (n.cpu < 0) {
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
+	if (n.cpu < 0)
+		finish_wait(&n.wq, &wait);
 
 	return;
 }
@@ -146,7 +167,9 @@ again:
 		hlist_add_head(&n->link, &b->list);
 	} else {
 		hlist_del_init(&n->link);
-		if (waitqueue_active(&n->wq))
+		if (n->cpu >= 0)
+			smp_send_reschedule(n->cpu);
+		else if (waitqueue_active(&n->wq))
 			wake_up(&n->wq);
 	}
 	spin_unlock(&b->lock);
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
