Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 23D2D900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 00:34:07 -0400 (EDT)
Received: by pwi10 with SMTP id 10so1317193pwi.14
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:34:05 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH] mempolicy: reduce references to the current
Date: Fri, 15 Apr 2011 13:33:59 +0900
Message-Id: <1302842039-7190-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Remove duplicated reference to the 'current' task using a local
variable. Since refering the current can be a burden, it'd better
cache the reference, IMHO. At least this saves some bytes on x86_64.

  $ size mempolicy-{old,new}.o
     text    data    bss     dec     hex filename
    25203    2448   9176   36827    8fdb mempolicy-old.o
    25136    2448   9184   36768    8fa0 mempolicy-new.o

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/mempolicy.c |   58 +++++++++++++++++++++++++++++--------------------------
 1 files changed, 31 insertions(+), 27 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 959a8b8c7350..37cc80ce5054 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -304,6 +304,7 @@ static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes,
 				 enum mpol_rebind_step step)
 {
 	nodemask_t tmp;
+	struct task_struct *curr = current;
 
 	if (pol->flags & MPOL_F_STATIC_NODES)
 		nodes_and(tmp, pol->w.user_nodemask, *nodes);
@@ -335,12 +336,12 @@ static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes,
 	else
 		BUG();
 
-	if (!node_isset(current->il_next, tmp)) {
-		current->il_next = next_node(current->il_next, tmp);
-		if (current->il_next >= MAX_NUMNODES)
-			current->il_next = first_node(tmp);
-		if (current->il_next >= MAX_NUMNODES)
-			current->il_next = numa_node_id();
+	if (!node_isset(curr->il_next, tmp)) {
+		curr->il_next = next_node(curr->il_next, tmp);
+		if (curr->il_next >= MAX_NUMNODES)
+			curr->il_next = first_node(tmp);
+		if (curr->il_next >= MAX_NUMNODES)
+			curr->il_next = numa_node_id();
 	}
 }
 
@@ -714,7 +715,8 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
 			     nodemask_t *nodes)
 {
 	struct mempolicy *new, *old;
-	struct mm_struct *mm = current->mm;
+	struct task_struct *curr = current;
+	struct mm_struct *mm = curr->mm;
 	NODEMASK_SCRATCH(scratch);
 	int ret;
 
@@ -734,22 +736,22 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
 	 */
 	if (mm)
 		down_write(&mm->mmap_sem);
-	task_lock(current);
+	task_lock(curr);
 	ret = mpol_set_nodemask(new, nodes, scratch);
 	if (ret) {
-		task_unlock(current);
+		task_unlock(curr);
 		if (mm)
 			up_write(&mm->mmap_sem);
 		mpol_put(new);
 		goto out;
 	}
-	old = current->mempolicy;
-	current->mempolicy = new;
+	old = curr->mempolicy;
+	curr->mempolicy = new;
 	mpol_set_task_struct_flag();
 	if (new && new->mode == MPOL_INTERLEAVE &&
 	    nodes_weight(new->v.nodes))
-		current->il_next = first_node(new->v.nodes);
-	task_unlock(current);
+		curr->il_next = first_node(new->v.nodes);
+	task_unlock(curr);
 	if (mm)
 		up_write(&mm->mmap_sem);
 
@@ -805,9 +807,10 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 			     unsigned long addr, unsigned long flags)
 {
 	int err;
-	struct mm_struct *mm = current->mm;
+	struct task_struct *curr = current;
+	struct mm_struct *mm = curr->mm;
 	struct vm_area_struct *vma = NULL;
-	struct mempolicy *pol = current->mempolicy;
+	struct mempolicy *pol = curr->mempolicy;
 
 	if (flags &
 		~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
@@ -817,9 +820,9 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 		if (flags & (MPOL_F_NODE|MPOL_F_ADDR))
 			return -EINVAL;
 		*policy = 0;	/* just so it's initialized */
-		task_lock(current);
+		task_lock(curr);
 		*nmask  = cpuset_current_mems_allowed;
-		task_unlock(current);
+		task_unlock(curr);
 		return 0;
 	}
 
@@ -851,9 +854,9 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 			if (err < 0)
 				goto out;
 			*policy = err;
-		} else if (pol == current->mempolicy &&
+		} else if (pol == curr->mempolicy &&
 				pol->mode == MPOL_INTERLEAVE) {
-			*policy = current->il_next;
+			*policy = curr->il_next;
 		} else {
 			err = -EINVAL;
 			goto out;
@@ -869,7 +872,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	}
 
 	if (vma) {
-		up_read(&current->mm->mmap_sem);
+		up_read(&mm->mmap_sem);
 		vma = NULL;
 	}
 
@@ -878,16 +881,16 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 		if (mpol_store_user_nodemask(pol)) {
 			*nmask = pol->w.user_nodemask;
 		} else {
-			task_lock(current);
+			task_lock(curr);
 			get_policy_nodemask(pol, nmask);
-			task_unlock(current);
+			task_unlock(curr);
 		}
 	}
 
  out:
 	mpol_cond_put(pol);
 	if (vma)
-		up_read(&current->mm->mmap_sem);
+		up_read(&mm->mmap_sem);
 	return err;
 }
 
@@ -1912,22 +1915,23 @@ EXPORT_SYMBOL(alloc_pages_current);
 /* Slow path of a mempolicy duplicate */
 struct mempolicy *__mpol_dup(struct mempolicy *old)
 {
+	struct task_struct *curr = current;
 	struct mempolicy *new = kmem_cache_alloc(policy_cache, GFP_KERNEL);
 
 	if (!new)
 		return ERR_PTR(-ENOMEM);
 
 	/* task's mempolicy is protected by alloc_lock */
-	if (old == current->mempolicy) {
-		task_lock(current);
+	if (old == curr->mempolicy) {
+		task_lock(curr);
 		*new = *old;
-		task_unlock(current);
+		task_unlock(curr);
 	} else
 		*new = *old;
 
 	rcu_read_lock();
 	if (current_cpuset_is_being_rebound()) {
-		nodemask_t mems = cpuset_mems_allowed(current);
+		nodemask_t mems = cpuset_mems_allowed(curr);
 		if (new->flags & MPOL_F_REBINDING)
 			mpol_rebind_policy(new, &mems, MPOL_REBIND_STEP2);
 		else
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
