Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF5496B002C
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 09:22:02 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f4-v6so3081547plr.11
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 06:22:02 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40136.outbound.protection.outlook.com. [40.107.4.136])
        by mx.google.com with ESMTPS id g12-v6si3907515pla.382.2018.03.21.06.22.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 06:22:01 -0700 (PDT)
Subject: [PATCH 04/10] fs: Propagate shrinker::id to list_lru
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Wed, 21 Mar 2018 16:21:51 +0300
Message-ID: <152163851112.21546.11559231484397320114.stgit@localhost.localdomain>
In-Reply-To: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, ktkhai@virtuozzo.com, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

The patch adds list_lru::shrk_id field, and populates
it by registered shrinker id.

This will be used to set correct bit in memcg shrinkers
map by lru code in next patches, after there appeared
the first related to memcg element in list_lru.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/super.c               |    5 +++++
 include/linux/list_lru.h |    1 +
 mm/list_lru.c            |    7 ++++++-
 mm/workingset.c          |    3 +++
 4 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/fs/super.c b/fs/super.c
index 0660083427fa..1f3dc4eab409 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -521,6 +521,11 @@ struct super_block *sget_userns(struct file_system_type *type,
 	if (err) {
 		deactivate_locked_super(s);
 		s = ERR_PTR(err);
+	} else {
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+		s->s_dentry_lru.shrk_id = s->s_shrink.id;
+		s->s_inode_lru.shrk_id = s->s_shrink.id;
+#endif
 	}
 	return s;
 }
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 96def9d15b1b..ce1d010cd3fa 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -53,6 +53,7 @@ struct list_lru {
 	struct list_lru_node	*node;
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 	struct list_head	list;
+	int			shrk_id;
 #endif
 };
 
diff --git a/mm/list_lru.c b/mm/list_lru.c
index d9c84c5bda1d..013bf04a9eb9 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -567,6 +567,9 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aware,
 	size_t size = sizeof(*lru->node) * nr_node_ids;
 	int err = -ENOMEM;
 
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+	lru->shrk_id = -1;
+#endif
 	memcg_get_cache_ids();
 
 	lru->node = kzalloc(size, GFP_KERNEL);
@@ -608,7 +611,9 @@ void list_lru_destroy(struct list_lru *lru)
 	memcg_destroy_list_lru(lru);
 	kfree(lru->node);
 	lru->node = NULL;
-
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+	lru->shrk_id = -1;
+#endif
 	memcg_put_cache_ids();
 }
 EXPORT_SYMBOL_GPL(list_lru_destroy);
diff --git a/mm/workingset.c b/mm/workingset.c
index b7d616a3bbbe..62c9eb000c4f 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -534,6 +534,9 @@ static int __init workingset_init(void)
 	ret = register_shrinker(&workingset_shadow_shrinker);
 	if (ret)
 		goto err_list_lru;
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+	shadow_nodes.shrk_id = workingset_shadow_shrinker.id;
+#endif
 	return 0;
 err_list_lru:
 	list_lru_destroy(&shadow_nodes);
