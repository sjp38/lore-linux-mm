Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id D5B4A6B005A
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 17:11:57 -0400 (EDT)
Message-Id: <20120801211156.092311733@linux.com>
Date: Wed, 01 Aug 2012 16:11:31 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [01/16] slub: Add debugging to verify correct cache use on kmem_cache_free()
References: <20120801211130.025389154@linux.com>
Content-Disposition: inline; filename=slub_new_debug
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Add additional debugging to check that the objects is actually from the cache
the caller claims. Doing so currently trips up some other debugging code. It
takes a lot to infer from that what was happening.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-07-31 11:46:01.544493395 -0500
+++ linux-2.6/mm/slub.c	2012-07-31 11:53:21.832078581 -0500
@@ -2583,6 +2583,13 @@
 
 	page = virt_to_head_page(x);
 
+	if (kmem_cache_debug(s) && page->slab != s) {
+		printk("kmem_cache_free: Wrong slab cache. %s but object"
+			" is from  %s\n", page->slab->name, s->name);
+		WARN_ON(1);
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
