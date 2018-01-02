Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5801B6B0299
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 05:03:26 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id n187so34734598pfn.10
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 02:03:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k5sor14994276plt.27.2018.01.02.02.03.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jan 2018 02:03:25 -0800 (PST)
From: Joey Pabalinas <joeypabalinas@gmail.com>
Subject: [PATCH 1/2] mm/zswap: make type and compressor const
Date: Tue,  2 Jan 2018 00:03:19 -1000
Message-Id: <20180102100320.24801-2-joeypabalinas@gmail.com>
In-Reply-To: <20180102100320.24801-1-joeypabalinas@gmail.com>
References: <20180102100320.24801-1-joeypabalinas@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sjenning@redhat.com, ddstreet@ieee.org, linux-kernel@vger.kernel.org, Joey Pabalinas <joeypabalinas@gmail.com>

The characters pointed to by `zswap_compressor`, `type`, and `compressor`
aren't ever modified. Add const to the static variable and both parameters in
`zswap_pool_find_get()`, `zswap_pool_create()`, and `__zswap_param_set()`

Signed-off-by: Joey Pabalinas <joeypabalinas@gmail.com>

 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index d39581a076c3aed1e9..a4f2dfaf9131694265 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -90,7 +90,7 @@ module_param_cb(enabled, &zswap_enabled_param_ops, &zswap_enabled, 0644);
 
 /* Crypto compressor to use */
 #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
-static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
+static const char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
 static int zswap_compressor_param_set(const char *,
 				      const struct kernel_param *);
 static struct kernel_param_ops zswap_compressor_param_ops = {
@@ -475,7 +475,8 @@ static struct zswap_pool *zswap_pool_last_get(void)
 }
 
 /* type and compressor must be null-terminated */
-static struct zswap_pool *zswap_pool_find_get(char *type, char *compressor)
+static struct zswap_pool *zswap_pool_find_get(const char *type,
+					      const char *compressor)
 {
 	struct zswap_pool *pool;
 
@@ -495,7 +496,8 @@ static struct zswap_pool *zswap_pool_find_get(char *type, char *compressor)
 	return NULL;
 }
 
-static struct zswap_pool *zswap_pool_create(char *type, char *compressor)
+static struct zswap_pool *zswap_pool_create(const char *type,
+					    const char *compressor)
 {
 	struct zswap_pool *pool;
 	char name[38]; /* 'zswap' + 32 char (max) num + \0 */
@@ -658,7 +660,7 @@ static void zswap_pool_put(struct zswap_pool *pool)
 
 /* val must be a null-terminated string */
 static int __zswap_param_set(const char *val, const struct kernel_param *kp,
-			     char *type, char *compressor)
+			     const char *type, const char *compressor)
 {
 	struct zswap_pool *pool, *put_pool = NULL;
 	char *s = strstrip((char *)val);
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
