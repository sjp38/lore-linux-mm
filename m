Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 6D2B86B00CC
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 04:50:39 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 26 Jun 2012 08:47:24 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5Q8goaU2032074
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:42:50 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5Q8oYri021380
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:50:34 +1000
Message-ID: <4FE977D7.3000409@linux.vnet.ibm.com>
Date: Tue, 26 Jun 2012 16:50:31 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH v2 3/9] zcache: remove unnecessary config option dependence
References: <4FE97792.9020807@linux.vnet.ibm.com>
In-Reply-To: <4FE97792.9020807@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org

zcache is enabled only if one of CONFIG_CLEANCACHE and CONFIG_FRONTSWAP is
enabled, see the Kconfig:
	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=y && X86
So, we can remove the check in the source code

Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 58e7bd4..36c3b05 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -36,9 +36,6 @@

 #include "../zsmalloc/zsmalloc.h"

-#if (!defined(CONFIG_CLEANCACHE) && !defined(CONFIG_FRONTSWAP))
-#error "zcache is useless without CONFIG_CLEANCACHE or CONFIG_FRONTSWAP"
-#endif
 #ifdef CONFIG_CLEANCACHE
 #include <linux/cleancache.h>
 #endif
@@ -2028,7 +2025,7 @@ static int __init zcache_init(void)
 		goto out;
 	}
 #endif /* CONFIG_SYSFS */
-#if defined(CONFIG_CLEANCACHE) || defined(CONFIG_FRONTSWAP)
+
 	if (zcache_enabled) {
 		unsigned int cpu;

@@ -2059,7 +2056,7 @@ static int __init zcache_init(void)
 		pr_err("zcache: can't create client\n");
 		goto out;
 	}
-#endif
+
 #ifdef CONFIG_CLEANCACHE
 	if (zcache_enabled && use_cleancache) {
 		struct cleancache_ops old_ops;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
