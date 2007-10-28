From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 05/10] SLUB: __slab_alloc() exit path consolidation
Date: Sat, 27 Oct 2007 20:32:01 -0700
Message-ID: <20071028033259.504765424@sgi.com>
References: <20071028033156.022983073@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756618AbXJ1Dea@vger.kernel.org>
Content-Disposition: inline; filename=slub_slab_alloc_exit_paths
Sender: linux-kernel-owner@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-Id: linux-mm.kvack.org

Use a single exit path by using goto's to the hottest exit path.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-10-25 19:38:14.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-10-25 19:38:47.000000000 -0700
@@ -1493,7 +1493,9 @@ load_freelist:
 	c->page->inuse = s->objects;
 	c->page->freelist = NULL;
 	c->node = page_to_nid(c->page);
+unlock_out:
 	slab_unlock(c->page);
+out:
 	return object;
 
 another_slab:
@@ -1541,7 +1543,8 @@ new_slab:
 		c->page = new;
 		goto load_freelist;
 	}
-	return NULL;
+	object = NULL;
+	goto out;
 debug:
 	object = c->page->freelist;
 	if (!alloc_debug_processing(s, c->page, object, addr))
@@ -1550,8 +1553,7 @@ debug:
 	c->page->inuse++;
 	c->page->freelist = object[c->offset];
 	c->node = -1;
-	slab_unlock(c->page);
-	return object;
+	goto unlock_out;
 }
 
 /*

-- 
