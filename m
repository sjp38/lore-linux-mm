Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id D06D26B0253
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 00:17:49 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so177448955pab.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 21:17:49 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id lr1si17419210pab.166.2015.07.10.21.17.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Jul 2015 21:17:48 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Sat, 11 Jul 2015 09:47:43 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id CA343394005C
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 09:47:41 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6B4Hfrf9306376
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 09:47:41 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6B33tkb009700
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 08:33:55 +0530
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH V3] mm/page: refine the calculation of highest possible node id
Date: Sat, 11 Jul 2015 12:17:28 +0800
Message-Id: <1436588248-25546-1-git-send-email-weiyang@linux.vnet.ibm.com>
In-Reply-To: <1436584096-7016-1-git-send-email-weiyang@linux.vnet.ibm.com>
References: <1436584096-7016-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Wei Yang <weiyang@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>

nr_node_ids records the highest possible node id, which is calculated by
scanning the bitmap node_states[N_POSSIBLE]. Current implementation scan
the bitmap from the beginning, which will scan the whole bitmap.

This patch reverse the order by scanning from the end with find_last_bit().

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Tejun Heo <tj@kernel.org>

---
v3:
   remove the unused variable node.
v2:
   Just call find_last_bit() on node_possible_map.
---
 mm/page_alloc.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59248f4..c635e80 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5449,11 +5449,9 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
  */
 void __init setup_nr_node_ids(void)
 {
-	unsigned int node;
-	unsigned int highest = 0;
+	unsigned int highest;
 
-	for_each_node_mask(node, node_possible_map)
-		highest = node;
+	highest = find_last_bit(node_possible_map.bits, MAX_NUMNODES);
 	nr_node_ids = highest + 1;
 }
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
