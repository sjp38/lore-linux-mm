From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 06 Dec 2007 16:20:59 -0500
Message-Id: <20071206212059.6279.64810.sendpatchset@localhost>
In-Reply-To: <20071206212047.6279.10881.sendpatchset@localhost>
References: <20071206212047.6279.10881.sendpatchset@localhost>
Subject: [PATCH/RFC 2/8] Mem Policy: Fixup Fallback for Default Shmem Policy
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, clameter@sgi.com, ak@suse.de, eric.whitney@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

PATCH/RFC 02/08 Mem Policy:  Fixup Fallback for Default Shmem/Shm Policy

Against:  2.6.24-rc2-mm1

get_vma_policy() is not handling fallback to task policy correctly
when the get_policy() vm_op returns NULL.  The NULL overwrites
the 'pol' variable that was holding the fallback task mempolicy.
So, it was falling back directly to system default policy.

Fix get_vma_policy() to use only non-NULL policy returned from
the vma get_policy op.

shm_get_policy() was falling back to current task's mempolicy if
the "backing file system" [tmpfs vs hugetlbfs] does not support
the get_policy vm_op and the vma policy is null.  This is incorrect
for show_numa_maps() which is likely querying the numa_maps of
some task other than current.  Remove this fallback.

Like get_vma_policy(), do_get_mempolicy() was potentially overwriting
the pol variable, which contains the current task's mempolicy as
first fallback, with a NULL policy.  This would cause incorrect
fallback to system default policy, instead of any non-NULL task
mempolicy.  Further, do_get_mempolicy() duplicates code in 
get_vma_policy().  Change do_get_mempolicy() to call get_vma_policy()
when MPOL_F_ADDR specified.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 ipc/shm.c      |    2 --
 mm/mempolicy.c |   20 +++++++++++---------
 2 files changed, 11 insertions(+), 11 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-11-28 12:58:36.000000000 -0500
+++ Linux/mm/mempolicy.c	2007-11-28 13:01:58.000000000 -0500
@@ -110,6 +110,8 @@ struct mempolicy default_policy = {
 	.policy = MPOL_DEFAULT,
 };
 
+static struct mempolicy *get_vma_policy(struct task_struct *task,
+		struct vm_area_struct *vma, unsigned long addr);
 static void mpol_rebind_policy(struct mempolicy *pol,
                                const nodemask_t *newmask);
 
@@ -543,15 +545,12 @@ static long do_get_mempolicy(int *policy
 			up_read(&mm->mmap_sem);
 			return -EFAULT;
 		}
-		if (vma->vm_ops && vma->vm_ops->get_policy)
-			pol = vma->vm_ops->get_policy(vma, addr);
-		else
-			pol = vma->vm_policy;
-	} else if (addr)
+		pol = get_vma_policy(current, vma, addr);
+	} else if (addr) {
 		return -EINVAL;
-
-	if (!pol)
+	} else if (!pol) {
 		pol = &default_policy;
+	}
 
 	if (flags & MPOL_F_NODE) {
 		if (flags & MPOL_F_ADDR) {
@@ -1116,7 +1115,7 @@ asmlinkage long compat_sys_mbind(compat_
  * @task != current].  It is the caller's responsibility to
  * free the reference in these cases.
  */
-static struct mempolicy * get_vma_policy(struct task_struct *task,
+static struct mempolicy *get_vma_policy(struct task_struct *task,
 		struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = task->mempolicy;
@@ -1124,7 +1123,10 @@ static struct mempolicy * get_vma_policy
 
 	if (vma) {
 		if (vma->vm_ops && vma->vm_ops->get_policy) {
-			pol = vma->vm_ops->get_policy(vma, addr);
+			struct mempolicy *vpol = vma->vm_ops->get_policy(vma,
+									addr);
+			if (vpol)
+				pol = vpol;
 			shared_pol = 1;	/* if pol non-NULL, add ref below */
 		} else if (vma->vm_policy &&
 				vma->vm_policy->policy != MPOL_DEFAULT)
Index: Linux/ipc/shm.c
===================================================================
--- Linux.orig/ipc/shm.c	2007-11-28 12:02:42.000000000 -0500
+++ Linux/ipc/shm.c	2007-11-28 13:01:58.000000000 -0500
@@ -273,8 +273,6 @@ static struct mempolicy *shm_get_policy(
 		pol = sfd->vm_ops->get_policy(vma, addr);
 	else if (vma->vm_policy)
 		pol = vma->vm_policy;
-	else
-		pol = current->mempolicy;
 	return pol;
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
