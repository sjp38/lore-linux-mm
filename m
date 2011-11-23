Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 97E616B00BF
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 20:26:09 -0500 (EST)
Received: by iaek3 with SMTP id k3so1203323iae.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 17:26:07 -0800 (PST)
Date: Tue, 22 Nov 2011 17:26:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, debug: test for online nid when allocating on single
 node
Message-ID: <alpine.DEB.2.00.1111221724550.18644@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

Calling alloc_pages_exact_node() means the allocation only passes the
zonelist of a single node into the page allocator.  If that node isn't
online, it's zonelist may never have been initialized causing a strange
oops that may not immediately be clear.

I recently debugged an issue where node 0 wasn't online and an allocator
was passing 0 to alloc_pages_exact_node() and it resulted in a NULL
pointer on zonelist->_zoneref.  If CONFIG_DEBUG_VM is enabled, though, it
would be nice to catch this a bit earlier.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/gfp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -313,7 +313,7 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
-	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
+	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
 
 	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
