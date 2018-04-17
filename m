Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D02716B0266
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:54:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z20so11570127pfn.11
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:54:56 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0097.outbound.protection.outlook.com. [104.47.2.97])
        by mx.google.com with ESMTPS id o128si12384822pfg.5.2018.04.17.08.54.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 08:54:55 -0700 (PDT)
Subject: [PATCH v2 11/12] mm: Add SHRINK_EMPTY shrinker methods return value
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 17 Apr 2018 21:54:43 +0300
Message-ID: <152399128393.3456.4036800434493129834.stgit@localhost.localdomain>
In-Reply-To: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

We need to differ the situations, when shrinker has
very small amount of objects (see vfs_pressure_ratio()
called from super_cache_count()), and when it has no
objects at all. Currently, in the both of these cases,
shrinker::count_objects() returns 0.

The patch introduces new SHRINK_EMPTY return value,
which will be used for "no objects at all" case.
It's is a refactoring mostly, as SHRINK_EMPTY is replaced
by 0 by all callers of do_shrink_slab() in this patch,
and all the magic will happen in further.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/super.c               |    3 +++
 include/linux/shrinker.h |    7 +++++--
 mm/vmscan.c              |   12 +++++++++---
 mm/workingset.c          |    3 +++
 4 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index 9bc5698c8c3c..06c87f81037c 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -134,6 +134,9 @@ static unsigned long super_cache_count(struct shrinker *shrink,
 	total_objects += list_lru_shrink_count(&sb->s_dentry_lru, sc);
 	total_objects += list_lru_shrink_count(&sb->s_inode_lru, sc);
 
+	if (!total_objects)
+		return SHRINK_EMPTY;
+
 	total_objects = vfs_pressure_ratio(total_objects);
 	return total_objects;
 }
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 22ee2996c480..973df501c335 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -34,12 +34,15 @@ struct shrink_control {
 };
 
 #define SHRINK_STOP (~0UL)
+#define SHRINK_EMPTY (~0UL - 1)
 /*
  * A callback you can register to apply pressure to ageable caches.
  *
  * @count_objects should return the number of freeable items in the cache. If
- * there are no objects to free or the number of freeable items cannot be
- * determined, it should return 0. No deadlock checks should be done during the
+ * there are no objects to free, it should return SHRINK_EMPTY, while 0 is
+ * returned in cases of the number of freeable items cannot be determined
+ * or shrinker should skip this cache for this time (e.g., their number
+ * is below shrinkable limit). No deadlock checks should be done during the
  * count callback - the shrinker relies on aggregating scan counts that couldn't
  * be executed due to potential deadlocks to be run at a later call when the
  * deadlock condition is no longer pending.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b81b8a7727b5..3be9b4d81c13 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -443,8 +443,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	long scanned = 0, next_deferred;
 
 	freeable = shrinker->count_objects(shrinker, shrinkctl);
-	if (freeable == 0)
-		return 0;
+	if (freeable == 0 || freeable == SHRINK_EMPTY)
+		return freeable;
 
 	/*
 	 * copy the current shrinker scan count into a local variable
@@ -579,6 +579,8 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 		}
 
 		ret = do_shrink_slab(&sc, shrinker, priority);
+		if (ret == SHRINK_EMPTY)
+			ret = 0;
 		freed += ret;
 
 		if (rwsem_is_contended(&shrinker_rwsem)) {
@@ -620,6 +622,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 {
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
+	int ret;
 
 	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
 		return 0;
@@ -642,7 +645,10 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
-		freed += do_shrink_slab(&sc, shrinker, priority);
+		ret = do_shrink_slab(&sc, shrinker, priority);
+		if (ret == SHRINK_EMPTY)
+			ret = 0;
+		freed += ret;
 		/*
 		 * Bail out if someone want to register a new shrinker to
 		 * prevent the regsitration from being stalled for long periods
diff --git a/mm/workingset.c b/mm/workingset.c
index 2e2555649d13..075b990e7c81 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -402,6 +402,9 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	}
 	max_nodes = cache >> (RADIX_TREE_MAP_SHIFT - 3);
 
+	if (!nodes)
+		return SHRINK_EMPTY;
+
 	if (nodes <= max_nodes)
 		return 0;
 	return nodes - max_nodes;
