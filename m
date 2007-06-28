Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200706280001.16383.ak@suse.de>
References: <20070625195224.21210.89898.sendpatchset@localhost>
	 <1182968078.4948.30.camel@localhost>
	 <Pine.LNX.4.64.0706271427400.31227@schroedinger.engr.sgi.com>
	 <200706280001.16383.ak@suse.de>
Content-Type: text/plain
Date: Thu, 28 Jun 2007 09:42:17 -0400
Message-Id: <1183038137.5697.16.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-06-28 at 00:01 +0200, Andi Kleen wrote:
> > The zonelist from MPOL_BIND is passed to __alloc_pages. As a result the 
> > RCU lock must be held over the call into the page allocator with reclaim 
> > etc etc. Note that the zonelist is part of the policy structure.
> 
> Yes I realized this at some point too. RCU doesn't work here because
> __alloc_pages can sleep. Have to use the reference counts even though
> it adds atomic operations.
> 
> > I think one prerequisite to memory policy uses like this is work out how a 
> > memory policy can be handled by the page allocator in such a way that
> > 
> > 1. The use is lightweight and does not impact performance.
> 
> The current mempolicies are all lightweight and zero cost in the main
> allocator path.
> 
> The only outlier is still cpusets which does strange stuff, but you
> can't blame mempolicies for that.

Andi, Christoph:

Here is a proposed approach for reference counting based on my factoring
of alloc_page_vma() into get_vma_policy() and alloc_page_pol().   I've
created a patch that would slot into my shared policy series after
#6--the factoring mentioned above.  I've tried to avoid taking a
reference count in the common cases of default system policy and the
current task's mempolicy.  I think it's safe and, I hope, less costly to
do the tests and avoid the ref than to go ahead and acquire the cache
line for write.

I'm not sure that the check for current task's policy is necessary in
get_file_policy() because it is always called in the context of the
current task--i.e., task == current.  I'm not even sure that we need the
task argument to get_file_policy.  I included it to match the call
to get_vma_policy().  Could [should?] probably be removed.  

Note, I've updated my series slightly since last post, to avoid using a
pseudo-vma in shmem_alloc_page(); adding some additional
documentation, ...  You'll see this in the patch below.  I can send the
revised patch #6 if you like.  I still need to think about
shmem_swapin_async() and read_swap_cache_async().  With some work, I
think I can avoid the pseudo vma there as well.  Later, tho'.

Here's the patch-untested.  thoughts on this approach?

Shared Mapped File Policy "6.1/11" fix policy reference counts

This patch acquires a reference count on vma policy and on task policy
when acquired from a task with a different policy--e.g., from
show_numa_map()--and frees that reference after allocating a page or
after converting the policy to a displayable string in show_numa_map().

Avoid the taking the reference count on the system default policy or the
current task's task policy.  Note that if show_numa_map() is called from
the context of a relative of the target task with the same task mempolicy,
we won't take an extra reference either.  This is safe, because the policy
remains referenced by the calling task during the mpol_to_str() processing.

Call __mpol_free() [a.k.a. the "slow path"] directly from alloc_page_pol()
and show_numa_map(), where we know we have non-NULL policy, if policy is
not the system default policy and not the current task's policy.  By
calling __mpol_free() directly in these two places, we avoid the extra
check for null policy in mpol_free() [admittedly a "cheap check"].

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c |   35 ++++++++++++++++++++++++++++-------
 mm/shmem.c     |    1 -
 2 files changed, 28 insertions(+), 8 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-06-28 09:14:39.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-06-28 09:34:20.000000000 -0400
