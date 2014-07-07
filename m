Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id DC90F900002
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 08:00:41 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id u10so2710681lbd.8
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 05:00:41 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id h7si41908632lbs.67.2014.07.07.05.00.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 05:00:40 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 7/8] memcg: move some kmem definitions upper
Date: Mon, 7 Jul 2014 16:00:12 +0400
Message-ID: <639c98b855541811b263e6c65fbef02803bfad25.1404733721.git.vdavydov@parallels.com>
In-Reply-To: <cover.1404733720.git.vdavydov@parallels.com>
References: <cover.1404733720.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I need this in the next patch.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |  114 +++++++++++++++++++++++++++----------------------------
 1 file changed, 56 insertions(+), 58 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fb25575bdb22..21cf15184ad8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -391,6 +391,45 @@ struct mem_cgroup {
 };
 
 #ifdef CONFIG_MEMCG_KMEM
+/*
+ * This will be the memcg's index in each cache's ->memcg_params->memcg_caches.
+ * The main reason for not using cgroup id for this:
+ *  this works better in sparse environments, where we have a lot of memcgs,
+ *  but only a few kmem-limited. Or also, if we have, for instance, 200
+ *  memcgs, and none but the 200th is kmem-limited, we'd have to have a
+ *  200 entry array for that.
+ *
+ * The current size of the caches array is stored in
+ * memcg_limited_groups_array_size.  It will double each time we have to
+ * increase it.
+ */
+static DEFINE_IDA(kmem_limited_groups);
+int memcg_limited_groups_array_size;
+
+/*
+ * MIN_SIZE is different than 1, because we would like to avoid going through
+ * the alloc/free process all the time. In a small machine, 4 kmem-limited
+ * cgroups is a reasonable guess. In the future, it could be a parameter or
+ * tunable, but that is strictly not necessary.
+ *
+ * MAX_SIZE should be as large as the number of cgrp_ids. Ideally, we could get
+ * this constant directly from cgroup, but it is understandable that this is
+ * better kept as an internal representation in cgroup.c. In any case, the
+ * cgrp_id space is not getting any smaller, and we don't have to necessarily
+ * increase ours as well if it increases.
+ */
+#define MEMCG_CACHES_MIN_SIZE 4
+#define MEMCG_CACHES_MAX_SIZE MEM_CGROUP_ID_MAX
+
+/*
+ * A lot of the calls to the cache allocation functions are expected to be
+ * inlined by the compiler. Since the calls to memcg_kmem_get_cache are
+ * conditional to this static branch, we'll have to allow modules that does
+ * kmem_cache_alloc and the such to see this symbol as well
+ */
+struct static_key memcg_kmem_enabled_key;
+EXPORT_SYMBOL(memcg_kmem_enabled_key);
+
 static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 {
 	return memcg->kmem_ctx->active;
@@ -433,6 +472,19 @@ static void memcg_release_kmem_context(struct mem_cgroup *memcg)
 {
 	kfree(memcg->kmem_ctx);
 }
+
+static void disarm_kmem_keys(struct mem_cgroup *memcg)
+{
+	if (memcg_kmem_is_active(memcg)) {
+		static_key_slow_dec(&memcg_kmem_enabled_key);
+		ida_simple_remove(&kmem_limited_groups, memcg->kmemcg_id);
+	}
+	/*
+	 * This check can't live in kmem destruction function,
+	 * since the charges will outlive the cgroup
+	 */
+	WARN_ON(res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0);
+}
 #else
 static int memcg_alloc_kmem_context(struct mem_cgroup *memcg)
 {
@@ -442,6 +494,10 @@ static int memcg_alloc_kmem_context(struct mem_cgroup *memcg)
 static void memcg_release_kmem_context(struct mem_cgroup *memcg)
 {
 }
+
+static void disarm_kmem_keys(struct mem_cgroup *memcg)
+{
+}
 #endif /* CONFIG_MEMCG_KMEM */
 
 /* Stuffs for move charges at task migration. */
@@ -636,64 +692,6 @@ static void disarm_sock_keys(struct mem_cgroup *memcg)
 }
 #endif
 
-#ifdef CONFIG_MEMCG_KMEM
-/*
- * This will be the memcg's index in each cache's ->memcg_params->memcg_caches.
- * The main reason for not using cgroup id for this:
- *  this works better in sparse environments, where we have a lot of memcgs,
- *  but only a few kmem-limited. Or also, if we have, for instance, 200
- *  memcgs, and none but the 200th is kmem-limited, we'd have to have a
- *  200 entry array for that.
- *
- * The current size of the caches array is stored in
- * memcg_limited_groups_array_size.  It will double each time we have to
- * increase it.
- */
-static DEFINE_IDA(kmem_limited_groups);
-int memcg_limited_groups_array_size;
-
-/*
- * MIN_SIZE is different than 1, because we would like to avoid going through
- * the alloc/free process all the time. In a small machine, 4 kmem-limited
- * cgroups is a reasonable guess. In the future, it could be a parameter or
- * tunable, but that is strictly not necessary.
- *
- * MAX_SIZE should be as large as the number of cgrp_ids. Ideally, we could get
- * this constant directly from cgroup, but it is understandable that this is
- * better kept as an internal representation in cgroup.c. In any case, the
- * cgrp_id space is not getting any smaller, and we don't have to necessarily
- * increase ours as well if it increases.
- */
-#define MEMCG_CACHES_MIN_SIZE 4
-#define MEMCG_CACHES_MAX_SIZE MEM_CGROUP_ID_MAX
-
-/*
- * A lot of the calls to the cache allocation functions are expected to be
- * inlined by the compiler. Since the calls to memcg_kmem_get_cache are
- * conditional to this static branch, we'll have to allow modules that does
- * kmem_cache_alloc and the such to see this symbol as well
- */
-struct static_key memcg_kmem_enabled_key;
-EXPORT_SYMBOL(memcg_kmem_enabled_key);
-
-static void disarm_kmem_keys(struct mem_cgroup *memcg)
-{
-	if (memcg_kmem_is_active(memcg)) {
-		static_key_slow_dec(&memcg_kmem_enabled_key);
-		ida_simple_remove(&kmem_limited_groups, memcg->kmemcg_id);
-	}
-	/*
-	 * This check can't live in kmem destruction function,
-	 * since the charges will outlive the cgroup
-	 */
-	WARN_ON(res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0);
-}
-#else
-static void disarm_kmem_keys(struct mem_cgroup *memcg)
-{
-}
-#endif /* CONFIG_MEMCG_KMEM */
-
 static void disarm_static_keys(struct mem_cgroup *memcg)
 {
 	disarm_sock_keys(memcg);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
