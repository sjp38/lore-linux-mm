Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2226B0069
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 02:20:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u84so19875173pfj.1
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 23:20:59 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id l7si11198153pan.265.2016.10.05.23.20.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Oct 2016 23:20:58 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id 190so613817pfv.1
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 23:20:58 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH] mm/slab: fix kmemcg cache creation delayed issue
Date: Thu,  6 Oct 2016 15:20:55 +0900
Message-Id: <1475734855-4837-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Doug Smythies <dsmythies@telus.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is a bug report that SLAB makes extreme load average due to
over 2000 kworker thread.

https://bugzilla.kernel.org/show_bug.cgi?id=172981

This issue is caused by kmemcg feature that try to create new set of
kmem_caches for each memcg. Recently, kmem_cache creation is slowed by
synchronize_sched() and futher kmem_cache creation is also delayed
since kmem_cache creation is synchronized by a global slab_mutex lock.
So, the number of kworker that try to create kmem_cache increases quitely.
synchronize_sched() is for lockless access to node's shared array but
it's not needed when a new kmem_cache is created. So, this patch
rules out that case.

Fixes: 801faf0db894 ("mm/slab: lockless decision to grow cache")
Cc: stable@vger.kernel.org
Reported-by: Doug Smythies <dsmythies@telus.net>
Tested-by: Doug Smythies <dsmythies@telus.net>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 6508b4d..3c83c29 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -961,7 +961,7 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
 	 * guaranteed to be valid until irq is re-enabled, because it will be
 	 * freed after synchronize_sched().
 	 */
-	if (force_change)
+	if (old_shared && force_change)
 		synchronize_sched();
 
 fail:
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
