Received: from taynzmail03.nz-tay.cpqcorp.net (relay.dec.com [16.47.4.103])
	by atlrel8.hp.com (Postfix) with ESMTP id AB4BB3579B
	for <linux-mm@kvack.org>; Sun, 12 Mar 2006 13:03:56 -0500 (EST)
Received: from anw.zk3.dec.com (alpha.zk3.dec.com [16.140.128.4])
	by taynzmail03.nz-tay.cpqcorp.net (Postfix) with ESMTP id 81D4167A2
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 14:38:18 -0500 (EST)
Subject: [PATCH/RFC] AutoPage Migration - V0.1 - 1/8 migrate task memory
	with default policy
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Fri, 10 Mar 2006 14:37:59 -0500
Message-Id: <1142019479.5204.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.1 - 1/8 migrate task memory with default policy

This patch introduces the mm/mempolicy.c "migrate_task_memory()" function.
When called, this function will migrate all possible task pages with default
policy that are not located on the node that contains the current task's cpu.

migrate_task_memory() operates on one vma at at time, filtering out those
that don't have default policy and that have no access.  Added helper
function migrate_vma_to_node()--a slight variant of migrate_to_node()--that
takes a vma instead of an mm struct.  Changed comment on migrate_to_node()
to indicate that it operates on entire mm.

I had to move get_vma_policy() up in mempolicy.c so that I could reference
it from migrate_task_memory().  Should I have just added a forward ref
declaration?

