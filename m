Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 7D6716B0023
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 15:23:29 -0500 (EST)
Received: by mail-vc0-f177.google.com with SMTP id m18so2729435vcm.36
        for <linux-mm@kvack.org>; Fri, 01 Feb 2013 12:23:28 -0800 (PST)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 07/15] xen: tmem: enable Xen tmem shim to be built/loaded as a module
Date: Fri,  1 Feb 2013 15:22:56 -0500
Message-Id: <1359750184-23408-8-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
References: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

From: Dan Magenheimer <dan.magenheimer@oracle.com>

Allow Xen tmem shim to be built/loaded as a module.  Xen self-ballooning
and frontswap-selfshrinking are now also "lazily" initialized when the
Xen tmem shim is loaded as a module, unless explicitly disabled
by module parameters.

Note runtime dependency disallows loading if cleancache/frontswap lazy
initialization patches are not present.

If built-in (not built as a module), the original mechanism of enabling via
a kernel boot parameter is retained, but this should be considered deprecated.

Note that module unload is explicitly not yet supported.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
[v1: Removed the [CLEANCACHE|FRONTSWAP]_HAS_LAZY_INIT ifdef]
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/xen/Kconfig           |  4 ++--
 drivers/xen/tmem.c            | 38 +++++++++++++++++++++++++++++---------
 drivers/xen/xen-selfballoon.c | 13 +++++++------
 include/xen/tmem.h            |  8 ++++++++
 4 files changed, 46 insertions(+), 17 deletions(-)

diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
index cabfa97..981646e 100644
--- a/drivers/xen/Kconfig
+++ b/drivers/xen/Kconfig
@@ -145,9 +145,9 @@ config SWIOTLB_XEN
 	select SWIOTLB
 
 config XEN_TMEM
-	bool
+	tristate
 	depends on !ARM
-	default y if (CLEANCACHE || FRONTSWAP)
+	default m if (CLEANCACHE || FRONTSWAP)
 	help
 	  Shim to interface in-kernel Transcendent Memory hooks
 	  (e.g. cleancache and frontswap) to Xen tmem hypercalls.
diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index 15e776c..9a4a9ec 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -5,6 +5,7 @@
  * Author: Dan Magenheimer
  */
 
+#include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/init.h>
@@ -128,6 +129,7 @@ static int xen_tmem_flush_object(u32 pool_id, struct tmem_oid oid)
 	return xen_tmem_op(TMEM_FLUSH_OBJECT, pool_id, oid, 0, 0, 0, 0, 0);
 }
 
+#ifndef CONFIG_XEN_TMEM_MODULE
 bool __read_mostly tmem_enabled = false;
 
 static int __init enable_tmem(char *s)
@@ -136,6 +138,7 @@ static int __init enable_tmem(char *s)
 	return 1;
 }
 __setup("tmem", enable_tmem);
+#endif
 
 #ifdef CONFIG_CLEANCACHE
 static int xen_tmem_destroy_pool(u32 pool_id)
@@ -227,14 +230,19 @@ static int tmem_cleancache_init_shared_fs(char *uuid, size_t pagesize)
 	return xen_tmem_new_pool(shared_uuid, TMEM_POOL_SHARED, pagesize);
 }
 
-static bool __initdata use_cleancache = true;
-
+static bool disable_cleancache __read_mostly;
+static bool disable_selfballooning __read_mostly;
+#ifdef CONFIG_XEN_TMEM_MODULE
+module_param(disable_cleancache, bool, S_IRUGO);
+module_param(disable_selfballooning, bool, S_IRUGO);
+#else
 static int __init no_cleancache(char *s)
 {
-	use_cleancache = false;
+	disable_cleancache = true;
 	return 1;
 }
 __setup("nocleancache", no_cleancache);
+#endif
 
 static struct cleancache_ops tmem_cleancache_ops = {
 	.put_page = tmem_cleancache_put_page,
@@ -353,14 +361,19 @@ static void tmem_frontswap_init(unsigned ignored)
 		    xen_tmem_new_pool(private, TMEM_POOL_PERSIST, PAGE_SIZE);
 }
 
-static bool __initdata use_frontswap = true;
-
+static bool disable_frontswap __read_mostly;
+static bool disable_frontswap_selfshrinking __read_mostly;
+#ifdef CONFIG_XEN_TMEM_MODULE
+module_param(disable_frontswap, bool, S_IRUGO);
+module_param(disable_frontswap_selfshrinking, bool, S_IRUGO);
+#else
 static int __init no_frontswap(char *s)
 {
-	use_frontswap = false;
+	disable_frontswap = true;
 	return 1;
 }
 __setup("nofrontswap", no_frontswap);
