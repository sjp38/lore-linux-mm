Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8083B6B009D
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:12:30 -0400 (EDT)
Received: by igbyr2 with SMTP id yr2so16535899igb.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:12:30 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id l10si1772968igx.31.2015.05.29.08.12.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:12:30 -0700 (PDT)
Received: by igbhj9 with SMTP id hj9so17093302igb.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:12:29 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] zpool: add zpool_has_pool()
Date: Fri, 29 May 2015 11:12:18 -0400
Message-Id: <1432912338-16775-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>

Add zpool_has_pool() function, indicating if the specified type of zpool
is available (i.e. zsmalloc or zbud).  This allows checking if a pool is
available, without actually trying to allocate it, similar to
crypto_has_alg().

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 include/linux/zpool.h |  2 ++
 mm/zpool.c            | 25 +++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index 56529b3..31b79e2 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -36,6 +36,8 @@ enum zpool_mapmode {
 	ZPOOL_MM_DEFAULT = ZPOOL_MM_RW
 };
 
+bool zpool_has_pool(char *type);
+
 struct zpool *zpool_create_pool(char *type, char *name,
 			gfp_t gfp, struct zpool_ops *ops);
 
diff --git a/mm/zpool.c b/mm/zpool.c
index 884659d..bff40ce 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -127,6 +127,31 @@ static void zpool_put_driver(struct zpool_driver *driver)
 }
 
 /**
+ * zpool_has_pool() - Check if the pool driver is available
+ * @type	The type of the zpool to check (e.g. zbud, zsmalloc)
+ *
+ * This checks if the @type pool driver is available.
+ *
+ * Returns: true if @type pool is available, false if not
+ */
+bool zpool_has_pool(char *type)
+{
+	struct zpool_driver *driver = zpool_get_driver(type);
+
+	if (!driver) {
+		request_module("zpool-%s", type);
+		driver = zpool_get_driver(type);
+	}
+
+	if (!driver)
+		return false;
+
+	zpool_put_driver(driver);
+	return true;
+}
+EXPORT_SYMBOL(zpool_has_pool);
+
+/**
  * zpool_create_pool() - Create a new zpool
  * @type	The type of the zpool to create (e.g. zbud, zsmalloc)
  * @name	The name of the zpool (e.g. zram0, zswap)
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
