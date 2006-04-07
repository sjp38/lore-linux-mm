Received: from smtp1.fc.hp.com (smtp1.fc.hp.com [15.15.136.127])
	by atlrel7.hp.com (Postfix) with ESMTP id D8F70340D0
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:21:39 -0400 (EDT)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by smtp1.fc.hp.com (Postfix) with ESMTP id B176A1097F
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:21:39 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 8FCBD134250
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:21:39 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 21216-05 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:21:37 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id 4F27A134225
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:21:37 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 2/6] Migrate-on-fault - check for
	misplaced page
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441108.5198.36.camel@localhost.localdomain>
References: <1144441108.5198.36.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:23:01 -0400
Message-Id: <1144441382.5198.40.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Migrate-on-fault prototype 2/6 V0.2 - check for misplaced page

V0.2 -	reworked against 2.6.17-rc1-mm1 with Christoph's migration
	code reorg
	Also:	get vma policy after updating task's cpuset memory
		state.  Use mems_allowed in policy to vet nodes,
		but I'm not sure this check is necessary.

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

Index: linux-2.6.17-rc1-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.17-rc1-mm1.orig/mm/mempolicy.c	2006-04-06 16:45:13.000000000 -0400
+++ linux-2.6.17-rc1-mm1/mm/mempolicy.c	2006-04-06 16:47:14.000000000 -0400
@@ -1874,3 +1874,102 @@ out:
 	return 0;
 }
 
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
+	struct mempolicy *pol;
+	struct zonelist *zl;
+	nodemask_t *mems;
+	int curnid = page_to_nid(page);
+	int polnid = -1, interleave = 0;
+	int i;
+
+//TODO:  can we call this here, in the fault path [with mmap_sem held?]
+//       do we want to?  applications and systems that could benefit from
+//       migrate-on-fault probably want cpusets as well.
+	cpuset_update_task_memory_state();
+	pol = get_vma_policy(current, vma, addr);
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
+			mems = &pol->cpuset_mems_allowed;
+			zl = pol->v.zonelist;
+			for (i = 0; zl->zones[i]; i++) {
+				int nid = zl->zones[i]->zone_pgdat->node_id;
+
+				if (nid == curnid)
+					return 0;
+
+				if (polnid < 0 &&
+//TODO:  is this check necessary?
+					node_isset(nid, *mems))
+					polnid = nid;
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
Index: linux-2.6.17-rc1-mm1/include/linux/mempolicy.h
===================================================================
--- linux-2.6.17-rc1-mm1.orig/include/linux/mempolicy.h	2006-04-06 16:45:13.000000000 -0400
+++ linux-2.6.17-rc1-mm1/include/linux/mempolicy.h	2006-04-06 16:46:17.000000000 -0400
@@ -173,6 +173,17 @@ static inline void check_highest_zone(in
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
