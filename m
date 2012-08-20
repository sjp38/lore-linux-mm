Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id AAEAC6B005D
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 16:47:52 -0400 (EDT)
Message-Id: <0000013945ca92e7-6a552895-9ede-4e78-9ef1-0324b72fef9e-000000@email.amazonses.com>
Date: Mon, 20 Aug 2012 20:47:47 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C12 [01/19] slub: Add debugging to verify correct cache use on kmem_cache_free()
References: <20120820204021.494276880@linux.com>
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
