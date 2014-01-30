Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 076876B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 11:01:51 -0500 (EST)
Received: by mail-la0-f46.google.com with SMTP id b8so2727353lan.33
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 08:01:51 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ya3si3312594lbb.56.2014.01.30.08.01.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jan 2014 08:01:35 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] memcg: fix mutex not unlocked on memcg_create_kmem_cache fail path
Date: Thu, 30 Jan 2014 20:01:33 +0400
Message-ID: <1391097693-31401-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 19d5d4274e22..53385cd4e6f0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3400,7 +3400,7 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
 static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 						  struct kmem_cache *s)
 {
-	struct kmem_cache *new;
+	struct kmem_cache *new = NULL;
 	static char *tmp_name = NULL;
 	static DEFINE_MUTEX(mutex);	/* protects tmp_name */
 
@@ -3416,7 +3416,7 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	if (!tmp_name) {
 		tmp_name = kmalloc(PATH_MAX, GFP_KERNEL);
 		if (!tmp_name)
-			return NULL;
+			goto out;
 	}
 
 	rcu_read_lock();
@@ -3426,12 +3426,11 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 
 	new = kmem_cache_create_memcg(memcg, tmp_name, s->object_size, s->align,
 				      (s->flags & ~SLAB_PANIC), s->ctor, s);
-
 	if (new)
 		new->allocflags |= __GFP_KMEMCG;
 	else
 		new = s;
-
+out:
 	mutex_unlock(&mutex);
 	return new;
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
