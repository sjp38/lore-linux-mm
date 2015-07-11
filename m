Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 80FFD6B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 23:08:55 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so49668010pdb.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 20:08:55 -0700 (PDT)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [122.248.162.7])
        by mx.google.com with ESMTPS id nl1si17204876pdb.146.2015.07.10.20.08.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Jul 2015 20:08:54 -0700 (PDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Sat, 11 Jul 2015 08:38:49 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 02F91E004C
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 08:42:40 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6B38cea35389526
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 08:38:40 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6B38bJU024945
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 08:38:37 +0530
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH V2] mm/page: refine the calculation of highest possible node id
Date: Sat, 11 Jul 2015 11:08:16 +0800
Message-Id: <1436584096-7016-1-git-send-email-weiyang@linux.vnet.ibm.com>
In-Reply-To: <20150710003555.4398c8ad.akpm@linux-foundation.org>
References: <20150710003555.4398c8ad.akpm@linux-foundation.org>
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
v2:
   Just call find_last_bit() on node_possible_map.
---
 mm/page_alloc.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59248f4..f8d0a98 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5450,10 +5450,9 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 void __init setup_nr_node_ids(void)
 {
 	unsigned int node;
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
