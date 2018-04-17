Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6406B025F
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:54:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e14so11610629pfi.9
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:54:51 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0126.outbound.protection.outlook.com. [104.47.2.126])
        by mx.google.com with ESMTPS id 31-v6si9931466plz.364.2018.04.17.08.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 08:54:50 -0700 (PDT)
Subject: [PATCH v2 10/12] mm: Iterate only over charged shrinkers during
 memcg shrink_slab()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 17 Apr 2018 21:54:34 +0300
Message-ID: <152399127400.3456.6644633244163904030.stgit@localhost.localdomain>
In-Reply-To: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

Using the preparations made in previous patches, in case of memcg
shrink, we may avoid shrinkers, which are not set in memcg's shrinkers
bitmap. To do that, we separate iterations over memcg-aware and
!memcg-aware shrinkers, and memcg-aware shrinkers are chosen
via for_each_set_bit() from the bitmap. In case of big nodes,
having many isolated environments, this gives significant
performance growth. See next patches for the details.

Note, that the patch does not respect to empty memcg shrinkers,
since we never clear the bitmap bits after we set it once.
Their shrinkers will be called again, with no shrinked objects
as result. This functionality is provided by next patches.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |   88 ++++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 72 insertions(+), 16 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 34cd1d9b8b22..b81b8a7727b5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -169,6 +169,20 @@ unsigned long vm_total_pages;
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
+static void link_shrinker(struct shrinker *shrinker)
+{
+	down_write(&shrinker_rwsem);
+	list_add_tail(&shrinker->list, &shrinker_list);
+	up_write(&shrinker_rwsem);
+}
+
+static void unlink_shrinker(struct shrinker *shrinker)
+{
+	down_write(&shrinker_rwsem);
+	list_del(&shrinker->list);
+	up_write(&shrinker_rwsem);
+}
+
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 static DEFINE_IDR(shrinkers_id_idr);
 
@@ -221,11 +235,13 @@ static void del_memcg_shrinker(struct shrinker *shrinker)
 #else /* CONFIG_MEMCG && !CONFIG_SLOB */
 static int add_memcg_shrinker(struct shrinker *shrinker, int nr, va_list args)
 {
+	link_shrinker(shrinker);
 	return 0;
 }
 
 static void del_memcg_shrinker(struct shrinker *shrinker)
 {
+	unlink_shrinker(shrinker);
 }
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
@@ -382,11 +398,9 @@ int __register_shrinker(struct shrinker *shrinker, int nr, ...)
 		va_end(args);
 		if (ret)
 			goto free_deferred;
-	}
+	} else
+		link_shrinker(shrinker);
 
-	down_write(&shrinker_rwsem);
-	list_add_tail(&shrinker->list, &shrinker_list);
-	up_write(&shrinker_rwsem);
 	return 0;
 
 free_deferred:
@@ -405,9 +419,8 @@ void unregister_shrinker(struct shrinker *shrinker)
 		return;
 	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
 		del_memcg_shrinker(shrinker);
-	down_write(&shrinker_rwsem);
-	list_del(&shrinker->list);
-	up_write(&shrinker_rwsem);
+	else
+		unlink_shrinker(shrinker);
 	kfree(shrinker->nr_deferred);
 	shrinker->nr_deferred = NULL;
 }
@@ -532,6 +545,53 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	return freed;
 }
 
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
+				       struct mem_cgroup *memcg,
+				       int priority)
+{
+	struct memcg_shrinker_map *map;
+	unsigned long freed = 0;
+	int ret, i;
+
+	if (!down_read_trylock(&shrinker_rwsem))
+		return 0;
+
+	/*
+	 * 1)Caller passes only alive memcg, so map can't be NULL.
+	 * 2)shrinker_rwsem protects from maps expanding.
+	 */
+	map = rcu_dereference_protected(SHRINKERS_MAP(memcg, nid), true);
+	BUG_ON(!map);
+
+	for_each_set_bit(i, map->map, shrinkers_max_nr) {
+		struct shrink_control sc = {
+			.gfp_mask = gfp_mask,
+			.nid = nid,
+			.memcg = memcg,
+		};
+		struct shrinker *shrinker;
+
+		shrinker = idr_find(&shrinkers_id_idr, i);
+		if (!shrinker) {
+			clear_bit(i, map->map);
+			continue;
+		}
+
+		ret = do_shrink_slab(&sc, shrinker, priority);
+		freed += ret;
+
+		if (rwsem_is_contended(&shrinker_rwsem)) {
+			freed = freed ? : 1;
+			break;
+		}
+	}
+
+	up_read(&shrinker_rwsem);
+	return freed;
+}
+#endif
+
 /**
  * shrink_slab - shrink slab caches
  * @gfp_mask: allocation context
@@ -564,6 +624,11 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
 		return 0;
 
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+	if (memcg)
+		return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
+#endif
+
 	if (!down_read_trylock(&shrinker_rwsem))
 		goto out;
 
@@ -574,15 +639,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 			.memcg = memcg,
 		};
 
-		/*
-		 * If kernel memory accounting is disabled, we ignore
-		 * SHRINKER_MEMCG_AWARE flag and call all shrinkers
-		 * passing NULL for memcg.
-		 */
-		if (memcg_kmem_enabled() &&
-		    !!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
-			continue;
-
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
