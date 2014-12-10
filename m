Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 807746B0078
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 11:30:43 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id e89so2311499qgf.24
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:30:43 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id 32si1344393qgt.46.2014.12.10.08.30.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 08:30:37 -0800 (PST)
Message-Id: <20141210163033.717707217@linux.com>
Date: Wed, 10 Dec 2014 10:30:20 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 3/7] slub: Do not use c->page on free
References: <20141210163017.092096069@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=slub_free_compare_address_range
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

Avoid using the page struct address on free by just doing an
address comparison. That is easily doable now that the page address
is available in the page struct and we already have the page struct
address of the object to be freed calculated.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-12-09 12:25:45.770405462 -0600
+++ linux/mm/slub.c	2014-12-09 12:25:45.766405582 -0600
@@ -2625,6 +2625,13 @@ slab_empty:
 	discard_slab(s, page);
 }
 
+static bool same_slab_page(struct kmem_cache *s, struct page *page, void *p)
+{
+	long d = p - page->address;
+
+	return d > 0 && d < (1 << MAX_ORDER) && d < (compound_order(page) << PAGE_SHIFT);
+}
+
 /*
  * Fastpath with forced inlining to produce a kfree and kmem_cache_free that
  * can perform fastpath freeing without additional function calls.
@@ -2658,7 +2665,7 @@ redo:
 	tid = c->tid;
 	preempt_enable();
 
-	if (likely(page == c->page)) {
+	if (likely(same_slab_page(s, page, c->freelist))) {
 		set_freepointer(s, object, c->freelist);
 
 		if (unlikely(!this_cpu_cmpxchg_double(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
