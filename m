Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6AAC46B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 05:43:03 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id u10so48849lbd.8
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 02:43:02 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id dr3si38143405lbc.33.2014.06.24.02.43.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jun 2014 02:43:01 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] slub: kmem_cache_shrink: check if partial list is empty under list_lock
Date: Tue, 24 Jun 2014 13:42:42 +0400
Message-ID: <1403602962-18946-1-git-send-email-vdavydov@parallels.com>
In-Reply-To: <20140624075011.GD4836@js1304-P5Q-DELUXE>
References: <20140624075011.GD4836@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: iamjoonsoo.kim@lge.com, cl@linux.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

SLUB's implementation of kmem_cache_shrink skips nodes that have
nr_partial=0, because they surely don't have any empty slabs to free.
This check is done w/o holding any locks, therefore it can race with
concurrent kfree adding an empty slab to a partial list. As a result, a
just shrinked cache can have empty slabs.

This is unacceptable for kmemcg, which needs to be sure that there will
be no empty slabs on dead memcg caches after kmem_cache_shrink was
called, because otherwise we may leak a dead cache.

Let's fix this race by checking if node partial list is empty under
node->list_lock. Since the nr_partial!=0 branch of kmem_cache_shrink
does nothing if the list is empty, we can simply remove the nr_partial=0
check.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slub.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 67da14d9ec70..891ac6cd78cc 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3397,9 +3397,6 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 
 	flush_all(s);
 	for_each_kmem_cache_node(s, node, n) {
-		if (!n->nr_partial)
-			continue;
-
 		for (i = 0; i < objects; i++)
 			INIT_LIST_HEAD(slabs_by_inuse + i);
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
