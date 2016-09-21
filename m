Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79B286B0263
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 04:38:59 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y6so4381787lff.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 01:38:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p8si32727159wjw.65.2016.09.21.01.38.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 01:38:57 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8L8bgVC023862
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 04:38:56 -0400
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25kjkwtqby-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 04:38:56 -0400
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Wed, 21 Sep 2016 09:38:54 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 52EF02190061
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 09:38:12 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8L8cqSY7143934
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 08:38:52 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8L8chk2024249
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 02:38:44 -0600
Subject: [PATCH] mem-hotplug: Use nodes that contain memory as mask in
 new_node_page()
From: Li Zhong <zhong@linux.vnet.ibm.com>
Date: Wed, 21 Sep 2016 16:38:37 +0800
In-Reply-To: <alpine.DEB.2.10.1609201413210.84794@chino.kir.corp.google.com>
References: <1473044391.4250.19.camel@TP420>
	 <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz>
	 <20160912091811.GE14524@dhcp22.suse.cz>
	 <c144f768-7591-8bb8-4238-b3f1ecaf8b4b@suse.cz>
	 <alpine.DEB.2.10.1609201413210.84794@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Message-Id: <1474447117.28370.6.camel@TP420>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, linux-mm <linux-mm@kvack.org>, jallen@linux.vnet.ibm.com, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

Commit 9bb627be47a5 ("mem-hotplug: don't clear the only node in
new_node_page()") prevents allocating from an empty nodemask, but as David
points out, it is still wrong. As node_online_map may include memoryless
nodes, only allocating from these nodes is meaningless.

This patch uses node_states[N_MEMORY] mask to prevent the above case.

Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b58906b..9d29ba0 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1555,8 +1555,8 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 {
 	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
 	int nid = page_to_nid(page);
-	nodemask_t nmask = node_online_map;
-	struct page *new_page;
+	nodemask_t nmask = node_states[N_MEMORY];
+	struct page *new_page = NULL;
 
 	/*
 	 * TODO: allocate a destination hugepage from a nearest neighbor node,
@@ -1567,14 +1567,14 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					next_node_in(nid, nmask));
 
-	if (nid != next_node_in(nid, nmask))
-		node_clear(nid, nmask);
+	node_clear(nid, nmask);
 
 	if (PageHighMem(page)
 	    || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
 		gfp_mask |= __GFP_HIGHMEM;
 
-	new_page = __alloc_pages_nodemask(gfp_mask, 0,
+	if (!nodes_empty(nmask))
+		new_page = __alloc_pages_nodemask(gfp_mask, 0,
 					node_zonelist(nid, gfp_mask), &nmask);
 	if (!new_page)
 		new_page = __alloc_pages(gfp_mask, 0,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
