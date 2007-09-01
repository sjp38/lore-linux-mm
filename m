From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 02/26] SLUB: Move count_partial()
Date: Fri, 31 Aug 2007 18:41:09 -0700
Message-ID: <20070901014219.759177433@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752721AbXIABmg@vger.kernel.org>
Content-Disposition: inline; filename=0002-slab_defrag_move_count_partial.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

Move the counting function for objects in partial slabs so that it is placed
before kmem_cache_shrink. We will need to use it to establish the
fragmentation ratio of per node slab lists.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 45c76fe..aad6f83 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2595,6 +2595,19 @@ void kfree(const void *x)
 }
 EXPORT_SYMBOL(kfree);
 
+static unsigned long count_partial(struct kmem_cache_node *n)
+{
+	unsigned long flags;
+	unsigned long x = 0;
+	struct page *page;
+
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry(page, &n->partial, lru)
+		x += page->inuse;
+	spin_unlock_irqrestore(&n->list_lock, flags);
+	return x;
+}
+
 /*
  * kmem_cache_shrink removes empty slabs from the partial lists and sorts
  * the remaining slabs by the number of items in use. The slabs with the
@@ -3331,19 +3344,6 @@ static int list_locations(struct kmem_cache *s, char *buf,
 	return n;
 }
 
-static unsigned long count_partial(struct kmem_cache_node *n)
-{
-	unsigned long flags;
-	unsigned long x = 0;
-	struct page *page;
-
-	spin_lock_irqsave(&n->list_lock, flags);
-	list_for_each_entry(page, &n->partial, lru)
-		x += page->inuse;
-	spin_unlock_irqrestore(&n->list_lock, flags);
-	return x;
-}
-
 enum slab_stat_type {
 	SL_FULL,
 	SL_PARTIAL,
-- 
1.5.2.4

-- 
