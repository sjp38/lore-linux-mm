Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 3C6F06B0010
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 15:23:28 -0500 (EST)
Received: by mail-ve0-f170.google.com with SMTP id 14so2666273vea.1
        for <linux-mm@kvack.org>; Fri, 01 Feb 2013 12:23:27 -0800 (PST)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 06/15] staging: zcache: enable zcache to be built/loaded as a module
Date: Fri,  1 Feb 2013 15:22:55 -0500
Message-Id: <1359750184-23408-7-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
References: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Allow zcache to be built/loaded as a module.  Note runtime dependency
disallows loading if cleancache/frontswap lazy initialization patches
are not present.  Zsmalloc support has not yet been merged into zcache
but, once merged, could now easily be selected via a module_param.

If built-in (not built as a module), the original mechanism of enabling via
a kernel boot parameter is retained, but this should be considered deprecated.

Note that module unload is explicitly not yet supported.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
[v1: Rebased with different order of patches]
[v2: Removed [CLEANCACHE|FRONTSWAP]_HAS_LAZY_INIT ifdef]
[v3: Rebased on top of ramster->zcache move]
[v4: Redid the Makefile]
[v5: s/ZCACHE2/ZCACHE/]
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/zcache/Kconfig       |  6 ++---
 drivers/staging/zcache/Makefile      | 11 ++++-----
 drivers/staging/zcache/tmem.c        |  6 ++++-
 drivers/staging/zcache/tmem.h        |  8 +++----
 drivers/staging/zcache/zcache-main.c | 45 +++++++++++++++++++++++++++++++++---
 drivers/staging/zcache/zcache.h      |  2 +-
 6 files changed, 60 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
index c1dbd04..88e3c59 100644
--- a/drivers/staging/zcache/Kconfig
+++ b/drivers/staging/zcache/Kconfig
@@ -1,5 +1,5 @@
 config ZCACHE
-	bool "Dynamic compression of swap pages and clean pagecache pages"
+	tristate "Dynamic compression of swap pages and clean pagecache pages"
 	depends on CRYPTO=y && SWAP=y && CLEANCACHE && FRONTSWAP
 	select CRYPTO_LZO
 	default n
@@ -11,8 +11,8 @@ config ZCACHE
 	  providing a noticeable reduction in disk I/O.
 
 config RAMSTER
-	bool "Cross-machine RAM capacity sharing, aka peer-to-peer tmem"
-	depends on CONFIGFS_FS=y && SYSFS=y && !HIGHMEM && ZCACHE=y
+	tristate "Cross-machine RAM capacity sharing, aka peer-to-peer tmem"
+	depends on CONFIGFS_FS=y && SYSFS=y && !HIGHMEM && ZCACHE
 	depends on NET
 	# must ensure struct page is 8-byte aligned
 	select HAVE_ALIGNED_STRUCT_PAGE if !64_BIT
diff --git a/drivers/staging/zcache/Makefile b/drivers/staging/zcache/Makefile
index 4711049..98c4e32 100644
--- a/drivers/staging/zcache/Makefile
+++ b/drivers/staging/zcache/Makefile
@@ -1,6 +1,5 @@
-zcache-y	:=		zcache-main.o tmem.o zbud.o
-zcache-$(CONFIG_RAMSTER)	+=	ramster/ramster.o ramster/r2net.o
-zcache-$(CONFIG_RAMSTER)	+=	ramster/nodemanager.o ramster/tcp.o
-zcache-$(CONFIG_RAMSTER)	+=	ramster/heartbeat.o ramster/masklog.o
-
-obj-$(CONFIG_ZCACHE)	+=	zcache.o
+obj-$(CONFIG_ZCACHE)	+= zcache.o
+zcache-y		:=	zcache-main.o tmem.o zbud.o
+zcache-$(CONFIG_RAMSTER)+=	ramster/ramster.o ramster/r2net.o
+zcache-$(CONFIG_RAMSTER)+=	ramster/nodemanager.o ramster/tcp.o
+zcache-$(CONFIG_RAMSTER)+=	ramster/heartbeat.o ramster/masklog.o
diff --git a/drivers/staging/zcache/tmem.c b/drivers/staging/zcache/tmem.c
index a2b7e03..d7e51e4 100644
--- a/drivers/staging/zcache/tmem.c
+++ b/drivers/staging/zcache/tmem.c
@@ -35,7 +35,8 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/atomic.h>
-#ifdef CONFIG_RAMSTER
+#include <linux/export.h>
+#if defined(CONFIG_RAMSTER) || defined(CONFIG_RAMSTER_MODULE)
 #include <linux/delay.h>
 #endif
 
