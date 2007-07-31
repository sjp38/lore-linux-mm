Date: Tue, 31 Jul 2007 07:41:42 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc] balance-on-fork NUMA placement
Message-ID: <20070731054142.GB11306@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I haven't given this idea testing yet, but I just wanted to get some
opinions on it first. NUMA placement still isn't ideal (eg. tasks with
a memory policy will not do any placement, and process migrations of
course will leave the memory behind...), but it does give a bit more
chance for the memory controllers and interconnects to get evenly
loaded.

The primary reason for currently doing balance on fork is to improve
the NUMA placement of user memory, so on the basis that is useful, I
think it should be useful for kernel memory too?

---
NUMA balance-on-fork code is in a good position to allocate all of a new
process's memory on a chosen node. However, it really only starts allocating
on the correct node after the process starts running.

task and thread structures, stack, mm_struct, vmas, page tables etc. are
all allocated on the parent's node.

This patch uses memory policies to attempt to improve this. It requires
that we ask the scheduler to suggest the child's new CPU earlier in the
fork, but that is not a fundamental difference.



Index: linux-2.6/include/linux/mempolicy.h
===================================================================
--- linux-2.6.orig/include/linux/mempolicy.h
+++ linux-2.6/include/linux/mempolicy.h
@@ -141,6 +141,8 @@ void mpol_free_shared_policy(struct shar
 struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
 					    unsigned long idx);
 
+extern int mpol_prefer_cpu_start(int cpu);
+extern void mpol_prefer_cpu_end(int arg);
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
 extern void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *new);