+#endif
 
 static struct frontswap_ops tmem_frontswap_ops = {
 	.store = tmem_frontswap_store,
@@ -371,12 +384,12 @@ static struct frontswap_ops tmem_frontswap_ops = {
 };
 #endif
 
-static int __init xen_tmem_init(void)
+static int xen_tmem_init(void)
 {
 	if (!xen_domain())
 		return 0;
 #ifdef CONFIG_FRONTSWAP
-	if (tmem_enabled && use_frontswap) {
+	if (tmem_enabled && !disable_frontswap) {
 		char *s = "";
 		struct frontswap_ops *old_ops =
 			frontswap_register_ops(&tmem_frontswap_ops);
@@ -390,7 +403,7 @@ static int __init xen_tmem_init(void)
 #endif
 #ifdef CONFIG_CLEANCACHE
 	BUG_ON(sizeof(struct cleancache_filekey) != sizeof(struct tmem_oid));
-	if (tmem_enabled && use_cleancache) {
+	if (tmem_enabled && !disable_cleancache) {
 		char *s = "";
 		struct cleancache_ops *old_ops =
 			cleancache_register_ops(&tmem_cleancache_ops);
@@ -400,7 +413,14 @@ static int __init xen_tmem_init(void)
 				 "Xen Transcendent Memory%s\n", s);
 	}
 #endif
+#ifdef CONFIG_XEN_SELFBALLOONING
+	xen_selfballoon_init(!disable_selfballooning,
+				!disable_frontswap_selfshrinking);
+#endif
 	return 0;
 }
 
 module_init(xen_tmem_init)
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Dan Magenheimer <dan.magenheimer@oracle.com>");
+MODULE_DESCRIPTION("Shim to Xen transcendent memory");
diff --git a/drivers/xen/xen-selfballoon.c b/drivers/xen/xen-selfballoon.c
index 2552d3e..6965e9b 100644
--- a/drivers/xen/xen-selfballoon.c
+++ b/drivers/xen/xen-selfballoon.c
@@ -121,7 +121,7 @@ static DECLARE_DELAYED_WORK(selfballoon_worker, selfballoon_process);
 static bool frontswap_selfshrinking __read_mostly;
 
 /* Enable/disable with kernel boot option. */
-static bool use_frontswap_selfshrink __initdata = true;
+static bool use_frontswap_selfshrink = true;
 
 /*
  * The default values for the following parameters were deemed reasonable
@@ -185,7 +185,7 @@ static int __init xen_nofrontswap_selfshrink_setup(char *s)
 __setup("noselfshrink", xen_nofrontswap_selfshrink_setup);
 
 /* Disable with kernel boot option. */
-static bool use_selfballooning __initdata = true;
+static bool use_selfballooning = true;
 
 static int __init xen_noselfballooning_setup(char *s)
 {
@@ -196,7 +196,7 @@ static int __init xen_noselfballooning_setup(char *s)
 __setup("noselfballooning", xen_noselfballooning_setup);
 #else /* !CONFIG_FRONTSWAP */
 /* Enable with kernel boot option. */
-static bool use_selfballooning __initdata = false;
+static bool use_selfballooning;
 
 static int __init xen_selfballooning_setup(char *s)
 {
@@ -537,7 +537,7 @@ int register_xen_selfballooning(struct device *dev)
 }
 EXPORT_SYMBOL(register_xen_selfballooning);
 
-static int __init xen_selfballoon_init(void)
+int xen_selfballoon_init(bool use_selfballooning, bool use_frontswap_selfshrink)
 {
 	bool enable = false;
 
@@ -571,7 +571,8 @@ static int __init xen_selfballoon_init(void)
 
 	return 0;
 }
+EXPORT_SYMBOL(xen_selfballoon_init);
 
+#ifndef CONFIG_XEN_TMEM_MODULE
 subsys_initcall(xen_selfballoon_init);
-
-MODULE_LICENSE("GPL");
+#endif
diff --git a/include/xen/tmem.h b/include/xen/tmem.h
index 591550a..3930a90 100644
--- a/include/xen/tmem.h
+++ b/include/xen/tmem.h
@@ -3,7 +3,15 @@
 
 #include <linux/types.h>
 
+#ifdef CONFIG_XEN_TMEM_MODULE
+#define tmem_enabled true
+#else
 /* defined in drivers/xen/tmem.c */
 extern bool tmem_enabled;
+#endif
+
+#ifdef CONFIG_XEN_SELFBALLOONING
+extern int xen_selfballoon_init(bool, bool);
+#endif
 
 #endif /* _XEN_TMEM_H */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
