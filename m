Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 03D806B0074
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 11:30:38 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id f51so2358919qge.35
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:30:37 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id q5si5337854qal.127.2014.12.10.08.30.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 08:30:36 -0800 (PST)
Message-Id: <20141210163033.497862168@linux.com>
Date: Wed, 10 Dec 2014 10:30:18 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 1/7] slub: Remove __slab_alloc code duplication
References: <20141210163017.092096069@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=simplify_code
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

Somehow the two branches in __slab_alloc do the same.
Unify them.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-12-08 13:24:05.193185492 -0600
+++ linux/mm/slub.c	2014-12-09 12:23:11.927032128 -0600
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
