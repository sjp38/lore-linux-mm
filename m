Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A2F92830BE
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 11:58:09 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o1so164825553qkd.3
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 08:58:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d6si14776801qtd.129.2016.08.26.08.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Aug 2016 08:58:08 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7QFtbKp028672
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 11:58:08 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2527gq43q6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 11:58:08 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 26 Aug 2016 09:58:07 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] mm: Use zonelist name instead of using hardcoded index
Date: Fri, 26 Aug 2016 21:27:58 +0530
Message-Id: <1472227078-24852-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This use the existing enums instead of hardcoded index when looking at the
zonelist. This makes it more readable. No functionality change by this
patch.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/mempolicy.c  | 2 +-
 mm/page_alloc.c | 8 ++++----
 mm/vmscan.c     | 2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d8c4e38fb5f4..f38fe1e64192 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1749,7 +1749,7 @@ unsigned int mempolicy_slab_node(void)
 		 */
 		struct zonelist *zonelist;
 		enum zone_type highest_zoneidx = gfp_zone(GFP_KERNEL);
-		zonelist = &NODE_DATA(node)->node_zonelists[0];
+		zonelist = &NODE_DATA(node)->node_zonelists[ZONELIST_FALLBACK];
 		z = first_zones_zonelist(zonelist, highest_zoneidx,
 							&policy->v.nodes);
 		return z->zone ? z->zone->node : node;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3fbe73a6fe4b..8bcd18c3118c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4602,7 +4602,7 @@ static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
 	int j;
 	struct zonelist *zonelist;
 
-	zonelist = &pgdat->node_zonelists[0];
+	zonelist = &pgdat->node_zonelists[ZONELIST_FALLBACK];
 	for (j = 0; zonelist->_zonerefs[j].zone != NULL; j++)
 		;
 	j = build_zonelists_node(NODE_DATA(node), zonelist, j);
@@ -4618,7 +4618,7 @@ static void build_thisnode_zonelists(pg_data_t *pgdat)
 	int j;
 	struct zonelist *zonelist;
 
-	zonelist = &pgdat->node_zonelists[1];
+	zonelist = &pgdat->node_zonelists[ZONELIST_NOFALLBACK];
 	j = build_zonelists_node(pgdat, zonelist, 0);
 	zonelist->_zonerefs[j].zone = NULL;
 	zonelist->_zonerefs[j].zone_idx = 0;
@@ -4639,7 +4639,7 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 	struct zone *z;
 	struct zonelist *zonelist;
 
-	zonelist = &pgdat->node_zonelists[0];
+	zonelist = &pgdat->node_zonelists[ZONELIST_FALLBACK];
 	pos = 0;
 	for (zone_type = MAX_NR_ZONES - 1; zone_type >= 0; zone_type--) {
 		for (j = 0; j < nr_nodes; j++) {
@@ -4774,7 +4774,7 @@ static void build_zonelists(pg_data_t *pgdat)
 
 	local_node = pgdat->node_id;
 
-	zonelist = &pgdat->node_zonelists[0];
+	zonelist = &pgdat->node_zonelists[ZONELIST_FALLBACK];
 	j = build_zonelists_node(pgdat, zonelist, 0);
 
 	/*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 374d95d04178..25522e0ce2b5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3060,7 +3060,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	 */
 	nid = mem_cgroup_select_victim_node(memcg);
 
-	zonelist = NODE_DATA(nid)->node_zonelists;
+	zonelist = &NODE_DATA(nid)->node_zonelists[ZONELIST_FALLBACK];
 
 	trace_mm_vmscan_memcg_reclaim_begin(0,
 					    sc.may_writepage,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
