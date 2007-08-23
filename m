From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 4/6] SLUB: Avoid touching page struct when freeing to per cpu slab
Date: Wed, 22 Aug 2007 23:46:57 -0700
Message-ID: <20070823064734.558994491@sgi.com>
References: <20070823064653.081843729@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756324AbXHWGsJ@vger.kernel.org>
Content-Disposition: inline; filename=0008-SLUB-Avoid-touching-page-struct-when-freeing-to-per.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-Id: linux-mm.kvack.org

Set c->node to -1 if we allocate from a debug slab instead for SlabDebug
which requires access the page struct cacheline.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6.23-rc3-mm1/mm/slub.c
===================================================================
--- linux-2.6.23-rc3-mm1.orig/mm/slub.c	2007-08-22 17:20:28.000000000 -0700
+++ linux-2.6.23-rc3-mm1/mm/slub.c	2007-08-22 17:20:33.000000000 -0700
@@ -1517,6 +1517,7 @@ debug:
 
 	c->page->inuse++;
 	c->page->freelist = object[c->offset];
+	c->node = -1;
 	slab_unlock(c->page);
 	return object;
 }
@@ -1540,8 +1541,7 @@ static void __always_inline *slab_alloc(
 
 	local_irq_save(flags);
 	c = get_cpu_slab(s, smp_processor_id());
-	if (unlikely(!c->page || !c->freelist ||
-					!node_match(c, node)))
+	if (unlikely(!c->freelist || !node_match(c, node)))
 
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 
@@ -1650,7 +1650,7 @@ static void __always_inline slab_free(st
 	local_irq_save(flags);
 	debug_check_no_locks_freed(object, s->objsize);
 	c = get_cpu_slab(s, smp_processor_id());
-	if (likely(page == c->page && !SlabDebug(page))) {
+	if (likely(page == c->page && c->node >= 0)) {
 		object[c->offset] = c->freelist;
 		c->freelist = object;
 	} else

-- 
