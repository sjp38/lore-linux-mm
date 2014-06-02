Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id C41E36B0085
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 18:20:35 -0400 (EDT)
Received: by mail-yk0-f181.google.com with SMTP id 131so4196093ykp.12
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 15:20:35 -0700 (PDT)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id m36si25963357yhi.82.2014.06.02.15.20.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 15:20:35 -0700 (PDT)
Received: by mail-yk0-f176.google.com with SMTP id q9so4211776ykb.35
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 15:20:35 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCHv2 6/6] mm/zpool: prevent zbud/zsmalloc from unloading when used
Date: Mon,  2 Jun 2014 18:19:46 -0400
Message-Id: <1401747586-11861-7-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1401747586-11861-1-git-send-email-ddstreet@ieee.org>
References: <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
 <1401747586-11861-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Add try_module_get() to zpool_create_pool(), and module_put() to
zpool_destroy_pool().  Without module usage counting, the driver module(s)
could be unloaded while their pool(s) were active, resulting in an oops
when zpool tried to access them.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Weijie Yang <weijie.yang@samsung.com>
---

Changes since v1 : https://lkml.org/lkml/2014/5/24/134
  -add owner field to struct zpool_driver, pointing to driver module
  -move module usage counting from zbud/zsmalloc into zpool

 include/linux/zpool.h |  5 +++++
 mm/zbud.c             |  1 +
 mm/zpool.c            | 22 +++++++++++++++-------
 mm/zsmalloc.c         |  1 +
 4 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index a528f7c..49bd02b 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -176,6 +176,7 @@ u64 zpool_get_total_size(struct zpool *pool);
  */
 struct zpool_driver {
 	char *type;
+	struct module *owner;
 	struct list_head list;
 
 	void *(*create)(gfp_t gfp, struct zpool_ops *ops);
@@ -203,6 +204,10 @@ void zpool_register_driver(struct zpool_driver *driver);
 /**
  * zpool_unregister_driver() - unregister a zpool implementation.
  * @driver:	driver to unregister.
+ *
+ * Module usage counting is used to prevent using a driver
+ * while/after unloading.  Please only call unregister from
+ * module exit function.
  */
 void zpool_unregister_driver(struct zpool_driver *driver);
 
diff --git a/mm/zbud.c b/mm/zbud.c
index 645379e..440bab7 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -184,6 +184,7 @@ u64 zbud_zpool_total_size(void *pool)
 
 static struct zpool_driver zbud_zpool_driver = {
 	.type =		"zbud",
+	.owner =	THIS_MODULE,
 	.create =	zbud_zpool_create,
 	.destroy =	zbud_zpool_destroy,
 	.malloc =	zbud_zpool_malloc,
diff --git a/mm/zpool.c b/mm/zpool.c
index 578c379..119f340 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -72,15 +72,24 @@ static struct zpool_driver *zpool_get_driver(char *type)
 {
 	struct zpool_driver *driver;
 
-	assert_spin_locked(&drivers_lock);
+	spin_lock(&drivers_lock);
 	list_for_each_entry(driver, &drivers_head, list) {
-		if (!strcmp(driver->type, type))
-			return driver;
+		if (!strcmp(driver->type, type)) {
+			bool got = try_module_get(driver->owner);
+			spin_unlock(&drivers_lock);
+			return got ? driver : NULL;
+		}
 	}
 
+	spin_unlock(&drivers_lock);
 	return NULL;
 }
 
+static void zpool_put_driver(struct zpool_driver *driver)
+{
+	module_put(driver->owner);
+}
+
 struct zpool *zpool_create_pool(char *type, gfp_t flags,
 			struct zpool_ops *ops)
 {
@@ -89,15 +98,11 @@ struct zpool *zpool_create_pool(char *type, gfp_t flags,
 
 	pr_info("creating pool type %s\n", type);
 
-	spin_lock(&drivers_lock);
 	driver = zpool_get_driver(type);
-	spin_unlock(&drivers_lock);
 
 	if (!driver) {
 		request_module(type);
-		spin_lock(&drivers_lock);
 		driver = zpool_get_driver(type);
-		spin_unlock(&drivers_lock);
 	}
 
 	if (!driver) {
@@ -108,6 +113,7 @@ struct zpool *zpool_create_pool(char *type, gfp_t flags,
 	zpool = kmalloc(sizeof(*zpool), GFP_KERNEL);
 	if (!zpool) {
 		pr_err("couldn't create zpool - out of memory\n");
+		zpool_put_driver(driver);
 		return NULL;
 	}
 
@@ -118,6 +124,7 @@ struct zpool *zpool_create_pool(char *type, gfp_t flags,
 
 	if (!zpool->pool) {
 		pr_err("couldn't create %s pool\n", type);
+		zpool_put_driver(driver);
 		kfree(zpool);
 		return NULL;
 	}
@@ -139,6 +146,7 @@ void zpool_destroy_pool(struct zpool *zpool)
 	list_del(&zpool->list);
 	spin_unlock(&pools_lock);
 	zpool->driver->destroy(zpool->pool);
+	zpool_put_driver(zpool->driver);
 	kfree(zpool);
 }
 
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index feba644..ae3a28f 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -303,6 +303,7 @@ u64 zs_zpool_total_size(void *pool)
 
 static struct zpool_driver zs_zpool_driver = {
 	.type =		"zsmalloc",
+	.owner =	THIS_MODULE,
 	.create =	zs_zpool_create,
 	.destroy =	zs_zpool_destroy,
 	.malloc =	zs_zpool_malloc,
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
