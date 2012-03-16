Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 94B3B6B00F1
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:07 -0400 (EDT)
Message-Id: <20120316144241.477101322@chello.nl>
Date: Fri, 16 Mar 2012 15:40:49 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 21/26] mm, mpol: Introduce vma_put_policy()
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=mpol-vma_put_policy.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

In preparation of other changes, create a new interface so that we can
later extend its behaviour without having to touch all these sites.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mempolicy.h |    5 +++++
 mm/mempolicy.c            |    5 +++++
 mm/mmap.c                 |    8 ++++----
 3 files changed, 14 insertions(+), 4 deletions(-)

--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -169,6 +169,7 @@ static inline struct mempolicy *mpol_dup
 #define vma_set_policy(vma, pol) ((vma)->vm_policy = (pol))
 
 extern int vma_dup_policy(struct vm_area_struct *new, struct vm_area_struct *old);
+extern void vma_put_policy(struct vm_area_struct *vma);
 
 static inline void mpol_get(struct mempolicy *pol)
 {
@@ -315,6 +316,10 @@ mpol_shared_policy_lookup(struct shared_
 #define vma_set_policy(vma, pol) do {} while(0)
 #define vma_dup_policy(new, old) (0)
 
+static inline void vma_put_policy(struct vm_area_struct *)
+{
+}
+
 static inline void numa_policy_init(void)
 {
 }
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1982,6 +1982,11 @@ int vma_dup_policy(struct vm_area_struct
 	return 0;
 }
 
+void vma_put_policy(struct vm_area_struct *vma)
+{
+	mpol_put(vma_policy(vma));
+}
+
 /*
  * If *frompol needs [has] an extra ref, copy *frompol to *tompol ,
  * eliminate the * MPOL_F_* flags that require conditional ref and
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -236,7 +236,7 @@ static struct vm_area_struct *remove_vma
 		if (vma->vm_flags & VM_EXECUTABLE)
 			removed_exe_file_vma(vma->vm_mm);
 	}
-	mpol_put(vma_policy(vma));
+	vma_put_policy(vma);
 	kmem_cache_free(vm_area_cachep, vma);
 	return next;
 }
@@ -633,7 +633,7 @@ again:			remove_next = 1 + (end > next->
 		if (next->anon_vma)
 			anon_vma_merge(vma, next);
 		mm->map_count--;
-		mpol_put(vma_policy(next));
+		vma_put_policy(next);
 		kmem_cache_free(vm_area_cachep, next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
@@ -1994,7 +1994,7 @@ static int __split_vma(struct mm_struct
 	}
 	unlink_anon_vmas(new);
  out_free_mpol:
-	mpol_put(new->vm_policy);
+	vma_put_policy(new);
  out_free_vma:
 	kmem_cache_free(vm_area_cachep, new);
  out_err:
@@ -2392,7 +2392,7 @@ struct vm_area_struct *copy_vma(struct v
 	return new_vma;
 
  out_free_mempol:
-	mpol_put(new_vma->vm_policy);
+	vma_put_policy(new_vma);
  out_free_vma:
 	kmem_cache_free(vm_area_cachep, new_vma);
 	return NULL;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
