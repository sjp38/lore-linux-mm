Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 177416B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:13:18 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e20so7870598pff.14
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 05:13:18 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0096.outbound.protection.outlook.com. [104.47.0.96])
        by mx.google.com with ESMTPS id 37-v6si13666360plc.140.2018.04.24.05.13.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 05:13:17 -0700 (PDT)
Subject: [PATCH v3 07/14] fs: Propagate shrinker::id to list_lru
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 24 Apr 2018 15:13:10 +0300
Message-ID: <152457199089.22533.12993688427659059890.stgit@localhost.localdomain>
In-Reply-To: <152457151556.22533.5742587589232401708.stgit@localhost.localdomain>
References: <152457151556.22533.5742587589232401708.stgit@localhost.localdomain>
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
 include/linux/list_lru.h |    1 +
 mm/list_lru.c            |    6 ++++++
 mm/workingset.c          |    3 +++
 4 files changed, 14 insertions(+)

diff --git a/fs/super.c b/fs/super.c
index d95fa174edab..c9a6ef33a98b 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -258,6 +258,10 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 		goto fail;
 	if (list_lru_init_memcg(&s->s_inode_lru))
 		goto fail;
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+	s->s_dentry_lru.shrinker_id = s->s_shrink.id;
+	s->s_inode_lru.shrinker_id = s->s_shrink.id;
+#endif
 	return s;
 
 fail:
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
diff --git a/mm/workingset.c b/mm/workingset.c
index c3a4fe145bb7..b8900573db25 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -534,6 +534,9 @@ static int __init workingset_init(void)
 	ret = __list_lru_init(&shadow_nodes, true, &shadow_nodes_key);
 	if (ret)
 		goto err_list_lru;
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+	shadow_nodes.shrinker_id = workingset_shadow_shrinker.id;
+#endif
 	register_shrinker_prepared(&workingset_shadow_shrinker);
 	return 0;
 err_list_lru:
