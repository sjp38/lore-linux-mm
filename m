Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D8D756B0031
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:53:16 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id u11-v6so12574831pls.22
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:53:16 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0133.outbound.protection.outlook.com. [104.47.2.133])
        by mx.google.com with ESMTPS id q5si12107477pgc.620.2018.04.17.08.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 08:53:15 -0700 (PDT)
Subject: [PATCH v2 01/12] mm: Assign id to every memcg-aware shrinker
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 17 Apr 2018 21:53:02 +0300
Message-ID: <152399118252.3456.17590357803686895373.stgit@localhost.localdomain>
In-Reply-To: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

The patch introduces shrinker::id number, which is used to enumerate
memcg-aware shrinkers. The number start from 0, and the code tries
to maintain it as small as possible.

This will be used as to represent a memcg-aware shrinkers in memcg
shrinkers map.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/shrinker.h |    2 ++
 mm/vmscan.c              |   51 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 53 insertions(+)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index a3894918a436..86b651fa2846 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -66,6 +66,8 @@ struct shrinker {
 
 	/* These are for internal use */
 	struct list_head list;
+	/* ID in shrinkers_id_idr */
+	int id;
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
 };
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8b920ce3ae02..4f02fe83537e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -169,6 +169,43 @@ unsigned long vm_total_pages;
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+static DEFINE_IDR(shrinkers_id_idr);
+
+static int add_memcg_shrinker(struct shrinker *shrinker)
+{
+	int id, ret;
+
+	down_write(&shrinker_rwsem);
+	ret = id = idr_alloc(&shrinkers_id_idr, shrinker, 0, 0, GFP_KERNEL);
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
+	down_write(&shrinker_rwsem);
+	idr_remove(&shrinkers_id_idr, id);
+	up_write(&shrinker_rwsem);
+}
+#else /* CONFIG_MEMCG && !CONFIG_SLOB */
+static int add_memcg_shrinker(struct shrinker *shrinker)
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
@@ -306,6 +343,7 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone
 int register_shrinker(struct shrinker *shrinker)
 {
 	size_t size = sizeof(*shrinker->nr_deferred);
+	int ret;
 
 	if (shrinker->flags & SHRINKER_NUMA_AWARE)
 		size *= nr_node_ids;
@@ -314,10 +352,21 @@ int register_shrinker(struct shrinker *shrinker)
 	if (!shrinker->nr_deferred)
 		return -ENOMEM;
 
+	if (shrinker->flags & SHRINKER_MEMCG_AWARE) {
+		ret = add_memcg_shrinker(shrinker);
+		if (ret)
+			goto free_deferred;
+	}
+
 	down_write(&shrinker_rwsem);
 	list_add_tail(&shrinker->list, &shrinker_list);
 	up_write(&shrinker_rwsem);
 	return 0;
+
+free_deferred:
+	kfree(shrinker->nr_deferred);
+	shrinker->nr_deferred = NULL;
+	return -ENOMEM;
 }
 EXPORT_SYMBOL(register_shrinker);
 
@@ -328,6 +377,8 @@ void unregister_shrinker(struct shrinker *shrinker)
 {
 	if (!shrinker->nr_deferred)
 		return;
+	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
+		del_memcg_shrinker(shrinker);
 	down_write(&shrinker_rwsem);
 	list_del(&shrinker->list);
 	up_write(&shrinker_rwsem);
