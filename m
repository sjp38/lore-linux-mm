Message-Id: <20070510101129.908781235@chello.nl>
References: <20070510100839.621199408@chello.nl>
Date: Thu, 10 May 2007 12:08:54 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 15/15] mm: dirty balancing for tasks
Content-Disposition: inline; filename=dirty_pages2.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

Based on ideas of Andrew:
  http://marc.info/?l=linux-kernel&m=102912915020543&w=2

Scale the bdi dirty limit inversly with the tasks dirty rate.
This makes heavy writers have a lower dirty limit than the occasional writer. 

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/sched.h |    2 +
 kernel/exit.c         |    1 
 kernel/fork.c         |    1 
 mm/page-writeback.c   |   60 +++++++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 63 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h	2007-05-10 11:06:12.000000000 +0200
+++ linux-2.6/include/linux/sched.h	2007-05-10 11:48:20.000000000 +0200
@@ -83,6 +83,7 @@ struct sched_param {
 #include <linux/timer.h>
 #include <linux/hrtimer.h>
 #include <linux/task_io_accounting.h>
+#include <linux/proportions.h>
 
 #include <asm/processor.h>
 
@@ -1092,6 +1093,7 @@ struct task_struct {
 #ifdef CONFIG_FAULT_INJECTION
 	int make_it_fail;
 #endif
+	struct prop_local dirties;
 };
 
 static inline pid_t process_group(struct task_struct *tsk)
Index: linux-2.6/kernel/exit.c
===================================================================
--- linux-2.6.orig/kernel/exit.c	2007-05-10 11:06:12.000000000 +0200
+++ linux-2.6/kernel/exit.c	2007-05-10 11:48:20.000000000 +0200
@@ -160,6 +160,7 @@ repeat:
 	ptrace_unlink(p);
 	BUG_ON(!list_empty(&p->ptrace_list) || !list_empty(&p->ptrace_children));
 	__exit_signal(p);
+	prop_local_destroy(&p->dirties);
 
 	/*
 	 * If we are the last non-leader member of the thread
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2007-05-10 11:06:12.000000000 +0200
+++ linux-2.6/kernel/fork.c	2007-05-10 11:48:20.000000000 +0200
@@ -191,6 +191,7 @@ static struct task_struct *dup_task_stru
 	tsk->btrace_seq = 0;
 #endif
 	tsk->splice_pipe = NULL;
+	prop_local_init(&tsk->dirties);
 	return tsk;
 }
 
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2007-05-10 11:06:12.000000000 +0200
+++ linux-2.6/mm/page-writeback.c	2007-05-10 11:54:56.000000000 +0200
@@ -118,6 +118,7 @@ static void background_writeout(unsigned
  *
  */
 struct prop_descriptor vm_completions;
+struct prop_descriptor vm_dirties;
 
 static unsigned long determine_dirtyable_memory(void);
 
@@ -146,6 +147,7 @@ int dirty_ratio_handler(ctl_table *table
 	if (ret == 0 && write && vm_dirty_ratio != old_ratio) {
 		int shift = calc_period_shift();
 		prop_change_shift(&vm_completions, shift);
+		prop_change_shift(&vm_dirties, shift);
 	}
 	return ret;
 }
@@ -161,6 +163,16 @@ static void __bdi_writeout_inc(struct ba
 	prop_put_global(&vm_completions, pg);
 }
 
+static void task_dirty_inc(struct task_struct *tsk)
+{
+	unsigned long flags;
+	struct prop_global *pg = prop_get_global(&vm_dirties);
+	local_irq_save(flags);
+	__prop_inc(pg, &tsk->dirties);
+	local_irq_restore(flags);
+	prop_put_global(&vm_dirties, pg);
+}
+
 /*
  * Obtain an accurate fraction of the BDI's portion.
  */
@@ -177,6 +189,14 @@ void bdi_writeout_fraction(struct backin
 	}
 }
 
+void task_dirties_fraction(struct task_struct *tsk,
+		long *numerator, long *denominator)
+{
+	struct prop_global *pg = prop_get_global(&vm_dirties);
+	prop_fraction(pg, &tsk->dirties, numerator, denominator);
+	prop_put_global(&vm_dirties, pg);
+}
+
 /*
  * Work out the current dirty-memory clamping and background writeout
  * thresholds.
@@ -310,6 +330,33 @@ clip_bdi_dirty_limit(struct backing_dev_
 }
 
 /*
+ * scale the dirty limit
+ *
+ * task specific dirty limit:
+ *
+ *   dirty -= (dirty/2) * p_{t}
+ */
+void task_dirty_limit(struct task_struct *tsk, long *pdirty)
+{
+	long numerator, denominator;
+	long dirty = *pdirty;
+	long long inv = dirty >> 1;
+
+	task_dirties_fraction(tsk, &numerator, &denominator);
+	inv *= numerator;
+	do_div(inv, denominator);
+
+	dirty -= inv;
+	if (dirty < *pdirty/2) {
+		printk("odd limit: %ld %ld %ld\n",
+				*pdirty, dirty, (long)inv);
+		dirty = *pdirty/2;
+	}
+
+	*pdirty = dirty;
+}
+
+/*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
  * the caller to perform writeback if the system is over `vm_dirty_ratio'.
@@ -340,6 +387,7 @@ static void balance_dirty_pages(struct a
 		get_dirty_limits(&background_thresh, &dirty_thresh,
 				&bdi_thresh, bdi);
 		clip_bdi_dirty_limit(bdi, dirty_thresh, &bdi_thresh);
+		task_dirty_limit(current, &bdi_thresh);
 		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
 		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
@@ -360,6 +408,7 @@ static void balance_dirty_pages(struct a
 			get_dirty_limits(&background_thresh, &dirty_thresh,
 				       &bdi_thresh, bdi);
 			clip_bdi_dirty_limit(bdi, dirty_thresh, &bdi_thresh);
+			task_dirty_limit(current, &bdi_thresh);
 
 			/*
 			 * In order to avoid the stacked BDI deadlock we need
@@ -732,6 +781,7 @@ void __init page_writeback_init(void)
 
 	shift = calc_period_shift();
 	prop_descriptor_init(&vm_completions, shift);
+	prop_descriptor_init(&vm_dirties, shift);
 }
 
 /**
@@ -1009,7 +1059,7 @@ EXPORT_SYMBOL(redirty_page_for_writepage
  * If the mapping doesn't provide a set_page_dirty a_op, then
  * just fall through and assume that it wants buffer_heads.
  */
-int fastcall set_page_dirty(struct page *page)
+static int __set_page_dirty(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 
@@ -1027,6 +1077,14 @@ int fastcall set_page_dirty(struct page 
 	}
 	return 0;
 }
+
+int fastcall set_page_dirty(struct page *page)
+{
+	int ret = __set_page_dirty(page);
+	if (ret)
+		task_dirty_inc(current);
+	return ret;
+}
 EXPORT_SYMBOL(set_page_dirty);
 
 /*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
