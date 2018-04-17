Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62C566B0253
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:54:02 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d9-v6so3621671plj.4
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:54:02 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0139.outbound.protection.outlook.com. [104.47.2.139])
        by mx.google.com with ESMTPS id n7si11894206pga.199.2018.04.17.08.54.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 08:54:01 -0700 (PDT)
Subject: [PATCH v2 05/12] fs: Propagate shrinker::id to list_lru
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 17 Apr 2018 21:53:47 +0300
Message-ID: <152399122780.3456.1111065927024895559.stgit@localhost.localdomain>
In-Reply-To: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

The patch adds list_lru::shrinker_id field, and populates
it by registered shrinker id.

This will be used to set correct bit in memcg shrinkers
map by lru code in next patches, after there appeared
the first related to memcg element in list_lru.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/super.c               |    4 +++-
 include/linux/list_lru.h |    1 +
 include/linux/shrinker.h |    8 +++++++-
 mm/list_lru.c            |    6 ++++++
 mm/vmscan.c              |   15 ++++++++++-----
 mm/workingset.c          |    3 ++-
 6 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index 5fa9a8d8d865..9bc5698c8c3c 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -518,7 +518,9 @@ struct super_block *sget_userns(struct file_system_type *type,
 	hlist_add_head(&s->s_instances, &type->fs_supers);
 	spin_unlock(&sb_lock);
 	get_filesystem(type);
-	err = register_shrinker(&s->s_shrink);
+	err = register_shrinker_args(&s->s_shrink, 2,
+				     &s->s_dentry_lru.shrinker_id,
+				     &s->s_inode_lru.shrinker_id);
 	if (err) {
 		deactivate_locked_super(s);
 		s = ERR_PTR(err);
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 96def9d15b1b..f5b6bb7a8670 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -53,6 +53,7 @@ struct list_lru {
 	struct list_lru_node	*node;
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 	struct list_head	list;
+	int			shrinker_id;
 #endif
 };
 
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 86b651fa2846..22ee2996c480 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -77,6 +77,12 @@ struct shrinker {
 #define SHRINKER_NUMA_AWARE	(1 << 0)
 #define SHRINKER_MEMCG_AWARE	(1 << 1)
 
-extern __must_check int register_shrinker(struct shrinker *);
+extern __must_check int __register_shrinker(struct shrinker *, int, ...);
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#define register_shrinker_args(...) __register_shrinker(__VA_ARGS__)
+#else
+#define register_shrinker_args(shrinker,...) __register_shrinker(shrinker, 0)
+#endif
+#define register_shrinker(shrinker) register_shrinker_args(shrinker, 0)
 extern void unregister_shrinker(struct shrinker *);
 #endif
diff --git a/mm/list_lru.c b/mm/list_lru.c
index d9c84c5bda1d..2a4d29491947 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -567,6 +567,9 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aware,
 	size_t size = sizeof(*lru->node) * nr_node_ids;
 	int err = -ENOMEM;
 
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+	lru->shrinker_id = -1;
+#endif
 	memcg_get_cache_ids();
 
 	lru->node = kzalloc(size, GFP_KERNEL);
@@ -609,6 +612,9 @@ void list_lru_destroy(struct list_lru *lru)
 	kfree(lru->node);
 	lru->node = NULL;
 
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+	lru->shrinker_id = -1;
+#endif
 	memcg_put_cache_ids();
 }
 EXPORT_SYMBOL_GPL(list_lru_destroy);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f63eb5596c35..34cd1d9b8b22 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -188,7 +188,7 @@ static int expand_shrinker_id(int id)
 	return 0;
 }
 
-static int add_memcg_shrinker(struct shrinker *shrinker)
+static int add_memcg_shrinker(struct shrinker *shrinker, int nr, va_list va_ids)
 {
 	int id, ret;
 
@@ -202,6 +202,8 @@ static int add_memcg_shrinker(struct shrinker *shrinker)
 		goto unlock;
 	}
 	shrinker->id = id;
+	while (nr-- > 0)
+		*va_arg(va_ids, int *) = id;
 	ret = 0;
 unlock:
 	up_write(&shrinker_rwsem);
@@ -217,7 +219,7 @@ static void del_memcg_shrinker(struct shrinker *shrinker)
 	up_write(&shrinker_rwsem);
 }
 #else /* CONFIG_MEMCG && !CONFIG_SLOB */
-static int add_memcg_shrinker(struct shrinker *shrinker)
+static int add_memcg_shrinker(struct shrinker *shrinker, int nr, va_list args)
 {
 	return 0;
 }
@@ -361,9 +363,10 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone
 /*
  * Add a shrinker callback to be called from the vm.
  */
-int register_shrinker(struct shrinker *shrinker)
+int __register_shrinker(struct shrinker *shrinker, int nr, ...)
 {
 	size_t size = sizeof(*shrinker->nr_deferred);
+	va_list args;
 	int ret;
 
 	if (shrinker->flags & SHRINKER_NUMA_AWARE)
@@ -374,7 +377,9 @@ int register_shrinker(struct shrinker *shrinker)
 		return -ENOMEM;
 
 	if (shrinker->flags & SHRINKER_MEMCG_AWARE) {
-		ret = add_memcg_shrinker(shrinker);
+		va_start(args, nr);
+		ret = add_memcg_shrinker(shrinker, nr, args);
+		va_end(args);
 		if (ret)
 			goto free_deferred;
 	}
@@ -389,7 +394,7 @@ int register_shrinker(struct shrinker *shrinker)
 	shrinker->nr_deferred = NULL;
 	return -ENOMEM;
 }
-EXPORT_SYMBOL(register_shrinker);
+EXPORT_SYMBOL(__register_shrinker);
 
 /*
  * Remove one
diff --git a/mm/workingset.c b/mm/workingset.c
index 40ee02c83978..2e2555649d13 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -531,7 +531,8 @@ static int __init workingset_init(void)
 	ret = __list_lru_init(&shadow_nodes, true, &shadow_nodes_key);
 	if (ret)
 		goto err;
-	ret = register_shrinker(&workingset_shadow_shrinker);
+	ret = register_shrinker_args(&workingset_shadow_shrinker,
+				     1, &shadow_nodes.shrinker_id);
 	if (ret)
 		goto err_list_lru;
 	return 0;
