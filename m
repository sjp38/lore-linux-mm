Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DCB7A6B006E
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:30 -0500 (EST)
Message-Id: <20111111200726.995401746@linux.com>
Date: Fri, 11 Nov 2011 14:07:14 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 03/18] slub: Extract get_freelist from __slab_alloc
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=extract_get_freelist
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

get_freelist retrieves free objects from the page freelist (put there by remote
frees) or deactivates a slab page if no more objects are available.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |   57 ++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 32 insertions(+), 25 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-09 11:10:55.671388657 -0600
+++ linux-2.6/mm/slub.c	2011-11-09 11:11:13.471490305 -0600
@@ -2110,6 +2110,37 @@ static inline void *new_slab_objects(str
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
@@ -2130,8 +2161,6 @@ static void *__slab_alloc(struct kmem_ca
 {
 	void **object;
 	unsigned long flags;
-	struct page new;
-	unsigned long counters;
 
 	local_irq_save(flags);
 #ifdef CONFIG_PREEMPT
@@ -2156,29 +2185,7 @@ redo:
 
 	stat(s, ALLOC_SLOWPATH);
 
-	do {
-		object = c->page->freelist;
-		counters = c->page->counters;
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
-		 */
-
-		new.inuse = c->page->objects;
-		new.frozen = object != NULL;
-
-	} while (!__cmpxchg_double_slab(s, c->page,
-			object, counters,
-			NULL, new.counters,
-			"__slab_alloc"));
+	object = get_freelist(s, c->page);
 
 	if (!object) {
 		c->page = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
