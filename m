Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 353F56B0038
	for <linux-mm@kvack.org>; Sun,  4 Sep 2016 23:00:06 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id hi6so168993720pac.0
        for <linux-mm@kvack.org>; Sun, 04 Sep 2016 20:00:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s70si26747182pfa.89.2016.09.04.20.00.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Sep 2016 20:00:05 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u852qW1U068231
	for <linux-mm@kvack.org>; Sun, 4 Sep 2016 23:00:03 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 257tp0uawy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 04 Sep 2016 23:00:03 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Mon, 5 Sep 2016 04:00:00 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 5189A2190023
	for <linux-mm@kvack.org>; Mon,  5 Sep 2016 03:59:20 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u852xwv513959670
	for <linux-mm@kvack.org>; Mon, 5 Sep 2016 02:59:58 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u852xvdI018093
	for <linux-mm@kvack.org>; Sun, 4 Sep 2016 20:59:57 -0600
Subject: [PATCH] mem-hotplug: Don't clear the only node in new_node_page()
From: Li Zhong <zhong@linux.vnet.ibm.com>
Date: Mon, 05 Sep 2016 10:59:51 +0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Message-Id: <1473044391.4250.19.camel@TP420>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: jallen@linux.vnet.ibm.com, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, n-horiguchi@ah.jp.nec.com, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>

Commit 394e31d2c introduced new_node_page() for memory hotplug. 

In new_node_page(), the nid is cleared before calling __alloc_pages_nodemask().
But if it is the only node of the system, and the first round allocation fails,
it will not be able to get memory from an empty nodemask, and trigger oom. 

The patch checks whether it is the last node on the system, and if it is, then
don't clear the nid in the nodemask.

Reported-by: John Allen <jallen@linux.vnet.ibm.com>
Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 41266dc..b58906b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1567,7 +1567,9 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					next_node_in(nid, nmask));
 
-	node_clear(nid, nmask);
+	if (nid != next_node_in(nid, nmask))
+		node_clear(nid, nmask);
+
 	if (PageHighMem(page)
 	    || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
 		gfp_mask |= __GFP_HIGHMEM;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
