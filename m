Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id B15C86B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 04:02:41 -0400 (EDT)
Received: by pdbdz6 with SMTP id dz6so46790673pdb.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 01:02:41 -0700 (PDT)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id pv10si2747451pbc.93.2015.07.08.01.02.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Jul 2015 01:02:40 -0700 (PDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 8 Jul 2015 18:02:34 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 706242CE8040
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 18:02:32 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6882Oxr50069634
	for <linux-mm@kvack.org>; Wed, 8 Jul 2015 18:02:33 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6881w6R017351
	for <linux-mm@kvack.org>; Wed, 8 Jul 2015 18:01:58 +1000
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] mm/memblock: WARN_ON when nid differs from overlap region
Date: Wed,  8 Jul 2015 16:01:28 +0800
Message-Id: <1436342488-19851-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tj@kernel.org
Cc: linux-mm@kvack.org, Wei Yang <weiyang@linux.vnet.ibm.com>

Each memblock_region has nid to indicates the Node ID of this range. For
the overlap case, memblock_add_range() inserts the lower part and leave the
upper part as indicated in the overlapped region.

If the nid of the new range differs from the overlapped region, the
information recorded is not correct.

This patch adds a WARN_ON when the nid of the new range differs from the
overlapped region.

---

I am not familiar with the lower level topology, maybe this case will not
happen. 

If current implementation is based on the assumption, that overlapped
ranges' nid and flags are the same, I would suggest to add a comment to
indicates this background.

If the assumption is not correct, I suggest to add a WARN_ON or BUG_ON to
indicates this case.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 mm/memblock.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memblock.c b/mm/memblock.c
index 9318b56..09efe70 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -540,6 +540,9 @@ repeat:
 		 * area, insert that portion.
 		 */
 		if (rbase > base) {
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+			WARN_ON(nid != memblock_get_region_node(rgn));
+#endif
 			nr_new++;
 			if (insert)
 				memblock_insert_region(type, i++, base,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
