From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 12 Oct 2007 11:49:18 -0400
Message-Id: <20071012154918.8157.26655.sendpatchset@localhost>
In-Reply-To: <20071012154854.8157.51441.sendpatchset@localhost>
References: <20071012154854.8157.51441.sendpatchset@localhost>
Subject: [PATCH/RFC 4/4] Mem Policy: Fixup Fallback for Default Shmem Policy
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, ak@suse.de, eric.whitney@hp.com, clameter@sgi.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

PATCH 4/4 Mempolicy:  Fixup Fallback for Default Shmem Policy

Against:  2.6.23-rc8-mm2

Separated from previous multi-issue patch 2/2

get_vma_policy() was not handling fallback to task policy correctly
when the get_policy() vm_op returns NULL.  The NULL overwrites
the 'pol' variable that was holding the fallback task mempolicy.
So, it was falling back directly to system default policy.

Fix get_vma_policy() to use only non-NULL policy returned from
the vma get_policy op and indicate that this policy does not need
another ref count.  

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-10-12 10:50:05.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-10-12 10:52:46.000000000 -0400
@@ -1112,19 +1112,25 @@ static struct mempolicy * get_vma_policy
 		struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = task->mempolicy;
-	int shared_pol = 0;
+	int pol_needs_ref = (task != current);
 
 	if (vma) {
 		if (vma->vm_ops && vma->vm_ops->get_policy) {
-			pol = vma->vm_ops->get_policy(vma, addr);
-			shared_pol = 1;	/* if pol non-NULL, add ref below */
+			struct mempolicy *vpol = vma->vm_ops->get_policy(vma,
+									addr);
+			if (vpol) {
+				pol = vpol;
+				pol_needs_ref = 0; /* get_policy() added ref */
+			}
 		} else if (vma->vm_policy &&
-				vma->vm_policy->policy != MPOL_DEFAULT)
+				vma->vm_policy->policy != MPOL_DEFAULT) {
 			pol = vma->vm_policy;
+			pol_needs_ref++;
+		}
 	}
 	if (!pol)
 		pol = &default_policy;
-	else if (!shared_pol && pol != current->mempolicy)
+	else if (pol_needs_ref)
 		mpol_get(pol);	/* vma or other task's policy */
 	return pol;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
