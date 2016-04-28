Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2943B6B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 05:16:15 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n83so154053370qkn.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 02:16:15 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id k93si4478144qgf.62.2016.04.28.02.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 02:16:14 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id i7so1882144qkd.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 02:16:14 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] mm/zswap: provide unique zpool name
Date: Thu, 28 Apr 2016 05:13:23 -0400
Message-Id: <1461834803-5565-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <CALZtONArGwmaWNcHJODmY1uXm306NiqeZtRekfCFgZsMz_cngw@mail.gmail.com>
References: <CALZtONArGwmaWNcHJODmY1uXm306NiqeZtRekfCFgZsMz_cngw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@redhat.com>
Cc: Yu Zhao <yuzhao@google.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>, Dan Streetman <dan.streetman@canonical.com>

Instead of using "zswap" as the name for all zpools created, add
an atomic counter and use "zswap%x" with the counter number for each
zpool created, to provide a unique name for each new zpool.

As zsmalloc, one of the zpool implementations, requires/expects a
unique name for each pool created, zswap should provide a unique name.
The zsmalloc pool creation does not fail if a new pool with a
conflicting name is created, unless CONFIG_ZSMALLOC_STAT is enabled;
in that case, zsmalloc pool creation fails with -ENOMEM.  Then zswap
will be unable to change its compressor parameter if its zpool is
zsmalloc; it also will be unable to change its zpool parameter back
to zsmalloc, if it has any existing old zpool using zsmalloc with
page(s) in it.  Attempts to change the parameters will result in
failure to create the zpool.  This changes zswap to provide a
unique name for each zpool creation.

Fixes: f1c54846ee45 ("zswap: dynamic pool creation")
Reported-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Dan Streetman <dan.streetman@canonical.com>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zswap.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index f207da7..275b22c 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -170,6 +170,8 @@ static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
 static LIST_HEAD(zswap_pools);
 /* protects zswap_pools list modification */
 static DEFINE_SPINLOCK(zswap_pools_lock);
+/* pool counter to provide unique names to zpool */
+static atomic_t zswap_pools_count = ATOMIC_INIT(0);
 
 /* used by param callback function */
 static bool zswap_init_started;
@@ -565,6 +567,7 @@ static struct zswap_pool *zswap_pool_find_get(char *type, char *compressor)
 static struct zswap_pool *zswap_pool_create(char *type, char *compressor)
 {
 	struct zswap_pool *pool;
+	char name[38]; /* 'zswap' + 32 char (max) num + \0 */
 	gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM;
 
 	pool = kzalloc(sizeof(*pool), GFP_KERNEL);
@@ -573,7 +576,10 @@ static struct zswap_pool *zswap_pool_create(char *type, char *compressor)
 		return NULL;
 	}
 
-	pool->zpool = zpool_create_pool(type, "zswap", gfp, &zswap_zpool_ops);
+	/* unique name for each pool specifically required by zsmalloc */
+	snprintf(name, 38, "zswap%x", atomic_inc_return(&zswap_pools_count));
+
+	pool->zpool = zpool_create_pool(type, name, gfp, &zswap_zpool_ops);
 	if (!pool->zpool) {
 		pr_err("%s zpool not available\n", type);
 		goto error;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
