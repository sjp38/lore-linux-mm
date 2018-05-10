Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA966B05ED
	for <linux-mm@kvack.org>; Thu, 10 May 2018 05:54:03 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c187-v6so906189pfa.20
        for <linux-mm@kvack.org>; Thu, 10 May 2018 02:54:03 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0129.outbound.protection.outlook.com. [104.47.0.129])
        by mx.google.com with ESMTPS id j188-v6si385025pgc.94.2018.05.10.02.54.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 10 May 2018 02:54:02 -0700 (PDT)
Subject: [PATCH v5 11/13] mm: Iterate only over charged shrinkers during
 memcg shrink_slab()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Thu, 10 May 2018 12:53:55 +0300
Message-ID: <152594603565.22949.12428911301395699065.stgit@localhost.localdomain>
In-Reply-To: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
References: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

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
 include/linux/memcontrol.h |    1 +
 mm/vmscan.c                |   70 ++++++++++++++++++++++++++++++++++++++------
 2 files changed, 62 insertions(+), 9 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 82f892e77637..436691a66500 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -760,6 +760,7 @@ void mem_cgroup_split_huge_fixup(struct page *head);
 #define MEM_CGROUP_ID_MAX	0
 
 struct mem_cgroup;
+#define root_mem_cgroup NULL
 
 static inline bool mem_cgroup_disabled(void)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d8a2870710e0..a2e38e05adb5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -376,6 +376,7 @@ int prealloc_shrinker(struct shrinker *shrinker)
 			goto free_deferred;
 	}
 
+	INIT_LIST_HEAD(&shrinker->list);
 	return 0;
 
 free_deferred:
@@ -547,6 +548,63 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	return freed;
 }
 
+#ifdef CONFIG_MEMCG_SHRINKER
+static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
+			struct mem_cgroup *memcg, int priority)
+{
+	struct memcg_shrinker_map *map;
+	unsigned long freed = 0;
+	int ret, i;
+
+	if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
+		return 0;
+
+	if (!down_read_trylock(&shrinker_rwsem))
+		return 0;
+
+	/*
+	 * 1)Caller passes only alive memcg, so map can't be NULL.
+	 * 2)shrinker_rwsem protects from maps expanding.
+	 */
+	map = rcu_dereference_protected(MEMCG_SHRINKER_MAP(memcg, nid), true);
+	BUG_ON(!map);
+
+	for_each_set_bit(i, map->map, memcg_shrinker_nr_max) {
+		struct shrink_control sc = {
+			.gfp_mask = gfp_mask,
+			.nid = nid,
+			.memcg = memcg,
+		};
+		struct shrinker *shrinker;
+
+		shrinker = idr_find(&shrinker_idr, i);
+		if (!shrinker) {
+			clear_bit(i, map->map);
+			continue;
+		}
+		if (list_empty(&shrinker->list))
+			continue;
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
+#else /* CONFIG_MEMCG_SHRINKER */
+static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
+			struct mem_cgroup *memcg, int priority)
+{
+	return 0;
+}
+#endif /* CONFIG_MEMCG_SHRINKER */
+
 /**
  * shrink_slab - shrink slab caches
  * @gfp_mask: allocation context
@@ -576,8 +634,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
 
-	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
-		return 0;
+	if (memcg && memcg != root_mem_cgroup)
+		return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
 
 	if (!down_read_trylock(&shrinker_rwsem))
 		goto out;
@@ -589,13 +647,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 			.memcg = memcg,
 		};
 
-		/*
-		 * If kernel memory accounting is disabled, we ignore
-		 * SHRINKER_MEMCG_AWARE flag and call all shrinkers
-		 * passing NULL for memcg.
-		 */
-		if (memcg_kmem_enabled() &&
-		    !!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
+		if (!!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
 			continue;
 
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
