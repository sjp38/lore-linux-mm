Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 752406B002C
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:34 -0400 (EDT)
Message-Id: <20110516202632.259446673@linux.com>
Date: Mon, 16 May 2011 15:26:24 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 19/25] slub: Not necessary to check for empty slab on load_freelist
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=goto_load_freelist
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

load_freelist is now only branched to only if there are objects available.
So no need to check the object variable for NULL.

---
 mm/slub.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-16 12:51:57.171458507 -0500
+++ linux-2.6/mm/slub.c	2011-05-16 12:52:00.731458504 -0500
@@ -1983,9 +1983,6 @@ static void *__slab_alloc(struct kmem_ca
 			NULL, new.counters,
 			"__slab_alloc"));
 
-load_freelist:
-	VM_BUG_ON(!page->frozen);
-
 	if (unlikely(!object)) {
 		c->page = NULL;
 		stat(s, DEACTIVATE_BYPASS);
@@ -1994,6 +1991,8 @@ load_freelist:
 
 	stat(s, ALLOC_REFILL);
 
+load_freelist:
+	VM_BUG_ON(!page->frozen);
 	c->freelist = get_freepointer(s, object);
 	c->tid = next_tid(c->tid);
 	local_irq_restore(flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
