Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 75B3F6B0262
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f193so24181666wmg.1
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:32:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 191si10075673wmh.55.2016.10.23.21.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:32:27 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4SuVf001114
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:26 -0400
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com [125.16.236.2])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26922s0kjq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:26 -0400
Received: from localhost
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 10:02:21 +0530
Received: from d28relay09.in.ibm.com (d28relay09.in.ibm.com [9.184.220.160])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id AEDB5394005C
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:19 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay09.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4WJgl38797556
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:19 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4WIKC020894
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:18 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 3/8] mm: Isolate coherent device memory nodes from HugeTLB allocation paths
Date: Mon, 24 Oct 2016 10:01:52 +0530
In-Reply-To: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477283517-2504-4-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

This change is part of the isolation requiring coherent device memory nodes
implementation.

Isolation seeking coherent device memory node requires allocation isolation
from implicit memory allocations from user space. Towards that effect, the
memory should not be used for generic HugeTLB page pool allocations. This
modifies relevant functions to skip all coherent memory nodes present on
the system during allocation, freeing and auditing for HugeTLB pages.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/hugetlb.c | 38 ++++++++++++++++++++++++++++++++++++--
 1 file changed, 36 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ec49d9e..466a44c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1147,6 +1147,9 @@ static int alloc_fresh_gigantic_page(struct hstate *h,
 	int nr_nodes, node;
 
 	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
+		if (isolated_cdm_node(node))
+			continue;
+
 		page = alloc_fresh_gigantic_page_node(h, node);
 		if (page)
 			return 1;
@@ -1382,6 +1385,9 @@ static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
 	int ret = 0;
 
 	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
+		if (isolated_cdm_node(node))
+			continue;
+
 		page = alloc_fresh_huge_page_node(h, node);
 		if (page) {
 			ret = 1;
@@ -1410,6 +1416,9 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
 	int ret = 0;
 
 	for_each_node_mask_to_free(h, nr_nodes, node, nodes_allowed) {
+		if (isolated_cdm_node(node))
+			continue;
+
 		/*
 		 * If we're returning unused surplus pages, only examine
 		 * nodes with surplus pages.
@@ -2028,6 +2037,9 @@ int __weak alloc_bootmem_huge_page(struct hstate *h)
 	for_each_node_mask_to_alloc(h, nr_nodes, node, &node_states[N_MEMORY]) {
 		void *addr;
 
+		if (isolated_cdm_node(node))
+			continue;
+
 		addr = memblock_virt_alloc_try_nid_nopanic(
 				huge_page_size(h), huge_page_size(h),
 				0, BOOTMEM_ALLOC_ACCESSIBLE, node);
@@ -2156,6 +2168,10 @@ static void try_to_free_low(struct hstate *h, unsigned long count,
 	for_each_node_mask(i, *nodes_allowed) {
 		struct page *page, *next;
 		struct list_head *freel = &h->hugepage_freelists[i];
+
+		if (isolated_cdm_node(i))
+			continue;
+
 		list_for_each_entry_safe(page, next, freel, lru) {
 			if (count >= h->nr_huge_pages)
 				return;
@@ -2189,11 +2205,17 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
 
 	if (delta < 0) {
 		for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
+			if (isolated_cdm_node(node))
+				continue;
+
 			if (h->surplus_huge_pages_node[node])
 				goto found;
 		}
 	} else {
 		for_each_node_mask_to_free(h, nr_nodes, node, nodes_allowed) {
+			if (isolated_cdm_node(node))
+				continue;
+
 			if (h->surplus_huge_pages_node[node] <
 					h->nr_huge_pages_node[node])
 				goto found;
@@ -2666,6 +2688,10 @@ static void __init hugetlb_register_all_nodes(void)
 
 	for_each_node_state(nid, N_MEMORY) {
 		struct node *node = node_devices[nid];
+
+		if (isolated_cdm_node(nid))
+			continue;
+
 		if (node->dev.id == nid)
 			hugetlb_register_node(node);
 	}
@@ -2819,8 +2845,12 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
 	int node;
 	unsigned int nr = 0;
 
-	for_each_node_mask(node, cpuset_current_mems_allowed)
+	for_each_node_mask(node, cpuset_current_mems_allowed) {
+		if (isolated_cdm_node(node))
+			continue;
+
 		nr += array[node];
+	}
 
 	return nr;
 }
@@ -2940,7 +2970,10 @@ void hugetlb_show_meminfo(void)
 	if (!hugepages_supported())
 		return;
 
-	for_each_node_state(nid, N_MEMORY)
+	for_each_node_state(nid, N_MEMORY) {
+		if (isolated_cdm_node(nid))
+			continue;
+
 		for_each_hstate(h)
 			pr_info("Node %d hugepages_total=%u hugepages_free=%u hugepages_surp=%u hugepages_size=%lukB\n",
 				nid,
@@ -2948,6 +2981,7 @@ void hugetlb_show_meminfo(void)
 				h->free_huge_pages_node[nid],
 				h->surplus_huge_pages_node[nid],
 				1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
+	}
 }
 
 void hugetlb_report_usage(struct seq_file *m, struct mm_struct *mm)
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
