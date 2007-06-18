Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5IHYt9l010132
	for <linux-mm@kvack.org>; Mon, 18 Jun 2007 13:34:55 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5IHYtxN488536
	for <linux-mm@kvack.org>; Mon, 18 Jun 2007 13:34:55 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5IHYs1q013748
	for <linux-mm@kvack.org>; Mon, 18 Jun 2007 13:34:55 -0400
Date: Mon, 18 Jun 2007 10:34:28 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH 1/3] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070618173428.GB10714@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: anton@samba.org, lee.schermerhorn@hp.com, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Anton found a problem with the hugetlb pool allocation when some nodes
have no memory (http://marc.info/?l=linux-mm&m=118133042025995&w=2). Lee
worked on versions that tried to fix it, but none were accepted.
Christoph has created a set of patches which allow for GFP_THISNODE
allocations to fail if the node has no memory and for exporting a
node_memory_map indicating which nodes have memory. Since mempolicy.c
already has a number of functions which support interleaving, create a
mempolicy when we invoke alloc_fresh_huge_page() that specifies
interleaving across all the nodes in node_memory_map, rather than custom
interleaving code in hugetlb.c.  This requires adding some dummy
functions, and some declarations, in mempolicy.h to compile with NUMA or
!NUMA.

Compiled-test w/ NUMA and !NUMA. Run-tested with the follow-on patches
on 4-node ppc64 w/ 2 memoryless nodes and 4-node x86_64 w/ 0 memoryless
nodes.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Anton Blanchard <anton@samba.org>
Cc: Lee Schermerhorn <lee.schermerhon@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>
Cc: William Lee Irwin III <wli@holomorphy.com>

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 22b668c..c8a68b8 100644
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
@@ -164,6 +166,8 @@ static inline void check_highest_zone(enum zone_type k)
 		policy_zone = k;
 }
 
+extern unsigned interleave_nodes(struct mempolicy *policy);
+
 int do_migrate_pages(struct mm_struct *mm,
 	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags);
 
@@ -179,6 +183,11 @@ static inline int mpol_equal(struct mempolicy *a, struct mempolicy *b)
 
 #define mpol_set_vma_default(vma) do {} while(0)
 
+static inline struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
+{
+	return NULL;
+}
+
 static inline void mpol_free(struct mempolicy *p)
 {
 }
@@ -267,6 +276,11 @@ static inline int do_migrate_pages(struct mm_struct *mm,
 static inline void check_highest_zone(int k)
 {
 }
+
+static inline unsigned interleave_nodes(struct mempolicy *policy)
+{
+	return 0;
+}
 #endif /* CONFIG_NUMA */
 #endif /* __KERNEL__ */
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 858c0b3..88e1a30 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -103,15 +103,22 @@ static void free_huge_page(struct page *page)
 	spin_unlock(&hugetlb_lock);
 }
 
-static int alloc_fresh_huge_page(void)
+static int alloc_fresh_huge_page(struct mempolicy *policy)
 {
-	static int nid = 0;
+	int nid;
 	struct page *page;
-	page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
-					HUGETLB_PAGE_ORDER);
-	nid = next_node(nid, node_online_map);
-	if (nid == MAX_NUMNODES)
-		nid = first_node(node_online_map);
+	int start_nid = interleave_nodes(policy);
+
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
 	if (page) {
 		set_compound_page_dtor(page, free_huge_page);
 		spin_lock(&hugetlb_lock);
@@ -153,6 +160,7 @@ fail:
 static int __init hugetlb_init(void)
 {
 	unsigned long i;
+	struct mempolicy *pol;
 
 	if (HPAGE_SHIFT == 0)
 		return 0;
@@ -160,11 +168,16 @@ static int __init hugetlb_init(void)
 	for (i = 0; i < MAX_NUMNODES; ++i)
 		INIT_LIST_HEAD(&hugepage_freelists[i]);
 
+	pol = mpol_new(MPOL_INTERLEAVE, &node_memory_map);
+	if (IS_ERR(pol))
+		goto quit;
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
@@ -232,10 +245,16 @@ static inline void try_to_free_low(unsigned long count)
 
 static unsigned long set_max_huge_pages(unsigned long count)
 {
+	struct mempolicy *pol;
+
+	pol = mpol_new(MPOL_INTERLEAVE, &node_memory_map);
+	if (IS_ERR(pol))
+		return nr_huge_pages;
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
index d2289f3..00bf061 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -171,7 +171,7 @@ static struct zonelist *bind_zonelist(nodemask_t *nodes)
 }
 
 /* Create a new policy */
-static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
+struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
 {
 	struct mempolicy *policy;
 
@@ -1121,7 +1121,7 @@ static struct zonelist *zonelist_policy(gfp_t gfp, struct mempolicy *policy)
 }
 
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
