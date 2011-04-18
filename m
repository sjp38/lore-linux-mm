Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DB291900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 08:18:51 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 41AC43EE0BC
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:18:49 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F88A45DEA4
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:18:49 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 04B1C45DEA0
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:18:49 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DC07BE08003
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:18:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CA8A1DB803A
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:18:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/3] mm: convert mm->cpu_vm_cpumask into cpumask_var_t
In-Reply-To: <20110418211455.9359.A69D9226@jp.fujitsu.com>
References: <20110418211455.9359.A69D9226@jp.fujitsu.com>
Message-Id: <20110418211950.9365.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 18 Apr 2011 21:18:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>

cpumask_t is very big struct and cpu_vm_mask is placed wrong position.
It might lead to reduce cache hit ratio.

This patch has two change.
1) Move the place of cpumask into last of mm_struct. Because usually cpumask
   is accessed only front bits when the system has cpu-hotplug capability
2) Convert cpu_vm_mask into cpumask_var_t. It may help to reduce memory
   footprint if cpumask_size() will use nr_cpumask_bits properly in future.

In addition, this patch change the name of cpu_vm_mask with cpu_vm_mask_var.
It may help to detect out of tree cpu_vm_mask users.

This patch has no functional change.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 Documentation/cachetlb.txt |    2 +-
 include/linux/mm_types.h   |    9 ++++++---
 include/linux/sched.h      |    1 +
 init/main.c                |    2 ++
 kernel/fork.c              |   37 ++++++++++++++++++++++++++++++++++---
 mm/init-mm.c               |    1 -
 6 files changed, 44 insertions(+), 8 deletions(-)

This patch don't touch x86/kerrnel/tboot.c. because it can't be compiled.

diff --git a/Documentation/cachetlb.txt b/Documentation/cachetlb.txt
index 9164ae3..9b728dc 100644
--- a/Documentation/cachetlb.txt
+++ b/Documentation/cachetlb.txt
@@ -16,7 +16,7 @@ on all processors in the system.  Don't let this scare you into
 thinking SMP cache/tlb flushing must be so inefficient, this is in
 fact an area where many optimizations are possible.  For example,
 if it can be proven that a user address space has never executed
-on a cpu (see vma->cpu_vm_mask), one need not perform a flush
+on a cpu (see mm_cpumask()), one need not perform a flush
 for this address space on that cpu.
 
 First, the TLB flushing interfaces, since they are the simplest.  The
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ca01ab2..070c7f2 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -267,8 +267,6 @@ struct mm_struct {
 
 	struct linux_binfmt *binfmt;
 
-	cpumask_t cpu_vm_mask;
-
 	/* Architecture-specific MM context */
 	mm_context_t context;
 
@@ -318,9 +316,14 @@ struct mm_struct {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
 #endif
+
+	cpumask_var_t cpu_vm_mask_var;
 };
 
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
-#define mm_cpumask(mm) (&(mm)->cpu_vm_mask)
+static inline cpumask_t* mm_cpumask(struct mm_struct *mm)
+{
+	return mm->cpu_vm_mask_var;
+}
 
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 3f7d3f9..7068380 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2170,6 +2170,7 @@ static inline void mmdrop(struct mm_struct * mm)
 	if (unlikely(atomic_dec_and_test(&mm->mm_count)))
 		__mmdrop(mm);
 }
+extern int mm_init_cpumask(struct mm_struct *mm, struct mm_struct *oldmm);
 
 /* mmput gets rid of the mappings and all user-space */
 extern void mmput(struct mm_struct *);
diff --git a/init/main.c b/init/main.c
index 4a9479e..8451425 100644
--- a/init/main.c
+++ b/init/main.c
@@ -509,6 +509,8 @@ asmlinkage void __init start_kernel(void)
 	sort_main_extable();
 	trap_init();
 	mm_init();
+	BUG_ON(mm_init_cpumask(&init_mm, 0));
+
 	/*
 	 * Set up the scheduler prior starting any interrupts (such as the
 	 * timer interrupt). Full topology setup happens at smp_init()
diff --git a/kernel/fork.c b/kernel/fork.c
index cc04197..5d303a2 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -486,6 +486,20 @@ static void mm_init_aio(struct mm_struct *mm)
 #endif
 }
 
+int mm_init_cpumask(struct mm_struct *mm, struct mm_struct *oldmm)
+{
+#ifdef CONFIG_CPUMASK_OFFSTACK
+	if (!alloc_cpumask_var(&mm->cpu_vm_mask_var, GFP_KERNEL))
+		return -ENOMEM;
+
+	if (oldmm)
+		cpumask_copy(mm_cpumask(mm), mm_cpumask(oldmm));
+	else
+		memset(mm_cpumask(mm), 0, cpumask_size());
+#endif
+	return 0;
+}
+
 static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 {
 	atomic_set(&mm->mm_users, 1);
@@ -522,10 +536,20 @@ struct mm_struct * mm_alloc(void)
 	struct mm_struct * mm;
 
 	mm = allocate_mm();
-	if (mm) {
-		memset(mm, 0, sizeof(*mm));
-		mm = mm_init(mm, current);
+	if (!mm)
+		return NULL;
+
+	memset(mm, 0, sizeof(*mm));
+	mm = mm_init(mm, current);
+	if (!mm)
+		return NULL;
+
+	if (mm_init_cpumask(mm, NULL)) {
+		mm_free_pgd(mm);
+		free_mm(mm);
+		return NULL;
 	}
+
 	return mm;
 }
 
@@ -537,6 +561,7 @@ struct mm_struct * mm_alloc(void)
 void __mmdrop(struct mm_struct *mm)
 {
 	BUG_ON(mm == &init_mm);
+	free_cpumask_var(mm->cpu_vm_mask_var);
 	mm_free_pgd(mm);
 	destroy_context(mm);
 	mmu_notifier_mm_destroy(mm);
@@ -691,6 +716,9 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 	if (!mm_init(mm, tsk))
 		goto fail_nomem;
 
+	if (mm_init_cpumask(mm, oldmm))
+		goto fail_nocpumask;
+
 	if (init_new_context(tsk, mm))
 		goto fail_nocontext;
 
@@ -717,6 +745,9 @@ fail_nomem:
 	return NULL;
 
 fail_nocontext:
+	free_cpumask_var(mm->cpu_vm_mask_var);
+
+fail_nocpumask:
 	/*
 	 * If init_new_context() failed, we cannot use mmput() to free the mm
 	 * because it calls destroy_context()
diff --git a/mm/init-mm.c b/mm/init-mm.c
index 1d29cdf..4019979 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -21,6 +21,5 @@ struct mm_struct init_mm = {
 	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
-	.cpu_vm_mask	= CPU_MASK_ALL,
 	INIT_MM_CONTEXT(init_mm)
 };
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
