Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA2A6B026C
	for <linux-mm@kvack.org>; Tue, 22 May 2018 06:08:49 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f10-v6so11809263pln.21
        for <linux-mm@kvack.org>; Tue, 22 May 2018 03:08:49 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0113.outbound.protection.outlook.com. [104.47.0.113])
        by mx.google.com with ESMTPS id y12-v6si15242619pfl.283.2018.05.22.03.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 May 2018 03:08:48 -0700 (PDT)
Subject: [PATCH v7 08/17] fs: Propagate shrinker::id to list_lru
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 22 May 2018 13:08:36 +0300
Message-ID: <152698371665.3393.13441718686811755204.stgit@localhost.localdomain>
In-Reply-To: <152698356466.3393.5351712806709424140.stgit@localhost.localdomain>
References: <152698356466.3393.5351712806709424140.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

The patch adds list_lru::shrinker_id field, and populates
it by registered shrinker id.

This will be used to set correct bit in memcg shrinkers
map by lru code in next patches, after there appeared
the first related to memcg element in list_lru.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/super.c               |    4 ++--
 include/linux/list_lru.h |   14 +++++++++-----
 mm/list_lru.c            |   11 ++++++++++-
 mm/workingset.c          |    3 ++-
 4 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index 78227c4ddb21..f5f96e52e0cd 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -261,9 +261,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	s->s_shrink.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
 	if (prealloc_shrinker(&s->s_shrink))
 		goto fail;
-	if (list_lru_init_memcg(&s->s_dentry_lru))
+	if (list_lru_init_memcg(&s->s_dentry_lru, &s->s_shrink))
 		goto fail;
-	if (list_lru_init_memcg(&s->s_inode_lru))
+	if (list_lru_init_memcg(&s->s_inode_lru, &s->s_shrink))
 		goto fail;
 	return s;
 
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 2d23b5b745be..9e75bb33766b 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -53,16 +53,20 @@ struct list_lru {
 	struct list_lru_node	*node;
 #ifdef CONFIG_MEMCG_KMEM
 	struct list_head	list;
+	int			shrinker_id;
 #endif
 };
 
 void list_lru_destroy(struct list_lru *lru);
 int __list_lru_init(struct list_lru *lru, bool memcg_aware,
-		    struct lock_class_key *key);
-
-#define list_lru_init(lru)		__list_lru_init((lru), false, NULL)
-#define list_lru_init_key(lru, key)	__list_lru_init((lru), false, (key))
-#define list_lru_init_memcg(lru)	__list_lru_init((lru), true, NULL)
+		    struct lock_class_key *key, struct shrinker *shrinker);
+
+#define list_lru_init(lru)				\
+	__list_lru_init((lru), false, NULL, NULL)
+#define list_lru_init_key(lru, key)			\
+	__list_lru_init((lru), false, (key), NULL)
+#define list_lru_init_memcg(lru, shrinker)		\
+	__list_lru_init((lru), true, NULL, shrinker)
 
 int memcg_update_all_list_lrus(int num_memcgs);
 void memcg_drain_all_list_lrus(int src_idx, int dst_idx);
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 232bb637cf02..dde9ecae7cb5 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -559,12 +559,18 @@ static void memcg_destroy_list_lru(struct list_lru *lru)
 #endif /* CONFIG_MEMCG_KMEM */
 
 int __list_lru_init(struct list_lru *lru, bool memcg_aware,
-		    struct lock_class_key *key)
+		    struct lock_class_key *key, struct shrinker *shrinker)
 {
 	int i;
 	size_t size = sizeof(*lru->node) * nr_node_ids;
 	int err = -ENOMEM;
 
+#ifdef CONFIG_MEMCG_KMEM
+	if (shrinker)
+		lru->shrinker_id = shrinker->id;
+	else
+		lru->shrinker_id = -1;
+#endif
 	memcg_get_cache_ids();
 
 	lru->node = kzalloc(size, GFP_KERNEL);
@@ -607,6 +613,9 @@ void list_lru_destroy(struct list_lru *lru)
 	kfree(lru->node);
 	lru->node = NULL;
 
+#ifdef CONFIG_MEMCG_KMEM
+	lru->shrinker_id = -1;
+#endif
 	memcg_put_cache_ids();
 }
 EXPORT_SYMBOL_GPL(list_lru_destroy);
diff --git a/mm/workingset.c b/mm/workingset.c
index c3a4fe145bb7..79099bc5c256 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -531,7 +531,8 @@ static int __init workingset_init(void)
 	ret = prealloc_shrinker(&workingset_shadow_shrinker);
 	if (ret)
 		goto err;
-	ret = __list_lru_init(&shadow_nodes, true, &shadow_nodes_key);
+	ret = __list_lru_init(&shadow_nodes, true, &shadow_nodes_key,
+			      &workingset_shadow_shrinker);
 	if (ret)
 		goto err_list_lru;
 	register_shrinker_prepared(&workingset_shadow_shrinker);
