Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id AA68C6B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 18:18:08 -0500 (EST)
Received: by iecrl12 with SMTP id rl12so359171iec.4
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 15:18:08 -0800 (PST)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id y73si31917788ioi.26.2015.02.24.15.18.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 15:18:08 -0800 (PST)
Received: by mail-ig0-f182.google.com with SMTP id h15so1412187igd.3
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 15:18:08 -0800 (PST)
Date: Tue, 24 Feb 2015 15:18:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, mempolicy: migrate_to_node should only migrate to node
Message-ID: <alpine.DEB.2.10.1502241511540.8003@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

migrate_to_node() is intended to migrate a page from one source node to a 
target node.

Today, migrate_to_node() could end up migrating to any node, not only the 
target node.  This is because the page migration allocator, 
new_node_page() does not pass __GFP_THISNODE to alloc_pages_exact_node().  
This causes the target node to be preferred but allows fallback to any 
other node in order of affinity.

Prevent this by allocating with __GFP_THISNODE.  If memory is not 
available, -ENOMEM will be returned as appropriate.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/mempolicy.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -945,7 +945,8 @@ static struct page *new_node_page(struct page *page, unsigned long node, int **x
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					node);
 	else
-		return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
+		return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE |
+						    __GFP_THISNODE, 0);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
