Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6EKbZp7007745
	for <linux-mm@kvack.org>; Sat, 14 Jul 2007 16:37:35 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6EKbZ2b261242
	for <linux-mm@kvack.org>; Sat, 14 Jul 2007 14:37:35 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6EKbYvl016259
	for <linux-mm@kvack.org>; Sat, 14 Jul 2007 14:37:34 -0600
Date: Sat, 14 Jul 2007 13:37:33 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH v8] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070714203733.GA17929@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: anton@samba.org, lee.schermerhorn@hp.com, wli@holomorphy.com, kxr@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fix hugetlb pool allocation with empty nodes

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

Compile tested on x86, x86_64 and ppc64. Run tested on 4-node x86-64 (no
memoryless nodes), non-NUMA x86 and 4-node ppc64 (2 memoryless nodes).

Depends on Christoph's memoryless node patch stack to guarantee THISNODE
allocations stay on the requested node.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Anton Blanchard <anton@samba.org>
Cc: Lee Schermerhorn <lee.schermerhon@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>
Cc: William Lee Irwin III <wli@holomorphy.com>
Cc: Keith Rich <kxr@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

---

 include/linux/mempolicy.h |   14 ++++++++++++++
 mm/hugetlb.c              |   39 +++++++++++++++++++++++++++++----------
 mm/mempolicy.c            |    4 ++--
 3 files changed, 45 insertions(+), 12 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 9e1734a..6d7099c 100644
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
@@ -162,6 +164,8 @@ static inline void check_highest_zone(enum zone_type k)
 		policy_zone = k;
 }
 
+extern unsigned interleave_nodes(struct mempolicy *policy);
+
 int do_migrate_pages(struct mm_struct *mm,
 	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags);
 
@@ -177,6 +181,11 @@ static inline int mpol_equal(struct mempolicy *a, struct mempolicy *b)
 
 #define mpol_set_vma_default(vma) do {} while(0)
 
+static inline struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
+{
+	return NULL;
+}
+
 static inline void mpol_free(struct mempolicy *p)
 {
 }
@@ -259,6 +268,11 @@ static inline int do_migrate_pages(struct mm_struct *mm,
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
index 858c0b3..1cd3118 100644
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
 
+	pol = mpol_new(MPOL_INTERLEAVE, &node_states[N_MEMORY]);
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
+	pol = mpol_new(MPOL_INTERLEAVE, &node_states[N_MEMORY]);
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
index d401414..6ccd658 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -169,7 +169,7 @@ static struct zonelist *bind_zonelist(nodemask_t *nodes)
 }
 
 /* Create a new policy */
-static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
+struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
 {
 	struct mempolicy *policy;
 
@@ -1122,7 +1122,7 @@ static struct zonelist *zonelist_policy(gfp_t gfp, struct mempolicy *policy)
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
