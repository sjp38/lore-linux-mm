Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id CC15C6B0069
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 12:42:29 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/5] mempolicy: Remove mempolicy sharing
Date: Mon, 20 Aug 2012 17:36:31 +0100
Message-Id: <1345480594-27032-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1345480594-27032-1-git-send-email-mgorman@suse.de>
References: <1345480594-27032-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Ben Hutchings <ben@decadent.org.uk>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Dave Jones' system call fuzz testing tool "trinity" triggered the following
bug error with slab debugging enabled

[ 7613.229315] =============================================================================
[ 7613.229955] BUG numa_policy (Not tainted): Poison overwritten
[ 7613.230560] -----------------------------------------------------------------------------
[ 7613.230560]
[ 7613.231834] INFO: 0xffff880146498250-0xffff880146498250. First byte 0x6a instead of 0x6b
[ 7613.232518] INFO: Allocated in mpol_new+0xa3/0x140 age=46310 cpu=6 pid=32154
[ 7613.233188]  __slab_alloc+0x3d3/0x445
[ 7613.233877]  kmem_cache_alloc+0x29d/0x2b0
[ 7613.234564]  mpol_new+0xa3/0x140
[ 7613.235236]  sys_mbind+0x142/0x620
[ 7613.235929]  system_call_fastpath+0x16/0x1b
[ 7613.236640] INFO: Freed in __mpol_put+0x27/0x30 age=46268 cpu=6 pid=32154
[ 7613.237354]  __slab_free+0x2e/0x1de
[ 7613.238080]  kmem_cache_free+0x25a/0x260
[ 7613.238799]  __mpol_put+0x27/0x30
[ 7613.239515]  remove_vma+0x68/0x90
[ 7613.240223]  exit_mmap+0x118/0x140
[ 7613.240939]  mmput+0x73/0x110
[ 7613.241651]  exit_mm+0x108/0x130
[ 7613.242367]  do_exit+0x162/0xb90
[ 7613.243074]  do_group_exit+0x4f/0xc0
[ 7613.243790]  sys_exit_group+0x17/0x20
[ 7613.244507]  system_call_fastpath+0x16/0x1b
[ 7613.245212] INFO: Slab 0xffffea0005192600 objects=27 used=27 fp=0x          (null) flags=0x20000000004080
[ 7613.246000] INFO: Object 0xffff880146498250 @offset=592 fp=0xffff88014649b9d0

The problem is that the structure is being prematurely freed due to a
reference count imbalance. In the following case mbind(addr, len) should
replace the memory policies of both vma1 and vma2 and thus they will
become to share the same mempolicy and the new mempolicy will have the
MPOL_F_SHARED flag.

  +-------------------+-------------------+
  |     vma1          |     vma2(shmem)   |
  +-------------------+-------------------+
  |                                       |
 addr                                 addr+len

alloc_pages_vma() uses get_vma_policy() and mpol_cond_put() pair for
maintaining the mempolicy reference count. The current rule is that
get_vma_policy() only increments refcount for shmem VMA and mpol_conf_put()
only decrements refcount if the policy has MPOL_F_SHARED.

In above case, vma1 is not shmem vma and vma->policy has MPOL_F_SHARED!
The reference count will be decreased even though was not increased whenever
alloc_page_vma() is called. This has been broken since commit [52cd3b07:
mempolicy: rework mempolicy Reference Counting] in 2008.

There is another serious bug with the sharing of memory policies. Currently,
mempolicy rebind logic (it is called from cpuset rebinding) ignores a refcount
of mempolicy and override it forcibly. Thus, any mempolicy sharing may cause
mempolicy corruption. The bug was introduced by commit [68860ec1: cpusets:
automatic numa mempolicy rebinding].

Ideally, the shared policy handling would be rewritten to either properly
handle COW of the policy structures or at least reference count MPOL_F_SHARED
based exclusively on information within the policy.  However, this patch takes
the easier approach of disabling any policy sharing between VMAs. Each new
range allocated with sp_alloc will allocate a new policy, set the reference
count to 1 and drop the reference count of the old policy. This increases
the memory footprint but is not expected to be a major problem as mbind()
is unlikely to be used for fine-grained ranges. It is also inefficient
because it means we allocate a new policy even in cases where mbind_range()
could use the new_policy passed to it. However, it is more straight-forward
and the change should be invisible to the user.

[mgorman@suse.de: Edited changelog]
Reported-by: Dave Jones <davej@redhat.com>,
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>,
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: <stable@vger.kernel.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/mempolicy.c |   52 ++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 38 insertions(+), 14 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 22dcf9a..8025720 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -607,24 +607,39 @@ check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 	return first;
 }
 
-/* Apply policy to a single VMA */
-static int policy_vma(struct vm_area_struct *vma, struct mempolicy *new)
+/*
+ * Apply policy to a single VMA
+ * This must be called with the mmap_sem held for writing.
+ */
+static int vma_replace_policy(struct vm_area_struct *vma,
+						struct mempolicy *pol)
 {
-	int err = 0;
-	struct mempolicy *old = vma->vm_policy;
+	int err;
+	struct mempolicy *old;
+	struct mempolicy *new;
 
 	pr_debug("vma %lx-%lx/%lx vm_ops %p vm_file %p set_policy %p\n",
 		 vma->vm_start, vma->vm_end, vma->vm_pgoff,
 		 vma->vm_ops, vma->vm_file,
 		 vma->vm_ops ? vma->vm_ops->set_policy : NULL);
 
-	if (vma->vm_ops && vma->vm_ops->set_policy)
+	new = mpol_dup(pol);
+	if (IS_ERR(new))
+		return PTR_ERR(new);
+
+	if (vma->vm_ops && vma->vm_ops->set_policy) {
 		err = vma->vm_ops->set_policy(vma, new);
-	if (!err) {
-		mpol_get(new);
-		vma->vm_policy = new;
-		mpol_put(old);
+		if (err)
+			goto err_out;
 	}
+
+	old = vma->vm_policy;
+	vma->vm_policy = new; /* protected by mmap_sem */
+	mpol_put(old);
+
+	return 0;
+ err_out:
+	mpol_put(new);
 	return err;
 }
 
@@ -676,7 +691,7 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 			if (err)
 				goto out;
 		}
-		err = policy_vma(vma, new_pol);
+		err = vma_replace_policy(vma, new_pol);
 		if (err)
 			goto out;
 	}
@@ -2153,15 +2168,24 @@ static void sp_delete(struct shared_policy *sp, struct sp_node *n)
 static struct sp_node *sp_alloc(unsigned long start, unsigned long end,
 				struct mempolicy *pol)
 {
-	struct sp_node *n = kmem_cache_alloc(sn_cache, GFP_KERNEL);
+	struct sp_node *n;
+	struct mempolicy *newpol;
 
+	n = kmem_cache_alloc(sn_cache, GFP_KERNEL);
 	if (!n)
 		return NULL;
+
+	newpol = mpol_dup(pol);
+	if (IS_ERR(newpol)) {
+		kmem_cache_free(sn_cache, n);
+		return NULL;
+	}
+	newpol->flags |= MPOL_F_SHARED;
+
 	n->start = start;
 	n->end = end;
-	mpol_get(pol);
-	pol->flags |= MPOL_F_SHARED;	/* for unref */
-	n->policy = pol;
+	n->policy = newpol;
+
 	return n;
 }
 
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
