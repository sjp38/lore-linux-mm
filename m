Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C85526B05E3
	for <linux-mm@kvack.org>; Thu, 10 May 2018 05:53:14 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m24-v6so1814198ioh.5
        for <linux-mm@kvack.org>; Thu, 10 May 2018 02:53:14 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50093.outbound.protection.outlook.com. [40.107.5.93])
        by mx.google.com with ESMTPS id g124-v6si541482ith.133.2018.05.10.02.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 10 May 2018 02:53:13 -0700 (PDT)
Subject: [PATCH v5 06/13] fs: Propagate shrinker::id to list_lru
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Thu, 10 May 2018 12:53:06 +0300
Message-ID: <152594598693.22949.2394903594690437296.stgit@localhost.localdomain>
In-Reply-To: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
References: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
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
 fs/super.c               |    4 ++++
 include/linux/list_lru.h |    3 +++
 mm/list_lru.c            |    6 ++++++
 mm/workingset.c          |    3 +++
 4 files changed, 16 insertions(+)

diff --git a/fs/super.c b/fs/super.c
index 2ccacb78f91c..dfa85e725e45 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -258,6 +258,10 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 		goto fail;
 	if (list_lru_init_memcg(&s->s_inode_lru))
 		goto fail;
+#ifdef CONFIG_MEMCG_SHRINKER
+	s->s_dentry_lru.shrinker_id = s->s_shrink.id;
+	s->s_inode_lru.shrinker_id = s->s_shrink.id;
+#endif
 	return s;
 
 fail:
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 96def9d15b1b..a63b7a4abc6b 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -54,6 +54,9 @@ struct list_lru {
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 	struct list_head	list;
 #endif
+#ifdef CONFIG_MEMCG_SHRINKER
+	int			shrinker_id;
+#endif
 };
 
 void list_lru_destroy(struct list_lru *lru);
diff --git a/mm/list_lru.c b/mm/list_lru.c
index d9c84c5bda1d..8dd3f181d86f 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -567,6 +567,9 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aware,
 	size_t size = sizeof(*lru->node) * nr_node_ids;
 	int err = -ENOMEM;
 
+#ifdef CONFIG_MEMCG_SHRINKER
+	lru->shrinker_id = -1;
+#endif
 	memcg_get_cache_ids();
 
 	lru->node = kzalloc(size, GFP_KERNEL);
@@ -609,6 +612,9 @@ void list_lru_destroy(struct list_lru *lru)
 	kfree(lru->node);
 	lru->node = NULL;
 
+#ifdef CONFIG_MEMCG_SHRINKER
+	lru->shrinker_id = -1;
+#endif
 	memcg_put_cache_ids();
 }
 EXPORT_SYMBOL_GPL(list_lru_destroy);
diff --git a/mm/workingset.c b/mm/workingset.c
index c3a4fe145bb7..da720f3b0a0a 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -534,6 +534,9 @@ static int __init workingset_init(void)
 	ret = __list_lru_init(&shadow_nodes, true, &shadow_nodes_key);
 	if (ret)
 		goto err_list_lru;
+#ifdef CONFIG_MEMCG_SHRINKER
+	shadow_nodes.shrinker_id = workingset_shadow_shrinker.id;
+#endif
 	register_shrinker_prepared(&workingset_shadow_shrinker);
 	return 0;
 err_list_lru:
