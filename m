Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 58BA16B002A
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:34 -0400 (EDT)
Message-Id: <20110516202631.680279544@linux.com>
Date: Mon, 16 May 2011 15:26:23 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 18/25] slub: fast release on full slab
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=slab_alloc_fast_release
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

Make deactivation occur implicitly while checking out the current freelist.

This avoids one cmpxchg operation on a slab that is now fully in use.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slub_def.h |    1 +
 mm/slub.c                |   21 +++++++++++++++++++--
 2 files changed, 20 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-16 12:51:49.901458516 -0500
+++ linux-2.6/mm/slub.c	2011-05-16 12:51:57.171458507 -0500
@@ -1963,9 +1963,21 @@ static void *__slab_alloc(struct kmem_ca
 		object = page->freelist;
 		counters = page->counters;
 		new.counters = counters;
-		new.inuse = page->objects;
 		VM_BUG_ON(!new.frozen);
 
+		/*
+		 * If there is no object left then we use this loop to
+		 * deactivate the slab which is simple since no objects
+		 * are left in the slab and therefore we do not need to
+		 * put the page back onto the partial list.
+		 *
+		 * If there are objects left then we retrieve them
+		 * and use them to refill the per cpu queue.
+		*/
+
+		new.inuse = page->objects;
+		new.frozen = object != NULL;
+
 	} while (!cmpxchg_double_slab(s, page,
 			object, counters,
 			NULL, new.counters,
@@ -1974,8 +1986,11 @@ static void *__slab_alloc(struct kmem_ca
 load_freelist:
 	VM_BUG_ON(!page->frozen);
 
-	if (unlikely(!object))
+	if (unlikely(!object)) {
+		c->page = NULL;
+		stat(s, DEACTIVATE_BYPASS);
 		goto new_slab;
+	}
 
 	stat(s, ALLOC_REFILL);
 
@@ -4659,6 +4674,7 @@ STAT_ATTR(DEACTIVATE_EMPTY, deactivate_e
 STAT_ATTR(DEACTIVATE_TO_HEAD, deactivate_to_head);
 STAT_ATTR(DEACTIVATE_TO_TAIL, deactivate_to_tail);
 STAT_ATTR(DEACTIVATE_REMOTE_FREES, deactivate_remote_frees);
+STAT_ATTR(DEACTIVATE_BYPASS, deactivate_bypass);
 STAT_ATTR(ORDER_FALLBACK, order_fallback);
 STAT_ATTR(CMPXCHG_DOUBLE_CPU_FAIL, cmpxchg_double_cpu_fail);
 STAT_ATTR(CMPXCHG_DOUBLE_FAIL, cmpxchg_double_fail);
@@ -4719,6 +4735,7 @@ static struct attribute *slab_attrs[] =
 	&deactivate_to_head_attr.attr,
 	&deactivate_to_tail_attr.attr,
 	&deactivate_remote_frees_attr.attr,
+	&deactivate_bypass_attr.attr,
 	&order_fallback_attr.attr,
 	&cmpxchg_double_fail_attr.attr,
 	&cmpxchg_double_cpu_fail_attr.attr,
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2011-05-16 12:51:49.901458516 -0500
+++ linux-2.6/include/linux/slub_def.h	2011-05-16 12:51:57.171458507 -0500
@@ -32,6 +32,7 @@ enum stat_item {
 	DEACTIVATE_TO_HEAD,	/* Cpu slab was moved to the head of partials */
 	DEACTIVATE_TO_TAIL,	/* Cpu slab was moved to the tail of partials */
 	DEACTIVATE_REMOTE_FREES,/* Slab contained remotely freed objects */
+	DEACTIVATE_BYPASS,	/* Implicit deactivation */
 	ORDER_FALLBACK,		/* Number of times fallback was necessary */
 	CMPXCHG_DOUBLE_CPU_FAIL,/* Failure of this_cpu_cmpxchg_double */
 	CMPXCHG_DOUBLE_FAIL,	/* Number of times that cmpxchg double did not match */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
