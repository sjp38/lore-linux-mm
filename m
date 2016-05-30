Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 063536B025E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 11:00:02 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id q17so86734061lbn.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 08:00:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id au9si44919930wjc.47.2016.05.30.08.00.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 May 2016 08:00:00 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v7 01/10] kthread/smpboot: Do not park in kthread_create_on_cpu()
Date: Mon, 30 May 2016 16:59:22 +0200
Message-Id: <1464620371-31346-2-git-send-email-pmladek@suse.com>
In-Reply-To: <1464620371-31346-1-git-send-email-pmladek@suse.com>
References: <1464620371-31346-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

kthread_create_on_cpu() was added by the commit 2a1d446019f9a5983e
("kthread: Implement park/unpark facility"). It is currently used
only when enabling new CPU. For this purpose, the newly created
kthread has to be parked.

The CPU binding is a bit tricky. The kthread is parked when the CPU
has not been allowed yet. And the CPU is bound when the kthread
is unparked.

The function would be useful for more per-CPU kthreads, e.g.
bnx2fc_thread, fcoethread. For this purpose, the newly created
kthread should stay in the uninterruptible state.

This patch moves the parking into smpboot. It binds the thread
already when created. Then the function might be used universally.
Also the behavior is consistent with kthread_create() and
kthread_create_on_node().

Signed-off-by: Petr Mladek <pmladek@suse.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---
 kernel/kthread.c | 8 ++++++--
 kernel/smpboot.c | 5 +++++
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/kernel/kthread.c b/kernel/kthread.c
index 9ff173dca1ae..1ffc11ec5546 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -390,10 +390,10 @@ struct task_struct *kthread_create_on_cpu(int (*threadfn)(void *data),
 				   cpu);
 	if (IS_ERR(p))
 		return p;
+	kthread_bind(p, cpu);
+	/* CPU hotplug need to bind once again when unparking the thread. */
 	set_bit(KTHREAD_IS_PER_CPU, &to_kthread(p)->flags);
 	to_kthread(p)->cpu = cpu;
-	/* Park the thread to get it out of TASK_UNINTERRUPTIBLE state */
-	kthread_park(p);
 	return p;
 }
 
@@ -407,6 +407,10 @@ static void __kthread_unpark(struct task_struct *k, struct kthread *kthread)
 	 * which might be about to be cleared.
 	 */
 	if (test_and_clear_bit(KTHREAD_IS_PARKED, &kthread->flags)) {
+		/*
+		 * Newly created kthread was parked when the CPU was offline.
+		 * The binding was lost and we need to set it again.
+		 */
 		if (test_bit(KTHREAD_IS_PER_CPU, &kthread->flags))
 			__kthread_bind(k, kthread->cpu, TASK_PARKED);
 		wake_up_state(k, TASK_PARKED);
diff --git a/kernel/smpboot.c b/kernel/smpboot.c
index 13bc43d1fb22..4a5c6e73ecd4 100644
--- a/kernel/smpboot.c
+++ b/kernel/smpboot.c
@@ -186,6 +186,11 @@ __smpboot_create_thread(struct smp_hotplug_thread *ht, unsigned int cpu)
 		kfree(td);
 		return PTR_ERR(tsk);
 	}
+	/*
+	 * Park the thread so that it could start right on the CPU
+	 * when it is available.
+	 */
+	kthread_park(tsk);
 	get_task_struct(tsk);
 	*per_cpu_ptr(ht->store, cpu) = tsk;
 	if (ht->create) {
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
