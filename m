Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 36C9E6B0005
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 17:22:38 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n83so3529279qkn.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 14:22:38 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id b39si11624362qkh.202.2016.04.25.14.22.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 14:22:37 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id q184so11411792qkf.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 14:22:36 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] mm/zpool: use workqueue for zpool_destroy
Date: Mon, 25 Apr 2016 17:20:10 -0400
Message-Id: <1461619210-10057-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <CALZtONCDqBjL9TFmUEwuHaNU3n55k0VwbYWqW-9dODuNWyzkLQ@mail.gmail.com>
References: <CALZtONCDqBjL9TFmUEwuHaNU3n55k0VwbYWqW-9dODuNWyzkLQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@redhat.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>, Dan Streetman <dan.streetman@canonical.com>

Add a work_struct to struct zpool, and change zpool_destroy_pool to
defer calling the pool implementation destroy.

The zsmalloc pool destroy function, which is one of the zpool
implementations, may sleep during destruction of the pool.  However
zswap, which uses zpool, may call zpool_destroy_pool from atomic
context.  So we need to defer the call to the zpool implementation
to destroy the pool.

This is essentially the same as Yu Zhao's proposed patch to zsmalloc,
but moved to zpool.

Reported-by: Yu Zhao <yuzhao@google.com>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Dan Streetman <dan.streetman@canonical.com>
---
 mm/zpool.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/mm/zpool.c b/mm/zpool.c
index fd3ff71..ea12069 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -23,6 +23,7 @@ struct zpool {
 	const struct zpool_ops *ops;
 
 	struct list_head list;
+	struct work_struct work;
 };
 
 static LIST_HEAD(drivers_head);
@@ -197,6 +198,15 @@ struct zpool *zpool_create_pool(const char *type, const char *name, gfp_t gfp,
 	return zpool;
 }
 
+static void zpool_destroy_pool_work(struct work_struct *work)
+{
+	struct zpool *zpool = container_of(work, struct zpool, work);
+
+	zpool->driver->destroy(zpool->pool);
+	zpool_put_driver(zpool->driver);
+	kfree(zpool);
+}
+
 /**
  * zpool_destroy_pool() - Destroy a zpool
  * @pool	The zpool to destroy.
@@ -204,7 +214,8 @@ struct zpool *zpool_create_pool(const char *type, const char *name, gfp_t gfp,
  * Implementations must guarantee this to be thread-safe,
  * however only when destroying different pools.  The same
  * pool should only be destroyed once, and should not be used
- * after it is destroyed.
+ * after it is destroyed.  This defers calling the implementation
+ * to a workqueue, so the implementation may sleep.
  *
  * This destroys an existing zpool.  The zpool should not be in use.
  */
@@ -215,9 +226,8 @@ void zpool_destroy_pool(struct zpool *zpool)
 	spin_lock(&pools_lock);
 	list_del(&zpool->list);
 	spin_unlock(&pools_lock);
-	zpool->driver->destroy(zpool->pool);
-	zpool_put_driver(zpool->driver);
-	kfree(zpool);
+	INIT_WORK(&zpool->work, zpool_destroy_pool_work);
+	schedule_work(&zpool->work);
 }
 
 /**
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
