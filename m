Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 722726B0038
	for <linux-mm@kvack.org>; Tue, 14 May 2013 14:20:47 -0400 (EDT)
Received: by mail-ve0-f179.google.com with SMTP id oz10so1048890veb.10
        for <linux-mm@kvack.org>; Tue, 14 May 2013 11:20:46 -0700 (PDT)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 2/9] xen/tmem: Move all of the boot and module parameters to the top of the file.
Date: Tue, 14 May 2013 14:09:19 -0400
Message-Id: <1368554966-30469-3-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
References: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bob.liu@oracle.com, dan.magenheimer@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xen-devel@lists.xensource.com
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Just code movement to see the different boot or module parameters.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/xen/tmem.c |   85 +++++++++++++++++++++++++++------------------------
 1 files changed, 45 insertions(+), 40 deletions(-)

diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index 5686d6d..edf7e18 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -20,6 +20,51 @@
 #include <asm/xen/hypervisor.h>
 #include <xen/tmem.h>
 
+#ifndef CONFIG_XEN_TMEM_MODULE
+bool __read_mostly tmem_enabled = false;
+
+static int __init enable_tmem(char *s)
+{
+	tmem_enabled = true;
+	return 1;
+}
+__setup("tmem", enable_tmem);
+#endif
+
+#ifdef CONFIG_CLEANCACHE
+static bool disable_cleancache __read_mostly;
+static bool disable_selfballooning __read_mostly;
+#ifdef CONFIG_XEN_TMEM_MODULE
+module_param(disable_cleancache, bool, S_IRUGO);
+module_param(disable_selfballooning, bool, S_IRUGO);
+#else
+static int __init no_cleancache(char *s)
+{
+	disable_cleancache = true;
+	return 1;
+}
+__setup("nocleancache", no_cleancache);
+#endif
+#endif /* CONFIG_CLEANCACHE */
+
+#ifdef CONFIG_FRONTSWAP
+static bool disable_frontswap __read_mostly;
+static bool disable_frontswap_selfshrinking __read_mostly;
+#ifdef CONFIG_XEN_TMEM_MODULE
+module_param(disable_frontswap, bool, S_IRUGO);
+module_param(disable_frontswap_selfshrinking, bool, S_IRUGO);
+#else
+static int __init no_frontswap(char *s)
+{
+	disable_frontswap = true;
+	return 1;
+}
+__setup("nofrontswap", no_frontswap);
+#endif
+#else /* CONFIG_FRONTSWAP */
+#define disable_frontswap_selfshrinking 1
+#endif /* CONFIG_FRONTSWAP */
+
 #define TMEM_CONTROL               0
 #define TMEM_NEW_POOL              1
 #define TMEM_DESTROY_POOL          2
@@ -125,16 +170,6 @@ static int xen_tmem_flush_object(u32 pool_id, struct tmem_oid oid)
 	return xen_tmem_op(TMEM_FLUSH_OBJECT, pool_id, oid, 0, 0, 0, 0, 0);
 }
 
-#ifndef CONFIG_XEN_TMEM_MODULE
-bool __read_mostly tmem_enabled = false;
-
-static int __init enable_tmem(char *s)
-{
-	tmem_enabled = true;
-	return 1;
-}
-__setup("tmem", enable_tmem);
-#endif
 
 #ifdef CONFIG_CLEANCACHE
 static int xen_tmem_destroy_pool(u32 pool_id)
@@ -226,20 +261,6 @@ static int tmem_cleancache_init_shared_fs(char *uuid, size_t pagesize)
 	return xen_tmem_new_pool(shared_uuid, TMEM_POOL_SHARED, pagesize);
 }
 
-static bool disable_cleancache __read_mostly;
-static bool disable_selfballooning __read_mostly;
-#ifdef CONFIG_XEN_TMEM_MODULE
-module_param(disable_cleancache, bool, S_IRUGO);
-module_param(disable_selfballooning, bool, S_IRUGO);
-#else
-static int __init no_cleancache(char *s)
-{
-	disable_cleancache = true;
-	return 1;
-}
-__setup("nocleancache", no_cleancache);
-#endif
-
 static struct cleancache_ops tmem_cleancache_ops = {
 	.put_page = tmem_cleancache_put_page,
 	.get_page = tmem_cleancache_get_page,
@@ -357,20 +378,6 @@ static void tmem_frontswap_init(unsigned ignored)
 		    xen_tmem_new_pool(private, TMEM_POOL_PERSIST, PAGE_SIZE);
 }
 
-static bool disable_frontswap __read_mostly;
-static bool disable_frontswap_selfshrinking __read_mostly;
-#ifdef CONFIG_XEN_TMEM_MODULE
-module_param(disable_frontswap, bool, S_IRUGO);
-module_param(disable_frontswap_selfshrinking, bool, S_IRUGO);
-#else
-static int __init no_frontswap(char *s)
-{
-	disable_frontswap = true;
-	return 1;
-}
-__setup("nofrontswap", no_frontswap);
-#endif
-
 static struct frontswap_ops tmem_frontswap_ops = {
 	.store = tmem_frontswap_store,
 	.load = tmem_frontswap_load,
@@ -378,8 +385,6 @@ static struct frontswap_ops tmem_frontswap_ops = {
 	.invalidate_area = tmem_frontswap_flush_area,
 	.init = tmem_frontswap_init
 };
-#else	/* CONFIG_FRONTSWAP */
-#define disable_frontswap_selfshrinking 1
 #endif
 
 static int xen_tmem_init(void)
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
