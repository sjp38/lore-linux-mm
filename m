Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C4FD26B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:12:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b2so8565753pgt.6
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 05:12:13 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00094.outbound.protection.outlook.com. [40.107.0.94])
        by mx.google.com with ESMTPS id j185si1270433pgc.606.2018.04.24.05.12.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 05:12:12 -0700 (PDT)
Subject: [PATCH v3 01/14] mm: Assign id to every memcg-aware shrinker
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 24 Apr 2018 15:12:01 +0300
Message-ID: <152457192101.22533.16719199747465975214.stgit@localhost.localdomain>
In-Reply-To: <152457151556.22533.5742587589232401708.stgit@localhost.localdomain>
References: <152457151556.22533.5742587589232401708.stgit@localhost.localdomain>
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
index 9b697323a88c..6c986c07dd75 100644
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
