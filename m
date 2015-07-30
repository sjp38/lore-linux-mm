Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2A99003C7
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 12:35:01 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so75733870wib.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 09:35:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dx2si14743265wib.2.2015.07.30.09.34.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 09:34:59 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 3/3] mm: use numa_mem_id() in alloc_pages_node()
Date: Thu, 30 Jul 2015 18:34:31 +0200
Message-Id: <1438274071-22551-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1438274071-22551-1-git-send-email-vbabka@suse.cz>
References: <1438274071-22551-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>

numa_mem_id() is able to handle allocation from CPUs on memory-less nodes,
so it's a more robust fallback than the currently used numa_node_id().

Suggested-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/gfp.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 4a12cae2..f92cbd2 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -318,13 +318,14 @@ __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
 
 /*
  * Allocate pages, preferring the node given as nid. When nid == NUMA_NO_NODE,
- * prefer the current CPU's node. Otherwise node must be valid and online.
+ * prefer the current CPU's closest node. Otherwise node must be valid and
+ * online.
  */
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
 	if (nid == NUMA_NO_NODE)
-		nid = numa_node_id();
+		nid = numa_mem_id();
 
 	return __alloc_pages_node(nid, gfp_mask, order);
 }
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
