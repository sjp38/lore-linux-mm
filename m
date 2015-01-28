Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9C71F6B006C
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 11:23:02 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so27068954pad.1
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 08:23:02 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id w5si6345879pbz.124.2015.01.28.08.23.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jan 2015 08:23:01 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 1/3] slub: never fail to shrink cache
Date: Wed, 28 Jan 2015 19:22:49 +0300
Message-ID: <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com>
In-Reply-To: <cover.1422461573.git.vdavydov@parallels.com>
References: <cover.1422461573.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

SLUB's version of __kmem_cache_shrink() not only removes empty slabs,
but also tries to rearrange the partial lists to place slabs filled up
most to the head to cope with fragmentation. To achieve that, it
allocates a temporary array of lists used to sort slabs by the number of
objects in use. If the allocation fails, the whole procedure is aborted.

This is unacceptable for the kernel memory accounting extension of the
memory cgroup, where we want to make sure that kmem_cache_shrink()
successfully discarded empty slabs. Although the allocation failure is
utterly unlikely with the current page allocator implementation, which
retries GFP_KERNEL allocations of order <= 2 infinitely, it is better
not to rely on that.

This patch therefore makes __kmem_cache_shrink() allocate the array on
stack instead of calling kmalloc, which may fail. The array size is
chosen to be equal to 32, because most SLUB caches store not more than
32 objects per slab page. Slab pages with <= 32 free objects are sorted
using the array by the number of objects in use and promoted to the head
of the partial list, while slab pages with > 32 free objects are left in
the end of the list without any ordering imposed on them.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slub.c |   57 ++++++++++++++++++++++++++++++---------------------------
 1 file changed, 30 insertions(+), 27 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 1562955fe099..dbf9334b6a5c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3358,11 +3358,12 @@ void kfree(const void *x)
 }
 EXPORT_SYMBOL(kfree);
 
+#define SHRINK_PROMOTE_MAX 32
+
 /*
- * kmem_cache_shrink removes empty slabs from the partial lists and sorts
- * the remaining slabs by the number of items in use. The slabs with the
- * most items in use come first. New allocations will then fill those up
- * and thus they can be removed from the partial lists.
+ * kmem_cache_shrink discards empty slabs and promotes the slabs filled
+ * up most to the head of the partial lists. New allocations will then
+ * fill those up and thus they can be removed from the partial lists.
  *
  * The slabs with the least items are placed last. This results in them
  * being allocated from last increasing the chance that the last objects
@@ -3375,51 +3376,56 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 	struct kmem_cache_node *n;
 	struct page *page;
 	struct page *t;
-	int objects = oo_objects(s->max);
-	struct list_head *slabs_by_inuse =
-		kmalloc(sizeof(struct list_head) * objects, GFP_KERNEL);
+	LIST_HEAD(discard);
+	struct list_head promote[SHRINK_PROMOTE_MAX];
 	unsigned long flags;
 
-	if (!slabs_by_inuse)
-		return -ENOMEM;
+	for (i = 0; i < SHRINK_PROMOTE_MAX; i++)
+		INIT_LIST_HEAD(promote + i);
 
 	flush_all(s);
 	for_each_kmem_cache_node(s, node, n) {
 		if (!n->nr_partial)
 			continue;
 
-		for (i = 0; i < objects; i++)
-			INIT_LIST_HEAD(slabs_by_inuse + i);
-
 		spin_lock_irqsave(&n->list_lock, flags);
 
 		/*
-		 * Build lists indexed by the items in use in each slab.
+		 * Build lists of slabs to discard or promote.
 		 *
 		 * Note that concurrent frees may occur while we hold the
 		 * list_lock. page->inuse here is the upper limit.
 		 */
 		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			list_move(&page->lru, slabs_by_inuse + page->inuse);
-			if (!page->inuse)
+			int free = page->objects - page->inuse;
+
+			/* Do not reread page->inuse */
+			barrier();
+
+			/* We do not keep full slabs on the list */
+			BUG_ON(free <= 0);
+
+			if (free == page->objects) {
+				list_move(&page->lru, &discard);
 				n->nr_partial--;
+			} else if (free <= SHRINK_PROMOTE_MAX)
+				list_move(&page->lru, promote + free - 1);
 		}
 
 		/*
-		 * Rebuild the partial list with the slabs filled up most
-		 * first and the least used slabs at the end.
+		 * Promote the slabs filled up most to the head of the
+		 * partial list.
 		 */
-		for (i = objects - 1; i > 0; i--)
-			list_splice(slabs_by_inuse + i, n->partial.prev);
+		for (i = SHRINK_PROMOTE_MAX - 1; i >= 0; i--)
+			list_splice_init(promote + i, &n->partial);
 
 		spin_unlock_irqrestore(&n->list_lock, flags);
 
 		/* Release empty slabs */
-		list_for_each_entry_safe(page, t, slabs_by_inuse, lru)
+		list_for_each_entry_safe(page, t, &discard, lru)
 			discard_slab(s, page);
 	}
 
-	kfree(slabs_by_inuse);
 	return 0;
 }
 
@@ -4682,12 +4688,9 @@ static ssize_t shrink_show(struct kmem_cache *s, char *buf)
 static ssize_t shrink_store(struct kmem_cache *s,
 			const char *buf, size_t length)
 {
-	if (buf[0] == '1') {
-		int rc = kmem_cache_shrink(s);
-
-		if (rc)
-			return rc;
-	} else
+	if (buf[0] == '1')
+		kmem_cache_shrink(s);
+	else
 		return -EINVAL;
 	return length;
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
