Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 74FDA6B006C
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 12:42:32 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/5] mempolicy: fix a memory corruption by refcount imbalance in alloc_pages_vma()
Date: Mon, 20 Aug 2012 17:36:34 +0100
Message-Id: <1345480594-27032-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1345480594-27032-1-git-send-email-mgorman@suse.de>
References: <1345480594-27032-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Ben Hutchings <ben@decadent.org.uk>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

[cc9a6c87: cpuset: mm: reduce large amounts of memory barrier related damage
v3] introduced a potential memory corruption. shmem_alloc_page() uses a
pseudo vma and it has one significant unique combination, vma->vm_ops=NULL
and vma->policy->flags & MPOL_F_SHARED.

get_vma_policy() does NOT increase a policy ref when vma->vm_ops=NULL and
mpol_cond_put() DOES decrease a policy ref when a policy has MPOL_F_SHARED.
Therefore, when a cpuset update race occurs, alloc_pages_vma() falls in 'goto
retry_cpuset' path, decrements the reference count and frees the policy
prematurely.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/mempolicy.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 45f9825..82e872f 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1545,15 +1545,28 @@ struct mempolicy *get_vma_policy(struct task_struct *task,
 		struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = task->mempolicy;
+	int got_ref;
 
 	if (vma) {
 		if (vma->vm_ops && vma->vm_ops->get_policy) {
 			struct mempolicy *vpol = vma->vm_ops->get_policy(vma,
 									addr);
-			if (vpol)
+			if (vpol) {
 				pol = vpol;
-		} else if (vma->vm_policy)
+				got_ref = 1;
+			}
+		} else if (vma->vm_policy) {
 			pol = vma->vm_policy;
+
+			/*
+			 * shmem_alloc_page() passes MPOL_F_SHARED policy with
+			 * a pseudo vma whose vma->vm_ops=NULL. Take a reference
+			 * count on these policies which will be dropped by
+			 * mpol_cond_put() later
+			 */
+			if (mpol_needs_cond_ref(pol))
+				mpol_get(pol);
+		}
 	}
 	if (!pol)
 		pol = &default_policy;
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
