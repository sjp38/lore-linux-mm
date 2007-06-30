Subject: [PATCH/RFC] Fix Mempolicy Ref Counts - was Re: [PATCH/RFC 0/11]
	Shared Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200706291942.06679.ak@suse.de>
References: <20070625195224.21210.89898.sendpatchset@localhost>
	 <200706290002.12113.ak@suse.de> <1183137257.5012.12.camel@localhost>
	 <200706291942.06679.ak@suse.de>
Content-Type: text/plain
Date: Sat, 30 Jun 2007 14:34:06 -0400
Message-Id: <1183228446.6975.10.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-06-29 at 19:42 +0200, Andi Kleen wrote:
> > Andi:  I could restore the tail call for the common cases of system
> > default and task policy, but that would require a second call to
> > __alloc_pages(), I think, for the shared and vma policies.  What do you
> > think about that solution?
> 
> Fine

Andi:

Here's a possible fix for the mempolicy reference counting.  Uncompiled,
untested, probably bogus, against 2.6.22-rc4-mm2 [what I have on my
laptop; no time to refresh right now].  I attempted to extract the
earlier patch from my shared policy series and restored the tail call
for the "common cases".  Probably 

I think it's a bit late to get into .22, but I wanted to send this to
you in case you wanted to fix this up and try.  I'll be mostly off-line
for the next week.

Regards,
Lee

----------
PATCH fix reference counting for memory policy

Against 2.6.22-rc4-mm2; UNTESTED

This patch proposes fixes to the reference counting of memory policy
in the page allocation path [alloc_page_vma()] and in show_numa_map().

Shared policy lookup [shmem] has always added a reference to the
policy, but this was never unrefed after page allocation or after
formatting the numa map data.  

Default system policy should not require additional ref counting,
nor should the current task's task policy.  However, show_numa_map()
calls get_vma_policy() to examine what may be [likely is] another
task's policy.  The latter case needs protection against freeing
of the policy.

This patch adds a reference count to a mempolicy returned by
get_vma_policy() when the policy is a vma policy or another
task's mempolicy.  [Again, shared policy is already reference
counted on lookup.] A matching "unref" [__mpol_free()] is performed
in alloc_page_vma() for shared and vma policies, and in
show_numa_map() for shared and another task's mempolicy.
We can call __mpol_free() directly, saving an admittedly
inexpensive inline NULL test, because we know we have a non-NULL
policy.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c |   33 ++++++++++++++++++++++++++++-----
 1 file changed, 28 insertions(+), 5 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-06-30 12:56:51.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-06-30 13:49:12.000000000 -0400
@@ -1077,16 +1077,20 @@ static struct mempolicy * get_vma_policy
 		struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = task->mempolicy;
+	int shared_pol = 0;
 
 	if (vma) {
-		if (vma->vm_ops && vma->vm_ops->get_policy)
+		if (vma->vm_ops && vma->vm_ops->get_policy) {
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
+		mpol_get(pol);	/* vma or other task's policy */
 	return pol;
 }
 
@@ -1259,6 +1263,7 @@ struct page *
 alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
+	struct zonelist *zl;
 
 	cpuset_update_task_memory_state();
 
@@ -1268,7 +1273,19 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
 		return alloc_page_interleave(gfp, 0, nid);
 	}
-	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
+	zl = zonelist_policy(gfp, pol);
+	if (pol != &default_policy && pol != current->mempolicy) {
+		/*
+		 * slow path: ref counted policy -- shared or vma
+		 */
+		struct page *page =  __alloc_pages(gfp, 0, zl);
+		__mpol_free(pol);
+		return page;
+	}
+	/*
+	 * fast path:  default or task policy
+	 */
+	return __alloc_pages(gfp, 0, zl);
 }
 
 /**
@@ -1914,6 +1931,7 @@ int show_numa_map(struct seq_file *m, vo
 	struct numa_maps *md;
 	struct file *file = vma->vm_file;
 	struct mm_struct *mm = vma->vm_mm;
+	struct mempolicy *pol;
 	int n;
 	char buffer[50];
 
@@ -1924,8 +1942,13 @@ int show_numa_map(struct seq_file *m, vo
 	if (!md)
 		return 0;
 
-	mpol_to_str(buffer, sizeof(buffer),
-			    get_vma_policy(priv->task, vma, vma->vm_start));
+	pol = get_vma_policy(priv->task, vma, vma->vm_start);
+	mpol_to_str(buffer, sizeof(buffer), pol);
+	/*
+	 * unref shared or other task's mempolicy
+	 */
+	if (pol != &default_policy && pol != current->mempolicy)
+		__mpol_free(pol);
 
 	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
