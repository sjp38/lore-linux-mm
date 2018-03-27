Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB45A6B0009
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 23:57:17 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f3-v6so14452863plf.1
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 20:57:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b36-v6sor151294pli.45.2018.03.26.20.57.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 20:57:16 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/page_alloc: break on the first hit of mem range
Date: Tue, 27 Mar 2018 11:57:07 +0800
Message-Id: <20180327035707.84113-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, tj@kernel.org
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

find_min_pfn_for_node() iterate on pfn range to find the minimum pfn for a
node. The memblock_region in memblock_type are already ordered, which means
the first hit in iteration is the minimum pfn.

This patch returns the fist hit instead of iterating the whole regions.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_alloc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 635d7dd29d7f..a65de1ec4b91 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6365,14 +6365,14 @@ unsigned long __init node_map_pfn_alignment(void)
 /* Find the lowest pfn for a node */
 static unsigned long __init find_min_pfn_for_node(int nid)
 {
-	unsigned long min_pfn = ULONG_MAX;
-	unsigned long start_pfn;
+	unsigned long min_pfn;
 	int i;
 
-	for_each_mem_pfn_range(i, nid, &start_pfn, NULL, NULL)
-		min_pfn = min(min_pfn, start_pfn);
+	for_each_mem_pfn_range(i, nid, &min_pfn, NULL, NULL) {
+		break;
+	}
 
-	if (min_pfn == ULONG_MAX) {
+	if (i == -1) {
 		pr_warn("Could not find start_pfn for node %d\n", nid);
 		return 0;
 	}
-- 
2.15.1
