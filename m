Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id AB9536B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 15:06:36 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so13134325pdj.30
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 12:06:36 -0700 (PDT)
Received: from smtp.outflux.net (smtp.outflux.net. [2001:19d0:2:6:c0de:0:736d:7470])
        by mx.google.com with ESMTPS id uq2si16675985pbc.83.2014.08.12.12.06.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Aug 2014 12:06:34 -0700 (PDT)
Date: Tue, 12 Aug 2014 12:06:29 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2] mm/zpool: use prefixed module loading
Message-ID: <20140812190629.GA7179@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org

To avoid potential format string expansion via module parameters,
do not use the zpool type directly in request_module() without a
format string. Additionally, to avoid arbitrary modules being loaded
via zpool API (e.g. via the zswap_zpool_type module parameter) add a
"zpool-" prefix to the requested module, as well as module aliases for
the existing zpool types (zbud and zsmalloc).

Signed-off-by: Kees Cook <keescook@chromium.org>
---
v2:
- moved module aliases into ifdefs (ddstreet)
---
 mm/zbud.c     | 1 +
 mm/zpool.c    | 2 +-
 mm/zsmalloc.c | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index a05790b1915e..f26e7fcc7fa2 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -195,6 +195,7 @@ static struct zpool_driver zbud_zpool_driver = {
 	.total_size =	zbud_zpool_total_size,
 };
 
+MODULE_ALIAS("zpool-zbud");
 #endif /* CONFIG_ZPOOL */
 
 /*****************
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
index 4e2fc83cb394..94f38fac5e81 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -315,6 +315,7 @@ static struct zpool_driver zs_zpool_driver = {
 	.total_size =	zs_zpool_total_size,
 };
 
+MODULE_ALIAS("zpool-zsmalloc");
 #endif /* CONFIG_ZPOOL */
 
 /* per-cpu VM mapping areas for zspage accesses that cross page boundaries */
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
