Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C2B178D003B
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:26 -0400 (EDT)
Message-Id: <20110516202623.440437817@linux.com>
Date: Mon, 16 May 2011 15:26:09 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 04/25] slub: Push irq disable into allocate_slab()
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=push_irq_disable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

Do the irq handling in allocate_slab() instead of __slab_alloc().

__slab_alloc() is already cluttered and allocate_slab() is already
fiddling around with gfp flags.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-16 11:40:38.031463496 -0500
+++ linux-2.6/mm/slub.c	2011-05-16 11:42:31.921463363 -0500
@@ -1187,6 +1187,11 @@ static struct page *allocate_slab(struct
 	struct kmem_cache_order_objects oo = s->oo;
 	gfp_t alloc_gfp;
 
+	flags &= gfp_allowed_mask;
+
+	if (flags & __GFP_WAIT)
+		local_irq_enable();
+
 	flags |= s->allocflags;
 
 	/*
@@ -1203,12 +1208,15 @@ static struct page *allocate_slab(struct
 		 * Try a lower order alloc if possible
 		 */
 		page = alloc_slab_page(flags, node, oo);
-		if (!page)
-			return NULL;
-
 		stat(s, ORDER_FALLBACK);
 	}
 
+	if (flags & __GFP_WAIT)
+		local_irq_disable();
+
+	if (!page)
+		return NULL;
+
 	if (kmemcheck_enabled
 		&& !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
 		int pages = 1 << oo_order(oo);
@@ -1850,15 +1858,8 @@ new_slab:
 		goto load_freelist;
 	}
 
-	gfpflags &= gfp_allowed_mask;
-	if (gfpflags & __GFP_WAIT)
-		local_irq_enable();
-
 	page = new_slab(s, gfpflags, node);
 
-	if (gfpflags & __GFP_WAIT)
-		local_irq_disable();
-
 	if (page) {
 		c = __this_cpu_ptr(s->cpu_slab);
 		stat(s, ALLOC_SLAB);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
