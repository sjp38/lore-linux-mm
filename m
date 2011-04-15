Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 32E56900097
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:13:08 -0400 (EDT)
Message-Id: <20110415201305.961665970@linux.com>
Date: Fri, 15 Apr 2011 15:13:05 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv333num@/21] slub: fast release on full slab
References: <20110415201246.096634892@linux.com>
Content-Disposition: inline; filename=slab_alloc_fast_release
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-mm@kvack.org

Make deactivation occur implicitly while checking out the current freelist.

This avoids one cmpxchg operation on a slab that is now fully in use.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-04-15 14:30:10.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-04-15 14:30:12.000000000 -0500
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
