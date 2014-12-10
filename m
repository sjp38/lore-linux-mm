Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 51DF26B007B
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 11:30:46 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id q107so287513qgd.33
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:30:46 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id k8si5443830qad.19.2014.12.10.08.30.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 08:30:38 -0800 (PST)
Message-Id: <20141210163033.841468065@linux.com>
Date: Wed, 10 Dec 2014 10:30:21 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 4/7] slub: Avoid using the page struct address in allocation fastpath
References: <20141210163017.092096069@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=more_c_page
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

We can use virt_to_page there and only invoke the costly function if
actually a node is specified and we have to check the NUMA locality.

Increases the cost of allocating on a specific NUMA node but then that
was never cheap since we may have to dump our caches and retrieve memory
from the correct node.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-12-09 12:27:49.414686959 -0600
+++ linux/mm/slub.c	2014-12-09 12:27:49.414686959 -0600
@@ -2097,6 +2097,15 @@ static inline int node_match(struct page
 	return 1;
 }
 
+static inline int node_match_ptr(void *p, int node)
+{
+#ifdef CONFIG_NUMA
+	if (!p || (node != NUMA_NO_NODE && page_to_nid(virt_to_page(p)) != node))
+		return 0;
+#endif
+	return 1;
+}
+
 #ifdef CONFIG_SLUB_DEBUG
 static int count_free(struct page *page)
 {
@@ -2410,7 +2419,7 @@ redo:
 
 	object = c->freelist;
 	page = c->page;
-	if (unlikely(!object || !node_match(page, node))) {
+	if (unlikely(!object || !node_match_ptr(object, node))) {
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 		stat(s, ALLOC_SLOWPATH);
 	} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
