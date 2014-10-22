Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id E88FF6B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 14:27:07 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id uq10so1462299igb.2
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 11:27:07 -0700 (PDT)
Received: from resqmta-po-07v.sys.comcast.net (resqmta-po-07v.sys.comcast.net. [2001:558:fe16:19:96:114:154:166])
        by mx.google.com with ESMTPS id w19si22188537ich.28.2014.10.22.11.27.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 11:27:07 -0700 (PDT)
Date: Wed, 22 Oct 2014 13:27:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 1/4] slub: Remove __slab_alloc code duplication
In-Reply-To: <alpine.DEB.2.11.1410222002380.5308@nanos>
Message-ID: <alpine.DEB.2.11.1410221321320.6250@gentwo.org>
References: <20141022155517.560385718@linux.com> <20141022155526.942670823@linux.com> <alpine.DEB.2.11.1410222002380.5308@nanos>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: akpm@linuxfoundation.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

On Wed, 22 Oct 2014, Thomas Gleixner wrote:

> That's not compiling at all due to the left over '}' !

Argh. Stale patch.

> And shouldn't you keep the stat(); call in that code path?

True. Fixed up patch follows:


Subject: slub: Remove __slab_alloc code duplication

Somehow the two branches in __slab_alloc do the same.
Unify them.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -2282,10 +2282,7 @@ redo:

 		if (unlikely(!node_match(page, searchnode))) {
 			stat(s, ALLOC_NODE_MISMATCH);
-			deactivate_slab(s, page, c->freelist);
-			c->page = NULL;
-			c->freelist = NULL;
-			goto new_slab;
+			goto deactivate;
 		}
 	}

@@ -2294,12 +2291,8 @@ redo:
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
@@ -2328,6 +2321,11 @@ load_freelist:
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
