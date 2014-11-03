Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E766E6B00FA
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 16:00:27 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id kq14so12995789pab.10
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 13:00:27 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id tp6si16064547pbc.215.2014.11.03.13.00.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 13:00:26 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 8/8] slab: recharge slab pages to the allocating memory cgroup
Date: Mon, 3 Nov 2014 23:59:46 +0300
Message-ID: <fe7c55a7ff9bb8a1ddff0256f5404196c10bfd08.1415046910.git.vdavydov@parallels.com>
In-Reply-To: <cover.1415046910.git.vdavydov@parallels.com>
References: <cover.1415046910.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since we now reuse per cgroup kmem caches, the slab we allocate an
object from may be accounted to a dead memory cgroup. If we leave such a
slab accounted to a dead cgroup, we risk pinning the cgroup forever, so
we introduce a new function, memcg_kmem_recharge_slab, which is to be
called in the end of kmalloc. It recharges the new object's slab to the
current cgroup unless it is already charged to it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |   15 +++++++++++
 mm/memcontrol.c            |   62 ++++++++++++++++++++++++++++++++++++++++++++
 mm/slab.c                  |   10 +++++++
 mm/slub.c                  |    8 ++++++
 4 files changed, 95 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 224c045fd37f..4b0ff999605a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -408,6 +408,7 @@ bool __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg,
 void __memcg_kmem_commit_charge(struct page *page,
 				       struct mem_cgroup *memcg, int order);
 void __memcg_kmem_uncharge_pages(struct page *page, int order);
+int __memcg_kmem_recharge_slab(void *obj, gfp_t gfp);
 
 int memcg_cache_id(struct mem_cgroup *memcg);
 
@@ -501,6 +502,15 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 		return cachep;
 	return __memcg_kmem_get_cache(cachep, gfp);
 }
+
+static __always_inline int memcg_kmem_recharge_slab(void *obj, gfp_t gfp)
+{
+	if (!memcg_kmem_enabled())
+		return 0;
+	if (!memcg_kmem_should_charge(gfp))
+		return 0;
+	return __memcg_kmem_recharge_slab(obj, gfp);
+}
 #else
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
@@ -535,6 +545,11 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
 	return cachep;
 }
+
+static inline int memcg_kmem_recharge_slab(void *obj, gfp_t gfp)
+{
+	return 0;
+}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 755604079d8e..f6567627c3b1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2828,6 +2828,68 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	memcg_uncharge_kmem(memcg, 1 << order);
 	page->mem_cgroup = NULL;
 }
+
+/*
+ * Since we reuse per cgroup kmem caches, the slab we allocate an object from
+ * may be accounted to a dead memory cgroup. If we leave such a slab accounted
+ * to a dead cgroup, we risk pinning the cgroup forever, so this function is
+ * called in the end of kmalloc to recharge the new object's slab to the
+ * current cgroup unless it is already charged to it.
+ */
+int __memcg_kmem_recharge_slab(void *obj, gfp_t gfp)
+{
+	struct mem_cgroup *page_memcg, *memcg;
+	struct page *page;
+	int nr_pages;
+	int ret = 0;
+
+	if (current->memcg_kmem_skip_account)
+		goto out;
+
+	page = virt_to_head_page(obj);
+	page_memcg = ACCESS_ONCE(page->mem_cgroup);
+
+	rcu_read_lock();
+
+	memcg = mem_cgroup_from_task(rcu_dereference(current->mm->owner));
+	if (!memcg_kmem_is_active(memcg))
+		memcg = NULL;
+	if (likely(memcg == page_memcg))
+		goto out_unlock;
+	if (memcg && !css_tryget(&memcg->css))
+		goto out_unlock;
+
+	rcu_read_unlock();
+
+	nr_pages = 1 << compound_order(page);
+
+	if (memcg && memcg_charge_kmem(memcg, gfp, nr_pages)) {
+		ret = -ENOMEM;
+		goto out_put_memcg;
+	}
+
+	/*
+	 * We use cmpxchg to synchronize against concurrent threads allocating
+	 * from the same slab. If it fails, it means that some other thread
+	 * recharged the slab before us, and we are done.
+	 */
+	if (cmpxchg(&page->mem_cgroup, page_memcg, memcg) == page_memcg) {
+		if (page_memcg)
+			memcg_uncharge_kmem(page_memcg, nr_pages);
+	} else {
+		if (memcg)
+			memcg_uncharge_kmem(memcg, nr_pages);
+	}
+
+out_put_memcg:
+	if (memcg)
+		css_put(&memcg->css);
+	goto out;
+out_unlock:
+	rcu_read_unlock();
+out:
+	return ret;
+}
 #endif /* CONFIG_MEMCG_KMEM */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
diff --git a/mm/slab.c b/mm/slab.c
index 178a3b733a50..61b01c2ae1d9 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3133,6 +3133,8 @@ done:
 	return obj;
 }
 
+static __always_inline void slab_free(struct kmem_cache *cachep, void *objp);
+
 static __always_inline void *
 slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 		   unsigned long caller)
@@ -3185,6 +3187,10 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 		kmemcheck_slab_alloc(cachep, flags, ptr, cachep->object_size);
 		if (unlikely(flags & __GFP_ZERO))
 			memset(ptr, 0, cachep->object_size);
+		if (unlikely(memcg_kmem_recharge_slab(ptr, flags))) {
+			slab_free(cachep, ptr);
+			ptr = NULL;
+		}
 	}
 
 	return ptr;
@@ -3250,6 +3256,10 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 		kmemcheck_slab_alloc(cachep, flags, objp, cachep->object_size);
 		if (unlikely(flags & __GFP_ZERO))
 			memset(objp, 0, cachep->object_size);
+		if (unlikely(memcg_kmem_recharge_slab(objp, flags))) {
+			slab_free(cachep, objp);
+			objp = NULL;
+		}
 	}
 
 	return objp;
diff --git a/mm/slub.c b/mm/slub.c
index 205eaca18b7b..28721ddea448 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2360,6 +2360,9 @@ new_slab:
 	return freelist;
 }
 
+static __always_inline void slab_free(struct kmem_cache *s,
+			struct page *page, void *x, unsigned long addr);
+
 /*
  * Inlined fastpath so that allocation functions (kmalloc, kmem_cache_alloc)
  * have the fastpath folded into their functions. So no function call
@@ -2445,6 +2448,11 @@ redo:
 
 	slab_post_alloc_hook(s, gfpflags, object);
 
+	if (object && unlikely(memcg_kmem_recharge_slab(object, gfpflags))) {
+		slab_free(s, virt_to_head_page(object), object, _RET_IP_);
+		object = NULL;
+	}
+
 	return object;
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
