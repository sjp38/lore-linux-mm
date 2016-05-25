Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id E89786B0005
	for <linux-mm@kvack.org>; Wed, 25 May 2016 14:18:49 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id x1so70863530pav.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 11:18:49 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id m127si164753pfb.118.2016.05.25.11.18.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 11:18:48 -0700 (PDT)
Received: by mail-pa0-x22a.google.com with SMTP id xk12so19957080pac.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 11:18:48 -0700 (PDT)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] mm: use early_pfn_to_nid in page_ext_init
Date: Wed, 25 May 2016 10:51:29 -0700
Message-Id: <1464198689-23458-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

page_ext_init() checks suitable pages with pfn_to_nid(), but pfn_to_nid()
depends on memmap which will not be setup fully until page_alloc_init_late()
is done. Use early_pfn_to_nid() instead of pfn_to_nid() so that page extension
could be still used early even though CONFIG_ DEFERRED_STRUCT_PAGE_INIT is
enabled and catch early page allocation call sites.

Suggested by Joonsoo Kim [1], this fix basically undoes the change introduced
by commit b8f1a75d61d8405a753380c6fb17ba84a5603cd4 ("mm: call page_ext_init()
after all struct pages are initialized") and fixes the same problem with
a better approach.

[1] http://lkml.kernel.org/r/CAAmzW4OUmyPwQjvd7QUfc6W1Aic__TyAuH80MLRZNMxKy0-wPQ@mail.gmail.com

CC: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 init/main.c   | 3 +--
 mm/page_ext.c | 4 +++-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/init/main.c b/init/main.c
index bc0f9e0..4c17fda 100644
--- a/init/main.c
+++ b/init/main.c
@@ -607,6 +607,7 @@ asmlinkage __visible void __init start_kernel(void)
 		initrd_start = 0;
 	}
 #endif
+	page_ext_init();
 	debug_objects_mem_init();
 	kmemleak_init();
 	setup_per_cpu_pageset();
@@ -1003,8 +1004,6 @@ static noinline void __init kernel_init_freeable(void)
 	sched_init_smp();
 
 	page_alloc_init_late();
-	/* Initialize page ext after all struct pages are initializaed */
-	page_ext_init();
 
 	do_basic_setup();
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 2d864e6..44a4c02 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -390,8 +390,10 @@ void __init page_ext_init(void)
 			 * We know some arch can have a nodes layout such as
 			 * -------------pfn-------------->
 			 * N0 | N1 | N2 | N0 | N1 | N2|....
+			 *
+			 * Take into account DEFERRED_STRUCT_PAGE_INIT.
 			 */
-			if (pfn_to_nid(pfn) != nid)
+			if (early_pfn_to_nid(pfn) != nid)
 				continue;
 			if (init_section_page_ext(pfn, nid))
 				goto oom;
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
