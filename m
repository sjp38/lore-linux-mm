Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE376B0069
	for <linux-mm@kvack.org>; Sun, 16 Nov 2014 22:14:39 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y13so5195772pdi.37
        for <linux-mm@kvack.org>; Sun, 16 Nov 2014 19:14:38 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id or5si22500019pbb.41.2014.11.16.19.14.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Nov 2014 19:14:37 -0800 (PST)
Message-ID: <546967BA.9000101@huawei.com>
Date: Mon, 17 Nov 2014 11:12:58 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: remove the useless gfp in __memcg_kmem_get_cache
References: <1416193909-25163-1-git-send-email-zhenzhang.zhang@huawei.com>
In-Reply-To: <1416193909-25163-1-git-send-email-zhenzhang.zhang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, mhocko@suse.cz, vdavydov@parallels.com
Cc: wangnan0@huawei.com, Linux MM <linux-mm@kvack.org>

The gfp was passed in but never used in this function.

Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
---
 include/linux/memcontrol.h | 4 ++--
 mm/memcontrol.c            | 3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6b75640..9481ee9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -419,7 +419,7 @@ int memcg_cache_id(struct mem_cgroup *memcg);
 void memcg_update_array_size(int num_groups);

 struct kmem_cache *
-__memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
+__memcg_kmem_get_cache(struct kmem_cache *cachep);

 int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order);
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);
@@ -514,7 +514,7 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 	if (unlikely(fatal_signal_pending(current)))
 		return cachep;

-	return __memcg_kmem_get_cache(cachep, gfp);
+	return __memcg_kmem_get_cache(cachep);
 }
 #else
 #define for_each_memcg_cache_index(_idx)	\
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d6ac0e3..1186e4d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3152,8 +3152,7 @@ void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
  * Can't be called in interrupt context or from kernel threads.
  * This function needs to be called with rcu_read_lock() held.
  */
-struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
-					  gfp_t gfp)
+struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep)
 {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *memcg_cachep;
-- 
1.8.1.4


.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