@@ -1124,25 +1124,32 @@ asmlinkage long compat_sys_mbind(compat_
  * @task  - fall back to this task's policy if no vma policy at @addr
  * @vma   - vma struct containing @addr and possible policy
  * @addr  - virtual address in @vma for which to get policy
+ * Note:  policy returned with an extra reference if the VMA has a non-NULL,
+ * non-DEFAULT  policy or the policy is the task policy for a task other
+ * than "current".
  */
 static struct mempolicy * get_vma_policy(struct task_struct *task,
 		struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = task->mempolicy;
+	int shared_pol = 0;
 
 	if (vma) {
 		/*
 		 * use get_policy op, if any, for shared mappings
 		 */
 		if ((vma->vm_flags & (VM_SHARED|VM_NONLINEAR)) == VM_SHARED &&
-			vma->vm_ops && vma->vm_ops->get_policy)
+			vma->vm_ops && vma->vm_ops->get_policy) {
 			pol = vma->vm_ops->get_policy(vma, addr);
-		else if (vma->vm_policy &&
+			shared_pol = 1;	/* if non-NULL, that is */
+		} else if (vma->vm_policy &&
 				vma->vm_policy->policy != MPOL_DEFAULT)
 			pol = vma->vm_policy;
 	}
 	if (!pol)
 		pol = &default_policy;
+	else if (!shared_pol && pol != current->mempolicy)
+		mpol_get(pol);
 	return pol;
 }
 
@@ -1158,11 +1165,17 @@ struct mempolicy *get_file_policy(struct
 {
 	struct shared_policy *sp = x->spolicy;
 	struct mempolicy *pol = task->mempolicy;
+	int shared_pol = 0;
 
-	if (sp)
+	if (sp) {
 		pol = mpol_shared_policy_lookup(sp, pgoff);
+		shared_pol = 1;	/* if non-NULL, that is */
+	}
+
 	if (!pol)
 		pol = &default_policy;
+	else if (!shared_pol && pol != current->mempolicy)
+		mpol_get(pol);
 	return pol;
 }
 
@@ -1290,18 +1303,23 @@ static struct page *alloc_page_interleav
 /*
  * alloc_page_pol() -- allocate a page based on policy,offset.
  * @gfp   - gfp mask [flags + zone] for allocation
- * @pol   - policy to use for allocation
+ * @pol   - policy to use for allocation; must mpol_free()
  * @pgoff - page offset for interleaving -- used only if interleave policy
  */
 struct page *alloc_page_pol(gfp_t gfp, struct mempolicy *pol, pgoff_t pgoff)
 {
+	struct page *page;
+
 	if (unlikely(pol->policy == MPOL_INTERLEAVE)) {
 		unsigned nid;
 
 		nid = offset_il_node(pol, pgoff);
 		return alloc_page_interleave(gfp, 0, nid);
 	}
-	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
+	page =  __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
+	if (pol != &default_policy && pol != current->mempolicy)
+		__mpol_free(pol);
+	return page;
 }
 EXPORT_SYMBOL(alloc_page_pol);
 
@@ -2018,6 +2036,7 @@ int show_numa_map(struct seq_file *m, vo
 	struct numa_maps *md;
 	struct file *file = vma->vm_file;
 	struct mm_struct *mm = vma->vm_mm;
+	struct mempolicy *pol;
 	int n;
 	char buffer[50];
 
@@ -2028,8 +2047,10 @@ int show_numa_map(struct seq_file *m, vo
 	if (!md)
 		return 0;
 
-	mpol_to_str(buffer, sizeof(buffer),
-			    get_vma_policy(priv->task, vma, priv->saddr));
+	pol = get_vma_policy(priv->task, vma, priv->saddr);
+	mpol_to_str(buffer, sizeof(buffer), pol);
+	if (pol != &default_policy && pol != current->mempolicy)
+		__mpol_free(pol);
 
 	seq_printf(m, "%08lx %s", priv->saddr, buffer);
 
Index: Linux/mm/shmem.c
===================================================================
--- Linux.orig/mm/shmem.c	2007-06-28 09:14:57.000000000 -0400
+++ Linux/mm/shmem.c	2007-06-28 09:27:33.000000000 -0400
@@ -1005,7 +1005,6 @@ shmem_alloc_page(gfp_t gfp, struct share
 
 	pol = mpol_shared_policy_lookup(sp, idx);
 	page = alloc_page_pol(gfp | __GFP_ZERO, pol, idx);
-	mpol_free(pol);
 	return page;
 }
 #else




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
