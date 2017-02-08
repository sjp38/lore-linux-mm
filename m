Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4713B6B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 09:02:27 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id g49so136033130qta.0
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 06:02:27 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m18si7161041pgd.142.2017.02.08.06.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 06:02:25 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v18Dwocs026281
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 09:02:25 -0500
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com [125.16.236.2])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28fmwrcvyv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Feb 2017 09:02:23 -0500
Received: from localhost
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 8 Feb 2017 19:32:18 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 338363940033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 19:32:17 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v18E2HKW37028006
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 19:32:17 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v18E2Fej024434
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 19:32:16 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 2/3] mm: Enable HugeTLB allocation isolation for CDM nodes
Date: Wed,  8 Feb 2017 19:31:47 +0530
In-Reply-To: <20170208140148.16049-1-khandual@linux.vnet.ibm.com>
References: <20170208140148.16049-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170208140148.16049-3-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

HugeTLB allocation/release/accounting currently spans across all the nodes
under N_MEMORY node mask. Coherent memory nodes should not be part of these
allocations. So use system_mem_nodemask() call to fetch system RAM only
nodes on the platform which can then be used for HugeTLB allocation purpose
instead of N_MEMORY node mask. This isolates coherent device memory nodes
from HugeTLB allocations.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/hugetlb.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c7025c1..9a46d9f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1790,6 +1790,7 @@ static void return_unused_surplus_pages(struct hstate *h,
 					unsigned long unused_resv_pages)
 {
 	unsigned long nr_pages;
+	nodemask_t system_mem = system_mem_nodemask();
 
 	/* Cannot return gigantic pages currently */
 	if (hstate_is_gigantic(h))
@@ -1816,7 +1817,7 @@ static void return_unused_surplus_pages(struct hstate *h,
 	while (nr_pages--) {
 		h->resv_huge_pages--;
 		unused_resv_pages--;
-		if (!free_pool_huge_page(h, &node_states[N_MEMORY], 1))
+		if (!free_pool_huge_page(h, &system_mem, 1))
 			goto out;
 		cond_resched_lock(&hugetlb_lock);
 	}
@@ -2107,8 +2108,9 @@ int __weak alloc_bootmem_huge_page(struct hstate *h)
 {
 	struct huge_bootmem_page *m;
 	int nr_nodes, node;
+	nodemask_t system_mem = system_mem_nodemask();
 
-	for_each_node_mask_to_alloc(h, nr_nodes, node, &node_states[N_MEMORY]) {
+	for_each_node_mask_to_alloc(h, nr_nodes, node, &system_mem) {
 		void *addr;
 
 		addr = memblock_virt_alloc_try_nid_nopanic(
@@ -2177,13 +2179,14 @@ static void __init gather_bootmem_prealloc(void)
 static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 {
 	unsigned long i;
+	nodemask_t system_mem = system_mem_nodemask();
+
 
 	for (i = 0; i < h->max_huge_pages; ++i) {
 		if (hstate_is_gigantic(h)) {
 			if (!alloc_bootmem_huge_page(h))
 				break;
-		} else if (!alloc_fresh_huge_page(h,
-					 &node_states[N_MEMORY]))
+		} else if (!alloc_fresh_huge_page(h, &system_mem))
 			break;
 	}
 	h->max_huge_pages = i;
@@ -2420,6 +2423,8 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 					   unsigned long count, size_t len)
 {
 	int err;
+	nodemask_t system_mem = system_mem_nodemask();
+
 	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
 
 	if (hstate_is_gigantic(h) && !gigantic_page_supported()) {
@@ -2434,7 +2439,7 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 		if (!(obey_mempolicy &&
 				init_nodemask_of_mempolicy(nodes_allowed))) {
 			NODEMASK_FREE(nodes_allowed);
-			nodes_allowed = &node_states[N_MEMORY];
+			nodes_allowed = &system_mem;
 		}
 	} else if (nodes_allowed) {
 		/*
@@ -2444,11 +2449,11 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
 		init_nodemask_of_node(nodes_allowed, nid);
 	} else
-		nodes_allowed = &node_states[N_MEMORY];
+		nodes_allowed = &system_mem;
 
 	h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
 
-	if (nodes_allowed != &node_states[N_MEMORY])
+	if (nodes_allowed != &system_mem)
 		NODEMASK_FREE(nodes_allowed);
 
 	return len;
@@ -2745,9 +2750,10 @@ static void hugetlb_register_node(struct node *node)
  */
 static void __init hugetlb_register_all_nodes(void)
 {
+	nodemask_t nodes = system_mem_nodemask();
 	int nid;
 
-	for_each_node_state(nid, N_MEMORY) {
+	for_each_node_mask(nid, nodes) {
 		struct node *node = node_devices[nid];
 		if (node->dev.id == nid)
 			hugetlb_register_node(node);
@@ -3019,11 +3025,12 @@ void hugetlb_show_meminfo(void)
 {
 	struct hstate *h;
 	int nid;
+	nodemask_t system_mem = system_mem_nodemask();
 
 	if (!hugepages_supported())
 		return;
 
-	for_each_node_state(nid, N_MEMORY)
+	for_each_node_mask(nid, system_mem)
 		for_each_hstate(h)
 			pr_info("Node %d hugepages_total=%u hugepages_free=%u hugepages_surp=%u hugepages_size=%lukB\n",
 				nid,
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
