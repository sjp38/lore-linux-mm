Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9E6E831ED
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:42:43 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id u48so11183742wrc.0
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:42:43 -0800 (PST)
Received: from mail-wr0-x229.google.com (mail-wr0-x229.google.com. [2a00:1450:400c:c0c::229])
        by mx.google.com with ESMTPS id m75si466292wmi.142.2017.03.08.07.42.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 07:42:42 -0800 (PST)
Received: by mail-wr0-x229.google.com with SMTP id u48so26162097wrc.0
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:42:42 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] kasan: resched in quarantine_remove_cache()
Date: Wed,  8 Mar 2017 16:42:39 +0100
Message-Id: <20170308154239.25440-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, Greg Thelen <gthelen@google.com>

We see reported stalls/lockups in quarantine_remove_cache() on machines
with large amounts of RAM. quarantine_remove_cache() needs to scan whole
quarantine in order to take out all objects belonging to the cache.
Quarantine is currently 1/32-th of RAM, e.g. on a machine with 256GB
of memory that will be 8GB. Moreover quarantine scanning is a walk
over uncached linked list, which is slow.

Add cond_resched() after scanning of each non-empty batch of objects.
Batches are specifically kept of reasonable size for quarantine_put().
On a machine with 256GB of RAM we should have ~512 non-empty batches,
each with 16MB of objects.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev@googlegroups.com
Cc: linux-mm@kvack.org
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Greg Thelen <gthelen@google.com>
---
 mm/kasan/quarantine.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 075422c3cee3..3021d2976dd6 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -311,8 +311,15 @@ void quarantine_remove_cache(struct kmem_cache *cache)
 	on_each_cpu(per_cpu_remove_cache, cache, 1);
 
 	spin_lock_irqsave(&quarantine_lock, flags);
-	for (i = 0; i < QUARANTINE_BATCHES; i++)
+	for (i = 0; i < QUARANTINE_BATCHES; i++) {
+		if (qlist_empty(&global_quarantine[i]))
+			continue;
 		qlist_move_cache(&global_quarantine[i], &to_free, cache);
+		/* Scanning whole quarantine can take a while. */
+		spin_unlock_irqrestore(&quarantine_lock, flags);
+		cond_resched();
+		spin_lock_irqsave(&quarantine_lock, flags);
+	}
 	spin_unlock_irqrestore(&quarantine_lock, flags);
 
 	qlist_free_all(&to_free, cache);
-- 
2.12.0.246.ga2ecc84866-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
