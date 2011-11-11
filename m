Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AFBEF6B009C
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:40 -0500 (EST)
Message-Id: <20111111200735.092268263@linux.com>
Date: Fri, 11 Nov 2011 14:07:26 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 15/18] slub: new_slab_objects() can also get objects from partial list
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=move_partials_into_new_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-10 14:16:06.249338483 -0600
+++ linux-2.6/mm/slub.c	2011-11-10 14:22:31.831510734 -0600
@@ -2089,8 +2089,14 @@ static inline void *new_slab_objects(str
 {
 	void *freelist;
 	struct kmem_cache_cpu *c;
-	struct page *page = new_slab(s, flags, node);
+	struct page *page;
+
+	freelist = get_partial(s, flags, node);
 
+	if (freelist)
+		return freelist;
+
+	page = new_slab(s, flags, node);
 	if (page) {
 		c = __this_cpu_ptr(s->cpu_slab);
 		if (c->page)
@@ -2272,10 +2278,7 @@ new_slab:
 		goto redo;
 	}
 
-	freelist = get_partial(s, gfpflags, node);
-
-	if (!freelist)
-		freelist = new_slab_objects(s, gfpflags, node);
+	freelist = new_slab_objects(s, gfpflags, node);
 
 
 	if (unlikely(!freelist)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