@@ -641,6 +642,7 @@ void *tmem_localify_get_pampd(struct tmem_pool *pool, struct tmem_oid *oidp,
 	/* note, hashbucket remains locked */
 	return pampd;
 }
+EXPORT_SYMBOL_GPL(tmem_localify_get_pampd);
 
 void tmem_localify_finish(struct tmem_obj *obj, uint32_t index,
 			  void *pampd, void *saved_hb, bool delete)
@@ -658,6 +660,7 @@ void tmem_localify_finish(struct tmem_obj *obj, uint32_t index,
 	}
 	spin_unlock(&hb->lock);
 }
+EXPORT_SYMBOL_GPL(tmem_localify_finish);
 
 /*
  * For ramster only.  Helper function to support asynchronous tmem_get.
@@ -719,6 +722,7 @@ out:
 	spin_unlock(&hb->lock);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(tmem_replace);
 #endif
 
 /*
diff --git a/drivers/staging/zcache/tmem.h b/drivers/staging/zcache/tmem.h
index adbe5a8..d128ce2 100644
--- a/drivers/staging/zcache/tmem.h
+++ b/drivers/staging/zcache/tmem.h
@@ -126,7 +126,7 @@ static inline unsigned tmem_oid_hash(struct tmem_oid *oidp)
 				TMEM_HASH_BUCKET_BITS);
 }
 
-#ifdef CONFIG_RAMSTER
+#if defined(CONFIG_RAMSTER) || defined(CONFIG_RAMSTER_MODULE)
 struct tmem_xhandle {
 	uint8_t client_id;
 	uint8_t xh_data_cksum;
@@ -171,7 +171,7 @@ struct tmem_obj {
 	unsigned int objnode_tree_height;
 	unsigned long objnode_count;
 	long pampd_count;
-#ifdef CONFIG_RAMSTER
+#if defined(CONFIG_RAMSTER) || defined(CONFIG_RAMSTER_MODULE)
 	/*
 	 * for current design of ramster, all pages belonging to
 	 * an object reside on the same remotenode and extra is
@@ -215,7 +215,7 @@ struct tmem_pamops {
 				uint32_t);
 	void (*free)(void *, struct tmem_pool *,
 				struct tmem_oid *, uint32_t, bool);
-#ifdef CONFIG_RAMSTER
+#if defined(CONFIG_RAMSTER) || defined(CONFIG_RAMSTER_MODULE)
 	void (*new_obj)(struct tmem_obj *);
 	void (*free_obj)(struct tmem_pool *, struct tmem_obj *, bool);
 	void *(*repatriate_preload)(void *, struct tmem_pool *,
@@ -247,7 +247,7 @@ extern int tmem_flush_page(struct tmem_pool *, struct tmem_oid *,
 extern int tmem_flush_object(struct tmem_pool *, struct tmem_oid *);
 extern int tmem_destroy_pool(struct tmem_pool *);
 extern void tmem_new_pool(struct tmem_pool *, uint32_t);
-#ifdef CONFIG_RAMSTER
+#if defined(CONFIG_RAMSTER) || defined(CONFIG_RAMSTER_MODULE)
 extern int tmem_replace(struct tmem_pool *, struct tmem_oid *, uint32_t index,
 			void *);
 extern void *tmem_localify_get_pampd(struct tmem_pool *, struct tmem_oid *,
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index bb59b78..288c841 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -31,8 +31,10 @@
 #include "ramster.h"
 #ifdef CONFIG_RAMSTER
 static int ramster_enabled;
+static int disable_frontswap_selfshrink;
 #else
 #define ramster_enabled 0
+#define disable_frontswap_selfshrink 0
 #endif
 
 #ifndef __PG_WAS_ACTIVE
@@ -68,8 +70,12 @@ static char *namestr __read_mostly = "zcache";
 MODULE_LICENSE("GPL");
 
 /* crypto API for zcache  */
+#ifdef CONFIG_ZCACHE_MODULE
+static char *zcache_comp_name = "lzo";
+#else
 #define ZCACHE_COMP_NAME_SZ CRYPTO_MAX_ALG_NAME
 static char zcache_comp_name[ZCACHE_COMP_NAME_SZ] __read_mostly;
