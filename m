Message-Id: <20080430044321.016890376@sgi.com>
References: <20080430044251.266380837@sgi.com>
Date: Tue, 29 Apr 2008 21:43:00 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [09/11] slub: Use virtualizable compound for buffer
Content-Disposition: inline; filename=vcp_fallback_slub_buffer
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

The caller table can get quite large if there are many call sites for a
particular slab. Using a virtual compound page allows fallback to vmalloc in
case the caller table gets too big and memory is fragmented. Currently we
would fail the operation.

Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-04-29 16:40:30.851208783 -0700
+++ linux-2.6/mm/slub.c	2008-04-29 16:46:46.471205957 -0700
@@ -21,6 +21,7 @@
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
 #include <linux/memory.h>
+#include <linux/vmalloc.h>
 
 /*
  * Lock order:
@@ -3689,8 +3690,7 @@ struct loc_track {
 static void free_loc_track(struct loc_track *t)
 {
 	if (t->max)
-		free_pages((unsigned long)t->loc,
-			get_order(sizeof(struct location) * t->max));
+		__free_vcompound(t->loc);
 }
 
 static int alloc_loc_track(struct loc_track *t, unsigned long max, gfp_t flags)
@@ -3700,7 +3700,7 @@ static int alloc_loc_track(struct loc_tr
 
 	order = get_order(sizeof(struct location) * max);
 
-	l = (void *)__get_free_pages(flags, order);
+	l = __alloc_vcompound(flags, order);
 	if (!l)
 		return 0;
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
