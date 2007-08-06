Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l76GbR8i014870
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:37:27 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l76GbRrt215072
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 10:37:27 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l76GbQgu000581
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 10:37:27 -0600
Date: Mon, 6 Aug 2007 09:37:26 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 1/5] Fix hugetlb pool allocation with empty nodes V9
Message-ID: <20070806163726.GK15714@us.ibm.com>
References: <20070806163254.GJ15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070806163254.GJ15714@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: anton@samba.org, lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

Fix hugetlb pool allocation with empty nodes V9

Anton found a problem with the hugetlb pool allocation when some nodes
have no memory (http://marc.info/?l=linux-mm&m=118133042025995&w=2). Lee
worked on versions that tried to fix it, but none were accepted.
Christoph has created a set of patches which allow for GFP_THISNODE
allocations to fail if the node has no memory and for exporting a
node_memory_map indicating which nodes have memory. Since mempolicy.c
already has a number of functions which support interleaving, create a
mempolicy when we invoke alloc_fresh_huge_page() that specifies
interleaving across all the nodes in node_memory_map, rather than custom
interleaving code in hugetlb.c. This requires adding some dummy
functions, and some declarations, in mempolicy.h to compile with NUMA or
!NUMA. Since interleave_nodes() assumes that il_next has been set
properly (and it usually has by a syscall), make sure the interleaving
starts on a valid node.

On a 4-node ppc64 box with 2 memoryless nodes:

Before:

Trying to clear the hugetlb pool
Done.       0 free
Trying to resize the pool to 100
Node 3 HugePages_Free:      0
Node 2 HugePages_Free:      0
Node 1 HugePages_Free:     75
Node 0 HugePages_Free:     25
Done. Initially     100 free

After:

Trying to clear the hugetlb pool
Done.       0 free
Trying to resize the pool to 100
Node 3 HugePages_Free:      0
Node 2 HugePages_Free:      0
Node 1 HugePages_Free:     50
Node 0 HugePages_Free:     50
Done. Initially     100 free

Tested on: 2-node IA64, 4-node ppc64 (2 memoryless nodes), 4-node ppc64
(no memoryless nodes), 4-node x86_64, !NUMA x86, 1-node x86 (NUMA-Q), 

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 3930de2..6848072 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -76,6 +76,8 @@ struct mempolicy {
  * The default fast path of a NULL MPOL_DEFAULT policy is always inlined.
  */
 
+extern struct mempolicy *mpol_new(int mode, nodemask_t *nodes);
+
 extern void __mpol_free(struct mempolicy *pol);
 static inline void mpol_free(struct mempolicy *pol)
 {
@@ -161,6 +163,10 @@ static inline void check_highest_zone(enum zone_type k)
 		policy_zone = k;
 }
 
+extern void set_first_interleave_node(nodemask_t mask);
+
+extern unsigned interleave_nodes(struct mempolicy *policy);
+
 int do_migrate_pages(struct mm_struct *mm,
 	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags);
 
@@ -176,6 +182,11 @@ static inline int mpol_equal(struct mempolicy *a, struct mempolicy *b)
 
 #define mpol_set_vma_default(vma) do {} while(0)
 
+static inline struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
+{
+	return NULL;
+}
+
 static inline void mpol_free(struct mempolicy *p)
 {
 }
@@ -253,6 +264,15 @@ static inline int do_migrate_pages(struct mm_struct *mm,
 static inline void check_highest_zone(int k)
 {
 }
+
+static inline void set_first_interleave_node(nodemask_t mask)
+{
+}
+
+static inline unsigned interleave_nodes(struct mempolicy *policy)
+{
+	return 0;
+}
 #endif /* CONFIG_NUMA */
 #endif /* __KERNEL__ */
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d7ca59d..4f320b4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -101,26 +101,23 @@ static void free_huge_page(struct page *page)
 	spin_unlock(&hugetlb_lock);
 }
 
-static int alloc_fresh_huge_page(void)
+static int alloc_fresh_huge_page(struct mempolicy *policy)
 {
-	static int prev_nid;
 	struct page *page;
 	int nid;
+	int start_nid = interleave_nodes(policy);
 
-	/*
-	 * Copy static prev_nid to local nid, work on that, then copy it
-	 * back to prev_nid afterwards: otherwise there's a window in which
-	 * a racer might pass invalid nid MAX_NUMNODES to alloc_pages_node.
-	 * But we don't need to use a spin_lock here: it really doesn't
-	 * matter if occasionally a racer chooses the same nid as we do.
-	 */
-	nid = next_node(prev_nid, node_online_map);
-	if (nid == MAX_NUMNODES)
-		nid = first_node(node_online_map);
-	prev_nid = nid;
+	nid = start_nid;
+
+	do {
+		page = alloc_pages_node(nid,
+				htlb_alloc_mask|__GFP_COMP|GFP_THISNODE,
+				HUGETLB_PAGE_ORDER);
+		if (page)
+			break;
+		nid = interleave_nodes(policy);
+	} while (nid != start_nid);
 
-	page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
-					HUGETLB_PAGE_ORDER);
 	if (page) {
 		set_compound_page_dtor(page, free_huge_page);
 		spin_lock(&hugetlb_lock);
@@ -162,18 +159,30 @@ fail:
 static int __init hugetlb_init(void)
 {
 	unsigned long i;
+	struct mempolicy *pol;
 
 	if (HPAGE_SHIFT == 0)
 		return 0;
 
-	for (i = 0; i < MAX_NUMNODES; ++i)
+	for_each_node_state(i, N_HIGH_MEMORY)
 		INIT_LIST_HEAD(&hugepage_freelists[i]);
 
+	pol = mpol_new(MPOL_INTERLEAVE, &node_states[N_HIGH_MEMORY]);
+	if (IS_ERR(pol))
+		goto quit;
+	/*
+	 * since the mempolicy we are using was not specified by a
+	 * process, we need to make sure il_next has a good starting
+	 * value
+	 */
+	set_first_interleave_node(node_states[N_HIGH_MEMORY]);
 	for (i = 0; i < max_huge_pages; ++i) {
-		if (!alloc_fresh_huge_page())
+		if (!alloc_fresh_huge_page(pol))
 			break;
 	}
+	mpol_free(pol);
 	max_huge_pages = free_huge_pages = nr_huge_pages = i;
+quit:
 	printk("Total HugeTLB memory allocated, %ld\n", free_huge_pages);
 	return 0;
 }
@@ -219,7 +228,7 @@ static void try_to_free_low(unsigned long count)
 {
 	int i;
 
-	for (i = 0; i < MAX_NUMNODES; ++i) {
+	for_each_node_state(i, N_HIGH_MEMORY)
 		struct page *page, *next;
 		list_for_each_entry_safe(page, next, &hugepage_freelists[i], lru) {
 			if (PageHighMem(page))
@@ -241,10 +250,22 @@ static inline void try_to_free_low(unsigned long count)
 
 static unsigned long set_max_huge_pages(unsigned long count)
 {
+	struct mempolicy *pol;
+
+	pol = mpol_new(MPOL_INTERLEAVE, &node_states[N_HIGH_MEMORY]);
+	if (IS_ERR(pol))
+		return nr_huge_pages;
+	/*
+	 * since the mempolicy we are using was not specified by a
+	 * process, we need to make sure il_next has a good starting
+	 * value
+	 */
+	set_first_interleave_node(node_states[N_HIGH_MEMORY]);
 	while (count > nr_huge_pages) {
-		if (!alloc_fresh_huge_page())
-			return nr_huge_pages;
+		if (!alloc_fresh_huge_page(pol))
+			break;
 	}
+	mpol_free(pol);
 	if (count >= nr_huge_pages)
 		return nr_huge_pages;
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 87eb69e..c069891 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -171,7 +171,7 @@ static struct zonelist *bind_zonelist(nodemask_t *nodes)
 }
 
 /* Create a new policy */
-static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
+struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
 {
 	struct mempolicy *policy;
 
@@ -1125,8 +1125,13 @@ static struct zonelist *zonelist_policy(gfp_t gfp, struct mempolicy *policy)
 	return NODE_DATA(nd)->node_zonelists + gfp_zone(gfp);
 }
 
+void set_first_interleave_node(nodemask_t mask)
+{
+	current->il_next = first_node(mask);
+}
+
 /* Do dynamic interleaving for a process */
-static unsigned interleave_nodes(struct mempolicy *policy)
+unsigned interleave_nodes(struct mempolicy *policy)
 {
 	unsigned nid, next;
 	struct task_struct *me = current;

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
