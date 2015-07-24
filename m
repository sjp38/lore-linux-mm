Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id BC0166B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:45:57 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so32212774wib.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:45:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id op3si15236827wjc.25.2015.07.24.07.45.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 07:45:56 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC v2 2/4] mm: unify checks in alloc_pages_node family of functions
Date: Fri, 24 Jul 2015 16:45:24 +0200
Message-Id: <1437749126-25867-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>

Perform the same debug checks in alloc_pages_node() as are done in
alloc_pages_exact_node() and __alloc_pages_node() by making the latter
function the inner core of the former ones.

Change the !node_online(nid) check from VM_BUG_ON to VM_WARN_ON since it's not
fatal and this patch may expose some buggy callers.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/gfp.h | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index c50848e..54c3ee7 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -307,7 +307,8 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
 static inline struct page *
 __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
 {
-	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
+	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
+	VM_WARN_ON(!node_online(nid));
 
 	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }
@@ -319,11 +320,11 @@ __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
-	/* Unknown node is current node */
-	if (nid < 0)
+	/* Unknown node is current (or closest) node */
+	if (nid == NUMA_NO_NODE)
 		nid = numa_node_id();
 
-	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
+	return __alloc_pages_node(nid, gfp_mask, order);
 }
 
 /*
@@ -334,11 +335,7 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
-	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
-
-	gfp_mask |= __GFP_THISNODE;
-
-	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
+	return __alloc_pages_node(nid, gfp_mask | __GFP_THISNODE, order);
 }
 
 #ifdef CONFIG_NUMA
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
