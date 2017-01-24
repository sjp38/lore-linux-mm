Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 17AD26B027A
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 15:03:22 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id x49so165322197qtc.7
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 12:03:22 -0800 (PST)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id x65si8087939qke.229.2017.01.24.12.03.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 12:03:21 -0800 (PST)
Received: by mail-qt0-x241.google.com with SMTP id l7so27822723qtd.3
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 12:03:20 -0800 (PST)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 1/3] zswap: disable changing params if init fails
Date: Tue, 24 Jan 2017 15:02:57 -0500
Message-Id: <20170124200259.16191-2-ddstreet@ieee.org>
In-Reply-To: <20170124200259.16191-1-ddstreet@ieee.org>
References: <20170124200259.16191-1-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Dan Streetman <dan.streetman@canonical.com>

Add zswap_init_failed bool that prevents changing any of the module
params, if init_zswap() fails, and set zswap_enabled to false.  Change
'enabled' param to a callback, and check zswap_init_failed before
allowing any change to 'enabled', 'zpool', or 'compressor' params.

Any driver that is built-in to the kernel will not be unloaded if its
init function returns error, and its module params remain accessible for
users to change via sysfs.  Since zswap uses param callbacks, which
assume that zswap has been initialized, changing the zswap params after
a failed initialization will result in WARNING due to the param callbacks
expecting a pool to already exist.  This prevents that by immediately
exiting any of the param callbacks if initialization failed.

This was reported here:
https://marc.info/?l=linux-mm&m=147004228125528&w=4

And fixes this WARNING:
[  429.723476] WARNING: CPU: 0 PID: 5140 at mm/zswap.c:503
__zswap_pool_current+0x56/0x60

Fixes: 90b0fc26d5db ("zswap: change zpool/compressor at runtime")
Cc: stable@vger.kernel.org
Signed-off-by: Dan Streetman <dan.streetman@canonical.com>
---
 mm/zswap.c | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 067a0d6..cabf09e 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -78,7 +78,13 @@ static u64 zswap_duplicate_entry;
 
 /* Enable/disable zswap (disabled by default) */
 static bool zswap_enabled;
-module_param_named(enabled, zswap_enabled, bool, 0644);
+static int zswap_enabled_param_set(const char *,
+				   const struct kernel_param *);
+static struct kernel_param_ops zswap_enabled_param_ops = {
+	.set =		zswap_enabled_param_set,
+	.get =		param_get_bool,
+};
+module_param_cb(enabled, &zswap_enabled_param_ops, &zswap_enabled, 0644);
 
 /* Crypto compressor to use */
 #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
@@ -176,6 +182,9 @@ static atomic_t zswap_pools_count = ATOMIC_INIT(0);
 /* used by param callback function */
 static bool zswap_init_started;
 
+/* fatal error during init */
+static bool zswap_init_failed;
+
 /*********************************
 * helpers and fwd declarations
 **********************************/
@@ -624,6 +633,11 @@ static int __zswap_param_set(const char *val, const struct kernel_param *kp,
 	char *s = strstrip((char *)val);
 	int ret;
 
+	if (zswap_init_failed) {
+		pr_err("can't set param, initialization failed\n");
+		return -ENODEV;
+	}
+
 	/* no change required */
 	if (!strcmp(s, *(char **)kp->arg))
 		return 0;
@@ -703,6 +717,17 @@ static int zswap_zpool_param_set(const char *val,
 	return __zswap_param_set(val, kp, NULL, zswap_compressor);
 }
 
+static int zswap_enabled_param_set(const char *val,
+				   const struct kernel_param *kp)
+{
+	if (zswap_init_failed) {
+		pr_err("can't enable, initialization failed\n");
+		return -ENODEV;
+	}
+
+	return param_set_bool(val, kp);
+}
+
 /*********************************
 * writeback code
 **********************************/
@@ -1201,6 +1226,9 @@ static int __init init_zswap(void)
 dstmem_fail:
 	zswap_entry_cache_destroy();
 cache_fail:
+	/* if built-in, we aren't unloaded on failure; don't allow use */
+	zswap_init_failed = true;
+	zswap_enabled = false;
 	return -ENOMEM;
 }
 /* must be late so crypto has time to come up */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
