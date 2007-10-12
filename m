From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 12 Oct 2007 11:49:06 -0400
Message-Id: <20071012154906.8157.94215.sendpatchset@localhost>
In-Reply-To: <20071012154854.8157.51441.sendpatchset@localhost>
References: <20071012154854.8157.51441.sendpatchset@localhost>
Subject: [PATCH/RFC 2/4] Mem Policy: Fixup Shm and Interleave Policy Reference Counting
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, clameter@sgi.com, ak@suse.de, eric.whitney@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

PATCH 2/4 Mem Policy:  fix reference counting for SHM_HUGETLB segments

Against: 2.6.23-rc8-mm2

Separated from previous multi-issue patch 2/2

NOTE:  w/o this fix, one will BUG-out on 2nd page fault to a
SHM_HUGETLB segment with memory policy applied via mbind().

get_vma_policy() assumes that shared policies are referenced by
the get_policy() vm_op, if any.  This is true for shmem_get_policy()
but not for shm_get_policy() when the "backing file" does not
support a get_policy() vm_op.  The latter is the case for SHM_HUGETLB
segments.  Because get_vma_policy() expects the get_policy() op to
have added a ref, it doesn't do so itself.  This results in 
premature freeing of the policy.  Add the mpol_get() to the 
shm_get_policy() op when the backing file doesn't support shared
policies.

Further, shm_get_policy() was falling back to current task's task
policy if the backing file did not support get_policy() vm_op and
the vma policy was null.  This is not valid when get_vma_policy() is
called from show_numa_map() as task != current.  Also, this did
not match the behavior of the shmem_get_policy() vm_op which did
NOT fall back to task policy.  So, modify shm_get_policy() NOT to
fall back to current->mempolicy.

Document mempolicy return value reference semantics assumed by
the changes discussed above for the set_ and get_policy vm_ops
in <linux/mm.h>--where the prototypes are defined.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: Linux/ipc/shm.c
===================================================================
--- Linux.orig/ipc/shm.c	2007-10-10 14:58:12.000000000 -0400
+++ Linux/ipc/shm.c	2007-10-10 14:59:13.000000000 -0400
@@ -263,10 +263,10 @@ static struct mempolicy *shm_get_policy(
 
 	if (sfd->vm_ops->get_policy)
 		pol = sfd->vm_ops->get_policy(vma, addr);
-	else if (vma->vm_policy)
+	else if (vma->vm_policy) {
 		pol = vma->vm_policy;
-	else
-		pol = current->mempolicy;
+		mpol_get(pol);		/* get_vma_policy() assumes this */
+	}
 	return pol;
 }
 #endif
Index: Linux/include/linux/mm.h
===================================================================
--- Linux.orig/include/linux/mm.h	2007-10-10 14:58:12.000000000 -0400
+++ Linux/include/linux/mm.h	2007-10-11 14:07:43.000000000 -0400
@@ -173,7 +173,21 @@ struct vm_operations_struct {
 	 * writable, if an error is returned it will cause a SIGBUS */
 	int (*page_mkwrite)(struct vm_area_struct *vma, struct page *page);
 #ifdef CONFIG_NUMA
+	/*
+	 * set_policy() op must add a reference to any non-NULL @new mempolicy
+	 * to hold the policy upon return.  Caller should pass NULL @new to
+	 * remove a policy and fall back to surrounding context--i.e. do not
+	 * install a MPOL_DEFAULT policy, nor the task or system default
+	 * mempolicy.
+	 */
 	int (*set_policy)(struct vm_area_struct *vma, struct mempolicy *new);
+
+	/*
+	 * get_policy() op must add reference [mpol_get()] to any mempolicy
+	 * at (vma,addr).  If no [shared/vma] mempolicy exists at that addr,
+	 * get_policy() op must return NULL--i.e., do not "fallback" to task
+	 * or system default policy.
+	 */
 	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
 					unsigned long addr);
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
