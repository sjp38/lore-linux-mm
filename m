Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAD86B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 10:21:32 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so3242805pde.35
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 07:21:32 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id bq5si1537986pbb.108.2014.01.24.07.20.47
        for <linux-mm@kvack.org>;
        Fri, 24 Jan 2014 07:20:48 -0800 (PST)
Subject: [linux-next][PATCH] mm: slub: work around unneeded lockdep warning
From: Dave Hansen <dave@sr71.net>
Date: Fri, 24 Jan 2014 07:20:23 -0800
Message-Id: <20140124152023.A450E599@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Hansen <dave@sr71.net>, peterz@infradead.org, penberg@kernel.org, linux@arm.linux.org.uk


I think this is a next-only thing.  Pekka, can you pick this up,
please?

--

From: Dave Hansen <dave.hansen@linux.intel.com>

The slub code does some setup during early boot in
early_kmem_cache_node_alloc() with some local data.  There is no
possible way that another CPU can see this data, so the slub code
doesn't unnecessarily lock it.  However, some new lockdep asserts
check to make sure that add_partial() _always_ has the list_lock
held.

Just add the locking, even though it is technically unnecessary.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Russell King <linux@arm.linux.org.uk>
---

 b/mm/slub.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff -puN mm/slub.c~slub-lockdep-workaround mm/slub.c
--- a/mm/slub.c~slub-lockdep-workaround	2014-01-24 07:19:23.794069012 -0800
+++ b/mm/slub.c	2014-01-24 07:19:23.799069236 -0800
@@ -2890,7 +2890,13 @@ static void early_kmem_cache_node_alloc(
 	init_kmem_cache_node(n);
 	inc_slabs_node(kmem_cache_node, node, page->objects);
 
+	/*
+	 * the lock is for lockdep's sake, not for any actual
+	 * race protection
+	 */
+	spin_lock(&n->list_lock);
 	add_partial(n, page, DEACTIVATE_TO_HEAD);
+	spin_unlock(&n->list_lock);
 }
 
 static void free_kmem_cache_nodes(struct kmem_cache *s)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
