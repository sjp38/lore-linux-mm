Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 807B96B02D1
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 19:16:15 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o7MNGCx9028840
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 16:16:13 -0700
Received: from pvg13 (pvg13.prod.google.com [10.241.210.141])
	by hpaq1.eem.corp.google.com with ESMTP id o7MNGAs6000594
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 16:16:11 -0700
Received: by pvg13 with SMTP id 13so2801306pvg.24
        for <linux-mm@kvack.org>; Sun, 22 Aug 2010 16:16:10 -0700 (PDT)
Date: Sun, 22 Aug 2010 16:16:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] slob: fix gfp flags for order-0 page allocations
Message-ID: <alpine.DEB.2.00.1008221615350.29062@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kmalloc_node() may allocate higher order slob pages, but the __GFP_COMP
bit is only passed to the page allocator and not represented in the
tracepoint event.  The bit should be passed to trace_kmalloc_node() as
well.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slob.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -500,7 +500,9 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 	} else {
 		unsigned int order = get_order(size);
 
-		ret = slob_new_pages(gfp | __GFP_COMP, get_order(size), node);
+		if (likely(order))
+			gfp |= __GFP_COMP;
+		ret = slob_new_pages(gfp, order, node);
 		if (ret) {
 			struct page *page;
 			page = virt_to_page(ret);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
