Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0978F6B04F3
	for <linux-mm@kvack.org>; Wed,  9 May 2018 07:57:04 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 76-v6so30449594ioh.6
        for <linux-mm@kvack.org>; Wed, 09 May 2018 04:57:04 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0109.outbound.protection.outlook.com. [104.47.1.109])
        by mx.google.com with ESMTPS id a130-v6si11955523ita.84.2018.05.09.04.57.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 May 2018 04:57:02 -0700 (PDT)
Subject: [PATCH v4 01/13] mm: Assign id to every memcg-aware shrinker
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Wed, 09 May 2018 14:56:55 +0300
Message-ID: <152586701534.3048.9132875744525159636.stgit@localhost.localdomain>
In-Reply-To: <152586686544.3048.15776787801312398314.stgit@localhost.localdomain>
References: <152586686544.3048.15776787801312398314.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

The patch introduces shrinker::id number, which is used to enumerate
memcg-aware shrinkers. The number start from 0, and the code tries
to maintain it as small as possible.

This will be used as to represent a memcg-aware shrinkers in memcg
shrinkers map.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/super.c               |    3 ++
 include/linux/shrinker.h |    4 +++
 mm/vmscan.c              |   59 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+)

diff --git a/fs/super.c b/fs/super.c
index 122c402049a2..036a5522f9d0 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -248,6 +248,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	s->s_time_gran = 1000000000;
 	s->cleancache_poolid = CLEANCACHE_NO_POOL;
 
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+	s->s_shrink.id = -1;
+#endif
 	s->s_shrink.seeks = DEFAULT_SEEKS;
 	s->s_shrink.scan_objects = super_cache_scan;
 	s->s_shrink.count_objects = super_cache_count;
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 6794490f25b2..a9ec364e1b0b 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -66,6 +66,10 @@ struct shrinker {
 
 	/* These are for internal use */
 	struct list_head list;
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+	/* ID in shrinker_idr */
+	int id;
+#endif
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
 };
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 10c8a38c5eef..36808bdf02ae 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -169,6 +169,47 @@ unsigned long vm_total_pages;
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+static DEFINE_IDR(shrinker_idr);
+
+static int prealloc_memcg_shrinker(struct shrinker *shrinker)
+{
+	int id, ret;
+
+	down_write(&shrinker_rwsem);
+	ret = id = idr_alloc(&shrinker_idr, shrinker, 0, 0, GFP_KERNEL);
+	if (ret < 0)
+		goto unlock;
+	shrinker->id = id;
+	ret = 0;
+unlock:
+	up_write(&shrinker_rwsem);
+	return ret;
+}
+
+static void del_memcg_shrinker(struct shrinker *shrinker)
+{
+	int id = shrinker->id;
+
+	if (id < 0)
+		return;
+
+	down_write(&shrinker_rwsem);
+	idr_remove(&shrinker_idr, id);
+	up_write(&shrinker_rwsem);
+	shrinker->id = -1;
+}
+#else /* CONFIG_MEMCG && !CONFIG_SLOB */
+static int prealloc_memcg_shrinker(struct shrinker *shrinker)
+{
+	return 0;
+}
+
+static void del_memcg_shrinker(struct shrinker *shrinker)
+{
+}
+#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
+
 #ifdef CONFIG_MEMCG
 static bool global_reclaim(struct scan_control *sc)
 {
@@ -306,6 +347,7 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone
 int prealloc_shrinker(struct shrinker *shrinker)
 {
 	size_t size = sizeof(*shrinker->nr_deferred);
+	int ret;
 
 	if (shrinker->flags & SHRINKER_NUMA_AWARE)
 		size *= nr_node_ids;
@@ -313,11 +355,26 @@ int prealloc_shrinker(struct shrinker *shrinker)
 	shrinker->nr_deferred = kzalloc(size, GFP_KERNEL);
 	if (!shrinker->nr_deferred)
 		return -ENOMEM;
+
+	if (shrinker->flags & SHRINKER_MEMCG_AWARE) {
+		ret = prealloc_memcg_shrinker(shrinker);
+		if (ret)
+			goto free_deferred;
+	}
+
 	return 0;
+
+free_deferred:
+	kfree(shrinker->nr_deferred);
+	shrinker->nr_deferred = NULL;
+	return -ENOMEM;
 }
 
 void free_prealloced_shrinker(struct shrinker *shrinker)
 {
+	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
+		del_memcg_shrinker(shrinker);
+
 	kfree(shrinker->nr_deferred);
 	shrinker->nr_deferred = NULL;
 }
@@ -347,6 +404,8 @@ void unregister_shrinker(struct shrinker *shrinker)
 {
 	if (!shrinker->nr_deferred)
 		return;
+	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
+		del_memcg_shrinker(shrinker);
 	down_write(&shrinker_rwsem);
 	list_del(&shrinker->list);
 	up_write(&shrinker_rwsem);
