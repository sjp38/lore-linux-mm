Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 3F7736B00EF
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:06 -0400 (EDT)
Message-Id: <20120316144241.413417456@chello.nl>
Date: Fri, 16 Mar 2012 15:40:48 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 20/26] mm, mpol: Introduce vma_dup_policy()
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-vma_dup_policy.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

In preparation of other changes, pull some code duplication in a
common function so that we can later extend its behaviour without
having to touch all these sites.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mempolicy.h |    3 +++
 kernel/fork.c             |    9 +++------
 mm/mempolicy.c            |   11 +++++++++++
 mm/mmap.c                 |   17 +++++------------
 4 files changed, 22 insertions(+), 18 deletions(-)
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -168,6 +168,8 @@ static inline struct mempolicy *mpol_dup
 #define vma_policy(vma) ((vma)->vm_policy)
 #define vma_set_policy(vma, pol) ((vma)->vm_policy = (pol))
 
+extern int vma_dup_policy(struct vm_area_struct *new, struct vm_area_struct *old);
+
 static inline void mpol_get(struct mempolicy *pol)
 {
 	if (pol)
@@ -311,6 +313,7 @@ mpol_shared_policy_lookup(struct shared_
 
 #define vma_policy(vma) NULL
 #define vma_set_policy(vma, pol) do {} while(0)
+#define vma_dup_policy(new, old) (0)
 
 static inline void numa_policy_init(void)
 {
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -315,7 +315,6 @@ static int dup_mmap(struct mm_struct *mm
 	struct rb_node **rb_link, *rb_parent;
 	int retval;
 	unsigned long charge;
-	struct mempolicy *pol;
 
 	down_write(&oldmm->mmap_sem);
 	flush_cache_dup_mm(oldmm);
@@ -365,11 +364,9 @@ static int dup_mmap(struct mm_struct *mm
 			goto fail_nomem;
 		*tmp = *mpnt;
 		INIT_LIST_HEAD(&tmp->anon_vma_chain);
-		pol = mpol_dup(vma_policy(mpnt));
-		retval = PTR_ERR(pol);
-		if (IS_ERR(pol))
+		retval = vma_dup_policy(tmp, mpnt);
+		if (retval)
 			goto fail_nomem_policy;
-		vma_set_policy(tmp, pol);
 		tmp->vm_mm = mm;
 		if (anon_vma_fork(tmp, mpnt))
 			goto fail_nomem_anon_vma_fork;
@@ -431,7 +428,7 @@ static int dup_mmap(struct mm_struct *mm
 	up_write(&oldmm->mmap_sem);
 	return retval;
 fail_nomem_anon_vma_fork:
-	mpol_put(pol);
+	mpol_put(vma_policy(tmp));
 fail_nomem_policy:
 	kmem_cache_free(vm_area_cachep, tmp);
 fail_nomem:
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1971,6 +1971,17 @@ struct mempolicy *__mpol_dup(struct memp
 	return new;
 }
 
+int vma_dup_policy(struct vm_area_struct *new, struct vm_area_struct *old)
+{
+	struct mempolicy *mpol;
+
+	mpol = mpol_dup(vma_policy(old));
+	if (IS_ERR(mpol))
+		return PTR_ERR(mpol);
+	vma_set_policy(new, mpol);
+	return 0;
+}
+
 /*
  * If *frompol needs [has] an extra ref, copy *frompol to *tompol ,
  * eliminate the * MPOL_F_* flags that require conditional ref and
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1935,7 +1935,6 @@ detach_vmas_to_be_unmapped(struct mm_str
 static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 	      unsigned long addr, int new_below)
 {
-	struct mempolicy *pol;
 	struct vm_area_struct *new;
 	int err = -ENOMEM;
 
@@ -1959,12 +1958,9 @@ static int __split_vma(struct mm_struct
 		new->vm_pgoff += ((addr - vma->vm_start) >> PAGE_SHIFT);
 	}
 
-	pol = mpol_dup(vma_policy(vma));
-	if (IS_ERR(pol)) {
-		err = PTR_ERR(pol);
+	err = vma_dup_policy(new, vma);
+	if (err)
 		goto out_free_vma;
-	}
-	vma_set_policy(new, pol);
 
 	if (anon_vma_clone(new, vma))
 		goto out_free_mpol;
@@ -1998,7 +1994,7 @@ static int __split_vma(struct mm_struct
 	}
 	unlink_anon_vmas(new);
  out_free_mpol:
-	mpol_put(pol);
+	mpol_put(new->vm_policy);
  out_free_vma:
 	kmem_cache_free(vm_area_cachep, new);
  out_err:
@@ -2331,7 +2327,6 @@ struct vm_area_struct *copy_vma(struct v
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *new_vma, *prev;
 	struct rb_node **rb_link, *rb_parent;
-	struct mempolicy *pol;
 	bool faulted_in_anon_vma = true;
 
 	/*
@@ -2372,13 +2367,11 @@ struct vm_area_struct *copy_vma(struct v
 		new_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 		if (new_vma) {
 			*new_vma = *vma;
-			pol = mpol_dup(vma_policy(vma));
-			if (IS_ERR(pol))
+			if (vma_dup_policy(new_vma, vma))
 				goto out_free_vma;
 			INIT_LIST_HEAD(&new_vma->anon_vma_chain);
 			if (anon_vma_clone(new_vma, vma))
 				goto out_free_mempol;
-			vma_set_policy(new_vma, pol);
 			new_vma->vm_start = addr;
 			new_vma->vm_end = addr + len;
 			new_vma->vm_pgoff = pgoff;
@@ -2399,7 +2392,7 @@ struct vm_area_struct *copy_vma(struct v
 	return new_vma;
 
  out_free_mempol:
-	mpol_put(pol);
+	mpol_put(new_vma->vm_policy);
  out_free_vma:
 	kmem_cache_free(vm_area_cachep, new_vma);
 	return NULL;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
