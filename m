Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id CC5186B006E
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 11:09:29 -0400 (EDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 5/5] xen: tmem: enable Xen tmem shim to be built/loaded as a module
Date: Wed, 31 Oct 2012 08:07:54 -0700
Message-Id: <1351696074-29362-6-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1351696074-29362-1-git-send-email-dan.magenheimer@oracle.com>
References: <1351696074-29362-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, dan.magenheimer@oracle.com, fschmaus@gmail.com, andor.damm@googlemail.com, ilendir@googlemail.com, akpm@linux-foundation.org, mgorman@suse.de

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
---
 drivers/xen/Kconfig           |    4 +-
 drivers/xen/tmem.c            |   56 +++++++++++++++++++++++++++++++++--------
 drivers/xen/xen-selfballoon.c |   13 +++++----
 include/xen/tmem.h            |    8 ++++++
 4 files changed, 62 insertions(+), 19 deletions(-)

diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
index d4dffcd..68dd78f 100644
--- a/drivers/xen/Kconfig
+++ b/drivers/xen/Kconfig
@@ -144,8 +144,8 @@ config SWIOTLB_XEN
 	select SWIOTLB
 
 config XEN_TMEM
-	bool
-	default y if (CLEANCACHE || FRONTSWAP)
+	tristate
+	default m if (CLEANCACHE || FRONTSWAP)
 	help
 	  Shim to interface in-kernel Transcendent Memory hooks
 	  (e.g. cleancache and frontswap) to Xen tmem hypercalls.
diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index 144564e..8ba0a3f 100644
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
@@ -227,16 +230,21 @@ static int tmem_cleancache_init_shared_fs(char *uuid, size_t pagesize)
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
 
-static struct cleancache_ops __initdata tmem_cleancache_ops = {
+static struct cleancache_ops tmem_cleancache_ops = {
 	.put_page = tmem_cleancache_put_page,
 	.get_page = tmem_cleancache_get_page,
 	.invalidate_page = tmem_cleancache_flush_page,
@@ -353,16 +361,21 @@ static void tmem_frontswap_init(unsigned ignored)
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
 
-static struct frontswap_ops __initdata tmem_frontswap_ops = {
+static struct frontswap_ops tmem_frontswap_ops = {
 	.store = tmem_frontswap_store,
 	.load = tmem_frontswap_load,
 	.invalidate_page = tmem_frontswap_flush_page,
@@ -371,12 +384,19 @@ static struct frontswap_ops __initdata tmem_frontswap_ops = {
 };
 #endif
 
-static int __init xen_tmem_init(void)
+static int xen_tmem_init(void)
 {
 	if (!xen_domain())
 		return 0;
 #ifdef CONFIG_FRONTSWAP
-	if (tmem_enabled && use_frontswap) {
+#if defined(CONFIG_XEN_TMEM_MODULE) && !defined(FRONTSWAP_HAS_LAZY_INIT)
+	/* This ifdef can be removed when frontswap lazy init is merged */
+	if (!disable_frontswap) {
+		pr_err("Xen tmem module requires frontswap lazy init\n");
+		return -EINVAL;
+	}
+#endif
+	if (tmem_enabled && !disable_frontswap) {
 		char *s = "";
 		struct frontswap_ops old_ops =
 			frontswap_register_ops(&tmem_frontswap_ops);
@@ -389,8 +409,15 @@ static int __init xen_tmem_init(void)
 	}
 #endif
 #ifdef CONFIG_CLEANCACHE
+#if defined(CONFIG_XEN_TMEM_MODULE) && !defined(CLEANCACHE_HAS_LAZY_INIT)
+	/* This ifdef can be removed when cleancache lazy init is merged */
+	if (!disable_cleancache) {
+		pr_err("Xen tmem module requires cleancache lazy init\n");
+		return -EINVAL;
+	}
+#endif
 	BUG_ON(sizeof(struct cleancache_filekey) != sizeof(struct tmem_oid));
-	if (tmem_enabled && use_cleancache) {
+	if (tmem_enabled && !disable_cleancache) {
 		char *s = "";
 		struct cleancache_ops old_ops =
 			cleancache_register_ops(&tmem_cleancache_ops);
@@ -400,7 +427,14 @@ static int __init xen_tmem_init(void)
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
index 7d041cb..f4808aa 100644
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
index 591550a..f94bdd1 100644
--- a/include/xen/tmem.h
+++ b/include/xen/tmem.h
@@ -3,7 +3,15 @@
 
 #include <linux/types.h>
 
+#ifdef CONFIG_XEN_TMEM_MODULE
+#define tmem_enabled 1
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
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
