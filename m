Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D53B6B0253
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 08:44:54 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id s41so5026344wrc.22
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 05:44:54 -0800 (PST)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id i6si4905164wrh.313.2017.12.15.05.44.53
        for <linux-mm@kvack.org>;
        Fri, 15 Dec 2017 05:44:53 -0800 (PST)
Date: Fri, 15 Dec 2017 14:44:52 +0100
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH] mm/slab: Remove redundant assignments for slab_state
Message-ID: <20171215134452.GA1920@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rientjes@google.com, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com

slab_state is being set to "UP" in create_kmalloc_caches(), and later on
we set it again in kmem_cache_init_late(), but slab_state does not change
in the meantime.
Remove the redundant assignment from kmem_cache_init_late().

And unless I overlooked anything, the same goes for "slab_state = FULL".
slab_state is set to "FULL" in kmem_cache_init_late(), but it is later being set
again in cpucache_init(), which gets called from do_initcall_level().
So remove the assignment from cpucache_init() as well.

Signed-off-by: Oscar Salvador <osalvador@techadventures.net>
---
 mm/slab.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index a8310d75..d2ac2df 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1317,8 +1317,6 @@ void __init kmem_cache_init_late(void)
 {
 	struct kmem_cache *cachep;
 
-	slab_state = UP;
-
 	/* 6) resize the head arrays to their final sizes */
 	mutex_lock(&slab_mutex);
 	list_for_each_entry(cachep, &slab_caches, list)
@@ -1354,8 +1352,6 @@ static int __init cpucache_init(void)
 				slab_online_cpu, slab_offline_cpu);
 	WARN_ON(ret < 0);
 
-	/* Done! */
-	slab_state = FULL;
 	return 0;
 }
 __initcall(cpucache_init);
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
