Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 25EF890008A
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 15:48:35 -0400 (EDT)
Message-Id: <20110415194832.574871056@linux.com>
Date: Fri, 15 Apr 2011 14:48:16 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup6 5/5] slub: Move debug handlign in __slab_free
References: <20110415194811.810587216@linux.com>
Content-Disposition: inline; filename=move_debug
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Its easier to read if its with the check for debugging flags.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-04-15 12:54:21.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-04-15 12:54:21.000000000 -0500
@@ -2057,10 +2057,9 @@ static void __slab_free(struct kmem_cach
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
@@ -2104,12 +2103,6 @@ slab_empty:
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
