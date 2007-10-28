From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 04/10] SLUB: Avoid checking for a valid object before zeroing on the fast path
Date: Sat, 27 Oct 2007 20:32:00 -0700
Message-ID: <20071028033259.263401839@sgi.com>
References: <20071028033156.022983073@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757051AbXJ1Dep@vger.kernel.org>
Content-Disposition: inline; filename=slub_slab_alloc_move_oom
Sender: linux-kernel-owner@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-Id: linux-mm.kvack.org

The fast path always results in a valid object. Move the check
for the NULL pointer to the slow branch that calls
__slab_alloc. Only __slab_alloc can return NULL if there is no
memory available anymore and that case is exceedingly rare.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-10-25 19:37:38.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-10-25 19:38:14.000000000 -0700
@@ -1573,19 +1573,22 @@ static void __always_inline *slab_alloc(
 
 	local_irq_save(flags);
 	c = get_cpu_slab(s, smp_processor_id());
-	if (unlikely(!c->freelist || !node_match(c, node)))
+	if (unlikely(!c->freelist || !node_match(c, node))) {
 
 		object = __slab_alloc(s, gfpflags, node, addr, c);
-
-	else {
+		if (unlikely(!object)) {
+			local_irq_restore(flags);
+			goto out;
+		}
+	} else {
 		object = c->freelist;
 		c->freelist = object[c->offset];
 	}
 	local_irq_restore(flags);
 
-	if (unlikely((gfpflags & __GFP_ZERO) && object))
+	if (unlikely((gfpflags & __GFP_ZERO)))
 		memset(object, 0, c->objsize);
-
+out:
 	return object;
 }
 

-- 
