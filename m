Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id CAF936B0074
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 21:50:17 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so12360176pac.22
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 18:50:17 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id b14si2003627pat.34.2014.12.01.18.50.09
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 18:50:11 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 1/6] zsmalloc: expand size class to support sizeof(unsigned long)
Date: Tue,  2 Dec 2014 11:49:42 +0900
Message-Id: <1417488587-28609-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1417488587-28609-1-git-send-email-minchan@kernel.org>
References: <1417488587-28609-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Minchan Kim <minchan@kernel.org>

For compaction of zsmalloc, we need to decouple handle and
obj position binding. For that, we need another memory to
keep handle and I want to reuse existing functions of zsmalloc
to implement indirect layer.

For that, we need to support new size class(ie, sizeof(unsigned
long)) so this patch does it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 2021df5eb891..a806d714924c 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -100,7 +100,8 @@
  * span more than 1 page which avoids complex case of mapping 2 pages simply
  * to restore link_free pointer values.
  */
-#define ZS_ALIGN		8
+#define ZS_ALIGN		(sizeof(struct link_free))
+#define ZS_HANDLE_SIZE		(sizeof(unsigned long))
 
 /*
  * A single 'zspage' is composed of up to 2^N discontiguous 0-order (single)
@@ -138,11 +139,11 @@
 #define MAX(a, b) ((a) >= (b) ? (a) : (b))
 /* ZS_MIN_ALLOC_SIZE must be multiple of ZS_ALIGN */
 #define ZS_MIN_ALLOC_SIZE \
-	MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
-#define ZS_MAX_ALLOC_SIZE	PAGE_SIZE
+	MAX(ZS_ALIGN, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
+#define ZS_MAX_ALLOC_SIZE	(PAGE_SIZE + ZS_HANDLE_SIZE)
 
 /*
- * On systems with 4K page size, this gives 255 size classes! There is a
+ * On systems with 4K page size, this gives 257 size classes! There is a
  * trader-off here:
  *  - Large number of size classes is potentially wasteful as free page are
  *    spread across these classes
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
