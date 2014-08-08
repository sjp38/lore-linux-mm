Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D2A466B0035
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 03:53:22 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so6610340pdj.21
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 00:53:22 -0700 (PDT)
Received: from smtp.outflux.net (smtp.outflux.net. [2001:19d0:2:6:c0de:0:736d:7470])
        by mx.google.com with ESMTPS id td4si5426507pab.213.2014.08.08.00.53.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Aug 2014 00:53:21 -0700 (PDT)
Date: Fri, 8 Aug 2014 00:53:16 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] mm/zpool: use prefixed module loading
Message-ID: <20140808075316.GA21919@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>, Dan Carpenter <dan.carpenter@oracle.com>, linux-mm@kvack.org

To avoid potential format string expansion via module parameters,
do not use the zpool type directly in request_module() without a
format string. Additionally, to avoid arbitrary modules being loaded
via zpool API (e.g. via the zswap_zpool_type module parameter) add a
"zpool-" prefix to the requested module, as well as module aliases for
the existing zpool types (zbud and zsmalloc).

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 mm/zbud.c     | 1 +
 mm/zpool.c    | 2 +-
 mm/zsmalloc.c | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index a05790b1915e..aa74f7addab1 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -619,3 +619,4 @@ module_exit(exit_zbud);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Seth Jennings <sjenning@linux.vnet.ibm.com>");
 MODULE_DESCRIPTION("Buddy Allocator for Compressed Pages");
+MODULE_ALIAS("zpool-zbud");
diff --git a/mm/zpool.c b/mm/zpool.c
index e40612a1df00..739cdf0d183a 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -150,7 +150,7 @@ struct zpool *zpool_create_pool(char *type, gfp_t gfp, struct zpool_ops *ops)
 	driver = zpool_get_driver(type);
 
 	if (!driver) {
-		request_module(type);
+		request_module("zpool-%s", type);
 		driver = zpool_get_driver(type);
 	}
 
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 4e2fc83cb394..36af729eb3f6 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1199,3 +1199,4 @@ module_exit(zs_exit);
 
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
+MODULE_ALIAS("zpool-zsmalloc");
-- 
1.9.1


-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
