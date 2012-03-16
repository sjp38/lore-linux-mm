Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id BD5696B004D
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:02 -0400 (EDT)
Message-Id: <20120316144240.619207223@chello.nl>
Date: Fri, 16 Mar 2012 15:40:36 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 08/26] mm, mpol: Simplify do_mbind()
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=mempol-simplify-do_mbind.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

Code flow got a little convoluted, try and straighten it some.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/mempolicy.c |   73 +++++++++++++++++++++++++++++----------------------------
 1 file changed, 38 insertions(+), 35 deletions(-)
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1054,9 +1054,9 @@ static long do_mbind(unsigned long start
 {
 	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
-	struct mempolicy *new;
+	struct mempolicy *new = NULL;
 	unsigned long end;
-	int err;
+	int err, nr_failed = 0;
 	LIST_HEAD(pagelist);
 
   	if (flags & ~(unsigned long)MPOL_MF_VALID)
@@ -1078,13 +1078,15 @@ static long do_mbind(unsigned long start
 	if (end == start)
 		return 0;
 
-	new = mpol_new(mode, mode_flags, nmask);
-	if (IS_ERR(new))
-		return PTR_ERR(new);
+	if (mode != MPOL_NOOP) {
+		new = mpol_new(mode, mode_flags, nmask);
+		if (IS_ERR(new))
+			return PTR_ERR(new);
 
-	if (flags & MPOL_MF_LAZY)
-		new->flags |= MPOL_F_MOF;
+		if (flags & MPOL_MF_LAZY)
+			new->flags |= MPOL_F_MOF;
 
+	}
 	/*
 	 * If we are using the default policy then operation
 	 * on discontinuous address spaces is okay after all
@@ -1097,56 +1099,57 @@ static long do_mbind(unsigned long start
 		 nmask ? nodes_addr(*nmask)[0] : -1);
 
 	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
-
 		err = migrate_prep();
 		if (err)
 			goto mpol_out;
 	}
-	{
+
+	down_write(&mm->mmap_sem);
+
+	if (mode != MPOL_NOOP) {
 		NODEMASK_SCRATCH(scratch);
+		err = -ENOMEM;
 		if (scratch) {
-			down_write(&mm->mmap_sem);
 			task_lock(current);
 			err = mpol_set_nodemask(new, nmask, scratch);
 			task_unlock(current);
-			if (err)
-				up_write(&mm->mmap_sem);
-		} else
-			err = -ENOMEM;
+		}
 		NODEMASK_SCRATCH_FREE(scratch);
+		if (err)
+			goto mpol_out_unlock;
 	}
-	if (err)
-		goto mpol_out;
 
 	vma = check_range(mm, start, end, nmask,
 			  flags | MPOL_MF_INVERT, &pagelist);
 
 	err = PTR_ERR(vma);	/* maybe ... */
-	if (!IS_ERR(vma) && mode != MPOL_NOOP)
-		err = mbind_range(mm, start, end, new);
+	if (IS_ERR(vma))
+		goto mpol_out_unlock;
 
-	if (!err) {
-		int nr_failed = 0;
+	if (mode != MPOL_NOOP) {
+		err = mbind_range(mm, start, end, new);
+		if (err)
+			goto mpol_out_unlock;
+	}
 
-		if (!list_empty(&pagelist)) {
-			if (flags & MPOL_MF_LAZY)
-				nr_failed = migrate_pages_unmap_only(&pagelist);
-			else {
-				nr_failed = migrate_pages(&pagelist, new_vma_page,
-						(unsigned long)vma,
-						false, true);
-			}
-			if (nr_failed)
-				putback_lru_pages(&pagelist);
+	if (!list_empty(&pagelist)) {
+		if (flags & MPOL_MF_LAZY)
+			nr_failed = migrate_pages_unmap_only(&pagelist);
+		else {
+			nr_failed = migrate_pages(&pagelist, new_vma_page,
+					(unsigned long)vma,
+					false, true);
 		}
+	}
 
-		if (nr_failed && (flags & MPOL_MF_STRICT))
-			err = -EIO;
-	} else
-		putback_lru_pages(&pagelist);
+	if (nr_failed && (flags & MPOL_MF_STRICT))
+		err = -EIO;
+
+	putback_lru_pages(&pagelist);
 
+mpol_out_unlock:
 	up_write(&mm->mmap_sem);
- mpol_out:
+mpol_out:
 	mpol_put(new);
 	return err;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
