Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D3036900152
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 16:47:47 -0400 (EDT)
Message-Id: <20110902204745.539298711@linux.com>
Date: Fri, 02 Sep 2011 15:47:08 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub rfc1 11/12] slub: Remove kmem_cache_cpu dependency from acquire slab
References: <20110902204657.105194589@linux.com>
Content-Disposition: inline; filename=remove_kmem_cache_cpu_dependency_from_acquire_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, linux-mm@kvack.org

Instead of putting the freepointer into the kmem_cache_cpu structure put it
into the page struct reusing the lru.next field.

Also convert the manual warning into a WARN_ON.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   41 +++++++++++++++--------------------------
 1 file changed, 15 insertions(+), 26 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-09-02 10:12:25.981176437 -0500
+++ linux-2.6/mm/slub.c	2011-09-02 10:12:30.881176403 -0500
@@ -1569,37 +1569,25 @@ static inline int acquire_slab(struct km
 	 * The old freelist is the list of objects for the
 	 * per cpu allocation list.
 	 */
-	do {
-		freelist = page->freelist;
-		counters = page->counters;
-		new.counters = counters;
-		new.inuse = page->objects;
+	freelist = page->freelist;
+	counters = page->counters;
+	new.counters = counters;
+	new.inuse = page->objects;
 
-		VM_BUG_ON(new.frozen);
-		new.frozen = 1;
+	VM_BUG_ON(new.frozen);
+	new.frozen = 1;
 
-	} while (!__cmpxchg_double_slab(s, page,
+	if (!__cmpxchg_double_slab(s, page,
 			freelist, counters,
 			NULL, new.counters,
-			"lock and freeze"));
-
-	remove_partial(n, page);
+			"acquire_slab"))
 
-	if (freelist) {
-		/* Populate the per cpu freelist */
-		this_cpu_write(s->cpu_slab->freelist, freelist);
-		this_cpu_write(s->cpu_slab->page, page);
-		return 1;
-	} else {
-		/*
-		 * Slab page came from the wrong list. No object to allocate
-		 * from. Put it onto the correct list and continue partial
-		 * scan.
-		 */
-		printk(KERN_ERR "SLUB: %s : Page without available objects on"
-			" partial list\n", s->name);
 		return 0;
-	}
+
+	remove_partial(n, page);
+	WARN_ON(!freelist);
+	page->lru.next = freelist;
+	return 1;
 }
 
 /*
@@ -2133,7 +2121,8 @@ new_slab:
 	page = get_partial(s, gfpflags, node);
 	if (page) {
 		stat(s, ALLOC_FROM_PARTIAL);
-		freelist = c->freelist;
+		freelist = page->lru.next;
+		c->page  = page;
 		if (kmem_cache_debug(s))
 			goto debug;
 		goto load_freelist;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
