Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 423FA6B0011
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 15:23:27 -0500 (EST)
Received: by mail-vc0-f181.google.com with SMTP id d16so2728321vcd.12
        for <linux-mm@kvack.org>; Fri, 01 Feb 2013 12:23:26 -0800 (PST)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 05/15] staging: zcache: enable ramster to be built/loaded as a module
Date: Fri,  1 Feb 2013 15:22:54 -0500
Message-Id: <1359750184-23408-6-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
References: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

From: Dan Magenheimer <dan.magenheimer@oracle.com>

Enable module support for ramster.  Note runtime dependency disallows
loading if cleancache/frontswap lazy initialization patches are not
present.

If built-in (not built as a module), the original mechanism of enabling via
a kernel boot parameter is retained, but this should be considered deprecated.

Note that module unload is explicitly not yet supported.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
[v1: Fixed compile issues since ramster_init now has four arguments]
[v2: Fixed rebase on ramster->zcache move]
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/zcache/ramster.h                   |  6 ++++-
 drivers/staging/zcache/ramster/nodemanager.c       |  9 ++++---
 drivers/staging/zcache/ramster/ramster.c           | 29 ++++++++++++++++++----
 drivers/staging/zcache/ramster/ramster.h           |  2 +-
 .../staging/zcache/ramster/ramster_nodemanager.h   |  2 ++
 drivers/staging/zcache/zcache-main.c               |  2 +-
 6 files changed, 38 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/zcache/ramster.h b/drivers/staging/zcache/ramster.h
index 1b71aea..e1f91d5 100644
--- a/drivers/staging/zcache/ramster.h
+++ b/drivers/staging/zcache/ramster.h
@@ -11,10 +11,14 @@
 #ifndef _ZCACHE_RAMSTER_H_
 #define _ZCACHE_RAMSTER_H_
 
+#ifdef CONFIG_RAMSTER_MODULE
+#define CONFIG_RAMSTER
+#endif
+
 #ifdef CONFIG_RAMSTER
 #include "ramster/ramster.h"
 #else
-static inline void ramster_init(bool x, bool y, bool z)
+static inline void ramster_init(bool x, bool y, bool z, bool w)
 {
 }
 
diff --git a/drivers/staging/zcache/ramster/nodemanager.c b/drivers/staging/zcache/ramster/nodemanager.c
index c0f4815..2cfe933 100644
--- a/drivers/staging/zcache/ramster/nodemanager.c
+++ b/drivers/staging/zcache/ramster/nodemanager.c
@@ -949,7 +949,7 @@ static void __exit exit_r2nm(void)
 	r2hb_exit();
 }
 
-static int __init init_r2nm(void)
+int r2nm_init(void)
 {
 	int ret = -1;
 
@@ -986,10 +986,11 @@ out_r2hb:
 out:
 	return ret;
 }
+EXPORT_SYMBOL_GPL(r2nm_init);
 
 MODULE_AUTHOR("Oracle");
 MODULE_LICENSE("GPL");
 
-/* module_init(init_r2nm) */
-late_initcall(init_r2nm);
-/* module_exit(exit_r2nm) */
+#ifndef CONFIG_RAMSTER_MODULE
+late_initcall(r2nm_init);
+#endif
diff --git a/drivers/staging/zcache/ramster/ramster.c b/drivers/staging/zcache/ramster/ramster.c
index c06709f..491ec70 100644
--- a/drivers/staging/zcache/ramster/ramster.c
+++ b/drivers/staging/zcache/ramster/ramster.c
@@ -92,7 +92,7 @@ static unsigned long ramster_remote_page_flushes_failed;
 #include <linux/debugfs.h>
 #define	zdfs	debugfs_create_size_t
 #define	zdfs64	debugfs_create_u64
