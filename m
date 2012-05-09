Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 368216B011E
	for <linux-mm@kvack.org>; Wed,  9 May 2012 11:10:11 -0400 (EDT)
Message-Id: <20120509151009.590577631@linux.com>
Date: Wed, 09 May 2012 10:09:55 -0500
From: cl@linux.com
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup 5/9] slub: new_slab_objects() can also get objects from partial list
References: <20120509150950.243797150@linux.com>
Content-Disposition: inline; filename=move_partials_into_new_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Moving the attempt to get a slab page from the partial lists simplifies
__slab_alloc which is rather complicated.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-04-10 10:33:06.910750804 -0500
+++ linux-2.6/mm/slub.c	2012-04-10 10:33:09.866750743 -0500
@@ -2130,9 +2130,15 @@ static inline void *new_slab_objects(str
 			int node, struct kmem_cache_cpu **pc)
 {
 	void *freelist;
-	struct kmem_cache_cpu *c;
-	struct page *page = new_slab(s, flags, node);
+	struct kmem_cache_cpu *c = *pc;
+	struct page *page;
 
+	freelist = get_partial(s, flags, node, c);
+
+	if (freelist)
+		return freelist;
+
+	page = new_slab(s, flags, node);
 	if (page) {
 		c = __this_cpu_ptr(s->cpu_slab);
 		if (c->page)
@@ -2269,11 +2275,7 @@ new_slab:
 		goto redo;
 	}
 
-	/* Then do expensive stuff like retrieving pages from the partial lists */
-	freelist = get_partial(s, gfpflags, node, c);
-
-	if (!freelist)
-		freelist = new_slab_objects(s, gfpflags, node, &c);
+	freelist = new_slab_objects(s, gfpflags, node, &c);
 
 	if (unlikely(!freelist)) {
 		if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
