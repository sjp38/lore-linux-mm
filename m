Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E83B26B0260
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:28 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d199so24182821wmd.0
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:32:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d83si10077175wmh.105.2016.10.23.21.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:32:27 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4SwBJ101654
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:26 -0400
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0b-001b2d01.pphosted.com with ESMTP id 268v7wc5nf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:26 -0400
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 10:02:22 +0530
Received: from d28relay10.in.ibm.com (d28relay10.in.ibm.com [9.184.220.161])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 1F942E005E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:09 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay10.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4VwDh29163542
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:01:58 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4WFUn020790
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:17 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 2/8] mm: Add specialized fallback zonelist for coherent device memory nodes
Date: Mon, 24 Oct 2016 10:01:51 +0530
In-Reply-To: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477283517-2504-3-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

This change is part of the isolation requiring coherent device memory
node's implementation.

Isolation seeking coherent memory node requires isolation from implicit
memory allocations from user space but at the same time there should also
have an explicit way to do the allocation. Kernel allocation to this memory
can be prevented by putting the entire memory in ZONE_MOVABLE for example.

Platform node's both zonelists are fundamental to where the memory comes
when there is an allocation request. In order to achieve the two objectives
stated above, zonelists building process has to change as both zonelists
(FALLBACK and NOFALLBACK) gives access to the node's memory zones during
any kind of memory allocation. The following changes are implemented in
this regard.

(1) Coherent node's zones are not part of any other node's FALLBACK list
(2) Coherent node's FALLBACK list contains it's own memory zones followed
    by all system RAM zones in normal order
(3) Coherent node's zones are part of it's own NOFALLBACK list

The above changes which will ensure the following which in turn isolates
the coherent memory node as desired.

(1) There wont be any implicit allocation ending up in the coherent node
(2) __GFP_THISNODE marked allocations will come from the coherent node
(3) Coherent memory can also be allocated through MPOL_BIND interface

Sample zonelist configuration:

[NODE (0)]						System RAM node
        ZONELIST_FALLBACK (0xc00000000140da00)
                (0) (node 0) (DMA     0xc00000000140c000)
                (1) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc000000001411a10)
                (0) (node 0) (DMA     0xc00000000140c000)
[NODE (1)]						System RAM node
        ZONELIST_FALLBACK (0xc000000100001a00)
                (0) (node 1) (DMA     0xc000000100000000)
                (1) (node 0) (DMA     0xc00000000140c000)
        ZONELIST_NOFALLBACK (0xc000000100005a10)
                (0) (node 1) (DMA     0xc000000100000000)
[NODE (2)]						Coherent memory
        ZONELIST_FALLBACK (0xc000000001427700)
                (0) (node 2) (Movable 0xc000000001427080)
                (1) (node 0) (DMA     0xc00000000140c000)
                (2) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc00000000142b710)
                (0) (node 2) (Movable 0xc000000001427080)
[NODE (3)]						Coherent memory
        ZONELIST_FALLBACK (0xc000000001431400)
                (0) (node 3) (Movable 0xc000000001430d80)
                (1) (node 0) (DMA     0xc00000000140c000)
                (2) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc000000001435410)
                (0) (node 3) (Movable 0xc000000001430d80)
[NODE (4)]						Coherent memory
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
index 2b3bf67..a2536b4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4753,6 +4753,16 @@ static void build_zonelists(pg_data_t *pgdat)
 	i = 0;
 
 	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
+#ifdef CONFIG_COHERENT_DEVICE
+		/*
+		 * Isolation requiring coherent device memory node's zones
+		 * should not be part of any other node's fallback zonelist
+		 * but it's own fallback list.
+		 */
+		if (isolated_cdm_node(node) && (pgdat->node_id != node))
+			continue;
+#endif
+
 		/*
 		 * We don't want to pressure a particular node.
 		 * So adding penalty to the first node in same
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
