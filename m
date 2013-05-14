Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id EFF636B003C
	for <linux-mm@kvack.org>; Tue, 14 May 2013 14:20:51 -0400 (EDT)
Received: by mail-ve0-f174.google.com with SMTP id db10so1022123veb.5
        for <linux-mm@kvack.org>; Tue, 14 May 2013 11:20:50 -0700 (PDT)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 6/9] xen/tmem: Remove the boot options and fold them in the tmem.X parameters.
Date: Tue, 14 May 2013 14:09:23 -0400
Message-Id: <1368554966-30469-7-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
References: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bob.liu@oracle.com, dan.magenheimer@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xen-devel@lists.xensource.com
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

If tmem is built-in or a module, the user has the option on
the command line to influence it by doing: tmem.<some option>
instead of having a variety of "nocleancache", and
"nofrontswap". The others: "noselfballooning" and "selfballooning";
and "noselfshrink" are in a different driver xen-selfballoon.c
and the patches:

 xen/tmem: Remove the usage of 'noselfshrink' and use 'tmem.selfshrink' bool instead.
 xen/tmem: Remove the usage of 'noselfballoon','selfballoon' and use 'tmem.selfballon' bool instead.

removes them.

Also add documentation.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 Documentation/kernel-parameters.txt |   20 ++++++++++++++++++++
 drivers/xen/tmem.c                  |   28 ++++------------------------
 2 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index c3bfacb..3de01ed 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -3005,6 +3005,26 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			Force threading of all interrupt handlers except those
 			marked explicitly IRQF_NO_THREAD.
 
+	tmem		[KNL,XEN]
+			Enable the Transcendent memory driver if built-in.
+
+	tmem.cleancache=0|1 [KNL, XEN]
+			Default is on (1). Disable the usage of the cleancache
+			API to send anonymous pages to the hypervisor.
+
+	tmem.frontswap=0|1 [KNL, XEN]
+			Default is on (1). Disable the usage of the frontswap
+			API to send swap pages to the hypervisor.
+
+	tmem.selfballooning=0|1 [KNL, XEN]
+			Default is on (1). Disable the driving of swap pages
+			to the hypervisor.
+
+	tmem.selfshrinking=0|1 [KNL, XEN]
+			Default is on (1). Partial swapoff that immediately
+			transfers pages from Xen hypervisor back to the
+			kernel based on different criteria.
+
 	topology=	[S390]
 			Format: {off | on}
 			Specify if the kernel should make use of the cpu
diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index 411c7e3..c1df0ff 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -33,39 +33,19 @@ __setup("tmem", enable_tmem);
 
 #ifdef CONFIG_CLEANCACHE
 static bool cleancache __read_mostly = true;
-static bool selfballooning __read_mostly = true;
-#ifdef CONFIG_XEN_TMEM_MODULE
 module_param(cleancache, bool, S_IRUGO);
+static bool selfballooning __read_mostly = true;
 module_param(selfballooning, bool, S_IRUGO);
-#else
-static int __init no_cleancache(char *s)
-{
-	cleancache = false;
-	return 1;
-}
-__setup("nocleancache", no_cleancache);
-#endif
 #endif /* CONFIG_CLEANCACHE */
 
 #ifdef CONFIG_FRONTSWAP
 static bool frontswap __read_mostly = true;
-#ifdef CONFIG_XEN_TMEM_MODULE
 module_param(frontswap, bool, S_IRUGO);
-#else
-static int __init no_frontswap(char *s)
-{
-	frontswap = false;
-	return 1;
-}
-__setup("nofrontswap", no_frontswap);
-#endif
 #endif /* CONFIG_FRONTSWAP */
 
 #ifdef CONFIG_XEN_SELFBALLOONING
-static bool frontswap_selfshrinking __read_mostly = true;
-#ifdef CONFIG_XEN_TMEM_MODULE
-module_param(frontswap_selfshrinking, bool, S_IRUGO);
-#endif
+static bool selfshrinking __read_mostly = true;
+module_param(selfshrinking, bool, S_IRUGO);
 #endif /* CONFIG_XEN_SELFBALLOONING */
 
 #define TMEM_CONTROL               0
@@ -423,7 +403,7 @@ static int xen_tmem_init(void)
 	}
 #endif
 #ifdef CONFIG_XEN_SELFBALLOONING
-	xen_selfballoon_init(selfballooning, frontswap_selfshrinking);
+	xen_selfballoon_init(selfballooning, selfshrinking);
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
