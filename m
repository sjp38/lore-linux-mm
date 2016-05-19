Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 422476B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 17:56:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 77so181745208pfz.3
        for <linux-mm@kvack.org>; Thu, 19 May 2016 14:56:14 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id z10si22654759pab.116.2016.05.19.14.56.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 14:56:12 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id y69so34018277pfb.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 14:56:11 -0700 (PDT)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] mm: move page_ext_init after all struct pages are initialized
Date: Thu, 19 May 2016 14:29:05 -0700
Message-Id: <1463693345-30842-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

When DEFERRED_STRUCT_PAGE_INIT is enabled, just a subset of memmap at boot
are initialized, then the rest are initialized in parallel by starting one-off
"pgdatinitX" kernel thread for each node X.

If page_ext_init is called before it, some pages will not have valid extension,
so move page_ext_init() after it.

CC: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 init/main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/init/main.c b/init/main.c
index b3c6e36..2075faf 100644
--- a/init/main.c
+++ b/init/main.c
@@ -606,7 +606,6 @@ asmlinkage __visible void __init start_kernel(void)
 		initrd_start = 0;
 	}
 #endif
-	page_ext_init();
 	debug_objects_mem_init();
 	kmemleak_init();
 	setup_per_cpu_pageset();
@@ -1004,6 +1003,8 @@ static noinline void __init kernel_init_freeable(void)
 	sched_init_smp();
 
 	page_alloc_init_late();
+	/* Initialize page ext after all struct pages are initializaed */
+	page_ext_init();
 
 	do_basic_setup();
 
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
