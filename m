Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 6ECF06B0069
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 10:05:57 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 1/2] slab: commonize slab_cache field in struct page
Date: Mon, 22 Oct 2012 18:05:36 +0400
Message-Id: <1350914737-4097-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1350914737-4097-1-git-send-email-glommer@parallels.com>
References: <1350914737-4097-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

Right now, slab and slub have fields in struct page to derive which
cache a page belongs to, but they do it slightly differently.

slab uses a field called slab_cache, that lives in the third double
word. slub, uses a field called "slab", living outside of the
doublewords area.

Ideally, we could use the same field for this. Since slub heavily makes
use of the doubleword region, there isn't really much room to move
slub's slab_cache field around. Since slab does not have such strict
placement restrictions, we can move it outside the doubleword area.

The naming used by slab, "slab_cache", is less confusing, and it is
preferred over slub's generic "slab".

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@kernel.org>
CC: David Rientjes <rientjes@google.com>
---
 include/linux/mm_types.h |  7 ++-----
 mm/slub.c                | 24 ++++++++++++------------
 2 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 31f8a3a..2fef4e7 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -128,10 +128,7 @@ struct page {
 		};
 
 		struct list_head list;	/* slobs list of pages */
-		struct {		/* slab fields */
-			struct kmem_cache *slab_cache;
-			struct slab *slab_page;
-		};
+		struct slab *slab_page; /* slab fields */
 	};
 
 	/* Remainder is not double word aligned */
@@ -146,7 +143,7 @@ struct page {
 #if USE_SPLIT_PTLOCKS
 		spinlock_t ptl;
 #endif
-		struct kmem_cache *slab;	/* SLUB: Pointer to slab */
+		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
 		struct page *first_page;	/* Compound tail pages */
 	};
 
diff --git a/mm/slub.c b/mm/slub.c
index a34548e..259bc2c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1087,11 +1087,11 @@ static noinline struct kmem_cache_node *free_debug_processing(
 	if (!check_object(s, page, object, SLUB_RED_ACTIVE))
 		goto out;
 
-	if (unlikely(s != page->slab)) {
+	if (unlikely(s != page->slab_cache)) {
 		if (!PageSlab(page)) {
 			slab_err(s, page, "Attempt to free object(0x%p) "
 				"outside of slab", object);
-		} else if (!page->slab) {
+		} else if (!page->slab_cache) {
 			printk(KERN_ERR
 				"SLUB <none>: no slab for object 0x%p.\n",
 						object);
@@ -1352,7 +1352,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 		goto out;
 
 	inc_slabs_node(s, page_to_nid(page), page->objects);
-	page->slab = s;
+	page->slab_cache = s;
 	__SetPageSlab(page);
 	if (page->pfmemalloc)
 		SetPageSlabPfmemalloc(page);
@@ -1419,7 +1419,7 @@ static void rcu_free_slab(struct rcu_head *h)
 	else
 		page = container_of((struct list_head *)h, struct page, lru);
 
-	__free_slab(page->slab, page);
+	__free_slab(page->slab_cache, page);
 }
 
 static void free_slab(struct kmem_cache *s, struct page *page)
@@ -2612,9 +2612,9 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
 
 	page = virt_to_head_page(x);
 
-	if (kmem_cache_debug(s) && page->slab != s) {
+	if (kmem_cache_debug(s) && page->slab_cache != s) {
 		pr_err("kmem_cache_free: Wrong slab cache. %s but object"
-			" is from  %s\n", page->slab->name, s->name);
+			" is from  %s\n", page->slab_cache->name, s->name);
 		WARN_ON_ONCE(1);
 		return;
 	}
@@ -3413,7 +3413,7 @@ size_t ksize(const void *object)
 		return PAGE_SIZE << compound_order(page);
 	}
 
-	return slab_ksize(page->slab);
+	return slab_ksize(page->slab_cache);
 }
 EXPORT_SYMBOL(ksize);
 
@@ -3438,8 +3438,8 @@ bool verify_mem_not_deleted(const void *x)
 	}
 
 	slab_lock(page);
-	if (on_freelist(page->slab, page, object)) {
-		object_err(page->slab, page, object, "Object is on free-list");
+	if (on_freelist(page->slab_cache, page, object)) {
+		object_err(page->slab_cache, page, object, "Object is on free-list");
 		rv = false;
 	} else {
 		rv = true;
@@ -3470,7 +3470,7 @@ void kfree(const void *x)
 		__free_pages(page, compound_order(page));
 		return;
 	}
-	slab_free(page->slab, page, object, _RET_IP_);
+	slab_free(page->slab_cache, page, object, _RET_IP_);
 }
 EXPORT_SYMBOL(kfree);
 
@@ -3681,11 +3681,11 @@ static void __init kmem_cache_bootstrap_fixup(struct kmem_cache *s)
 
 		if (n) {
 			list_for_each_entry(p, &n->partial, lru)
-				p->slab = s;
+				p->slab_cache = s;
 
 #ifdef CONFIG_SLUB_DEBUG
 			list_for_each_entry(p, &n->full, lru)
-				p->slab = s;
+				p->slab_cache = s;
 #endif
 		}
 	}
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