@@ -227,6 +229,15 @@ mpol_shared_policy_lookup(struct shared_
 #define vma_policy(vma) NULL
 #define vma_set_policy(vma, pol) do {} while(0)
 
+static inline int mpol_prefer_cpu_start(int cpu)
+{
+	return 0;
+}
+
+static inline void mpol_prefer_cpu_end(int arg)
+{
+}
+
 static inline void numa_policy_init(void)
 {
 }
Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -1460,6 +1460,7 @@ extern void FASTCALL(wake_up_new_task(st
 #else
  static inline void kick_process(struct task_struct *tsk) { }
 #endif
+extern int sched_fork_suggest_cpu(int clone_flags);
 extern void sched_fork(struct task_struct *p, int clone_flags);
 extern void sched_dead(struct task_struct *p);
 
@@ -1782,6 +1783,7 @@ static inline unsigned int task_cpu(cons
 }
 
 extern void set_task_cpu(struct task_struct *p, unsigned int cpu);
+extern void __set_task_cpu(struct task_struct *p, unsigned int cpu);
 
 #else
 
@@ -1794,6 +1796,10 @@ static inline void set_task_cpu(struct t
 {
 }
 
+extern void __set_task_cpu(struct task_struct *p, unsigned int cpu)
+{
+}
+
 #endif /* CONFIG_SMP */
 
 #ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -964,6 +964,7 @@ static struct task_struct *copy_process(
 					int __user *child_tidptr,
 					struct pid *pid)
 {
+	int cpu, mpol_arg;
 	int retval;
 	struct task_struct *p = NULL;
 
@@ -989,10 +990,13 @@ static struct task_struct *copy_process(
 	if (retval)
 		goto fork_out;
 
+	cpu = sched_fork_suggest_cpu(clone_flags);
+	mpol_arg = mpol_prefer_cpu_start(cpu);
+
 	retval = -ENOMEM;
 	p = dup_task_struct(current);
 	if (!p)
-		goto fork_out;
+		goto fork_mpol;
 
 	rt_mutex_init_task(p);
 
@@ -1183,7 +1187,7 @@ static struct task_struct *copy_process(
 	INIT_LIST_HEAD(&p->ptrace_children);
 	INIT_LIST_HEAD(&p->ptrace_list);
 
-	/* Perform scheduler related setup. Assign this task to a CPU. */
+	/* Perform scheduler related setup. */
 	sched_fork(p, clone_flags);
 
 	/* Need tasklist lock for parent etc handling! */
@@ -1193,6 +1197,7 @@ static struct task_struct *copy_process(
 	p->ioprio = current->ioprio;
 
 	/*
+	 * Assign this task to a CPU.
 	 * The task hasn't been attached yet, so its cpus_allowed mask will
 	 * not be changed, nor will its assigned CPU.
 	 *
@@ -1202,9 +1207,10 @@ static struct task_struct *copy_process(
 	 * parent's CPU). This avoids alot of nasty races.
 	 */
 	p->cpus_allowed = current->cpus_allowed;
-	if (unlikely(!cpu_isset(task_cpu(p), p->cpus_allowed) ||
-			!cpu_online(task_cpu(p))))
-		set_task_cpu(p, smp_processor_id());
+	if (unlikely(!cpu_isset(cpu, p->cpus_allowed) ||
+			!cpu_online(cpu)))
+		cpu = smp_processor_id();
+	__set_task_cpu(p, cpu);
 
 	/* CLONE_PARENT re-uses the old parent */
 	if (clone_flags & (CLONE_PARENT|CLONE_THREAD))
@@ -1274,6 +1280,7 @@ static struct task_struct *copy_process(
 	spin_unlock(&current->sighand->siglock);
 	write_unlock_irq(&tasklist_lock);
 	proc_fork_connector(p);
+	mpol_prefer_cpu_end(mpol_arg);
 	return p;
 
 bad_fork_cleanup_namespaces:
@@ -1315,6 +1322,8 @@ bad_fork_cleanup_count:
 	free_uid(p->user);
 bad_fork_free:
 	free_task(p);
+fork_mpol:
+	mpol_prefer_cpu_end(mpol_arg);
 fork_out:
 	return ERR_PTR(retval);
 }
Index: linux-2.6/kernel/sched.c
===================================================================
--- linux-2.6.orig/kernel/sched.c
+++ linux-2.6/kernel/sched.c
@@ -981,16 +981,13 @@ unsigned long weighted_cpuload(const int
 	return cpu_rq(cpu)->ls.load.weight;
 }
 
-static inline void __set_task_cpu(struct task_struct *p, unsigned int cpu)
-{
 #ifdef CONFIG_SMP
+void __set_task_cpu(struct task_struct *p, unsigned int cpu)
+{
 	task_thread_info(p)->cpu = cpu;
 	set_task_cfs_rq(p);
-#endif
 }
 
-#ifdef CONFIG_SMP
-
 void set_task_cpu(struct task_struct *p, unsigned int new_cpu)
 {
 	int old_cpu = task_cpu(p);
@@ -1601,20 +1598,26 @@ static void __sched_fork(struct task_str
 	p->state = TASK_RUNNING;
 }
 
+int sched_fork_suggest_cpu(int clone_flags)
+{
+#ifdef CONFIG_SMP
+	int cpu, new_cpu;
+	cpu = get_cpu();
+	new_cpu = sched_balance_self(cpu, SD_BALANCE_FORK);
+	put_cpu();
+	return new_cpu;
+#else
+	return 0;
+#endif
+}
+
 /*
  * fork()/clone()-time setup:
  */
 void sched_fork(struct task_struct *p, int clone_flags)
 {
-	int cpu = get_cpu();
-
 	__sched_fork(p);
 
-#ifdef CONFIG_SMP
-	cpu = sched_balance_self(cpu, SD_BALANCE_FORK);
-#endif
-	__set_task_cpu(p, cpu);
-
 	/*
 	 * Make sure we do not leak PI boosting priority to the child:
 	 */
@@ -1631,7 +1634,6 @@ void sched_fork(struct task_struct *p, i
 	/* Want to start with kernel preemption disabled. */
 	task_thread_info(p)->preempt_count = 1;
 #endif
-	put_cpu();
 }
 
 /*
Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c
+++ linux-2.6/mm/mempolicy.c
@@ -1596,6 +1596,29 @@ void mpol_free_shared_policy(struct shar
 	spin_unlock(&p->lock);
 }
 
+int mpol_prefer_cpu_start(int cpu)
+{
+	nodemask_t prefer_node = nodemask_of_node(cpu_to_node(cpu));
+
+	/* Only change if we are MPOL_DEFAULT */
+	if (current->mempolicy)
+		return 0;
+
+	if (do_set_mempolicy(MPOL_PREFERRED, &prefer_node))
+		return 0;
+
+	return 1;
+}
+
+void mpol_prefer_cpu_end(int arg)
+{
+	if (!arg)
+		return;
+
+	if (do_set_mempolicy(MPOL_DEFAULT, NULL))
+		BUG();
+}
+
 /* assumes fs == KERNEL_DS */
 void __init numa_policy_init(void)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
