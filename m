Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id CB37E9003C7
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 09:46:59 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so14813386qkb.2
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 06:46:59 -0700 (PDT)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id 19si5433075qhf.58.2015.08.05.06.46.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 06:46:59 -0700 (PDT)
Received: by qged69 with SMTP id d69so29833183qge.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 06:46:59 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 1/3] zpool: add zpool_has_pool()
Date: Wed,  5 Aug 2015 09:46:41 -0400
Message-Id: <1438782403-29496-2-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

Add zpool_has_pool() function, indicating if the specified type of zpool
is available (i.e. zsmalloc or zbud).  This allows checking if a pool is
available, without actually trying to allocate it, similar to
crypto_has_alg().

This is used by a following patch to zswap that enables the dynamic
runtime creation of zswap zpools.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 include/linux/zpool.h |  2 ++
 mm/zpool.c            | 25 +++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index c924a28..42f8ec9 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -36,6 +36,8 @@ enum zpool_mapmode {
 	ZPOOL_MM_DEFAULT = ZPOOL_MM_RW
 };
 
+bool zpool_has_pool(char *type);
+
 struct zpool *zpool_create_pool(char *type, char *name,
 			gfp_t gfp, const struct zpool_ops *ops);
 
diff --git a/mm/zpool.c b/mm/zpool.c
index 951db32..aafcf8f 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -100,6 +100,31 @@ static void zpool_put_driver(struct zpool_driver *driver)
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