-static int __init ramster_debugfs_init(void)
+static int ramster_debugfs_init(void)
 {
 	struct dentry *root = debugfs_create_dir("ramster", NULL);
 	if (root == NULL)
@@ -191,6 +191,7 @@ int ramster_do_preload_flnode(struct tmem_pool *pool)
 		kmem_cache_free(ramster_flnode_cache, flnode);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(ramster_do_preload_flnode);
 
 /*
  * Called by the message handler after a (still compressed) page has been
@@ -458,6 +459,7 @@ void *ramster_pampd_free(void *pampd, struct tmem_pool *pool,
 	}
 	return local_pampd;
 }
+EXPORT_SYMBOL_GPL(ramster_pampd_free);
 
 void ramster_count_foreign_pages(bool eph, int count)
 {
@@ -489,6 +491,7 @@ void ramster_count_foreign_pages(bool eph, int count)
 		ramster_foreign_pers_pages = c;
 	}
 }
+EXPORT_SYMBOL_GPL(ramster_count_foreign_pages);
 
 /*
  * For now, just push over a few pages every few seconds to
@@ -674,7 +677,7 @@ requeue:
 	ramster_remotify_queue_delayed_work(HZ);
 }
 
-void __init ramster_remotify_init(void)
+void ramster_remotify_init(void)
 {
 	unsigned long n = 60UL;
 	ramster_remotify_workqueue =
@@ -849,8 +852,10 @@ static bool frontswap_selfshrinking __read_mostly;
 static void selfshrink_process(struct work_struct *work);
 static DECLARE_DELAYED_WORK(selfshrink_worker, selfshrink_process);
 
+#ifndef CONFIG_RAMSTER_MODULE
 /* Enable/disable with kernel boot option. */
 static bool use_frontswap_selfshrink __initdata = true;
+#endif
 
 /*
  * The default values for the following parameters were deemed reasonable
@@ -905,6 +910,7 @@ static void frontswap_selfshrink(void)
 	frontswap_shrink(tgt_frontswap_pages);
 }
 
+#ifndef CONFIG_RAMSTER_MODULE
 static int __init ramster_nofrontswap_selfshrink_setup(char *s)
 {
 	use_frontswap_selfshrink = false;
@@ -912,6 +918,7 @@ static int __init ramster_nofrontswap_selfshrink_setup(char *s)
 }
 
 __setup("noselfshrink", ramster_nofrontswap_selfshrink_setup);
+#endif
 
 static void selfshrink_process(struct work_struct *work)
 {
@@ -930,6 +937,7 @@ void ramster_cpu_up(int cpu)
 	per_cpu(ramster_remoteputmem1, cpu) = p1;
 	per_cpu(ramster_remoteputmem2, cpu) = p2;
 }
+EXPORT_SYMBOL_GPL(ramster_cpu_up);
 
 void ramster_cpu_down(int cpu)
 {
@@ -945,6 +953,7 @@ void ramster_cpu_down(int cpu)
 		kp->flnode = NULL;
 	}
 }
+EXPORT_SYMBOL_GPL(ramster_cpu_down);
 
 void ramster_register_pamops(struct tmem_pamops *pamops)
 {
@@ -955,9 +964,11 @@ void ramster_register_pamops(struct tmem_pamops *pamops)
 	pamops->repatriate = ramster_pampd_repatriate;
 	pamops->repatriate_preload = ramster_pampd_repatriate_preload;
 }
+EXPORT_SYMBOL_GPL(ramster_register_pamops);
 
-void __init ramster_init(bool cleancache, bool frontswap,
-				bool frontswap_exclusive_gets)
+void ramster_init(bool cleancache, bool frontswap,
+				bool frontswap_exclusive_gets,
+				bool frontswap_selfshrink)
 {
 	int ret = 0;
 
@@ -972,10 +983,17 @@ void __init ramster_init(bool cleancache, bool frontswap,
 	if (ret)
 		pr_err("ramster: can't create sysfs for ramster\n");
 	(void)r2net_register_handlers();
+#ifdef CONFIG_RAMSTER_MODULE
+	ret = r2nm_init();
+	if (ret)
+		pr_err("ramster: can't init r2net\n");
+	frontswap_selfshrinking = frontswap_selfshrink;
+#else
+	frontswap_selfshrinking = use_frontswap_selfshrink;
+#endif
 	INIT_LIST_HEAD(&ramster_rem_op_list);
 	ramster_flnode_cache = kmem_cache_create("ramster_flnode",
 				sizeof(struct flushlist_node), 0, 0, NULL);
-	frontswap_selfshrinking = use_frontswap_selfshrink;
 	if (frontswap_selfshrinking) {
 		pr_info("ramster: Initializing frontswap selfshrink driver.\n");
 		schedule_delayed_work(&selfshrink_worker,
@@ -983,3 +1001,4 @@ void __init ramster_init(bool cleancache, bool frontswap,
 	}
 	ramster_remotify_init();
 }
+EXPORT_SYMBOL_GPL(ramster_init);
diff --git a/drivers/staging/zcache/ramster/ramster.h b/drivers/staging/zcache/ramster/ramster.h
index 12ae56f..6d41a7a 100644
--- a/drivers/staging/zcache/ramster/ramster.h
+++ b/drivers/staging/zcache/ramster/ramster.h
@@ -147,7 +147,7 @@ extern int r2net_register_handlers(void);
 extern int r2net_remote_target_node_set(int);
 
 extern int ramster_remotify_pageframe(bool);
-extern void ramster_init(bool, bool, bool);
+extern void ramster_init(bool, bool, bool, bool);
 extern void ramster_register_pamops(struct tmem_pamops *);
 extern int ramster_localify(int, struct tmem_oid *oidp, uint32_t, char *,
 				unsigned int, void *);
diff --git a/drivers/staging/zcache/ramster/ramster_nodemanager.h b/drivers/staging/zcache/ramster/ramster_nodemanager.h
index 49f879d..dbaae34 100644
--- a/drivers/staging/zcache/ramster/ramster_nodemanager.h
+++ b/drivers/staging/zcache/ramster/ramster_nodemanager.h
@@ -36,4 +36,6 @@
 /* host name, group name, cluster name all 64 bytes */
 #define R2NM_MAX_NAME_LEN        64    /* __NEW_UTS_LEN */
 
+extern int r2nm_init(void);
+
 #endif /* _RAMSTER_NODEMANAGER_H */
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index b5a9dd0..bb59b78 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1811,7 +1811,7 @@ static int __init zcache_init(void)
 	}
 	if (ramster_enabled)
 		ramster_init(!disable_cleancache, !disable_frontswap,
-				frontswap_has_exclusive_gets);
+				frontswap_has_exclusive_gets, false);
 out:
 	return ret;
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
