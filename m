Message-Id: <20080321061726.446275264@sgi.com>
References: <20080321061703.921169367@sgi.com>
Date: Thu, 20 Mar 2008 23:17:13 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [10/14] vcompound: slub: Use for buffer to correlate allocation addresses
Content-Disposition: inline; filename=0015-vcompound-Fallback-for-buffer-to-correlate-alloc-lo.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The caller table can get quite large if there are many call sites for a
particular slab. Using a virtual compound page allows fallback to vmalloc in
case the caller table gets too big and memory is fragmented. Currently we
would fail the operation.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6.25-rc5-mm1/mm/slub.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/mm/slub.c	2008-03-20 18:04:44.153110938 -0700
+++ linux-2.6.25-rc5-mm1/mm/slub.c	2008-03-20 19:40:17.103393950 -0700
@@ -21,6 +21,7 @@
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
 #include <linux/memory.h>
+#include <linux/vmalloc.h>
 
 /*
  * Lock order:
@@ -3372,8 +3373,7 @@ struct loc_track {
 static void free_loc_track(struct loc_track *t)
 {
 	if (t->max)
-		free_pages((unsigned long)t->loc,
-			get_order(sizeof(struct location) * t->max));
+		__free_vcompound(t->loc);
 }
 
 static int alloc_loc_track(struct loc_track *t, unsigned long max, gfp_t flags)
@@ -3383,7 +3383,7 @@ static int alloc_loc_track(struct loc_tr
 
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
