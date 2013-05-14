Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 809F16B0039
	for <linux-mm@kvack.org>; Tue, 14 May 2013 14:20:48 -0400 (EDT)
Received: by mail-ve0-f179.google.com with SMTP id oz10so1048924veb.10
        for <linux-mm@kvack.org>; Tue, 14 May 2013 11:20:47 -0700 (PDT)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 3/9] xen/tmem: Split out the different module/boot options.
Date: Tue, 14 May 2013 14:09:20 -0400
Message-Id: <1368554966-30469-4-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
References: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bob.liu@oracle.com, dan.magenheimer@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xen-devel@lists.xensource.com
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

There are three options - depending on what combination of
CONFIG_FRONTSWAP, CONFIG_CLEANCACHE and CONFIG_XEN_SELFBALLOONING
is used. Lets split them out nicely out in three groups to
make it easier to clean up.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/xen/tmem.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index edf7e18..c2ee188 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -49,10 +49,8 @@ __setup("nocleancache", no_cleancache);
 
 #ifdef CONFIG_FRONTSWAP
 static bool disable_frontswap __read_mostly;
-static bool disable_frontswap_selfshrinking __read_mostly;
 #ifdef CONFIG_XEN_TMEM_MODULE
 module_param(disable_frontswap, bool, S_IRUGO);
-module_param(disable_frontswap_selfshrinking, bool, S_IRUGO);
 #else
 static int __init no_frontswap(char *s)
 {
@@ -61,8 +59,15 @@ static int __init no_frontswap(char *s)
 }
 __setup("nofrontswap", no_frontswap);
 #endif
-#else /* CONFIG_FRONTSWAP */
+#endif /* CONFIG_FRONTSWAP */
+
+#ifdef CONFIG_FRONTSWAP
+static bool disable_frontswap_selfshrinking __read_mostly;
+#ifdef CONFIG_XEN_TMEM_MODULE
+module_param(disable_frontswap_selfshrinking, bool, S_IRUGO);
+#else
 #define disable_frontswap_selfshrinking 1
+#endif
 #endif /* CONFIG_FRONTSWAP */
 
 #define TMEM_CONTROL               0
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
