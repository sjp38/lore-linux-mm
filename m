Message-Id: <20081108022013.777649000@nick.local0.net>
References: <20081108021512.686515000@suse.de>
Date: Sat, 08 Nov 2008 13:15:15 +1100
From: npiggin@suse.de
Subject: [patch 3/9] mm: vmalloc search restart fix
Content-Disposition: inline; filename=mm-vmalloc-restart-search-fix.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, glommer@redhat.com, rjw@sisk.pl
List-ID: <linux-mm.kvack.org>

Current vmalloc restart search for a free area in case we can't find one. The
reason is there are areas which are lazily freed, and could be possibly freed
now. However, current implementation start searching the tree from the last
failing address, which is pretty much by definition at the end of address
space. So, we fail.

The proposal of this patch is to restart the search from the beginning of the
requested vstart address. This fixes the regression in running KVM virtual
machines for me, described in http://lkml.org/lkml/2008/10/28/349, caused by
commit db64fe02258f1507e13fe5212a989922323685ce.

Signed-off-by: Glauber Costa <glommer@redhat.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/vmalloc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -324,14 +324,14 @@ static struct vmap_area *alloc_vmap_area
 
 	BUG_ON(size & ~PAGE_MASK);
 
-	addr = ALIGN(vstart, align);
-
 	va = kmalloc_node(sizeof(struct vmap_area),
 			gfp_mask & GFP_RECLAIM_MASK, node);
 	if (unlikely(!va))
 		return ERR_PTR(-ENOMEM);
 
 retry:
+	addr = ALIGN(vstart, align);
+
 	spin_lock(&vmap_area_lock);
 	/* XXX: could have a last_hole cache */
 	n = vmap_area_root.rb_node;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
