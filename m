Date: Fri, 8 Jun 2007 18:39:07 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] numa: mempolicy: Trivial debug fixes.
Message-ID: <20070608093907.GA18808@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Enabling debugging fails to build due to the nodemask variable in
do_mbind() having changed names, and then oopses on boot due to the
assumption that the nodemask can be dereferenced -- which doesn't work
out so well when the policy is changed to MPOL_DEFAULT with a NULL
nodemask by numa_default_policy().

This fixes it up, and switches from PDprintk() to pr_debug() while
we're at it.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 mm/mempolicy.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d76e8eb..4d2b15a 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -101,8 +103,6 @@
 static struct kmem_cache *policy_cache;
 static struct kmem_cache *sn_cache;
 
-#define PDprintk(fmt...)
-
 /* Highest zone. An specific allocation for a zone below that is not
    policied. */
 enum zone_type policy_zone = 0;
@@ -175,7 +175,9 @@ static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
 {
 	struct mempolicy *policy;
 
-	PDprintk("setting mode %d nodes[0] %lx\n", mode, nodes_addr(*nodes)[0]);
+	pr_debug("setting mode %d nodes[0] %lx\n",
+		 mode, nodes ? nodes_addr(*nodes)[0] : -1);
+
 	if (mode == MPOL_DEFAULT)
 		return NULL;
 	policy = kmem_cache_alloc(policy_cache, GFP_KERNEL);
@@ -379,7 +381,7 @@ static int policy_vma(struct vm_area_struct *vma, struct mempolicy *new)
 	int err = 0;
 	struct mempolicy *old = vma->vm_policy;
 
-	PDprintk("vma %lx-%lx/%lx vm_ops %p vm_file %p set_policy %p\n",
+	pr_debug("vma %lx-%lx/%lx vm_ops %p vm_file %p set_policy %p\n",
 		 vma->vm_start, vma->vm_end, vma->vm_pgoff,
 		 vma->vm_ops, vma->vm_file,
 		 vma->vm_ops ? vma->vm_ops->set_policy : NULL);
@@ -776,8 +778,8 @@ long do_mbind(unsigned long start, unsigned long len,
 	if (!new)
 		flags |= MPOL_MF_DISCONTIG_OK;
 
-	PDprintk("mbind %lx-%lx mode:%ld nodes:%lx\n",start,start+len,
-			mode,nodes_addr(nodes)[0]);
+	pr_debug("mbind %lx-%lx mode:%ld nodes:%lx\n",start,start+len,
+		 mode, nmask ? nodes_addr(*nmask)[0] : -1);
 
 	down_write(&mm->mmap_sem);
 	vma = check_range(mm, start, end, nmask,
@@ -1434,7 +1436,7 @@ static void sp_insert(struct shared_policy *sp, struct sp_node *new)
 	}
 	rb_link_node(&new->nd, parent, p);
 	rb_insert_color(&new->nd, &sp->root);
-	PDprintk("inserting %lx-%lx: %d\n", new->start, new->end,
+	pr_debug("inserting %lx-%lx: %d\n", new->start, new->end,
 		 new->policy ? new->policy->policy : 0);
 }
 
@@ -1459,7 +1461,7 @@ mpol_shared_policy_lookup(struct shared_policy *sp, unsigned long idx)
 
 static void sp_delete(struct shared_policy *sp, struct sp_node *n)
 {
-	PDprintk("deleting %lx-l%x\n", n->start, n->end);
+	pr_debug("deleting %lx-l%lx\n", n->start, n->end);
 	rb_erase(&n->nd, &sp->root);
 	mpol_free(n->policy);
 	kmem_cache_free(sn_cache, n);
@@ -1558,10 +1560,10 @@ int mpol_set_shared_policy(struct shared_policy *info,
 	struct sp_node *new = NULL;
 	unsigned long sz = vma_pages(vma);
 
-	PDprintk("set_shared_policy %lx sz %lu %d %lx\n",
+	pr_debug("set_shared_policy %lx sz %lu %d %lx\n",
 		 vma->vm_pgoff,
 		 sz, npol? npol->policy : -1,
-		npol ? nodes_addr(npol->v.nodes)[0] : -1);
+		 npol ? nodes_addr(npol->v.nodes)[0] : -1);
 
 	if (npol) {
 		new = sp_alloc(vma->vm_pgoff, vma->vm_pgoff + sz, npol);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
