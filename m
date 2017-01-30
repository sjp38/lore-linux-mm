Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 95FF66B0266
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:38 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id ez4so58566581wjd.2
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:37:38 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g93si14794323wrd.216.2017.01.29.19.37.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:37:37 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YPnK106720
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:36 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0b-001b2d01.pphosted.com with ESMTP id 289c9uhay0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:36 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:37:33 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 2EA9D357805B
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:31 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3bNVo20119702
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:31 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3aw8C019905
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:36:59 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC V2 03/12] mm: Change generic FALLBACK zonelist creation process
Date: Mon, 30 Jan 2017 09:05:44 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-4-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

Kernel allocation to CDM node has already been prevented by putting it's
entire memory in ZONE_MOVABLE. But the CDM nodes must also be isolated
from implicit allocations happening on the system.

Any isolation seeking CDM node requires isolation from implicit memory
allocations from user space but at the same time there should also have
an explicit way to do the memory allocation.

Platform node's both zonelists are fundamental to where the memory comes
from when there is an allocation request. In order to achieve these two
objectives as stated above, zonelists building process has to change as
both zonelists (i.e FALLBACK and NOFALLBACK) gives access to the node's
memory zones during any kind of memory allocation. The following changes
are implemented in this regard.

* CDM node's zones are not part of any other node's FALLBACK zonelist
* CDM node's FALLBACK list contains it's own memory zones followed by
  all system RAM zones in regular order as before
* CDM node's zones are part of it's own NOFALLBACK zonelist

These above changes ensure the following which in turn isolates the CDM
nodes as desired.

* There wont be any implicit memory allocation ending up in the CDM node
* Only __GFP_THISNODE marked allocations will come from the CDM node
* CDM node memory can be allocated through mbind(MPOL_BIND) interface
* System RAM memory will be used as fallback option in regular order in
  case the CDM memory is insufficient during targted allocation request

Sample zonelist configuration:

[NODE (0)]						RAM
        ZONELIST_FALLBACK (0xc00000000140da00)
                (0) (node 0) (DMA     0xc00000000140c000)
                (1) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc000000001411a10)
                (0) (node 0) (DMA     0xc00000000140c000)
[NODE (1)]						RAM
        ZONELIST_FALLBACK (0xc000000100001a00)
                (0) (node 1) (DMA     0xc000000100000000)
                (1) (node 0) (DMA     0xc00000000140c000)
        ZONELIST_NOFALLBACK (0xc000000100005a10)
                (0) (node 1) (DMA     0xc000000100000000)
[NODE (2)]						CDM
        ZONELIST_FALLBACK (0xc000000001427700)
                (0) (node 2) (Movable 0xc000000001427080)
                (1) (node 0) (DMA     0xc00000000140c000)
                (2) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc00000000142b710)
                (0) (node 2) (Movable 0xc000000001427080)
[NODE (3)]						CDM
        ZONELIST_FALLBACK (0xc000000001431400)
                (0) (node 3) (Movable 0xc000000001430d80)
                (1) (node 0) (DMA     0xc00000000140c000)
                (2) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc000000001435410)
                (0) (node 3) (Movable 0xc000000001430d80)
[NODE (4)]						CDM
        ZONELIST_FALLBACK (0xc00000000143b100)
                (0) (node 4) (Movable 0xc00000000143aa80)
                (1) (node 0) (DMA     0xc00000000140c000)
                (2) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc00000000143f110)
                (0) (node 4) (Movable 0xc00000000143aa80)

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f3e0c69..5db353a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4825,6 +4825,16 @@ static void build_zonelists(pg_data_t *pgdat)
 	i = 0;
 
 	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
+#ifdef CONFIG_COHERENT_DEVICE
+		/*
+		 * CDM node's own zones should not be part of any other
+		 * node's fallback zonelist but only it's own fallback
+		 * zonelist.
+		 */
+		if (is_cdm_node(node) && (pgdat->node_id != node))
+			continue;
+#endif
+
 		/*
 		 * We don't want to pressure a particular node.
 		 * So adding penalty to the first node in same
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
