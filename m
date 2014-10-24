Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id CD29E6B0075
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 06:38:15 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kx10so931756pab.12
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 03:38:15 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ae3si3787316pbd.235.2014.10.24.03.38.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 03:38:14 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 7/9] list_lru: organize all list_lrus to list
Date: Fri, 24 Oct 2014 14:37:38 +0400
Message-ID: <23ccb6ac5e91a5fd487029b17e01dafc007bfe0f.1414145863.git.vdavydov@parallels.com>
In-Reply-To: <cover.1414145862.git.vdavydov@parallels.com>
References: <cover.1414145862.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Dave Chinner <david@fromorbit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To make list_lru memcg aware, I need all list_lrus to be kept on a list
protected by a mutex, so that I could sleep while walking over the list.

Therefore after this change list_lru_destroy may sleep. Fortunately,
there is the only user that calls it from an atomic context - it's
put_super - and we can easily fix it by calling list_lru_destroy before
put_super in destroy_locked_super - anyway we don't longer need lrus by
that time.

Another point that should be noted is that list_lru_destroy is allowed
to be called on an uninitialized zeroed-out object, in which case it is
a no-op. Before this patch this was guaranteed by kfree, but now we need
an explicit check there.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/super.c               |    8 ++++++++
 include/linux/list_lru.h |    3 +++
 mm/list_lru.c            |   34 ++++++++++++++++++++++++++++++++++
 3 files changed, 45 insertions(+)

diff --git a/fs/super.c b/fs/super.c
index a2b735a42e74..b027849d92d2 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -282,6 +282,14 @@ void deactivate_locked_super(struct super_block *s)
 		unregister_shrinker(&s->s_shrink);
 		fs->kill_sb(s);
 
+		/*
+		 * Since list_lru_destroy() may sleep, we cannot call it from
+		 * put_super(), where we hold the sb_lock. Therefore we destroy
+		 * the lru lists right now.
+		 */
+		list_lru_destroy(&s->s_dentry_lru);
+		list_lru_destroy(&s->s_inode_lru);
+
 		put_filesystem(fs);
 		put_super(s);
 	} else {
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 53c1d6b78270..ee9486ac0621 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -31,6 +31,9 @@ struct list_lru_node {
 
 struct list_lru {
 	struct list_lru_node	*node;
+#ifdef CONFIG_MEMCG_KMEM
+	struct list_head	list;
+#endif
 };
 
 void list_lru_destroy(struct list_lru *lru);
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 07e198c77888..a9021cb3ccde 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -9,6 +9,34 @@
 #include <linux/mm.h>
 #include <linux/list_lru.h>
 #include <linux/slab.h>
+#include <linux/mutex.h>
+
+#ifdef CONFIG_MEMCG_KMEM
+static LIST_HEAD(list_lrus);
+static DEFINE_MUTEX(list_lrus_mutex);
+
+static void list_lru_register(struct list_lru *lru)
+{
+	mutex_lock(&list_lrus_mutex);
+	list_add(&lru->list, &list_lrus);
+	mutex_unlock(&list_lrus_mutex);
+}
+
+static void list_lru_unregister(struct list_lru *lru)
+{
+	mutex_lock(&list_lrus_mutex);
+	list_del(&lru->list);
+	mutex_unlock(&list_lrus_mutex);
+}
+#else
+static void list_lru_register(struct list_lru *lru)
+{
+}
+
+static void list_lru_unregister(struct list_lru *lru)
+{
+}
+#endif /* CONFIG_MEMCG_KMEM */
 
 bool list_lru_add(struct list_lru *lru, struct list_head *item)
 {
@@ -137,12 +165,18 @@ int list_lru_init_key(struct list_lru *lru, struct lock_class_key *key)
 		INIT_LIST_HEAD(&lru->node[i].list);
 		lru->node[i].nr_items = 0;
 	}
+	list_lru_register(lru);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(list_lru_init_key);
 
 void list_lru_destroy(struct list_lru *lru)
 {
+	/* Already destroyed or not yet initialized? */
+	if (!lru->node)
+		return;
+	list_lru_unregister(lru);
 	kfree(lru->node);
+	lru->node = NULL;
 }
 EXPORT_SYMBOL_GPL(list_lru_destroy);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
