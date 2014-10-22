Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id AADD76B007D
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 11:55:30 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id h18so1178488igc.6
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 08:55:30 -0700 (PDT)
Received: from resqmta-po-09v.sys.comcast.net (resqmta-po-09v.sys.comcast.net. [2001:558:fe16:19:96:114:154:168])
        by mx.google.com with ESMTPS id 4si2309228iot.91.2014.10.22.08.55.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 08:55:30 -0700 (PDT)
Message-Id: <20141022155526.942670823@linux.com>
Date: Wed, 22 Oct 2014 10:55:18 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 1/4] slub: Remove __slab_alloc code duplication
References: <20141022155517.560385718@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=simplify_code
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

Somehow the two branches in __slab_alloc do the same.
Unify them.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -2280,12 +2280,8 @@ redo:
 		if (node != NUMA_NO_NODE && !node_present_pages(node))
 			searchnode = node_to_mem_node(node);
 
-		if (unlikely(!node_match(page, searchnode))) {
-			stat(s, ALLOC_NODE_MISMATCH);
-			deactivate_slab(s, page, c->freelist);
-			c->page = NULL;
-			c->freelist = NULL;
-			goto new_slab;
+		if (unlikely(!node_match(page, searchnode)))
+			goto deactivate;
 		}
 	}
 
@@ -2294,12 +2290,8 @@ redo:
 	 * PFMEMALLOC but right now, we are losing the pfmemalloc
 	 * information when the page leaves the per-cpu allocator
 	 */
-	if (unlikely(!pfmemalloc_match(page, gfpflags))) {
-		deactivate_slab(s, page, c->freelist);
-		c->page = NULL;
-		c->freelist = NULL;
-		goto new_slab;
-	}
+	if (unlikely(!pfmemalloc_match(page, gfpflags)))
+		goto deactivate;
 
 	/* must check again c->freelist in case of cpu migration or IRQ */
 	freelist = c->freelist;
@@ -2328,6 +2320,11 @@ load_freelist:
 	local_irq_restore(flags);
 	return freelist;
 
+deactivate:
+	deactivate_slab(s, page, c->freelist);
+	c->page = NULL;
+	c->freelist = NULL;
+
 new_slab:
 
 	if (c->partial) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
