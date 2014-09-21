Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 38AFD6B006E
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 11:16:05 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fb1so3014446pad.27
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 08:16:04 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id sp8si6105666pab.87.2014.09.21.08.16.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Sep 2014 08:16:04 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 12/14] list_lru: organize all list_lrus to list
Date: Sun, 21 Sep 2014 19:14:44 +0400
Message-ID: <9e53255f042f70c7bc076009d8ee8d16581c9011.1411301245.git.vdavydov@parallels.com>
In-Reply-To: <cover.1411301245.git.vdavydov@parallels.com>
References: <cover.1411301245.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

I need it for making list_lru memcg-aware.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/list_lru.h |    3 +++
 mm/list_lru.c            |   29 +++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

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
index 07e198c77888..53086eda7942 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -10,6 +10,33 @@
 #include <linux/list_lru.h>
 #include <linux/slab.h>
 
+#ifdef CONFIG_MEMCG_KMEM
+static LIST_HEAD(list_lrus);
+static DEFINE_SPINLOCK(list_lrus_lock);
+
+static void list_lru_register(struct list_lru *lru)
+{
+	spin_lock(&list_lrus_lock);
+	list_add(&lru->list, &list_lrus);
+	spin_unlock(&list_lrus_lock);
+}
+
+static void list_lru_unregister(struct list_lru *lru)
+{
+	spin_lock(&list_lrus_lock);
+	list_del(&lru->list);
+	spin_unlock(&list_lrus_lock);
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
+
 bool list_lru_add(struct list_lru *lru, struct list_head *item)
 {
 	int nid = page_to_nid(virt_to_page(item));
@@ -137,12 +164,14 @@ int list_lru_init_key(struct list_lru *lru, struct lock_class_key *key)
 		INIT_LIST_HEAD(&lru->node[i].list);
 		lru->node[i].nr_items = 0;
 	}
+	list_lru_register(lru);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(list_lru_init_key);
 
 void list_lru_destroy(struct list_lru *lru)
 {
+	list_lru_unregister(lru);
 	kfree(lru->node);
 }
 EXPORT_SYMBOL_GPL(list_lru_destroy);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
