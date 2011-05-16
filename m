Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A670E6B002D
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:34 -0400 (EDT)
Message-Id: <20110516202630.444217953@linux.com>
Date: Mon, 16 May 2011 15:26:21 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 16/25] slub: Get rid of the another_slab label
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=eliminate_another_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

We can avoid deactivate slab in special cases if we do the
deactivation of slabs in each code flow that leads to new_slab.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-16 12:45:44.211458942 -0500
+++ linux-2.6/mm/slub.c	2011-05-16 12:45:49.831458937 -0500
@@ -1951,8 +1951,10 @@ static void *__slab_alloc(struct kmem_ca
 	if (!page)
 		goto new_slab;
 
-	if (unlikely(!node_match(c, node)))
-		goto another_slab;
+	if (unlikely(!node_match(c, node))) {
+		deactivate_slab(s, c);
+		goto new_slab;
+	}
 
 	stat(s, ALLOC_SLOWPATH);
 
@@ -1972,7 +1974,7 @@ load_freelist:
 	VM_BUG_ON(!page->frozen);
 
 	if (unlikely(!object))
-		goto another_slab;
+		goto new_slab;
 
 	stat(s, ALLOC_REFILL);
 
@@ -1981,9 +1983,6 @@ load_freelist:
 	local_irq_restore(flags);
 	return object;
 
-another_slab:
-	deactivate_slab(s, c);
-
 new_slab:
 	page = get_partial(s, gfpflags, node);
 	if (page) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
