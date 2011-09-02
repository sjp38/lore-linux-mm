Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B3E24900147
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 16:47:44 -0400 (EDT)
Message-Id: <20110902204742.029988881@linux.com>
Date: Fri, 02 Sep 2011 15:47:02 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub rfc1 05/12] slub: Extract get_freelist from __slab_alloc
References: <20110902204657.105194589@linux.com>
Content-Disposition: inline; filename=extract_get_freelist
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, linux-mm@kvack.org

get_freelist retrieves free objects from the page freelist (put there by remote
frees) or deactivates a slab page if no more objects are available.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |   57 ++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 32 insertions(+), 25 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-09-02 08:20:25.911219458 -0500
+++ linux-2.6/mm/slub.c	2011-09-02 08:20:32.491219417 -0500
@@ -2024,6 +2024,37 @@ slab_out_of_memory(struct kmem_cache *s,
 }
 
 /*
+ * Check the page->freelist of a page and either transfer the freelist to the per cpu freelist
+ * or deactivate the page.
+ *
+ * The page is still frozen if the return value is not NULL.
+ *
+ * If this function returns NULL then the page has been unfrozen.
+ */
+static inline void *get_freelist(struct kmem_cache *s, struct page *page)
+{
+	struct page new;
+	unsigned long counters;
+	void *freelist;
+
+	do {
+		freelist = page->freelist;
+		counters = page->counters;
+		new.counters = counters;
+		VM_BUG_ON(!new.frozen);
+
+		new.inuse = page->objects;
+		new.frozen = freelist != NULL;
+
+	} while (!cmpxchg_double_slab(s, page,
+		freelist, counters,
+		NULL, new.counters,
+		"get_freelist"));
+
+	return freelist;
+}
+
+/*
  * Slow path. The lockless freelist is empty or we need to perform
  * debugging duties.
  *
@@ -2047,8 +2078,6 @@ static void *__slab_alloc(struct kmem_ca
 	void **object;
 	struct page *page;
 	unsigned long flags;
-	struct page new;
-	unsigned long counters;
 
 	local_irq_save(flags);
 #ifdef CONFIG_PREEMPT
@@ -2074,29 +2103,7 @@ static void *__slab_alloc(struct kmem_ca
 
 	stat(s, ALLOC_SLOWPATH);
 
-	do {
-		object = page->freelist;
-		counters = page->counters;
-		new.counters = counters;
-		VM_BUG_ON(!new.frozen);
-
-		/*
-		 * If there is no object left then we use this loop to
-		 * deactivate the slab which is simple since no objects
-		 * are left in the slab and therefore we do not need to
-		 * put the page back onto the partial list.
-		 *
-		 * If there are objects left then we retrieve them
-		 * and use them to refill the per cpu queue.
-		*/
-
-		new.inuse = page->objects;
-		new.frozen = object != NULL;
-
-	} while (!__cmpxchg_double_slab(s, page,
-			object, counters,
-			NULL, new.counters,
-			"__slab_alloc"));
+	object = get_freelist(s, page);
 
 	if (unlikely(!object)) {
 		c->page = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
