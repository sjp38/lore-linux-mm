Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1AF6B0032
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 05:47:26 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so103483351wgy.2
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 02:47:25 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id wr1si23249588wjb.25.2015.04.09.02.47.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 02:47:24 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mempool: add missing include
Date: Thu, 09 Apr 2015 11:46:55 +0200
Message-ID: <3302342.cNyRUGN06P@wuerfel>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

This is a fix^3 for the mempool poisoning patch, which introduces
a compile-time error on some ARM randconfig builds:

mm/mempool.c: In function 'check_element':
mm/mempool.c:65:16: error: implicit declaration of function 'kmap_atomic' [-Werror=implicit-function-declaration]
   void *addr = kmap_atomic((struct page *)element);

The problem is clearly the missing declaration, and including
linux/highmem.h fixes it.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: a3db5a8463b0db ("mm, mempool: poison elements backed by page allocator fix fix")

diff --git a/mm/mempool.c b/mm/mempool.c
index 05ad55e61264..5e7c4a871391 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -12,6 +12,7 @@
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/kasan.h>
+#include <linux/highmem.h>
 #include <linux/kmemleak.h>
 #include <linux/export.h>
 #include <linux/mempool.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
