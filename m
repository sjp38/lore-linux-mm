Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id F27516B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 17:10:18 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id x7so60968859qkd.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 14:10:18 -0700 (PDT)
Received: from mail-qg0-x241.google.com (mail-qg0-x241.google.com. [2607:f8b0:400d:c04::241])
        by mx.google.com with ESMTPS id 201si422259qhg.121.2016.04.26.14.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 14:10:18 -0700 (PDT)
Received: by mail-qg0-x241.google.com with SMTP id b14so1788832qge.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 14:10:18 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] mm/zswap: use workqueue to destroy pool
Date: Tue, 26 Apr 2016 17:08:11 -0400
Message-Id: <1461704891-15272-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1461619210-10057-1-git-send-email-ddstreet@ieee.org>
References: <1461619210-10057-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@redhat.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>, Dan Streetman <dan.streetman@canonical.com>

Add a work_struct to struct zswap_pool, and change __zswap_pool_empty
to use the workqueue instead of using call_rcu().

When zswap destroys a pool no longer in use, it uses call_rcu() to
perform the destruction/freeing.  Since that executes in softirq
context, it must not sleep.  However, actually destroying the pool
involves freeing the per-cpu compressors (which requires locking the
cpu_add_remove_lock mutex) and freeing the zpool, for which the
implementation may sleep (e.g. zsmalloc calls kmem_cache_destroy,
which locks the slab_mutex).  So if either mutex is currently taken,
or any other part of the compressor or zpool implementation sleeps, it
will result in a BUG().

It's not easy to reproduce this when changing zswap's params normally.
In testing with a loaded system, this does not fail:

$ cd /sys/module/zswap/parameters
$ echo lz4 > compressor ; echo zsmalloc > zpool

nor does this:

$ while true ; do
> echo lzo > compressor ; echo zbud > zpool
> sleep 1
> echo lz4 > compressor ; echo zsmalloc > zpool
> sleep 1
> done

although it's still possible either of those might fail, depending on
whether anything else besides zswap has locked the mutexes.

However, changing a parameter with no delay immediately causes the
schedule while atomic BUG:

$ while true ; do
> echo lzo > compressor ; echo lz4 > compressor
> done

This is essentially the same as Yu Zhao's proposed patch to zsmalloc,
but moved to zswap, to cover compressor and zpool freeing.

Fixes: f1c54846ee45 ("zswap: dynamic pool creation")
Reported-by: Yu Zhao <yuzhao@google.com>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Dan Streetman <dan.streetman@canonical.com>
---
 mm/zswap.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 91dad80..f207da7 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -117,7 +117,7 @@ struct zswap_pool {
 	struct crypto_comp * __percpu *tfm;
 	struct kref kref;
 	struct list_head list;
-	struct rcu_head rcu_head;
+	struct work_struct work;
 	struct notifier_block notifier;
 	char tfm_name[CRYPTO_MAX_ALG_NAME];
 };
@@ -652,9 +652,11 @@ static int __must_check zswap_pool_get(struct zswap_pool *pool)
 	return kref_get_unless_zero(&pool->kref);
 }
 
-static void __zswap_pool_release(struct rcu_head *head)
+static void __zswap_pool_release(struct work_struct *work)
 {
-	struct zswap_pool *pool = container_of(head, typeof(*pool), rcu_head);
+	struct zswap_pool *pool = container_of(work, typeof(*pool), work);
+
+	synchronize_rcu();
 
 	/* nobody should have been able to get a kref... */
 	WARN_ON(kref_get_unless_zero(&pool->kref));
@@ -674,7 +676,9 @@ static void __zswap_pool_empty(struct kref *kref)
 	WARN_ON(pool == zswap_pool_current());
 
 	list_del_rcu(&pool->list);
-	call_rcu(&pool->rcu_head, __zswap_pool_release);
+
+	INIT_WORK(&pool->work, __zswap_pool_release);
+	schedule_work(&pool->work);
 
 	spin_unlock(&zswap_pools_lock);
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
