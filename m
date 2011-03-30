Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 414A58D0051
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:24:29 -0400 (EDT)
Message-Id: <20110330202426.533483554@linux.com>
Date: Wed, 30 Mar 2011 15:24:00 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubll1 18/19] slub: fast release on full slab
References: <20110330202342.669400887@linux.com>
Content-Disposition: inline; filename=slab_alloc_fast_release
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

Make deactivation occur implicitly while checking out the current freelist.

This avoids one cmpxchg operation on a slab that is now fully in use.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-03-30 14:43:57.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-03-30 14:44:00.000000000 -0500
@@ -1953,9 +1953,21 @@ static void *__slab_alloc(struct kmem_ca
 			object = page->freelist;
 			counters = page->counters;
 			new.counters = counters;
-			new.inuse = page->objects;
 			VM_BUG_ON(!new.frozen);
 
+			/*
+			 * If there is no object left then we use this loop to
+			 * deactivate the slab which is simple since no objects
+			 * are left in the slab and therefore we do not need to
+			 * put the page back onto the partial list.
+			 *
+			 * If there are objects left then we retrieve them
+			 * and use them to refill the per cpu queue.
+			*/
+
+			new.inuse = page->objects;
+			new.frozen = object != NULL;
+
 		} while (!cmpxchg_double_slab(s, page,
 				object, counters,
 				NULL, new.counters,
@@ -1965,8 +1977,10 @@ static void *__slab_alloc(struct kmem_ca
 load_freelist:
 	VM_BUG_ON(!page->frozen);
 
-	if (unlikely(!object))
+	if (unlikely(!object)) {
+		c->page = NULL;
 		goto new_slab;
+	}
 
 	c->freelist = get_freepointer(s, object);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
