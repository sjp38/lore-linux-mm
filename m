Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 3EF466B002D
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 15:23:37 -0500 (EST)
Received: by mail-vb0-f50.google.com with SMTP id ft2so2677105vbb.37
        for <linux-mm@kvack.org>; Fri, 01 Feb 2013 12:23:36 -0800 (PST)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 14/15] zcache/tmem: Better error checking on frontswap_register_ops return value.
Date: Fri,  1 Feb 2013 15:23:03 -0500
Message-Id: <1359750184-23408-15-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
References: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

In the past it either used to be NULL or the "older" backend. Now we
also return -Exx error codes.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/zcache/zcache-main.c | 5 ++++-
 drivers/xen/tmem.c                   | 5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 288c841..79c10af 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1826,8 +1826,11 @@ static int zcache_init(void)
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
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
