Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id EDB0A6B003B
	for <linux-mm@kvack.org>; Tue, 14 May 2013 14:20:50 -0400 (EDT)
Received: by mail-ve0-f178.google.com with SMTP id jy13so1027601veb.37
        for <linux-mm@kvack.org>; Tue, 14 May 2013 11:20:49 -0700 (PDT)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 5/9] xen/tmem: s/disable_// and change the logic.
Date: Tue, 14 May 2013 14:09:22 -0400
Message-Id: <1368554966-30469-6-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
References: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bob.liu@oracle.com, dan.magenheimer@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xen-devel@lists.xensource.com
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

The variety of disable_[cleancache|frontswap|selfshrinking] are
making this a bit complex. Just remove the "disable_" part and
change the logic around for the "nofrontswap" and "nocleancache"
parameters.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/xen/tmem.c |   27 +++++++++++++--------------
 1 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index 30bf974..411c7e3 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -32,15 +32,15 @@ __setup("tmem", enable_tmem);
 #endif
 
 #ifdef CONFIG_CLEANCACHE
-static bool disable_cleancache __read_mostly;
-static bool disable_selfballooning __read_mostly;
+static bool cleancache __read_mostly = true;
+static bool selfballooning __read_mostly = true;
 #ifdef CONFIG_XEN_TMEM_MODULE
-module_param(disable_cleancache, bool, S_IRUGO);
-module_param(disable_selfballooning, bool, S_IRUGO);
+module_param(cleancache, bool, S_IRUGO);
+module_param(selfballooning, bool, S_IRUGO);
 #else
 static int __init no_cleancache(char *s)
 {
-	disable_cleancache = true;
+	cleancache = false;
 	return 1;
 }
 __setup("nocleancache", no_cleancache);
@@ -48,13 +48,13 @@ __setup("nocleancache", no_cleancache);
 #endif /* CONFIG_CLEANCACHE */
 
 #ifdef CONFIG_FRONTSWAP
-static bool disable_frontswap __read_mostly;
+static bool frontswap __read_mostly = true;
 #ifdef CONFIG_XEN_TMEM_MODULE
-module_param(disable_frontswap, bool, S_IRUGO);
+module_param(frontswap, bool, S_IRUGO);
 #else
 static int __init no_frontswap(char *s)
 {
-	disable_frontswap = true;
+	frontswap = false;
 	return 1;
 }
 __setup("nofrontswap", no_frontswap);
@@ -62,9 +62,9 @@ __setup("nofrontswap", no_frontswap);
 #endif /* CONFIG_FRONTSWAP */
 
 #ifdef CONFIG_XEN_SELFBALLOONING
-static bool disable_frontswap_selfshrinking __read_mostly;
+static bool frontswap_selfshrinking __read_mostly = true;
 #ifdef CONFIG_XEN_TMEM_MODULE
-module_param(disable_frontswap_selfshrinking, bool, S_IRUGO);
+module_param(frontswap_selfshrinking, bool, S_IRUGO);
 #endif
 #endif /* CONFIG_XEN_SELFBALLOONING */
 
@@ -395,7 +395,7 @@ static int xen_tmem_init(void)
 	if (!xen_domain())
 		return 0;
 #ifdef CONFIG_FRONTSWAP
-	if (tmem_enabled && !disable_frontswap) {
+	if (tmem_enabled && frontswap) {
 		char *s = "";
 		struct frontswap_ops *old_ops =
 			frontswap_register_ops(&tmem_frontswap_ops);
@@ -412,7 +412,7 @@ static int xen_tmem_init(void)
 #endif
 #ifdef CONFIG_CLEANCACHE
 	BUG_ON(sizeof(struct cleancache_filekey) != sizeof(struct tmem_oid));
-	if (tmem_enabled && !disable_cleancache) {
+	if (tmem_enabled && cleancache) {
 		char *s = "";
 		struct cleancache_ops *old_ops =
 			cleancache_register_ops(&tmem_cleancache_ops);
@@ -423,8 +423,7 @@ static int xen_tmem_init(void)
 	}
 #endif
 #ifdef CONFIG_XEN_SELFBALLOONING
-	xen_selfballoon_init(!disable_selfballooning,
-				!disable_frontswap_selfshrinking);
+	xen_selfballoon_init(selfballooning, frontswap_selfshrinking);
 #endif
 	return 0;
 }
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
