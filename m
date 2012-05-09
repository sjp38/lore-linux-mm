Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 32A926B011A
	for <linux-mm@kvack.org>; Wed,  9 May 2012 11:10:10 -0400 (EDT)
Message-Id: <20120509151008.488635805@linux.com>
Date: Wed, 09 May 2012 10:09:53 -0500
From: cl@linux.com
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup 3/9] slub: Acquire_slab() avoid loop
References: <20120509150950.243797150@linux.com>
Content-Disposition: inline; filename=simplify
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Avoid the loop in acquire slab and simply fail if there is a conflict.

This will cause the next page on the list to be considered.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-04-10 10:32:58.634750976 -0500
+++ linux-2.6/mm/slub.c	2012-04-10 10:33:01.818750910 -0500
@@ -1490,12 +1490,12 @@ static inline void remove_partial(struct
 }
 
 /*
- * Lock slab, remove from the partial list and put the object into the
- * per cpu freelist.
+ * Remove slab from the partial list, freeze it and
+ * return the pointer to the freelist.
  *
  * Returns a list of objects or NULL if it fails.
  *
- * Must hold list_lock.
+ * Must hold list_lock since we modify the partial list.
  */
 static inline void *acquire_slab(struct kmem_cache *s,
 		struct kmem_cache_node *n, struct page *page,
@@ -1510,22 +1510,24 @@ static inline void *acquire_slab(struct
 	 * The old freelist is the list of objects for the
 	 * per cpu allocation list.
 	 */
-	do {
-		freelist = page->freelist;
-		counters = page->counters;
-		new.counters = counters;
-		if (mode)
-			new.inuse = page->objects;
+	freelist = page->freelist;
+	counters = page->counters;
+	new.counters = counters;
+	if (mode)
+		new.inuse = page->objects;
 
-		VM_BUG_ON(new.frozen);
-		new.frozen = 1;
+	VM_BUG_ON(new.frozen);
+	new.frozen = 1;
 
-	} while (!__cmpxchg_double_slab(s, page,
+	if (!__cmpxchg_double_slab(s, page,
 			freelist, counters,
 			NULL, new.counters,
-			"lock and freeze"));
+			"acquire_slab"))
+
+		return NULL;
 
 	remove_partial(n, page);
+	WARN_ON(!freelist);
 	return freelist;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
