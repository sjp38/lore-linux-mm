Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6E96B0029
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 09:21:29 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z11-v6so3062843plo.21
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 06:21:29 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40117.outbound.protection.outlook.com. [40.107.4.117])
        by mx.google.com with ESMTPS id u25si3083206pfm.164.2018.03.21.06.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 06:21:27 -0700 (PDT)
Subject: [PATCH 01/10] mm: Assign id to every memcg-aware shrinker
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Wed, 21 Mar 2018 16:21:17 +0300
Message-ID: <152163847740.21546.16821490541519326725.stgit@localhost.localdomain>
In-Reply-To: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, ktkhai@virtuozzo.com, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

The patch introduces shrinker::id number, which is used to enumerate
memcg-aware shrinkers. The number start from 0, and the code tries
to maintain it as small as possible.

This will be used as to represent a memcg-aware shrinkers in memcg
shrinkers map.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/shrinker.h |    1 +
 mm/vmscan.c              |   59 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index a3894918a436..738de8ef5246 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -66,6 +66,7 @@ struct shrinker {
 
 	/* These are for internal use */
 	struct list_head list;
+	int id;
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
 };
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8fcd9f8d7390..91b5120b924f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -159,6 +159,56 @@ unsigned long vm_total_pages;
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+static DEFINE_IDA(bitmap_id_ida);
+static DECLARE_RWSEM(bitmap_rwsem);
+static int bitmap_id_start;
+
+static int alloc_shrinker_id(struct shrinker *shrinker)
+{
+	int id, ret;
+
+	if (!(shrinker->flags & SHRINKER_MEMCG_AWARE))
+		return 0;
+retry:
+	ida_pre_get(&bitmap_id_ida, GFP_KERNEL);
+	down_write(&bitmap_rwsem);
+	ret = ida_get_new_above(&bitmap_id_ida, bitmap_id_start, &id);
+	if (!ret) {
+		shrinker->id = id;
+		bitmap_id_start = shrinker->id + 1;
+	}
+	up_write(&bitmap_rwsem);
+	if (ret == -EAGAIN)
+		goto retry;
+
+	return ret;
+}
+
+static void free_shrinker_id(struct shrinker *shrinker)
+{
+	int id = shrinker->id;
+
+	if (!(shrinker->flags & SHRINKER_MEMCG_AWARE))
+		return;
+
+	down_write(&bitmap_rwsem);
+	ida_remove(&bitmap_id_ida, id);
+	if (bitmap_id_start > id)
+		bitmap_id_start = id;
+	up_write(&bitmap_rwsem);
+}
+#else /* CONFIG_MEMCG && !CONFIG_SLOB */
+static int alloc_shrinker_id(struct shrinker *shrinker)
+{
+	return 0;
+}
+
+static void free_shrinker_id(struct shrinker *shrinker)
+{
+}
+#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
+
 #ifdef CONFIG_MEMCG
 static bool global_reclaim(struct scan_control *sc)
 {
@@ -269,10 +319,18 @@ int register_shrinker(struct shrinker *shrinker)
 	if (!shrinker->nr_deferred)
 		return -ENOMEM;
 
+	if (alloc_shrinker_id(shrinker))
+		goto free_deferred;
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
 
@@ -286,6 +344,7 @@ void unregister_shrinker(struct shrinker *shrinker)
 	down_write(&shrinker_rwsem);
 	list_del(&shrinker->list);
 	up_write(&shrinker_rwsem);
+	free_shrinker_id(shrinker);
 	kfree(shrinker->nr_deferred);
 	shrinker->nr_deferred = NULL;
 }