+#endif
 static struct crypto_comp * __percpu *zcache_comp_pcpu_tfms __read_mostly;
 
 enum comp_op {
@@ -1639,6 +1645,7 @@ struct frontswap_ops *zcache_frontswap_register_ops(void)
  * OR NOTHING HAPPENS!
  */
 
+#ifndef CONFIG_ZCACHE_MODULE
 static int __init enable_zcache(char *s)
 {
 	zcache_enabled = 1;
@@ -1705,18 +1712,27 @@ static int __init enable_zcache_compressor(char *s)
 	return 1;
 }
 __setup("zcache=", enable_zcache_compressor);
+#endif
 
 
-static int __init zcache_comp_init(void)
+static int zcache_comp_init(void)
 {
 	int ret = 0;
 
 	/* check crypto algorithm */
+#ifdef CONFIG_ZCACHE_MODULE
+	ret = crypto_has_comp(zcache_comp_name, 0, 0);
+	if (!ret) {
+		ret = -1;
+		goto out;
+	}
+#else
 	if (*zcache_comp_name != '\0') {
 		ret = crypto_has_comp(zcache_comp_name, 0, 0);
 		if (!ret)
 			pr_info("zcache: %s not supported\n",
 					zcache_comp_name);
+		goto out;
 	}
 	if (!ret)
 		strcpy(zcache_comp_name, "lzo");
@@ -1725,6 +1741,7 @@ static int __init zcache_comp_init(void)
 		ret = 1;
 		goto out;
 	}
+#endif
 	pr_info("zcache: using %s compressor\n", zcache_comp_name);
 
 	/* alloc percpu transforms */
@@ -1736,10 +1753,13 @@ out:
 	return ret;
 }
 
-static int __init zcache_init(void)
+static int zcache_init(void)
 {
 	int ret = 0;
 
+#ifdef CONFIG_ZCACHE_MODULE
+	zcache_enabled = 1;
+#endif
 	if (ramster_enabled) {
 		namestr = "ramster";
 		ramster_register_pamops(&zcache_pamops);
@@ -1811,9 +1831,28 @@ static int __init zcache_init(void)
 	}
 	if (ramster_enabled)
 		ramster_init(!disable_cleancache, !disable_frontswap,
-				frontswap_has_exclusive_gets, false);
+				frontswap_has_exclusive_gets,
+				!disable_frontswap_selfshrink);
 out:
 	return ret;
 }
 
+#ifdef CONFIG_ZCACHE_MODULE
+#ifdef CONFIG_RAMSTER
+module_param(ramster_enabled, int, S_IRUGO);
+module_param(disable_frontswap_selfshrink, int, S_IRUGO);
+#endif
+module_param(disable_cleancache, int, S_IRUGO);
+module_param(disable_frontswap, int, S_IRUGO);
+#ifdef FRONTSWAP_HAS_EXCLUSIVE_GETS
+module_param(frontswap_has_exclusive_gets, bool, S_IRUGO);
+#endif
+module_param(disable_frontswap_ignore_nonactive, int, S_IRUGO);
+module_param(zcache_comp_name, charp, S_IRUGO);
+module_init(zcache_init);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Dan Magenheimer <dan.magenheimer@oracle.com>");
+MODULE_DESCRIPTION("In-kernel compression of cleancache/frontswap pages");
+#else
 late_initcall(zcache_init);
+#endif
diff --git a/drivers/staging/zcache/zcache.h b/drivers/staging/zcache/zcache.h
index 81722b3..8491200 100644
--- a/drivers/staging/zcache/zcache.h
+++ b/drivers/staging/zcache/zcache.h
@@ -39,7 +39,7 @@ extern int zcache_flush_page(int, int, struct tmem_oid *, uint32_t);
 extern int zcache_flush_object(int, int, struct tmem_oid *);
 extern void zcache_decompress_to_page(char *, unsigned int, struct page *);
 
-#ifdef CONFIG_RAMSTER
+#if defined(CONFIG_RAMSTER) || defined(CONFIG_RAMSTER_MODULE)
 extern void *zcache_pampd_create(char *, unsigned int, bool, int,
 				struct tmem_handle *);
 int zcache_autocreate_pool(unsigned int cli_id, unsigned int pool_id, bool eph);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
