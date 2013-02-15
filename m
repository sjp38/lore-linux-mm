Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 6197E6B0031
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 15:20:50 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 11/11] zcache/tmem: Better error checking on frontswap_register_ops return value.
Date: Fri, 15 Feb 2013 15:20:35 -0500
Message-Id: <1360959635-18922-12-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1360959635-18922-1-git-send-email-konrad.wilk@oracle.com>
References: <1360959635-18922-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, minchan@kernel.org
Cc: ric.masonn@gmail.com, lliubbo@gmail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

In the past it either used to be NULL or the "older" backend. Now we
also return -Exx error codes.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/zcache/zcache-main.c | 5 ++++-
 drivers/xen/tmem.c                   | 5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 3554987..48e46c5 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -2006,8 +2006,11 @@ static int __init zcache_init(void)
 			namestr, frontswap_has_exclusive_gets,
 			!disable_frontswap_ignore_nonactive);
 #endif
-		if (old_ops != NULL)
+		if (IS_ERR(old_ops) || old_ops) {
+			if (IS_ERR(old_ops))
+				return PTR_RET(old_ops);
 			pr_warn("%s: frontswap_ops overridden\n", namestr);
+		}
 	}
 	if (ramster_enabled)
 		ramster_init(!disable_cleancache, !disable_frontswap,
diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index 9a4a9ec..2f939e5 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -395,8 +395,11 @@ static int xen_tmem_init(void)
 			frontswap_register_ops(&tmem_frontswap_ops);
 
 		tmem_frontswap_poolid = -1;
-		if (old_ops)
+		if (IS_ERR(old_ops) || old_ops) {
+			if (IS_ERR(old_ops))
+				return PTR_ERR(old_ops);
 			s = " (WARNING: frontswap_ops overridden)";
+		}
 		printk(KERN_INFO "frontswap enabled, RAM provided by "
 				 "Xen Transcendent Memory\n");
 	}
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
