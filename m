Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B9E366B0008
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 05:46:20 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 7-v6so7905236ita.0
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 02:46:20 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0096.outbound.protection.outlook.com. [104.47.0.96])
        by mx.google.com with ESMTPS id w186-v6si6174735itw.142.2018.06.18.02.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Jun 2018 02:46:19 -0700 (PDT)
Subject: [PATCH v7 REBASED 08/17] fs: Propagate shrinker::id to list_lru
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 18 Jun 2018 12:46:08 +0300
Message-ID: <152931516881.28457.17649784047022122337.stgit@localhost.localdomain>
In-Reply-To: <152931506756.28457.5620076974981468927.stgit@localhost.localdomain>
References: <152931506756.28457.5620076974981468927.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

The patch adds list_lru::shrinker_id field, and populates
it by registered shrinker id.

This will be used to set correct bit in memcg shrinkers
map by lru code in next patches, after there appeared
the first related to memcg element in list_lru.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Tested-by: Shakeel Butt <shakeelb@google.com>
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
index 7621084d5a7d..077956f8d58f 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -552,12 +552,18 @@ static void memcg_destroy_list_lru(struct list_lru *lru)
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
@@ -600,6 +606,9 @@ void list_lru_destroy(struct list_lru *lru)
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
