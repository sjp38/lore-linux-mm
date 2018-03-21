Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF4B6B0029
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 09:21:39 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id bb5-v6so3070450plb.22
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 06:21:39 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0122.outbound.protection.outlook.com. [104.47.2.122])
        by mx.google.com with ESMTPS id 31-v6si3916793pli.653.2018.03.21.06.21.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 06:21:37 -0700 (PDT)
Subject: [PATCH 02/10] mm: Maintain memcg-aware shrinkers in mcg_shrinkers
 array
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Wed, 21 Mar 2018 16:21:29 +0300
Message-ID: <152163848990.21546.2153496613786165374.stgit@localhost.localdomain>
In-Reply-To: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, ktkhai@virtuozzo.com, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

The patch introduces mcg_shrinkers array to keep memcg-aware
shrinkers in order of their shrinker::id.

This allows to access the shrinkers dirrectly by the id,
without iteration over shrinker_list list.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |   89 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 81 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 91b5120b924f..97ce4f342fab 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -163,6 +163,46 @@ static DECLARE_RWSEM(shrinker_rwsem);
 static DEFINE_IDA(bitmap_id_ida);
 static DECLARE_RWSEM(bitmap_rwsem);
 static int bitmap_id_start;
+static int bitmap_nr_ids;
+static struct shrinker **mcg_shrinkers;
+
+static int expand_shrinkers_array(int old_nr, int nr)
+{
+	struct shrinker **new;
+	int old_size, size;
+
+	size = nr * sizeof(struct shrinker *);
+	new = kvmalloc(size, GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
+
+	old_size = old_nr * sizeof(struct shrinker *);
+	memset((void *)new + old_size, 0, size - old_size);
+
+	down_write(&shrinker_rwsem);
+	memcpy((void *)new, mcg_shrinkers, old_size);
+	swap(new, mcg_shrinkers);
+	up_write(&shrinker_rwsem);
+
+	kvfree(new);
+	return 0;
+}
+
+static int expand_shrinker_id(int id)
+{
+	if (likely(id < bitmap_nr_ids))
+		return 0;
+
+	id = bitmap_nr_ids * 2;
+	if (id == 0)
+		id = BITS_PER_BYTE;
+
+	if (expand_shrinkers_array(bitmap_nr_ids, id))
+		return -ENOMEM;
+
+	bitmap_nr_ids = id;
+	return 0;
+}
 
 static int alloc_shrinker_id(struct shrinker *shrinker)
 {
@@ -175,8 +215,13 @@ static int alloc_shrinker_id(struct shrinker *shrinker)
 	down_write(&bitmap_rwsem);
 	ret = ida_get_new_above(&bitmap_id_ida, bitmap_id_start, &id);
 	if (!ret) {
-		shrinker->id = id;
-		bitmap_id_start = shrinker->id + 1;
+		if (expand_shrinker_id(id)) {
+			ida_remove(&bitmap_id_ida, id);
+			ret = -ENOMEM;
+		} else {
+			shrinker->id = id;
+			bitmap_id_start = shrinker->id + 1;
+		}
 	}
 	up_write(&bitmap_rwsem);
 	if (ret == -EAGAIN)
@@ -198,6 +243,24 @@ static void free_shrinker_id(struct shrinker *shrinker)
 		bitmap_id_start = id;
 	up_write(&bitmap_rwsem);
 }
+
+static void add_shrinker(struct shrinker *shrinker)
+{
+	down_write(&shrinker_rwsem);
+	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
+		mcg_shrinkers[shrinker->id] = shrinker;
+	list_add_tail(&shrinker->list, &shrinker_list);
+	up_write(&shrinker_rwsem);
+}
+
+static void del_shrinker(struct shrinker *shrinker)
+{
+	down_write(&shrinker_rwsem);
+	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
+		mcg_shrinkers[shrinker->id] = NULL;
+	list_del(&shrinker->list);
+	up_write(&shrinker_rwsem);
+}
 #else /* CONFIG_MEMCG && !CONFIG_SLOB */
 static int alloc_shrinker_id(struct shrinker *shrinker)
 {
@@ -207,6 +270,20 @@ static int alloc_shrinker_id(struct shrinker *shrinker)
 static void free_shrinker_id(struct shrinker *shrinker)
 {
 }
+
+static void add_shrinker(struct shrinker *shrinker)
+{
+	down_write(&shrinker_rwsem);
+	list_add_tail(&shrinker->list, &shrinker_list);
+	up_write(&shrinker_rwsem);
+}
+
+static void del_shrinker(struct shrinker *shrinker)
+{
+	down_write(&shrinker_rwsem);
+	list_del(&shrinker->list);
+	up_write(&shrinker_rwsem);
+}
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 #ifdef CONFIG_MEMCG
@@ -322,9 +399,7 @@ int register_shrinker(struct shrinker *shrinker)
 	if (alloc_shrinker_id(shrinker))
 		goto free_deferred;
 
-	down_write(&shrinker_rwsem);
-	list_add_tail(&shrinker->list, &shrinker_list);
-	up_write(&shrinker_rwsem);
+	add_shrinker(shrinker);
 	return 0;
 
 free_deferred:
@@ -341,9 +416,7 @@ void unregister_shrinker(struct shrinker *shrinker)
 {
 	if (!shrinker->nr_deferred)
 		return;
-	down_write(&shrinker_rwsem);
-	list_del(&shrinker->list);
-	up_write(&shrinker_rwsem);
+	del_shrinker(shrinker);
 	free_shrinker_id(shrinker);
 	kfree(shrinker->nr_deferred);
 	shrinker->nr_deferred = NULL;
