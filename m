Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l76GiCWA006904
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:44:12 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l76GiCnZ552046
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:44:12 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l76GiBIq026822
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:44:12 -0400
Date: Mon, 6 Aug 2007 09:44:10 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 4/5] hugetlb: fix cpuset-constrained pool resizing
Message-ID: <20070806164410.GO15714@us.ibm.com>
References: <20070806163254.GJ15714@us.ibm.com> <20070806163726.GK15714@us.ibm.com> <20070806163841.GL15714@us.ibm.com> <20070806164055.GN15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070806164055.GN15714@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com, pj@sgi.com
List-ID: <linux-mm.kvack.org>

With the previous 3 patches in this series applied, if a process is in a
constrained cpuset, and tries to grow the hugetlb pool, hugepages may be
allocated on nodes outside of the process' cpuset. More concretely,
growing the pool via

echo some_value > /proc/sys/vm/nr_hugepages

interleaves across all nodes with memory such that hugepage allocations
occur on nodes outside the cpuset. Similarly, this process is able to
change the values in values in
/sys/devices/system/node/nodeX/nr_hugepages, even when X is not in the
cpuset. This directly violates the isolation that cpusets is supposed to
guarantee.

For pool growth: fix the sysctl case by only interleaving across the
nodes in current's cpuset; fix the sysfs attribute case by verifying the
requested node is in current's cpuset. For pool shrinking: both cases
are mostly already covered by the cpuset_zone_allowed_softwall() check
in dequeue_huge_page_node(), but make sure that we only iterate over the
cpusets's nodes in try_to_free_low().

Before:

Trying to resize the pool back to     100 from the top cpuset
Node 3 HugePages_Free:      0
Node 2 HugePages_Free:      0
Node 1 HugePages_Free:    100
Node 0 HugePages_Free:      0
Done.     100 free
/cpuset/set1 /cpuset ~
Trying to resize the pool to     200 from a cpuset restricted to node 1
Node 3 HugePages_Free:      0
Node 2 HugePages_Free:      0
Node 1 HugePages_Free:    150
Node 0 HugePages_Free:     50
Done.     200 free
Trying to shrink the pool on node 0 down to 0 from a cpuset restricted
to node 1
Node 3 HugePages_Free:      0
Node 2 HugePages_Free:      0
Node 1 HugePages_Free:    150
Node 0 HugePages_Free:      0
Done.     150 free

After:

Trying to resize the pool back to     100 from the top cpuset
Node 3 HugePages_Free:      0
Node 2 HugePages_Free:      0
Node 1 HugePages_Free:    100
Node 0 HugePages_Free:      0
Done.     100 free
/cpuset/set1 /cpuset ~
Trying to resize the pool to     200 from a cpuset restricted to node 1
Node 3 HugePages_Free:      0
Node 2 HugePages_Free:      0
Node 1 HugePages_Free:    200
Node 0 HugePages_Free:      0
Done.     200 free
Trying to grow the pool on node 0 up to 50 from a cpuset restricted to
node 1
Node 3 HugePages_Free:      0
Node 2 HugePages_Free:      0
Node 1 HugePages_Free:    200
Node 0 HugePages_Free:      0
Done.     200 free

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 09ad639..af07a0b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -181,6 +181,10 @@ static int __init hugetlb_init(void)
 	for_each_node_state(i, N_HIGH_MEMORY)
 		INIT_LIST_HEAD(&hugepage_freelists[i]);
 
+	/*
+	 * at boot-time, interleave across all available nodes as there
+	 * is not any corresponding cpuset/process
+	 */
 	pol = mpol_new(MPOL_INTERLEAVE, &node_states[N_HIGH_MEMORY]);
 	if (IS_ERR(pol))
 		goto quit;
@@ -258,7 +262,7 @@ static void try_to_free_low(unsigned long count)
 {
 	int i;
 
-	for_each_node_state(i, N_HIGH_MEMORY) {
+	for_each_node_mask(i, cpuset_current_mems_allowed) {
 		try_to_free_low_node(i, count);
 		if (count >= nr_huge_pages)
 			return;
@@ -278,7 +282,7 @@ static unsigned long set_max_huge_pages(unsigned long count)
 {
 	struct mempolicy *pol;
 
-	pol = mpol_new(MPOL_INTERLEAVE, &node_states[N_HIGH_MEMORY]);
+	pol = mpol_new(MPOL_INTERLEAVE, &cpuset_current_mems_allowed);
 	if (IS_ERR(pol))
 		return nr_huge_pages;
 	/*
@@ -286,7 +290,7 @@ static unsigned long set_max_huge_pages(unsigned long count)
 	 * process, we need to make sure il_next has a good starting
 	 * value
 	 */
-	set_first_interleave_node(node_states[N_HIGH_MEMORY]);
+	set_first_interleave_node(cpuset_current_mems_allowed);
 	while (count > nr_huge_pages) {
 		if (!alloc_fresh_huge_page(pol))
 			break;
@@ -368,6 +372,10 @@ static ssize_t hugetlb_write_nr_hugepages_node(struct sys_device *dev,
 	unsigned long free_on_other_nodes;
 	unsigned long nr_huge_pages_req = simple_strtoul(buf, NULL, 10);
 
+	/* prevent per-node allocations from outside the allowed cpuset */
+	if (!node_isset(nid, cpuset_current_mems_allowed))
+		return count;
+
 	while (nr_huge_pages_req > nr_huge_pages_node[nid]) {
 		if (!alloc_fresh_huge_page_node(nid))
 			return count;

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
