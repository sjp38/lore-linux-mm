Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0C562900113
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:37 -0400 (EDT)
Message-Id: <20110516202635.172662310@linux.com>
Date: Mon, 16 May 2011 15:26:29 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 24/25] slub: Remove gotos from __slab_free()
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=degotofy_slab_free
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |   46 +++++++++++++++++++++++-----------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-16 14:27:50.551451801 -0500
+++ linux-2.6/mm/slub.c	2011-05-16 14:31:53.401451518 -0500
@@ -2259,34 +2259,34 @@ static void __slab_free(struct kmem_cach
 	if (was_frozen)
 		stat(s, FREE_FROZEN);
 	else {
-		if (unlikely(!inuse && n->nr_partial > s->min_partial))
-                        goto slab_empty;
+		if (unlikely(inuse || n->nr_partial <= s->min_partial)) {
+			/*
+			 * Objects left in the slab. If it was not on the partial list before
+			 * then add it.
+			 */
+			if (unlikely(!prior)) {
+				remove_full(s, page);
+				add_partial(n, page, 0);
+				stat(s, FREE_ADD_PARTIAL);
+			}
+		} else {
+			/* Empty slab */
+			if (prior) {
+				/*
+				 * Slab still on the partial list.
+				 */
+				remove_partial(n, page);
+				stat(s, FREE_REMOVE_PARTIAL);
+			}
 
-		/*
-		 * Objects left in the slab. If it was not on the partial list before
-		 * then add it.
-		 */
-		if (unlikely(!prior)) {
-			remove_full(s, page);
-			add_partial(n, page, 0);
-			stat(s, FREE_ADD_PARTIAL);
+			spin_unlock_irqrestore(&n->list_lock, flags);
+			stat(s, FREE_SLAB);
+			discard_slab(s, page);
+			return;
 		}
 	}
 	spin_unlock_irqrestore(&n->list_lock, flags);
 	return;
-
-slab_empty:
-	if (prior) {
-		/*
-		 * Slab still on the partial list.
-		 */
-		remove_partial(n, page);
-		stat(s, FREE_REMOVE_PARTIAL);
-	}
-
-	spin_unlock_irqrestore(&n->list_lock, flags);
-	stat(s, FREE_SLAB);
-	discard_slab(s, page);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
