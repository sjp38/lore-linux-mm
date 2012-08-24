Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 504506B009C
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:17:36 -0400 (EDT)
Message-Id: <00000139596ca1bb-cd01519b-4a4a-4673-9567-2f2b6d7d3616-000000@email.amazonses.com>
Date: Fri, 24 Aug 2012 16:17:35 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C13 [01/14] slub: Add debugging to verify correct cache use on kmem_cache_free()
References: <20120824160903.168122683@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Add additional debugging to check that the objects is actually from the cache
the caller claims. Doing so currently trips up some other debugging code. It
takes a lot to infer from that what was happening.

V2: Only warn once.

Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index c67bd0a..00f8557 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2614,6 +2614,13 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
 
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
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