Subsequent patches will arrange for this function to be called when a task
returns to user space after the scheduler migrates it to a cpu on a node
different from the node where it last executed.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc5-git6/include/linux/mempolicy.h
===================================================================
--- linux-2.6.16-rc5-git6.orig/include/linux/mempolicy.h	2006-03-02 16:40:38.000000000 -0500
+++ linux-2.6.16-rc5-git6/include/linux/mempolicy.h	2006-03-02 16:48:02.000000000 -0500
@@ -172,6 +172,8 @@ static inline void check_highest_zone(in
 int do_migrate_pages(struct mm_struct *mm,
 	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags);
 
+extern void migrate_task_memory(void);
+
 extern void *cpuset_being_rebound;	/* Trigger mpol_copy vma rebind */
 
 #else
@@ -263,6 +265,8 @@ static inline int do_migrate_pages(struc
 	return 0;
 }
 
+static inline void migrate_task_memory(void) { }
+
 static inline void check_highest_zone(int k)
 {
 }
Index: linux-2.6.16-rc5-git6/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc5-git6.orig/mm/mempolicy.c	2006-03-02 16:40:44.000000000 -0500
+++ linux-2.6.16-rc5-git6/mm/mempolicy.c	2006-03-06 12:55:27.000000000 -0500
@@ -112,6 +112,24 @@ struct mempolicy default_policy = {
 	.policy = MPOL_DEFAULT,
 };
 
+/* Return effective policy for a VMA */
+static struct mempolicy * get_vma_policy(struct task_struct *task,
+		struct vm_area_struct *vma, unsigned long addr)
+{
+	struct mempolicy *pol = task->mempolicy;
+
+	if (vma) {
+		if (vma->vm_ops && vma->vm_ops->get_policy)
+			pol = vma->vm_ops->get_policy(vma, addr);
+		else if (vma->vm_policy &&
+				vma->vm_policy->policy != MPOL_DEFAULT)
+			pol = vma->vm_policy;
+	}
+	if (!pol)
+		pol = &default_policy;
+	return pol;
+}
+
 /* Do sanity checking on a policy */
 static int mpol_check_policy(int mode, nodemask_t *nodes)
 {
@@ -629,7 +647,7 @@ out:
 }
 
 /*
- * Migrate pages from one node to a target node.
+ * Migrate all eligible pages mapped in mm from source node to destination node.
  * Returns error or the number of pages not migrated.
  */
 int migrate_to_node(struct mm_struct *mm, int source, int dest, int flags)
@@ -734,6 +752,97 @@ int do_migrate_pages(struct mm_struct *m
 	return busy;
 }
 
+
+/*
+ * Migrate all eligible pages mapped in vma NOT on destination node to
+ * the destination node.
+ * Returns error or the number of pages not migrated.
+ */
+static int migrate_vma_to_node(struct vm_area_struct *vma, int dest, int flags)
+{
+	nodemask_t nmask;
+	LIST_HEAD(pagelist);
+	int err = 0;
+
+	nodes_clear(nmask);
+	node_set(dest, nmask);
+
+	vma = check_range(vma->vm_mm, vma->vm_start, vma->vm_end, &nmask,
+			flags | MPOL_MF_INVERT,	/* pages NOT on dest */
+			&pagelist);
+
+	if (IS_ERR(vma))
+		err = PTR_ERR(vma);
+	else if (!list_empty(&pagelist))
+		err = migrate_pages_to(&pagelist, NULL, dest);
+
+	if (!list_empty(&pagelist))
+		putback_lru_pages(&pagelist);
+	return err;
+}
+
+/*
+ * for filtering 'no access' segments
+TODO:  what are these?
+ */
+static inline int vma_no_access(struct vm_area_struct *vma)
+{
+	const int VM_RWX = VM_READ|VM_WRITE|VM_EXEC;
+
+	return (vma->vm_flags & VM_RWX) == 0;
+}
+
+/**
+ * migrate_task_memory()
+ *
+ * Called just before returning to user state when a task has been
+ * migrated to a new node by the schedule and sched_migrate_memory
+ * is enabled.  Walks the current task's mm_struct's vma list and
+ * migrates pages of eligible vmas to the new node.  Eligible
+ * vmas are those with null or default memory policy, because
+ * default policy depends on local/home node.
+ */
+
+void migrate_task_memory(void)
+{
+	struct mm_struct *mm = NULL;
+	struct vm_area_struct *vma;
+	int dest;
+
+	BUG_ON(irqs_disabled());
+
+	mm = current->mm;
+	/*
+	 * we're returning to user space, so mm must be non-NULL
+	 */
+	BUG_ON(!mm);
+
+	/*
+	 * migrate eligible vma's pages
+	 */
+	dest = cpu_to_node(task_cpu(current));
+	down_read(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		struct mempolicy *pol = get_vma_policy(current, vma,
+							 vma->vm_start);
+		int err;
+
+		if (pol->policy != MPOL_DEFAULT)
+			continue;
+		if (vma_no_access(vma))
+			continue;
+
+		// TODO:  more eligibility filtering?
+
+		// TODO:  more agressive migration ['MOVE_ALL] ?
+		//        via sysctl?
+		err = migrate_vma_to_node(vma, dest, MPOL_MF_MOVE);
+
+	}
+	up_read(&mm->mmap_sem);
+
+}
+
 long do_mbind(unsigned long start, unsigned long len,
 		unsigned long mode, nodemask_t *nmask, unsigned long flags)
 {
@@ -1067,24 +1176,6 @@ asmlinkage long compat_sys_mbind(compat_
 
 #endif
 
-/* Return effective policy for a VMA */
-static struct mempolicy * get_vma_policy(struct task_struct *task,
-		struct vm_area_struct *vma, unsigned long addr)
-{
-	struct mempolicy *pol = task->mempolicy;
-
-	if (vma) {
-		if (vma->vm_ops && vma->vm_ops->get_policy)
-			pol = vma->vm_ops->get_policy(vma, addr);
-		else if (vma->vm_policy &&
-				vma->vm_policy->policy != MPOL_DEFAULT)
-			pol = vma->vm_policy;
-	}
-	if (!pol)
-		pol = &default_policy;
-	return pol;
-}
-
 /* Return a zonelist representing a mempolicy */
 static struct zonelist *zonelist_policy(gfp_t gfp, struct mempolicy *policy)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
