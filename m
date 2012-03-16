Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 7D9066B00F9
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:11 -0400 (EDT)
Message-Id: <20120316144241.540630849@chello.nl>
Date: Fri, 16 Mar 2012 15:40:50 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 22/26] mm, mpol: Split and explose some mempolicy functions
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=mpol-mbind-split.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

In order to allow creating 'custom' mpols, expose some guts. In
particular means to allocate fresh mpols and to bind them to memory
ranges, skipping out on the intermediate -- policy -- part of
sys_mbind().

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mempolicy.h |    8 +++
 mm/mempolicy.c            |  111 ++++++++++++++++++++++++++--------------------
 2 files changed, 71 insertions(+), 48 deletions(-)
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -203,6 +203,12 @@ struct shared_policy {
 	spinlock_t lock;
 };
 
+extern struct mempolicy *mpol_new(unsigned short mode, unsigned short flags,
+				  nodemask_t *nodes);
+extern long mpol_do_mbind(unsigned long start, unsigned long len,
+				struct mempolicy *policy, unsigned long mode,
+				nodemask_t *nmask, unsigned long flags);
+
 void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol);
 int mpol_set_shared_policy(struct shared_policy *info,
 				struct vm_area_struct *vma,
@@ -216,6 +222,8 @@ struct mempolicy *get_vma_policy(struct 
 
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
+extern void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *new,
+				enum mpol_rebind_step step);
 extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
 				enum mpol_rebind_step step);
 extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -259,7 +259,7 @@ static int mpol_set_nodemask(struct memp
  * This function just creates a new policy, does some check and simple
  * initialization. You must invoke mpol_set_nodemask() to set nodes.
  */
-static struct mempolicy *mpol_new(unsigned short mode, unsigned short flags,
+struct mempolicy *mpol_new(unsigned short mode, unsigned short flags,
 				  nodemask_t *nodes)
 {
 	struct mempolicy *policy;
@@ -401,7 +401,7 @@ static void mpol_rebind_preferred(struct
  * 	MPOL_REBIND_STEP1 - set all the newly nodes
  * 	MPOL_REBIND_STEP2 - clean all the disallowed nodes
  */
-static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask,
+void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask,
 				enum mpol_rebind_step step)
 {
 	if (!pol)
@@ -1067,55 +1067,28 @@ static struct page *new_vma_page(struct 
 }
 #endif
 
-static long do_mbind(unsigned long start, unsigned long len,
-		     unsigned short mode, unsigned short mode_flags,
-		     nodemask_t *nmask, unsigned long flags)
+long mpol_do_mbind(unsigned long start, unsigned long len,
+		struct mempolicy *new, unsigned long mode,
+		nodemask_t *nmask, unsigned long flags)
 {
-	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
-	struct mempolicy *new = NULL;
-	unsigned long end;
+	struct vm_area_struct *vma;
 	int err, nr_failed = 0;
+	unsigned long end;
 	LIST_HEAD(pagelist);
 
-  	if (flags & ~(unsigned long)MPOL_MF_VALID)
-		return -EINVAL;
-	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
-		return -EPERM;
-
-	if (start & ~PAGE_MASK)
-		return -EINVAL;
-
-	if (mode == MPOL_DEFAULT || mode == MPOL_NOOP)
-		flags &= ~MPOL_MF_STRICT;
-
 	len = (len + PAGE_SIZE - 1) & PAGE_MASK;
 	end = start + len;
 
-	if (end < start)
-		return -EINVAL;
-	if (end == start)
-		return 0;
-
-	if (mode != MPOL_NOOP) {
-		new = mpol_new(mode, mode_flags, nmask);
-		if (IS_ERR(new))
-			return PTR_ERR(new);
-
-		if (flags & MPOL_MF_LAZY)
-			new->flags |= MPOL_F_MOF;
-
+	if (end < start) {
+		err = -EINVAL;
+		goto mpol_out;
 	}
-	/*
-	 * If we are using the default policy then operation
-	 * on discontinuous address spaces is okay after all
-	 */
-	if (!new)
-		flags |= MPOL_MF_DISCONTIG_OK;
 
-	pr_debug("mbind %lx-%lx mode:%d flags:%d nodes:%lx\n",
-		 start, start + len, mode, mode_flags,
-		 nmask ? nodes_addr(*nmask)[0] : -1);
+	if (end == start) {
+		err = 0;
+		goto mpol_out;
+	}
 
 	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
 		err = migrate_prep();
@@ -1123,8 +1096,6 @@ static long do_mbind(unsigned long start
 			goto mpol_out;
 	}
 
-	down_write(&mm->mmap_sem);
-
 	if (mode != MPOL_NOOP) {
 		NODEMASK_SCRATCH(scratch);
 		err = -ENOMEM;
@@ -1135,7 +1106,7 @@ static long do_mbind(unsigned long start
 		}
 		NODEMASK_SCRATCH_FREE(scratch);
 		if (err)
-			goto mpol_out_unlock;
+			goto mpol_out;
 	}
 
 	vma = check_range(mm, start, end, nmask,
@@ -1143,12 +1114,12 @@ static long do_mbind(unsigned long start
 
 	err = PTR_ERR(vma);	/* maybe ... */
 	if (IS_ERR(vma))
-		goto mpol_out_unlock;
+		goto mpol_out_putback;
 
 	if (mode != MPOL_NOOP) {
 		err = mbind_range(mm, start, end, new);
 		if (err)
-			goto mpol_out_unlock;
+			goto mpol_out_putback;
 	}
 
 	if (!list_empty(&pagelist)) {
@@ -1164,12 +1135,56 @@ static long do_mbind(unsigned long start
 	if (nr_failed && (flags & MPOL_MF_STRICT))
 		err = -EIO;
 
+mpol_out_putback:
 	putback_lru_pages(&pagelist);
 
-mpol_out_unlock:
-	up_write(&mm->mmap_sem);
 mpol_out:
+	return err;
+}
+
+static long do_mbind(unsigned long start, unsigned long len,
+		     unsigned short mode, unsigned short mode_flags,
+		     nodemask_t *nmask, unsigned long flags)
+{
+	struct mm_struct *mm = current->mm;
+	struct mempolicy *new = NULL;
+	int err;
+
+	if (flags & ~(unsigned long)MPOL_MF_VALID)
+		return -EINVAL;
+	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
+		return -EPERM;
+
+	if (start & ~PAGE_MASK)
+		return -EINVAL;
+
+	if (mode == MPOL_DEFAULT || mode == MPOL_NOOP)
+		flags &= ~MPOL_MF_STRICT;
+
+	if (mode != MPOL_NOOP) {
+		new = mpol_new(mode, mode_flags, nmask);
+		if (IS_ERR(new))
+			return PTR_ERR(new);
+
+		if (flags & MPOL_MF_LAZY)
+			new->flags |= MPOL_F_MOF;
+	}
+	/*
+	 * If we are using the default policy then operation
+	 * on discontinuous address spaces is okay after all
+	 */
+	if (!new)
+		flags |= MPOL_MF_DISCONTIG_OK;
+
+	pr_debug("mbind %lx-%lx mode:%d flags:%d nodes:%lx\n",
+		 start, start + len, mode, mode_flags,
+		 nmask ? nodes_addr(*nmask)[0] : -1);
+
+	down_write(&mm->mmap_sem);
+	err = mpol_do_mbind(start, len, new, mode, nmask, flags);
+	up_write(&mm->mmap_sem);
 	mpol_put(new);
+
 	return err;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
