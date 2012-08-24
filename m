Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 55E5E6B0069
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:07:11 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ro12so4071582pbb.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2012 09:07:10 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 2/2] slub: correct the calculation of the number of cpu objects in get_partial_node
Date: Sat, 25 Aug 2012 01:05:03 +0900
Message-Id: <1345824303-30292-2-git-send-email-js1304@gmail.com>
In-Reply-To: <1345824303-30292-1-git-send-email-js1304@gmail.com>
References: <Yes>
 <1345824303-30292-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux-foundation.org>

In get_partial_node(), we want to refill cpu slab and cpu partial slabs
until the number of object kept in the per cpu slab and cpu partial lists
of a processor is reached to max_cpu_object.

However, in current implementation, it is not achieved.
See following code in get_partial_node().

if (!object) {
	c->page = page;
	stat(s, ALLOC_FROM_PARTIAL);
	object = t;
	available =  page->objects - page->inuse;
} else {
	available = put_cpu_partial(s, page, 0);
	stat(s, CPU_PARTIAL_NODE);
}
if (kmem_cache_debug(s) || available > s->cpu_partial / 2)
	break;

In case of !object (available = page->objects - page->inuse),
"available" means the number of objects in cpu slab.
In this time, we don't have any cpu partial slab, so "available" imply
the number of objects available to the cpu without locking.
This is what we want.

But, look at another "available" (available = put_cpu_partial(s, page, 0)).
This "available" doesn't include the number of objects in cpu slab.
It only include the number of objects in cpu partial slabs.
So, it doesn't imply the number of objects available to the cpu without locking.
This isn't what we want.

Therefore fix it to imply same meaning in both case
and rename "available" to "cpu_slab_objects" for readability.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>

diff --git a/mm/slub.c b/mm/slub.c
index d597530..c96e0e4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1538,6 +1538,7 @@ static void *get_partial_node(struct kmem_cache *s,
 {
 	struct page *page, *page2;
 	void *object = NULL;
+	int cpu_slab_objects = 0, pobjects = 0;
 
 	/*
 	 * Racy check. If we mistakenly see no partial slabs then we
@@ -1551,7 +1552,6 @@ static void *get_partial_node(struct kmem_cache *s,
 	spin_lock(&n->list_lock);
 	list_for_each_entry_safe(page, page2, &n->partial, lru) {
 		void *t = acquire_slab(s, n, page, object == NULL);
-		int available;
 
 		if (!t)
 			break;
@@ -1560,12 +1560,13 @@ static void *get_partial_node(struct kmem_cache *s,
 			c->page = page;
 			stat(s, ALLOC_FROM_PARTIAL);
 			object = t;
-			available =  page->objects - page->inuse;
+			cpu_slab_objects = page->objects - page->inuse;
 		} else {
-			available = put_cpu_partial(s, page, 0);
+			pobjects = put_cpu_partial(s, page, 0);
 			stat(s, CPU_PARTIAL_NODE);
 		}
-		if (kmem_cache_debug(s) || available > s->max_cpu_object / 2)
+		if (kmem_cache_debug(s)
+			|| cpu_slab_objects + pobjects > s->max_cpu_object / 2)
 			break;
 
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
