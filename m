Date: Tue, 21 Oct 2008 09:33:56 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: invoke oom-killer from page fault
Message-ID: <20081021073356.GB3237@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Yes I tested this and it correctly results in panic if panic_on_oom is set and
the page fault runs out of memory. It also doesn't try to kill init if some
other task can be killed.

One remaining problem is that we don't know the constraint of the allocation
(don't know the GFP mask etc), so we can't do exactly the right thing there
yet, but at least we do better than before.

---

mm: invoke OOM killer from pagefault handler

Rather than have the pagefault handler kill a process directly if it gets a
VM_FAULT_OOM, have it call into the OOM killer.

With increasingly sophisticated oom behaviour (cpusets, memory cgroups, oom
killing throttling, oom priority adjustment or selective disabling, panic on
oom, etc), it's silly to unconditionally kill the faulting process at page
fault time. Create a hook for pagefault oom path to call into instead.

Only converted x86 and uml so far.

Index: linux-2.6/mm/oom_kill.c
===================================================================
--- linux-2.6.orig/mm/oom_kill.c
+++ linux-2.6/mm/oom_kill.c
@@ -508,6 +508,69 @@ void clear_zonelist_oom(struct zonelist 
 	spin_unlock(&zone_scan_mutex);
 }
 
+/*
+ * Must be called with tasklist_lock held for read.
+ */
+void __out_of_memory(gfp_t gfp_mask, int order)
+{
+	if (sysctl_oom_kill_allocating_task) {
+		oom_kill_process(current, gfp_mask, order, 0, NULL,
+				"Out of memory (oom_kill_allocating_task)");
+
+	} else {
+		unsigned long points;
+		struct task_struct *p;
+
+retry:
+		/*
+		 * Rambo mode: Shoot down a process and hope it solves whatever
+		 * issues we may have.
+		 */
+		p = select_bad_process(&points, NULL);
+
+		if (PTR_ERR(p) == -1UL)
+			return;
+
+		/* Found nothing?!?! Either we hang forever, or we panic. */
+		if (!p) {
+			read_unlock(&tasklist_lock);
+			panic("Out of memory and no killable processes...\n");
+		}
+
+		if (oom_kill_process(p, gfp_mask, order, points, NULL,
+				     "Out of memory"))
+			goto retry;
+	}
+}
+
+/*
+ * pagefault handler calls into here because it is out of memory but
+ * doesn't know exactly how or why.
+ */
+void pagefault_out_of_memory(void)
+{
+	unsigned long freed = 0;
+
+	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
+	if (freed > 0)
+		/* Got some memory back in the last second. */
+		return;
+
+	if (sysctl_panic_on_oom)
+		panic("out of memory from page fault. panic_on_oom is selected.\n");
+
+	read_lock(&tasklist_lock);
+	__out_of_memory(0, 0); /* unknown gfp_mask and order */
+	read_unlock(&tasklist_lock);
+
+	/*
+	 * Give "p" a good chance of killing itself before we
+	 * retry to allocate memory unless "p" is current
+	 */
+	if (!test_thread_flag(TIF_MEMDIE))
+		schedule_timeout_uninterruptible(1);
+}
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  * @zonelist: zonelist pointer
@@ -521,8 +584,6 @@ void clear_zonelist_oom(struct zonelist 
  */
 void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 {
-	struct task_struct *p;
-	unsigned long points = 0;
 	unsigned long freed = 0;
 	enum oom_constraint constraint;
 
@@ -543,7 +604,7 @@ void out_of_memory(struct zonelist *zone
 
 	switch (constraint) {
 	case CONSTRAINT_MEMORY_POLICY:
-		oom_kill_process(current, gfp_mask, order, points, NULL,
+		oom_kill_process(current, gfp_mask, order, 0, NULL,
 				"No available memory (MPOL_BIND)");
 		break;
 
@@ -552,35 +613,10 @@ void out_of_memory(struct zonelist *zone
 			panic("out of memory. panic_on_oom is selected\n");
 		/* Fall-through */
 	case CONSTRAINT_CPUSET:
-		if (sysctl_oom_kill_allocating_task) {
-			oom_kill_process(current, gfp_mask, order, points, NULL,
-					"Out of memory (oom_kill_allocating_task)");
-			break;
-		}
-retry:
-		/*
-		 * Rambo mode: Shoot down a process and hope it solves whatever
-		 * issues we may have.
-		 */
-		p = select_bad_process(&points, NULL);
-
-		if (PTR_ERR(p) == -1UL)
-			goto out;
-
-		/* Found nothing?!?! Either we hang forever, or we panic. */
-		if (!p) {
-			read_unlock(&tasklist_lock);
-			panic("Out of memory and no killable processes...\n");
-		}
-
-		if (oom_kill_process(p, gfp_mask, order, points, NULL,
-				     "Out of memory"))
-			goto retry;
-
+		__out_of_memory(gfp_mask, order);
 		break;
 	}
 
-out:
 	read_unlock(&tasklist_lock);
 
 	/*
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -700,6 +700,11 @@ static inline int page_mapped(struct pag
 
 #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS)
 
+/*
+ * Can be called by the pagefault handler when it gets a VM_FAULT_OOM.
+ */
+extern void pagefault_out_of_memory(void);
+
 #define offset_in_page(p)	((unsigned long)(p) & ~PAGE_MASK)
 
 extern void show_free_areas(void);
Index: linux-2.6/arch/x86/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/fault.c
+++ linux-2.6/arch/x86/mm/fault.c
@@ -665,7 +665,6 @@ void __kprobes do_page_fault(struct pt_r
 	if (unlikely(in_atomic() || !mm))
 		goto bad_area_nosemaphore;
 
-again:
 	/*
 	 * When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in the
@@ -856,25 +855,14 @@ no_context:
 	oops_end(flags, regs, SIGKILL);
 #endif
 
-/*
- * We ran out of memory, or some other thing happened to us that made
- * us unable to handle the page fault gracefully.
- */
 out_of_memory:
+	/*
+	 * We ran out of memory, call the OOM killer, and return the userspace
+	 * (which will retry the fault, or kill us if we got oom-killed).
+	 */
 	up_read(&mm->mmap_sem);
-	if (is_global_init(tsk)) {
-		yield();
-		/*
-		 * Re-lookup the vma - in theory the vma tree might
-		 * have changed:
-		 */
-		goto again;
-	}
-
-	printk("VM: killing process %s\n", tsk->comm);
-	if (error_code & PF_USER)
-		do_group_exit(SIGKILL);
-	goto no_context;
+	pagefault_out_of_memory();
+	return;
 
 do_sigbus:
 	up_read(&mm->mmap_sem);
Index: linux-2.6/arch/um/kernel/trap.c
===================================================================
--- linux-2.6.orig/arch/um/kernel/trap.c
+++ linux-2.6/arch/um/kernel/trap.c
@@ -64,11 +64,10 @@ good_area:
 
 	do {
 		int fault;
-survive:
+
 		fault = handle_mm_fault(mm, vma, address, is_write);
 		if (unlikely(fault & VM_FAULT_ERROR)) {
 			if (fault & VM_FAULT_OOM) {
-				err = -ENOMEM;
 				goto out_of_memory;
 			} else if (fault & VM_FAULT_SIGBUS) {
 				err = -EACCES;
@@ -104,18 +103,14 @@ out:
 out_nosemaphore:
 	return err;
 
-/*
- * We ran out of memory, or some other thing happened to us that made
- * us unable to handle the page fault gracefully.
- */
 out_of_memory:
-	if (is_global_init(current)) {
-		up_read(&mm->mmap_sem);
-		yield();
-		down_read(&mm->mmap_sem);
-		goto survive;
-	}
-	goto out;
+	/*
+	 * We ran out of memory, call the OOM killer, and return the userspace
+	 * (which will retry the fault, or kill us if we got oom-killed).
+	 */
+	up_read(&mm->mmap_sem);
+	pagefault_out_of_memory();
+	return 0;
 }
 
 static void bad_segv(struct faultinfo fi, unsigned long ip)
@@ -214,9 +209,6 @@ unsigned long segv(struct faultinfo fi, 
 		si.si_addr = (void __user *)address;
 		current->thread.arch.faultinfo = fi;
 		force_sig_info(SIGBUS, &si, current);
-	} else if (err == -ENOMEM) {
-		printk(KERN_INFO "VM: killing process %s\n", current->comm);
-		do_exit(SIGKILL);
 	} else {
 		BUG_ON(err != -EFAULT);
 		si.si_signo = SIGSEGV;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
