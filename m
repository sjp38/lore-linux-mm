Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 2C37B6B006E
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 23:59:53 -0400 (EDT)
From: Jiang Liu <jiang.liu@huawei.com>
Subject: [RFC PATCH 3/4] SLAB: minor code cleanup
Date: Tue, 3 Jul 2012 11:57:16 +0800
Message-ID: <1341287837-7904-3-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com>
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

Minor code cleanup for SLAB allocator.

Signed-off-by: Jiang Liu <liuj97@gmail.com>
---
 mm/slab.c |   26 ++++++--------------------
 1 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index e901a36..cd163d1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -499,34 +499,23 @@ static inline void page_set_cache(struct page *page, struct kmem_cache *cache)
 	page->lru.next = (struct list_head *)cache;
 }
 
-static inline struct kmem_cache *page_get_cache(struct page *page)
-{
-	page = compound_head(page);
-	BUG_ON(!PageSlab(page));
-	return (struct kmem_cache *)page->lru.next;
-}
-
 static inline void page_set_slab(struct page *page, struct slab *slab)
 {
 	page->lru.prev = (struct list_head *)slab;
 }
 
-static inline struct slab *page_get_slab(struct page *page)
-{
-	BUG_ON(!PageSlab(page));
-	return (struct slab *)page->lru.prev;
-}
-
 static inline struct kmem_cache *virt_to_cache(const void *obj)
 {
 	struct page *page = virt_to_head_page(obj);
-	return page_get_cache(page);
+	BUG_ON(!PageSlab(page));
+	return (struct kmem_cache *)page->lru.next;
 }
 
 static inline struct slab *virt_to_slab(const void *obj)
 {
 	struct page *page = virt_to_head_page(obj);
-	return page_get_slab(page);
+	BUG_ON(!PageSlab(page));
+	return (struct slab *)page->lru.prev;
 }
 
 static inline void *index_to_obj(struct kmem_cache *cache, struct slab *slab,
@@ -3047,7 +3036,6 @@ static inline void verify_redzone_free(struct kmem_cache *cache, void *obj)
 static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 				   void *caller)
 {
-	struct page *page;
 	unsigned int objnr;
 	struct slab *slabp;
 
@@ -3055,9 +3043,7 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 
 	objp -= obj_offset(cachep);
 	kfree_debugcheck(objp);
-	page = virt_to_head_page(objp);
-
-	slabp = page_get_slab(page);
+	slabp = virt_to_slab(objp);
 
 	if (cachep->flags & SLAB_RED_ZONE) {
 		verify_redzone_free(cachep, objp);
@@ -3261,7 +3247,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 		struct slab *slabp;
 		unsigned objnr;
 
-		slabp = page_get_slab(virt_to_head_page(objp));
+		slabp = virt_to_slab(objp);
 		objnr = (unsigned)(objp - slabp->s_mem) / cachep->buffer_size;
 		slab_bufctl(slabp)[objnr] = BUFCTL_ACTIVE;
 	}
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
