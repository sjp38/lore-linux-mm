Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 093489000C9
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 08:20:15 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id p8KCKBgC000318
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:50:11 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KCIn9P1519690
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:48:49 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KCImx9005066
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:48:49 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 20 Sep 2011 17:35:17 +0530
Message-Id: <20110920120517.25326.57657.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v5 3.1.0-rc4-tip 26/26]   uprobes: queue signals while thread is singlestepping.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>


- Queue signals delivered from the time we singlestep till
  completion of postprocessing. The queueing is done on a
  per-task basis.
- After singlestep completion, dequeue the signals.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |    3 ++-
 kernel/signal.c         |   22 +++++++++++++++++++++-
 kernel/uprobes.c        |   22 ++++++++++++++++------
 3 files changed, 39 insertions(+), 8 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index a407d17..189cdce 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -24,7 +24,7 @@
  */
 
 #include <linux/rbtree.h>
-
+#include <linux/signal.h>	/* sigpending */
 struct vm_area_struct;
 #ifdef CONFIG_ARCH_SUPPORTS_UPROBES
 #include <asm/uprobes.h>
@@ -90,6 +90,7 @@ struct uprobe_task {
 	struct uprobe_task_arch_info tskinfo;
 
 	struct uprobe *active_uprobe;
+	struct sigpending delayed;
 };
 
 /*
diff --git a/kernel/signal.c b/kernel/signal.c
index 291c970..48b8c7c 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1034,6 +1034,11 @@ static int __send_signal(int sig, struct siginfo *info, struct task_struct *t,
 		return 0;
 
 	pending = group ? &t->signal->shared_pending : &t->pending;
+#ifdef CONFIG_UPROBES
+	if (!group && t->utask && t->utask->active_uprobe)
+		pending = &t->utask->delayed;
+#endif
+
 	/*
 	 * Short-circuit ignored signals and support queuing
 	 * exactly one non-rt signal, so that we can get more
@@ -1106,6 +1111,11 @@ static int __send_signal(int sig, struct siginfo *info, struct task_struct *t,
 		}
 	}
 
+#ifdef CONFIG_UPROBES
+	if (!group && t->utask && t->utask->active_uprobe)
+		return 0;
+#endif
+
 out_set:
 	signalfd_notify(t, sig);
 	sigaddset(&pending->signal, sig);
@@ -1569,6 +1579,13 @@ int send_sigqueue(struct sigqueue *q, struct task_struct *t, int group)
 	}
 	q->info.si_overrun = 0;
 
+#ifdef CONFIG_UPROBES
+	if (!group && t->utask && t->utask->active_uprobe) {
+		pending = &t->utask->delayed;
+		list_add_tail(&q->list, &pending->list);
+		goto out;
+	}
+#endif
 	signalfd_notify(t, sig);
 	pending = group ? &t->signal->shared_pending : &t->pending;
 	list_add_tail(&q->list, &pending->list);
@@ -2199,7 +2216,10 @@ int get_signal_to_deliver(siginfo_t *info, struct k_sigaction *return_ka,
 			spin_unlock_irq(&sighand->siglock);
 			goto relock;
 		}
-
+#ifdef CONFIG_UPROBES
+		if (current->utask && current->utask->active_uprobe)
+			break;
+#endif
 		signr = dequeue_signal(current, &current->blocked, info);
 
 		if (!signr)
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index ca1f622..d065fa7 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1298,11 +1298,14 @@ void free_uprobe_utask(struct task_struct *tsk)
 static struct uprobe_task *add_utask(void)
 {
 	struct uprobe_task *utask;
+	struct sigpending *delayed;
 
 	utask = kzalloc(sizeof *utask, GFP_KERNEL);
 	if (unlikely(utask == NULL))
 		return ERR_PTR(-ENOMEM);
 
+	delayed = &utask->delayed;
+	INIT_LIST_HEAD(&delayed->list);
 	utask->active_uprobe = NULL;
 	current->utask = utask;
 	return utask;
@@ -1337,6 +1340,16 @@ static bool sstep_complete(struct uprobe *uprobe, struct pt_regs *regs)
 	return true;
 }
 
+static void pushback_signals(struct sigpending *pending)
+{
+	struct sigqueue *q, *tmpq;
+
+	list_for_each_entry_safe(q, tmpq, &pending->list, list) {
+		list_del(&q->list);
+		send_sigqueue(q, current, 0);
+	}
+}
+
 /*
  * uprobe_notify_resume gets called in task context just before returning
  * to userspace.
@@ -1373,7 +1386,6 @@ void uprobe_notify_resume(struct pt_regs *regs)
 			if (!utask)
 				goto cleanup_ret;
 		}
-		/* TODO Start queueing signals. */
 		utask->active_uprobe = u;
 		handler_chain(u, regs);
 		utask->state = UTASK_SSTEP;
@@ -1390,8 +1402,7 @@ void uprobe_notify_resume(struct pt_regs *regs)
 			utask->state = UTASK_RUNNING;
 			user_disable_single_step(current);
 			xol_free_insn_slot(current);
-
-			/* TODO Stop queueing signals. */
+			pushback_signals(&current->utask->delayed);
 		}
 	}
 	return;
@@ -1404,9 +1415,8 @@ void uprobe_notify_resume(struct pt_regs *regs)
 	if (u) {
 		put_uprobe(u);
 		set_instruction_pointer(regs, probept);
-	} else {
-		/*TODO Return SIGTRAP signal */
-	}
+	} else
+		send_sig(SIGTRAP, current, 0);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
