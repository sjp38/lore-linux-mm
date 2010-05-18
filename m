Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 15A006004B1
	for <linux-mm@kvack.org>; Tue, 18 May 2010 10:30:55 -0400 (EDT)
Received: by wwa36 with SMTP id 36so3107221wwa.14
        for <linux-mm@kvack.org>; Tue, 18 May 2010 07:30:53 -0700 (PDT)
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH V3] Split executable and non-executable mmap tracking
Date: Tue, 18 May 2010 15:30:49 +0100
Message-Id: <1274193049-25997-1-git-send-email-ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: mingo@elte.hu
Cc: a.p.zijlstra@chello.nl, acme@redhat.com, arjan@linux.intel.com, anton@samba.org, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch splits tracking of executable and non-executable mmaps.
Executable mmaps are tracked normally and non-executable are
tracked when --data is used.

Signed-off-by: Anton Blanchard <anton@samba.org>

Updated code for stable perf ABI
Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
---
Changes from V2:
-In free_event and perf_event_mmap, collapse the attr.mmap and attr.mmap_data
 if statements into a single or'd if
-Add perf_mmap_event call in expand_upwards to match call in expand_downwards

Changes from V1:
-Changed mmap_exec to mmap_data and left mmap as the executable mmap tracker
 to maintain backwards compatibility
-Insert mmap_data at the end of the attr bit map
---
 fs/exec.c                   |    1 +
 include/linux/perf_event.h  |   12 +++---------
 kernel/perf_event.c         |   34 +++++++++++++++++++++++-----------
 mm/mmap.c                   |    6 +++++-
 tools/perf/builtin-record.c |    4 +++-
 5 files changed, 35 insertions(+), 22 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index e6e94c6..8204aef 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -648,6 +648,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	else
 		stack_base = vma->vm_start - stack_expand;
 #endif
+	current->mm->start_stack = bprm->p;
 	ret = expand_stack(vma, stack_base);
 	if (ret)
 		ret = -EFAULT;
diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 3fd5c82..e424ee7 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -214,8 +214,9 @@ struct perf_event_attr {
 				 *  See also PERF_RECORD_MISC_EXACT_IP
 				 */
 				precise_ip     :  2, /* skid constraint       */
+				mmap_data      :  1. /* non-exec mmap data    */
 
-				__reserved_1   : 47;
+				__reserved_1   : 46;
 
 	union {
 		__u32		wakeup_events;	  /* wakeup every n events */
@@ -956,14 +957,7 @@ perf_sw_event(u32 event_id, u64 nr, int nmi, struct pt_regs *regs, u64 addr)
 	}
 }
 
-extern void __perf_event_mmap(struct vm_area_struct *vma);
-
-static inline void perf_event_mmap(struct vm_area_struct *vma)
-{
-	if (vma->vm_flags & VM_EXEC)
-		__perf_event_mmap(vma);
-}
-
+extern void perf_event_mmap(struct vm_area_struct *vma);
 extern struct perf_guest_info_callbacks *perf_guest_cbs;
 extern int perf_register_guest_info_callbacks(struct perf_guest_info_callbacks *callbacks);
 extern int perf_unregister_guest_info_callbacks(struct perf_guest_info_callbacks *callbacks);
