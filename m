Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D58FE8D0049
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:24:20 -0400 (EDT)
Message-Id: <20110330202418.145015838@linux.com>
Date: Wed, 30 Mar 2011 15:23:47 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubll1 05/19] slub: Move debug handlign in __slab_free
References: <20110330202342.669400887@linux.com>
Content-Disposition: inline; filename=move_debug
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

Its easier to read if its with the check for debugging flags.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-03-28 14:52:13.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-03-28 14:52:58.000000000 -0500
@@ -2051,10 +2051,9 @@ static void __slab_free(struct kmem_cach
 	slab_lock(page);
 	stat(s, FREE_SLOWPATH);
 
-	if (kmem_cache_debug(s))
-		goto debug;
+	if (kmem_cache_debug(s) && !free_debug_processing(s, page, x, addr))
+		goto out_unlock;
 
-checks_ok:
 	prior = page->freelist;
 	set_freepointer(s, object, prior);
 	page->freelist = object;
@@ -2098,12 +2097,6 @@ slab_empty:
 #endif
 	stat(s, FREE_SLAB);
 	discard_slab(s, page);
-	return;
-
-debug:
-	if (!free_debug_processing(s, page, x, addr))
-		goto out_unlock;
-	goto checks_ok;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
