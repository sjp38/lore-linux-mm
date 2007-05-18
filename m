Date: Fri, 18 May 2007 10:16:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB Debug: Fix check for super sized slabs (>512k 64bit, >256k
 32bit)
Message-ID: <Pine.LNX.4.64.0705181014470.9490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The check for super sized slabs where we can no longer move the free 
pointer behind the object for debugging purposes etc is accessing a field 
that is not setup yet. We must use objsize here since the size of the slab 
has not been determined yet.

The effect of this is that a global slab shrink via "slabinfo -s" will 
show errors about offsets being wrong if booted with slub_debug. 
Potentially there are other troubles with huge slabs under slub_debug 
because the calculated free pointer offset is truncated.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-18 10:14:05.000000000 -0700
+++ slub/mm/slub.c	2007-05-18 10:14:13.000000000 -0700
@@ -946,7 +946,7 @@ static void kmem_cache_open_debug_check(
 	 * Debugging or ctor may create a need to move the free
 	 * pointer. Fail if this happens.
 	 */
-	if (s->size >= 65535 * sizeof(void *)) {
+	if (s->objsize >= 65535 * sizeof(void *)) {
 		BUG_ON(s->flags & (SLAB_RED_ZONE | SLAB_POISON |
 				SLAB_STORE_USER | SLAB_DESTROY_BY_RCU));
 		BUG_ON(s->ctor);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
