Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 758756B0025
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 15:58:27 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id c16so4645089pgv.8
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:58:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u4si4798153pgr.337.2018.03.22.12.58.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 12:58:25 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 1/4] decompression: Rename malloc and free
Date: Thu, 22 Mar 2018 12:58:16 -0700
Message-Id: <20180322195819.24271-2-willy@infradead.org>
In-Reply-To: <20180322195819.24271-1-willy@infradead.org>
References: <20180322195819.24271-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Rename the trivial malloc and free implementations to tmalloc and tfree
to avoid a namespace collision with an in-kernel free() function.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/decompress/mm.h | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/decompress/mm.h b/include/linux/decompress/mm.h
index 868e9eacd69e..0ac62b025c1b 100644
--- a/include/linux/decompress/mm.h
+++ b/include/linux/decompress/mm.h
@@ -31,7 +31,7 @@
 STATIC_RW_DATA unsigned long malloc_ptr;
 STATIC_RW_DATA int malloc_count;
 
-static void *malloc(int size)
+static void *tmalloc(int size)
 {
 	void *p;
 
@@ -52,15 +52,17 @@ static void *malloc(int size)
 	return p;
 }
 
-static void free(void *where)
+static void tfree(void *where)
 {
 	malloc_count--;
 	if (!malloc_count)
 		malloc_ptr = free_mem_ptr;
 }
 
-#define large_malloc(a) malloc(a)
-#define large_free(a) free(a)
+#define malloc(a) tmalloc(a)
+#define free(a) tfree(a)
+#define large_malloc(a) tmalloc(a)
+#define large_free(a) tfree(a)
 
 #define INIT
 
-- 
2.16.2
