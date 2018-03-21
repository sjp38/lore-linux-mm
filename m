Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8406B002A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 09:23:02 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g22so2405374pgv.16
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 06:23:02 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50103.outbound.protection.outlook.com. [40.107.5.103])
        by mx.google.com with ESMTPS id h19si3034158pfn.411.2018.03.21.06.23.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 06:23:01 -0700 (PDT)
Subject: [PATCH 09/10] mm: Iterate only over charged shrinkers during memcg
 shrink_slab()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Wed, 21 Mar 2018 16:22:51 +0300
Message-ID: <152163857170.21546.16040899989532143840.stgit@localhost.localdomain>
In-Reply-To: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, ktkhai@virtuozzo.com, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

Using the preparations made in previous patches, in case of memcg
shrink, we may avoid shrinkers, which are not set in memcg's shrinkers
bitmap. To do that, we separate iterations over memcg-aware and
!memcg-aware shrinkers, and memcg-aware shrinkers are chosen
via for_each_set_bit() from the bitmap. In case of big nodes,
having many isolated environments, this gives significant
performance growth. See next patch for the details.

Note, that the patch does not respect to empty memcg shrinkers,
since we never clear the bitmap bits after we set it once.
Their shrinkers will be called again, with no shrinked objects
as result. This functionality is provided by next patch.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |   54 +++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 41 insertions(+), 13 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 265cf069b470..e1fd16bc7a9b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -327,6 +327,8 @@ static int alloc_shrinker_id(struct shrinker *shrinker)
 
 	if (!(shrinker->flags & SHRINKER_MEMCG_AWARE))
 		return 0;
+	BUG_ON(!(shrinker->flags & SHRINKER_NUMA_AWARE));
+
 retry:
 	ida_pre_get(&bitmap_id_ida, GFP_KERNEL);
 	down_write(&bitmap_rwsem);
@@ -366,7 +368,8 @@ static void add_shrinker(struct shrinker *shrinker)
 	down_write(&shrinker_rwsem);
 	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
 		mcg_shrinkers[shrinker->id] = shrinker;
-	list_add_tail(&shrinker->list, &shrinker_list);
+	else
+		list_add_tail(&shrinker->list, &shrinker_list);
 	up_write(&shrinker_rwsem);
 }
 
@@ -375,7 +378,8 @@ static void del_shrinker(struct shrinker *shrinker)
 	down_write(&shrinker_rwsem);
 	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
 		mcg_shrinkers[shrinker->id] = NULL;
-	list_del(&shrinker->list);
+	else
+		list_del(&shrinker->list);
 	up_write(&shrinker_rwsem);
 }
 
@@ -701,6 +705,39 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	if (!down_read_trylock(&shrinker_rwsem))
 		goto out;
 
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+	if (!memcg_kmem_enabled() || memcg) {
+		struct shrinkers_map *map;
+		int i;
+
+		map = rcu_dereference_protected(SHRINKERS_MAP(memcg), true);
+		if (map) {
+			for_each_set_bit(i, map->map[nid], bitmap_nr_ids) {
+				struct shrink_control sc = {
+					.gfp_mask = gfp_mask,
+					.nid = nid,
+					.memcg = memcg,
+				};
+
+				shrinker = mcg_shrinkers[i];
+				if (!shrinker) {
+					clear_bit(i, map->map[nid]);
+					continue;
+				}
+				freed += do_shrink_slab(&sc, shrinker, priority);
+
+				if (rwsem_is_contended(&shrinker_rwsem)) {
+					freed = freed ? : 1;
+					goto unlock;
+				}
+			}
+		}
+
+		if (memcg_kmem_enabled() && memcg)
+			goto unlock;
+	}
+#endif
+
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		struct shrink_control sc = {
 			.gfp_mask = gfp_mask,
@@ -708,15 +745,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
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
 
@@ -728,10 +756,10 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		 */
 		if (rwsem_is_contended(&shrinker_rwsem)) {
 			freed = freed ? : 1;
-			break;
+			goto unlock;
 		}
 	}
-
+unlock:
 	up_read(&shrinker_rwsem);
 out:
 	cond_resched();
