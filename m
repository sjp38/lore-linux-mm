Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l57F0FBG023079
	for <linux-mm@kvack.org>; Thu, 7 Jun 2007 11:00:15 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57F4ROe041354
	for <linux-mm@kvack.org>; Thu, 7 Jun 2007 09:04:27 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57F4QrJ020481
	for <linux-mm@kvack.org>; Thu, 7 Jun 2007 09:04:26 -0600
Date: Thu, 7 Jun 2007 08:04:25 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH] gfp.h: GFP_THISNODE can go to other nodes if some are unpopulated
Message-ID: <20070607150425.GA15776@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Lee.Schermerhorn@hp.com, anton@samba.org, apw@shadowen.org, mel@csn.ul.ie, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

While testing my sysfs per-node hugepage allocator
(http://marc.info/?l=linux-mm&m=117935849517122&w=2), I found that an
alloc_pages_node(nid, GFP_THISNODE) request would sometimes return a
struct page such that page_to_nid(page) != nid. This was because, on
that particular machine, nodes 0 and 1 are populated and nodes 2 and 3
are not. When a page is requested get_page_from_freelist() relies on
zonelist->zones[0]->zone_pgdat indicating when THISNODE stops. But,
because, say, node 2 has no memory, the first zone_pgdat in the fallback
list points to a different node. Add a comment indicating that THISNODE
may not return pages on THISNODE if the node is unpopulated.

Am working on testing Lee/Anton's patch to add a node_populated_mask and
use that in the hugepage allocator path. But I think this may be a
problem anywhere THISNODE is used and memory is expected to come from
the requested node and nowhere else.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0d2ef0b..ed826e9 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -67,6 +67,10 @@ struct vm_area_struct;
 			 __GFP_HIGHMEM)
 
 #ifdef CONFIG_NUMA
+/*
+ * NOTE: if the requested node is unpopulated (no memory), a THISNODE
+ * request can go to other nodes due to the fallback list
+ */
 #define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
 #else
 #define GFP_THISNODE	((__force gfp_t)0)

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
