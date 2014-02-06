Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id C453A6B0037
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:08:16 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id u14so2065299lbd.1
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:08:16 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id mq2si821881lbb.32.2014.02.06.07.58.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Feb 2014 07:58:47 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC] slub: do not drop slab_mutex for sysfs_slab_{add,remove}
Date: Thu, 6 Feb 2014 19:58:13 +0400
Message-ID: <1391702294-27289-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

When creating/destroying a kmem cache, we do a lot of work holding the
slab_mutex, but we drop it for sysfs_slab_{add,remove} for some reason.
Since __kmem_cache_create and __kmem_cache_shutdown are extremely rare,
I propose to simplify locking by calling sysfs_slab_{add,remove} w/o
dropping the slab_mutex.

I'm interested in this, because when creating a memcg cache I need the
slab_mutex locked until the cache is fully initialized and registered to
the memcg subsys (memcg_cache_register() is called). If this is not
true, I get races when several threads try to create a cache for the
same memcg.  An alternative fix for my problem would be moving
sysfs_slab_{add,remove} after the slab_mutex is dropped, but I'd like to
try the shortest path first.

Any objections to this?

Thanks.
---
 mm/slub.c |   15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 3d3a8a7a0f8c..6f4393892d2d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3229,19 +3229,8 @@ int __kmem_cache_shutdown(struct kmem_cache *s)
 {
 	int rc = kmem_cache_close(s);
 
-	if (!rc) {
-		/*
-		 * We do the same lock strategy around sysfs_slab_add, see
-		 * __kmem_cache_create. Because this is pretty much the last
-		 * operation we do and the lock will be released shortly after
-		 * that in slab_common.c, we could just move sysfs_slab_remove
-		 * to a later point in common code. We should do that when we
-		 * have a common sysfs framework for all allocators.
-		 */
-		mutex_unlock(&slab_mutex);
+	if (!rc)
 		sysfs_slab_remove(s);
-		mutex_lock(&slab_mutex);
-	}
 
 	return rc;
 }
@@ -3772,9 +3761,7 @@ int __kmem_cache_create(struct kmem_cache *s, unsigned long flags)
 		return 0;
 
 	memcg_propagate_slab_attrs(s);
-	mutex_unlock(&slab_mutex);
 	err = sysfs_slab_add(s);
-	mutex_lock(&slab_mutex);
 
 	if (err)
 		kmem_cache_close(s);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
