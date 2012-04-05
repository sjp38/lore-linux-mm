Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id A0C976B00EB
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 18:22:51 -0400 (EDT)
Date: Fri, 6 Apr 2012 00:22:21 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 6/6] uprobes: kill uprobes_srcu/uprobe_srcu_id
Message-ID: <20120405222221.GF19166@redhat.com>
References: <20120405222024.GA19154@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120405222024.GA19154@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

Kill the no longer needed uprobes_srcu/uprobe_srcu_id code.

It doesn't really work anyway. synchronize_srcu() can only synchronize
with the code "inside" the srcu_read_lock/srcu_read_unlock section,
while uprobe_pre_sstep_notifier() does srcu_read_lock() _after_ we
already hit the breakpoint.

I guess this probably works "in practice". synchronize_srcu() is slow
and it implies synchronize_sched(), and the probed task enters the non-
preemptible section at the start of exception handler. Still this is not
right at least in theory, and task->uprobe_srcu_id blows task_struct.
---
 include/linux/sched.h   |    1 -
 kernel/events/uprobes.c |   22 +++-------------------
 2 files changed, 3 insertions(+), 20 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8379e37..90a1f1d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1592,7 +1592,6 @@ struct task_struct {
 #endif
 #ifdef CONFIG_UPROBES
 	struct uprobe_task *utask;
-	int uprobe_srcu_id;
 #endif
 };
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index ed76ee5..221e670 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -38,7 +38,6 @@
 #define UINSNS_PER_PAGE			(PAGE_SIZE/UPROBE_XOL_SLOT_BYTES)
 #define MAX_UPROBE_XOL_SLOTS		UINSNS_PER_PAGE
 
-static struct srcu_struct uprobes_srcu;
 static struct rb_root uprobes_tree = RB_ROOT;
 
 static DEFINE_SPINLOCK(uprobes_treelock);	/* serialize rbtree access */
@@ -723,20 +722,14 @@ remove_breakpoint(struct uprobe *uprobe, struct mm_struct *mm, loff_t vaddr)
 }
 
 /*
- * There could be threads that have hit the breakpoint and are entering the
- * notifier code and trying to acquire the uprobes_treelock. The thread
- * calling delete_uprobe() that is removing the uprobe from the rb_tree can
- * race with these threads and might acquire the uprobes_treelock compared
- * to some of the breakpoint hit threads. In such a case, the breakpoint
- * hit threads will not find the uprobe. The current unregistering thread
- * waits till all other threads have hit a breakpoint, to acquire the
- * uprobes_treelock before the uprobe is removed from the rbtree.
+ * There could be threads that have already hit the breakpoint. They
+ * will recheck the current insn and restart if find_uprobe() fails.
+ * See find_active_uprobe().
  */
 static void delete_uprobe(struct uprobe *uprobe)
 {
 	unsigned long flags;
 
-	synchronize_srcu(&uprobes_srcu);
 	spin_lock_irqsave(&uprobes_treelock, flags);
 	rb_erase(&uprobe->rb_node, &uprobes_tree);
 	spin_unlock_irqrestore(&uprobes_treelock, flags);
@@ -1373,9 +1366,6 @@ void uprobe_free_utask(struct task_struct *t)
 {
 	struct uprobe_task *utask = t->utask;
 
-	if (t->uprobe_srcu_id != -1)
-		srcu_read_unlock_raw(&uprobes_srcu, t->uprobe_srcu_id);
-
 	if (!utask)
 		return;
 
@@ -1393,7 +1383,6 @@ void uprobe_free_utask(struct task_struct *t)
 void uprobe_copy_process(struct task_struct *t)
 {
 	t->utask = NULL;
-	t->uprobe_srcu_id = -1;
 }
 
 /*
@@ -1521,9 +1510,6 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
 	} else {
 		*is_swbp = -EFAULT;
 	}
-
-	srcu_read_unlock_raw(&uprobes_srcu, current->uprobe_srcu_id);
-	current->uprobe_srcu_id = -1;
 	up_read(&mm->mmap_sem);
 
 	return uprobe;
@@ -1664,7 +1650,6 @@ int uprobe_pre_sstep_notifier(struct pt_regs *regs)
 		utask->state = UTASK_BP_HIT;
 
 	set_thread_flag(TIF_UPROBE);
-	current->uprobe_srcu_id = srcu_read_lock_raw(&uprobes_srcu);
 
 	return 1;
 }
@@ -1699,7 +1684,6 @@ static int __init init_uprobes(void)
 		mutex_init(&uprobes_mutex[i]);
 		mutex_init(&uprobes_mmap_mutex[i]);
 	}
-	init_srcu_struct(&uprobes_srcu);
 
 	return register_die_notifier(&uprobe_exception_nb);
 }
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
