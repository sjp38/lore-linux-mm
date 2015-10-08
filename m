Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 410566B0256
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 12:03:07 -0400 (EDT)
Received: by lbbwt4 with SMTP id wt4so52441433lbb.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 09:03:06 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 98si1834362lfx.14.2015.10.08.09.03.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 09:03:05 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 3/3] slab_common: do not warn that cache is busy on destroy more than once
Date: Thu, 8 Oct 2015 19:02:41 +0300
Message-ID: <23a47be2e9090ca8044865022373b174d5551ffa.1444319304.git.vdavydov@virtuozzo.com>
In-Reply-To: <6a18aab2f1c3088377d7fd2207b4cc1a1a743468.1444319304.git.vdavydov@virtuozzo.com>
References: <6a18aab2f1c3088377d7fd2207b4cc1a1a743468.1444319304.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, when kmem_cache_destroy is called for a global cache, we
print a warning for each per memcg cache attached to it that has active
objects (see shutdown_cache). This is redundant, because it gives no new
information and only clutters the log. If a cache being destroyed has
active objects, there must be a memory leak in the module that created
the cache, and it does not matter if the cache was used by users in
memory cgroups or not.

This patch moves the warning from shutdown_cache, which is called for
shutting down both global and per memcg caches, to kmem_cache_destroy,
so that the warning is only printed once if there are objects left in
the cache being destroyed.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/slab_common.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index ab1f20e303e4..fba78e4a6643 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -451,12 +451,8 @@ EXPORT_SYMBOL(kmem_cache_create);
 static int shutdown_cache(struct kmem_cache *s,
 		struct list_head *release, bool *need_rcu_barrier)
 {
-	if (__kmem_cache_shutdown(s) != 0) {
-		printk(KERN_ERR "kmem_cache_destroy %s: "
-		       "Slab cache still has objects\n", s->name);
-		dump_stack();
+	if (__kmem_cache_shutdown(s) != 0)
 		return -EBUSY;
-	}
 
 	if (s->flags & SLAB_DESTROY_BY_RCU)
 		*need_rcu_barrier = true;
@@ -722,8 +718,13 @@ void kmem_cache_destroy(struct kmem_cache *s)
 
 	err = shutdown_memcg_caches(s, &release, &need_rcu_barrier);
 	if (!err)
-		shutdown_cache(s, &release, &need_rcu_barrier);
+		err = shutdown_cache(s, &release, &need_rcu_barrier);
 
+	if (err) {
+		pr_err("kmem_cache_destroy %s: "
+		       "Slab cache still has objects\n", s->name);
+		dump_stack();
+	}
 out_unlock:
 	mutex_unlock(&slab_mutex);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
