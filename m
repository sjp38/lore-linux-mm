Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 434716B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 02:27:17 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so163248244pac.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 23:27:17 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id x1si12943511pdm.181.2015.07.09.23.27.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Jul 2015 23:27:16 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Fri, 10 Jul 2015 11:57:10 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 788CBE0067
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 12:00:53 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6A6QmrT27001040
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 11:56:58 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6A6QlqN030536
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 11:56:47 +0530
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] mm/page: refine the calculation of highest possible node id
Date: Fri, 10 Jul 2015 14:26:21 +0800
Message-Id: <1436509581-9370-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tj@kernel.org
Cc: linux-mm@kvack.org, Wei Yang <weiyang@linux.vnet.ibm.com>

nr_node_ids records the highest possible node id, which is calculated by
scanning the bitmap node_states[N_POSSIBLE]. Current implementation scan
the bitmap from the beginning, which will scan the whole bitmap.

This patch reverse the order by scanning from the end. By doing so, this
will save some time whose worst case is the best case of current
implementation.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 include/linux/nodemask.h |   16 ++++++++++++++++
 mm/page_alloc.c          |    3 +--
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 6e85889..dfca95f 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -253,6 +253,12 @@ static inline int __first_node(const nodemask_t *srcp)
 	return min_t(int, MAX_NUMNODES, find_first_bit(srcp->bits, MAX_NUMNODES));
 }
 
+#define last_node(src) __last_node(&(src))
+static inline int __last_node(const nodemask_t *srcp)
+{
+	return min_t(int, MAX_NUMNODES, find_last_bit(srcp->bits, MAX_NUMNODES));
+}
+
 #define next_node(n, src) __next_node((n), &(src))
 static inline int __next_node(int n, const nodemask_t *srcp)
 {
@@ -360,10 +366,20 @@ static inline void __nodes_fold(nodemask_t *dstp, const nodemask_t *origp,
 	for ((node) = first_node(mask);			\
 		(node) < MAX_NUMNODES;			\
 		(node) = next_node((node), (mask)))
+
+static inline int highest_node_id(const nodemask_t possible)
+{
+	return last_node(possible);
+}
 #else /* MAX_NUMNODES == 1 */
 #define for_each_node_mask(node, mask)			\
 	if (!nodes_empty(mask))				\
 		for ((node) = 0; (node) < 1; (node)++)
+
+static inline int highest_node_id(const nodemask_t possible)
+{
+	return 0;
+}
 #endif /* MAX_NUMNODES */
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 506eac8..b2f75ea 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5453,8 +5453,7 @@ void __init setup_nr_node_ids(void)
 	unsigned int node;
 	unsigned int highest = 0;
 
-	for_each_node_mask(node, node_possible_map)
-		highest = node;
+	highest = highest_node_id(node_possible_map);
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
