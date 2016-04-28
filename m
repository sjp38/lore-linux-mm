Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 584686B0005
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 18:07:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so167311154pfy.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 15:07:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f3si18185650pas.21.2016.04.28.15.07.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 15:07:10 -0700 (PDT)
Date: Thu, 28 Apr 2016 15:07:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/zsmalloc: don't fail if can't create debugfs info
Message-Id: <20160428150709.2eef0506d84cd37ac6b61d12@linux-foundation.org>
In-Reply-To: <1461857808-11030-1-git-send-email-ddstreet@ieee.org>
References: <1461857808-11030-1-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Yu Zhao <yuzhao@google.com>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On Thu, 28 Apr 2016 11:36:48 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> Change the return type of zs_pool_stat_create() to void, and
> remove the logic to abort pool creation if the stat debugfs
> dir/file could not be created.
> 
> The debugfs stat file is for debugging/information only, and doesn't
> affect operation of zsmalloc; there is no reason to abort creating
> the pool if the stat file can't be created.  This was seen with
> zswap, which used the same name for all pool creations, which caused
> zsmalloc to fail to create a second pool for zswap if
> CONFIG_ZSMALLOC_STAT was enabled.

Needed a bit of tweaking due to
http://ozlabs.org/~akpm/mmotm/broken-out/zsmalloc-reordering-function-parameter.patch


From: Dan Streetman <ddstreet@ieee.org>
Subject: mm/zsmalloc: don't fail if can't create debugfs info

Change the return type of zs_pool_stat_create() to void, and
remove the logic to abort pool creation if the stat debugfs
dir/file could not be created.

The debugfs stat file is for debugging/information only, and doesn't
affect operation of zsmalloc; there is no reason to abort creating
the pool if the stat file can't be created.  This was seen with
zswap, which used the same name for all pool creations, which caused
zsmalloc to fail to create a second pool for zswap if
CONFIG_ZSMALLOC_STAT was enabled.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Dan Streetman <dan.streetman@canonical.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/zsmalloc.c |   18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff -puN mm/zsmalloc.c~mm-zsmalloc-dont-fail-if-cant-create-debugfs-info mm/zsmalloc.c
--- a/mm/zsmalloc.c~mm-zsmalloc-dont-fail-if-cant-create-debugfs-info
+++ a/mm/zsmalloc.c
@@ -568,17 +568,17 @@ static const struct file_operations zs_s
 	.release        = single_release,
 };
 
-static int zs_pool_stat_create(struct zs_pool *pool, const char *name)
+static void zs_pool_stat_create(struct zs_pool *pool, const char *name)
 {
 	struct dentry *entry;
 
 	if (!zs_stat_root)
-		return -ENODEV;
+		return;
 
 	entry = debugfs_create_dir(name, zs_stat_root);
 	if (!entry) {
 		pr_warn("debugfs dir <%s> creation failed\n", name);
-		return -ENOMEM;
+		return;
 	}
 	pool->stat_dentry = entry;
 
@@ -587,10 +587,8 @@ static int zs_pool_stat_create(struct zs
 	if (!entry) {
 		pr_warn("%s: debugfs file entry <%s> creation failed\n",
 				name, "classes");
-		return -ENOMEM;
+		return;
 	}
-
-	return 0;
 }
 
 static void zs_pool_stat_destroy(struct zs_pool *pool)
@@ -608,9 +606,8 @@ static void __exit zs_stat_exit(void)
 {
 }
 
-static inline int zs_pool_stat_create(struct zs_pool *pool, const char *name)
+static inline void zs_pool_stat_create(struct zs_pool *pool, const char *name)
 {
-	return 0;
 }
 
 static inline void zs_pool_stat_destroy(struct zs_pool *pool)
@@ -618,7 +615,6 @@ static inline void zs_pool_stat_destroy(
 }
 #endif
 
-
 /*
  * For each size class, zspages are divided into different groups
  * depending on how "full" they are. This was done so that we could
@@ -1944,8 +1940,8 @@ struct zs_pool *zs_create_pool(const cha
 		prev_class = class;
 	}
 
-	if (zs_pool_stat_create(pool, name))
-		goto err;
+	/* debug only, don't abort if it fails */
+	zs_pool_stat_create(pool, name);
 
 	/*
 	 * Not critical, we still can use the pool
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
