Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id BD3AB6B0088
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 04:26:18 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so760607pdb.14
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 01:26:18 -0700 (PDT)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id wh10si1576164pab.249.2014.03.12.01.26.16
        for <linux-mm@kvack.org>;
        Wed, 12 Mar 2014 01:26:17 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RESEND PATCH] slub: fix high order page allocation problem with  __GFP_NOFAIL
Date: Wed, 12 Mar 2014 17:26:20 +0900
Message-Id: <1394612780-8033-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christian Casteyde <casteyde.christian@free.fr>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

SLUB already try to allocate high order page with clearing __GFP_NOFAIL.
But, when allocating shadow page for kmemcheck, it missed clearing
the flag. This trigger WARN_ON_ONCE() reported by Christian Casteyde.

https://bugzilla.kernel.org/show_bug.cgi?id=65991
https://lkml.org/lkml/2013/12/3/764

This patch fix this situation by using same allocation flag as original
allocation.

Reported-by: Christian Casteyde <casteyde.christian@free.fr>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slub.c b/mm/slub.c
index 3508ede..d43b063 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1348,11 +1348,12 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	page = alloc_slab_page(alloc_gfp, node, oo);
 	if (unlikely(!page)) {
 		oo = s->min;
+		alloc_gfp = flags;
 		/*
 		 * Allocation may have failed due to fragmentation.
 		 * Try a lower order alloc if possible
 		 */
-		page = alloc_slab_page(flags, node, oo);
+		page = alloc_slab_page(alloc_gfp, node, oo);
 
 		if (page)
 			stat(s, ORDER_FALLBACK);
@@ -1362,7 +1363,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 		&& !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
 		int pages = 1 << oo_order(oo);
 
-		kmemcheck_alloc_shadow(page, oo_order(oo), flags, node);
+		kmemcheck_alloc_shadow(page, oo_order(oo), alloc_gfp, node);
 
 		/*
 		 * Objects from caches that have a constructor don't get
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
