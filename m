Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AD0216B004F
	for <linux-mm@kvack.org>; Fri, 22 May 2009 04:50:16 -0400 (EDT)
Date: Fri, 22 May 2009 18:20:40 +0930
From: Ron <ron@debian.org>
Subject: [PATCH] slab: add missing guard for kernel_map_pages() use
Message-ID: <20090522085040.GC4448@homer.shelbyville.oz>
References: <20090521192822.GB4448@homer.shelbyville.oz> <1242979372.13681.1.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1242979372.13681.1.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org, akinobu.mita@gmail.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


All other uses of kernel_map_pages() are explicitly excluded without
CONFIG_DEBUG_PAGEALLOC, this one should be too.

Signed-off-by: Ron Lee <ron@debian.org>


diff --git a/mm/slab.c b/mm/slab.c
index 9a90b00..b5e5b27 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2674,10 +2683,12 @@ static void cache_init_objs(struct kmem_cache *cachep,
 				slab_error(cachep, "constructor overwrote the"
 					   " start of an object");
 		}
+#ifdef CONFIG_DEBUG_PAGEALLOC
 		if ((cachep->buffer_size % PAGE_SIZE) == 0 &&
 			    OFF_SLAB(cachep) && cachep->flags & SLAB_POISON)
 			kernel_map_pages(virt_to_page(objp),
 					 cachep->buffer_size / PAGE_SIZE, 0);
+#endif
 #else
 		if (cachep->ctor)
 			cachep->ctor(objp);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