diff --git a/kernel/perf_event.c b/kernel/perf_event.c
index a4fa381..e7ba170 100644
--- a/kernel/perf_event.c
+++ b/kernel/perf_event.c
@@ -1848,7 +1848,7 @@ static void free_event(struct perf_event *event)
 
 	if (!event->parent) {
 		atomic_dec(&nr_events);
-		if (event->attr.mmap)
+		if (event->attr.mmap || event->attr.mmap_data)
 			atomic_dec(&nr_mmap_events);
 		if (event->attr.comm)
 			atomic_dec(&nr_comm_events);
@@ -3413,7 +3413,7 @@ perf_event_read_event(struct perf_event *event,
 /*
  * task tracking -- fork/exit
  *
- * enabled by: attr.comm | attr.mmap | attr.task
+ * enabled by: attr.comm | attr.mmap | attr.mmap_data | attr.task
  */
 
 struct perf_task_event {
@@ -3473,7 +3473,8 @@ static int perf_event_task_match(struct perf_event *event)
 	if (event->cpu != -1 && event->cpu != smp_processor_id())
 		return 0;
 
-	if (event->attr.comm || event->attr.mmap || event->attr.task)
+	if (event->attr.comm || event->attr.mmap ||
+	    event->attr.mmap_data || event->attr.task)
 		return 1;
 
 	return 0;
@@ -3698,7 +3699,8 @@ static void perf_event_mmap_output(struct perf_event *event,
 }
 
 static int perf_event_mmap_match(struct perf_event *event,
-				   struct perf_mmap_event *mmap_event)
+				   struct perf_mmap_event *mmap_event,
+				   int executable)
 {
 	if (event->state < PERF_EVENT_STATE_INACTIVE)
 		return 0;
@@ -3706,19 +3708,21 @@ static int perf_event_mmap_match(struct perf_event *event,
 	if (event->cpu != -1 && event->cpu != smp_processor_id())
 		return 0;
 
-	if (event->attr.mmap)
+	if ((!executable && event->attr.mmap_data) ||
+	    (executable && event->attr.mmap))
 		return 1;
 
 	return 0;
 }
 
 static void perf_event_mmap_ctx(struct perf_event_context *ctx,
-				  struct perf_mmap_event *mmap_event)
+				  struct perf_mmap_event *mmap_event,
+				  int executable)
 {
 	struct perf_event *event;
 
 	list_for_each_entry_rcu(event, &ctx->event_list, event_entry) {
-		if (perf_event_mmap_match(event, mmap_event))
+		if (perf_event_mmap_match(event, mmap_event, executable))
 			perf_event_mmap_output(event, mmap_event);
 	}
 }
@@ -3762,6 +3766,14 @@ static void perf_event_mmap_event(struct perf_mmap_event *mmap_event)
 		if (!vma->vm_mm) {
 			name = strncpy(tmp, "[vdso]", sizeof(tmp));
 			goto got_name;
+		} else if (vma->vm_start <= vma->vm_mm->start_brk &&
+				vma->vm_end >= vma->vm_mm->brk) {
+			name = strncpy(tmp, "[heap]", sizeof(tmp));
+			goto got_name;
+		} else if (vma->vm_start <= vma->vm_mm->start_stack &&
+				vma->vm_end >= vma->vm_mm->start_stack) {
+			name = strncpy(tmp, "[stack]", sizeof(tmp));
+			goto got_name;
 		}
 
 		name = strncpy(tmp, "//anon", sizeof(tmp));
@@ -3778,17 +3790,17 @@ got_name:
 
 	rcu_read_lock();
 	cpuctx = &get_cpu_var(perf_cpu_context);
-	perf_event_mmap_ctx(&cpuctx->ctx, mmap_event);
+	perf_event_mmap_ctx(&cpuctx->ctx, mmap_event, vma->vm_flags & VM_EXEC);
 	ctx = rcu_dereference(current->perf_event_ctxp);
 	if (ctx)
-		perf_event_mmap_ctx(ctx, mmap_event);
+		perf_event_mmap_ctx(ctx, mmap_event, vma->vm_flags & VM_EXEC);
 	put_cpu_var(perf_cpu_context);
 	rcu_read_unlock();
 
 	kfree(buf);
 }
 
-void __perf_event_mmap(struct vm_area_struct *vma)
+void perf_event_mmap(struct vm_area_struct *vma)
 {
 	struct perf_mmap_event mmap_event;
 
@@ -4795,7 +4807,7 @@ done:
 
 	if (!event->parent) {
 		atomic_inc(&nr_events);
-		if (event->attr.mmap)
+		if (event->attr.mmap || event->attr.mmap_data)
 			atomic_inc(&nr_mmap_events);
 		if (event->attr.comm)
 			atomic_inc(&nr_comm_events);
diff --git a/mm/mmap.c b/mm/mmap.c
index 456ec6f..e38e910 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1734,8 +1734,10 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 		grow = (address - vma->vm_end) >> PAGE_SHIFT;
 
 		error = acct_stack_growth(vma, size, grow);
-		if (!error)
+		if (!error) {
 			vma->vm_end = address;
+			perf_event_mmap(vma);
+		}
 	}
 	anon_vma_unlock(vma);
 	return error;
@@ -1781,6 +1783,7 @@ static int expand_downwards(struct vm_area_struct *vma,
 		if (!error) {
 			vma->vm_start = address;
 			vma->vm_pgoff -= grow;
+			perf_event_mmap(vma);
 		}
 	}
 	anon_vma_unlock(vma);
@@ -2208,6 +2211,7 @@ unsigned long do_brk(unsigned long addr, unsigned long len)
 	vma->vm_page_prot = vm_get_page_prot(flags);
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 out:
+	perf_event_mmap(vma);
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
 		if (!mlock_vma_pages_range(vma, addr, addr + len))
diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index cb46c7d..d047388 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -284,8 +284,10 @@ static void create_counter(int counter, int cpu)
 	if (inherit_stat)
 		attr->inherit_stat = 1;
 
-	if (sample_address)
+	if (sample_address) {
 		attr->sample_type	|= PERF_SAMPLE_ADDR;
+		attr->mmap_data = track;
+	}
 
 	if (call_graph)
 		attr->sample_type	|= PERF_SAMPLE_CALLCHAIN;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
