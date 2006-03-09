Subject: Re: [PATCH/RFC] Migrate-on-fault prototype 2/5 V0.1 - check for
	misplaced page
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <1141928947.6393.12.camel@localhost.localdomain>
References: <1141928947.6393.12.camel@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 09 Mar 2006 16:42:01 -0500
Message-Id: <1141940521.8326.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-03-09 at 13:29 -0500, Lee Schermerhorn wrote:
> Migrate-on-fault prototype 2/5 V0.1 - check for misplaced page
> 

Resend of 1/5 looked OK.  Here's #2 again:

Migrate-on-fault prototype 2/5 V0.1 - check for misplaced page

This patch provides a new function to test whether a page resides
on a node that is appropriate for the mempolicy for the vma and
address where the page is supposed to be mapped.  This involves
looking up the node where the page belongs.  So, the function
returns that node so that it may be used to allocated the page
without consulting the policy again.  Because interleaved and
non-interleaved allocations are accounted differently, the function
also returns whether or not the new node came from an interleaved
policy, if the page is misplaced.

A subsequent patch will call this function from the fault path for
stable pages with zero page_mapcount().  Because of this, I don't
want to go ahead and allocate the page, e.g., via alloc_page_vma()
only to have to free it if it has the correct policy.  So, I just
mimic the alloc_page_vma() node computation logic.

Note that for "process interleaving" the destination node depends
on the order of access to pages.  I.e., there is no fixed layout
for process interleaved pages, as there is for pages interleaved
via vma policy.  So, as long as the page resides on a node that
exists in the process's interleave set, no migration is indicated.
Having said that, we may never need to call this function without
a vma, so maybe we can lose that "feature".

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc5-git11/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc5-git11.orig/mm/mempolicy.c	2006-03-08 15:49:08.000000000 -0500
+++ linux-2.6.16-rc5-git11/mm/mempolicy.c	2006-03-08 15:49:41.000000000 -0500
@@ -1891,3 +1891,97 @@ out:
 	return 0;
 }
 
+
+/**
+ * mpol_misplaced - check whether current page node id valid in policy
+ *
+ * @page   - page to be checked
+ * @vma    - vm area where page mapped
+ * @addr   - virtual address where page mapped
+ * @newnid - [ptr to] node id to which page should be migrated
+ *
+ * lookup current policy node id for vma,addr and "compare to" page's
+ * node id.
+ * if same, return 0 -- reuse current page
+ * if different,
+ *     return destination nid via newnid
+ *     return MPOL_MIGRATE_NONINTERLEAVED for non-interleaved policy
+ *     return MPOL_MIGRATE_INTERLEAVED for interleaved policy.
+ * policy determination mimics alloc_page_vma()
+ */
+int mpol_misplaced(struct page *page, struct vm_area_struct *vma,
+			 unsigned long addr, int *newnid)
+{
+	struct mempolicy *pol = get_vma_policy(current, vma, addr);
+	struct zonelist *zl;
+	int curnid = page_to_nid(page);
+	int polnid = -1, interleave = 0;
+	int i;
+
+	cpuset_update_task_memory_state();
+
+	if (unlikely(pol->policy == MPOL_INTERLEAVE)) {
+		interleave = 1;	/* for accounting */
+		if (vma) {
+			unsigned long off;
+			BUG_ON(addr >= vma->vm_end);
+			BUG_ON(addr < vma->vm_start);
+			off = vma->vm_pgoff;
+			off += (addr - vma->vm_start) >> PAGE_SHIFT;
+			polnid = offset_il_node(pol, vma, off);
+		} else {
+//TODO:  can this ever happen?
+			/*
+			 * for process interleaving, just ensure that
+			 * curnid is in policy nodes -- to avoid thrashing
+			 */
+			if (node_isset(curnid, pol->v.nodes))
+				return 0;
+			polnid = interleave_nodes(pol);
+		}
+	} else
+		switch (pol->policy) {
+		case MPOL_PREFERRED:
+			polnid = pol->v.preferred_node;
+			if (polnid < 0)
+				polnid = numa_node_id();
+			break;
+		case MPOL_BIND:
+			/*
+			 * allows binding to multiple nodes.
+			 * use current page if in zonelist,
+			 * else select first allowed node
+			 */
+			zl = pol->v.zonelist;
+			for (i = 0; zl->zones[i]; i++) {
+				int nid = zl->zones[i]->zone_pgdat->node_id;
+
+				if (nid == curnid)
+					return 0;
+
+				if (polnid < 0 &&
+				    node_isset(nid, current->mems_allowed)) {
+					polnid = nid;
+				}
+			}
+			if (polnid >= 0)
+				break;
+			/*FALL THROUGH*/
+		case MPOL_INTERLEAVE: /* should not happen */
+		case MPOL_DEFAULT:
+			polnid = numa_node_id();
+			break;
+		default:
+			polnid = 0;
+			BUG();
+		}
+
+	if (curnid == polnid)
+		return 0;
+
+	*newnid = polnid;
+	if (interleave)
+		return MPOL_MIGRATE_INTERLEAVED;
+
+	return MPOL_MIGRATE_NONINTERLEAVED;
+}
Index: linux-2.6.16-rc5-git11/include/linux/mempolicy.h
===================================================================
--- linux-2.6.16-rc5-git11.orig/include/linux/mempolicy.h	2006-03-08 15:49:03.000000000 -0500
+++ linux-2.6.16-rc5-git11/include/linux/mempolicy.h	2006-03-08 15:49:41.000000000 -0500
@@ -172,6 +172,17 @@ static inline void check_highest_zone(in
 int do_migrate_pages(struct mm_struct *mm,
 	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags);
 
+/*
+ * mm/vmscan.c doesn't include mempolicy.  Keep knowledge of these
+ * macros' values internal to mempolicy.[ch]
+ */
+#define MPOL_MIGRATE_NONINTERLEAVED 1
+#define MPOL_MIGRATE_INTERLEAVED 2
+#define misplaced_is_interleaved(pol) (MPOL_MIGRATE_INTERLEAVED - 1)
+
+int mpol_misplaced(struct page *, struct vm_area_struct *,
+		unsigned long, int *);
+
 extern void *cpuset_being_rebound;	/* Trigger mpol_copy vma rebind */
 
 #else


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
