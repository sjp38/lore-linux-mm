Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id F411B6B003A
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 07:47:34 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so8963307pdb.5
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 04:47:34 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ba2si2767714pdb.0.2014.07.21.04.47.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jul 2014 04:47:32 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 3/6] memcg: make memcg_cache_id static
Date: Mon, 21 Jul 2014 15:47:13 +0400
Message-ID: <32eff8a3e8db2b6084942cf07f3203c27c7c7751.1405941342.git.vdavydov@parallels.com>
In-Reply-To: <cover.1405941342.git.vdavydov@parallels.com>
References: <cover.1405941342.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It's not used anywhere outside mm/memcontrol.c.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    7 -------
 mm/memcontrol.c            |   20 ++++++++++----------
 2 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e0752d204d9e..4b4a26725cbb 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -438,8 +438,6 @@ void __memcg_kmem_commit_charge(struct page *page,
 				       struct mem_cgroup *memcg, int order);
 void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
-int memcg_cache_id(struct mem_cgroup *memcg);
-
 int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 			     struct kmem_cache *root_cache);
 void memcg_free_cache_params(struct kmem_cache *s);
@@ -569,11 +567,6 @@ memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg, int order)
 {
 }
 
-static inline int memcg_cache_id(struct mem_cgroup *memcg)
-{
-	return -1;
-}
-
 static inline int memcg_alloc_cache_params(struct mem_cgroup *memcg,
 		struct kmem_cache *s, struct kmem_cache *root_cache)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7d5c4a5e4c74..cc1064a504cc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2781,6 +2781,16 @@ static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 }
 
 /*
+ * helper for acessing a memcg's index. It will be used as an index in the
+ * child cache array in kmem_cache, and also to derive its name. This function
+ * will return -1 when this is not a kmem-limited memcg.
+ */
+static inline int memcg_cache_id(struct mem_cgroup *memcg)
+{
+	return memcg ? memcg->kmemcg_id : -1;
+}
+
+/*
  * This is a bit cumbersome, but it is rarely used and avoids a backpointer
  * in the memcg_cache_params struct.
  */
@@ -2872,16 +2882,6 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 		css_put(&memcg->css);
 }
 
-/*
- * helper for acessing a memcg's index. It will be used as an index in the
- * child cache array in kmem_cache, and also to derive its name. This function
- * will return -1 when this is not a kmem-limited memcg.
- */
-int memcg_cache_id(struct mem_cgroup *memcg)
-{
-	return memcg ? memcg->kmemcg_id : -1;
-}
-
 static size_t memcg_caches_array_size(int num_groups)
 {
 	ssize_t size;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
