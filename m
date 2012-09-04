Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 1FDFB6B0072
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 19:06:16 -0400 (EDT)
Message-Id: <000001399388b912-0f946031-9abd-4b99-8380-e6dd4d88341d-000000@email.amazonses.com>
Date: Tue, 4 Sep 2012 23:06:14 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C14 [01/14] [PATCH 10/28] slub: Add debugging to verify correct cache use on kmem_cache_free()
References: <20120904230609.691088980@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Add additional debugging to check that the objects is actually from the cache
the caller claims. Doing so currently trips up some other debugging code. It
takes a lot to infer from that what was happening.

V2: Only warn once.

Reviewed-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-09-04 18:00:13.218025791 -0500
+++ linux/mm/slub.c	2012-09-04 18:02:00.947707104 -0500
@@ -2614,6 +2614,13 @@ void kmem_cache_free(struct kmem_cache *
 
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
