Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 35FEE6B0080
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 09:57:54 -0400 (EDT)
Message-Id: <20120809135633.629317723@linux.com>
Date: Thu, 09 Aug 2012 08:56:24 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common11r [01/20] slub: Add debugging to verify correct cache use on kmem_cache_free()
References: <20120809135623.574621297@linux.com>
Content-Disposition: inline; filename=slub_new_debug
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Add additional debugging to check that the objects is actually from the cache
the caller claims. Doing so currently trips up some other debugging code. It
takes a lot to infer from that what was happening.

V2: Only warn once. 

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-03 14:16:27.396663869 -0500
+++ linux-2.6/mm/slub.c	2012-08-03 14:16:38.664866880 -0500
@@ -2607,6 +2607,13 @@ void kmem_cache_free(struct kmem_cache *
 
 	page = virt_to_head_page(x);
 
+	if (kmem_cache_debug(s) && page->slab != s) {
+		printk("kmem_cache_free: Wrong slab cache. %s but object"
+			" is from  %s\n", page->slab->name, s->name);
+		WARN_ON_ONCE(1);
+		return;
+	}
+
 	slab_free(s, page, x, _RET_IP_);
 
 	trace_kmem_cache_free(_RET_IP_, x);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
