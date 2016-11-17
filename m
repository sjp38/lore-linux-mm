Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5023A6B0260
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 02:59:21 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so185355260pgc.1
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 23:59:21 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d198si471344pga.322.2016.11.16.23.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 23:59:20 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAH7xFj9022322
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 02:59:19 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26s789bb7n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 02:59:19 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 17 Nov 2016 17:59:16 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id E25083578056
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:59:14 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAH7xEeT55181504
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:59:14 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAH7xEbv024903
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:59:14 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DRAFT 2/2] mm/hugetlb: Restrict HugeTLB allocations only to the system RAM nodes
Date: Thu, 17 Nov 2016 13:29:09 +0530
In-Reply-To: <1479369549-13309-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <582D5F02.6010705@linux.vnet.ibm.com>
 <1479369549-13309-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1479369549-13309-2-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

HugeTLB allocation/release/accounting currently spans across all the nodes
under N_MEMORY mask. CDM nodes should not be part of these. So use
system_ram() call to fetch system RAM only nodes on the platform which can
then be used for HugeTLB purpose instead of N_MEMORY. This isolates CDM
nodes from HugeTLB allocation.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
This also completely isolates CDM nodes from user space HugeTLB allocations
. Hence explicit allocation to the CDM nodes would not be possible any more
. To again enable explicit HugeTLB allocation capability from user space,
HugeTLB subsystem needs to be changed.

 mm/hugetlb.c | 32 +++++++++++++++++++++++---------
 1 file changed, 23 insertions(+), 9 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 418bf01..1936c5a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1782,6 +1782,9 @@ static void return_unused_surplus_pages(struct hstate *h,
 					unsigned long unused_resv_pages)
 {
 	unsigned long nr_pages;
+	nodemask_t nodes;
+
+	nodes = system_ram();
 
 	/* Uncommit the reservation */
 	h->resv_huge_pages -= unused_resv_pages;
@@ -1801,7 +1804,7 @@ static void return_unused_surplus_pages(struct hstate *h,
 	 * on-line nodes with memory and will handle the hstate accounting.
 	 */
 	while (nr_pages--) {
-		if (!free_pool_huge_page(h, &node_states[N_MEMORY], 1))
+		if (!free_pool_huge_page(h, &nodes, 1))
 			break;
 		cond_resched_lock(&hugetlb_lock);
 	}
@@ -2088,8 +2091,10 @@ int __weak alloc_bootmem_huge_page(struct hstate *h)
 {
 	struct huge_bootmem_page *m;
 	int nr_nodes, node;
+	nodemask_t nodes;
 
-	for_each_node_mask_to_alloc(h, nr_nodes, node, &node_states[N_MEMORY]) {
+	nodes = system_ram();
+	for_each_node_mask_to_alloc(h, nr_nodes, node, &nodes) {
 		void *addr;
 
 		addr = memblock_virt_alloc_try_nid_nopanic(
@@ -2158,13 +2163,15 @@ static void __init gather_bootmem_prealloc(void)
 static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 {
 	unsigned long i;
+	nodemask_t nodes;
+
 
+	nodes = system_ram();
 	for (i = 0; i < h->max_huge_pages; ++i) {
 		if (hstate_is_gigantic(h)) {
 			if (!alloc_bootmem_huge_page(h))
 				break;
-		} else if (!alloc_fresh_huge_page(h,
-					 &node_states[N_MEMORY]))
+		} else if (!alloc_fresh_huge_page(h, &nodes))
 			break;
 	}
 	h->max_huge_pages = i;
@@ -2401,8 +2408,11 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 					   unsigned long count, size_t len)
 {
 	int err;
+	nodemask_t ram_nodes;
+
 	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
 
+	ram_nodes = system_ram();
 	if (hstate_is_gigantic(h) && !gigantic_page_supported()) {
 		err = -EINVAL;
 		goto out;
@@ -2415,7 +2425,7 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 		if (!(obey_mempolicy &&
 				init_nodemask_of_mempolicy(nodes_allowed))) {
 			NODEMASK_FREE(nodes_allowed);
-			nodes_allowed = &node_states[N_MEMORY];
+			nodes_allowed = &ram_nodes;
 		}
 	} else if (nodes_allowed) {
 		/*
@@ -2425,11 +2435,11 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
 		init_nodemask_of_node(nodes_allowed, nid);
 	} else
-		nodes_allowed = &node_states[N_MEMORY];
+		nodes_allowed = &ram_nodes;
 
 	h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
 
-	if (nodes_allowed != &node_states[N_MEMORY])
+	if (nodes_allowed != &ram_nodes)
 		NODEMASK_FREE(nodes_allowed);
 
 	return len;
@@ -2726,9 +2736,11 @@ static void hugetlb_register_node(struct node *node)
  */
 static void __init hugetlb_register_all_nodes(void)
 {
+	nodemask_t nodes;
 	int nid;
 
-	for_each_node_state(nid, N_MEMORY) {
+	nodes = system_ram();
+	for_each_node_mask(nid, nodes) {
 		struct node *node = node_devices[nid];
 		if (node->dev.id == nid)
 			hugetlb_register_node(node);
@@ -2998,13 +3010,15 @@ int hugetlb_report_node_meminfo(int nid, char *buf)
 
 void hugetlb_show_meminfo(void)
 {
+	nodemask_t nodes;
 	struct hstate *h;
 	int nid;
 
 	if (!hugepages_supported())
 		return;
 
-	for_each_node_state(nid, N_MEMORY)
+	nodes = system_ram();
+	for_each_node_mask(nid, nodes)
 		for_each_hstate(h)
 			pr_info("Node %d hugepages_total=%u hugepages_free=%u hugepages_surp=%u hugepages_size=%lukB\n",
 				nid,
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
