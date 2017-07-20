Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3B36B0311
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 09:40:42 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l81so2798136wmg.8
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 06:40:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b23si6617756wra.151.2017.07.20.06.40.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 06:40:40 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 4/4] mm, page_ext: move page_ext_init() after page_alloc_init_late()
Date: Thu, 20 Jul 2017 15:40:29 +0200
Message-Id: <20170720134029.25268-5-vbabka@suse.cz>
In-Reply-To: <20170720134029.25268-1-vbabka@suse.cz>
References: <20170720134029.25268-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>, Vlastimil Babka <vbabka@suse.cz>

Commit b8f1a75d61d8 ("mm: call page_ext_init() after all struct pages are
initialized") has avoided a a NULL pointer dereference due to
DEFERRED_STRUCT_PAGE_INIT clashing with page_ext, by calling page_ext_init()
only after the deferred struct page init has finished. Later commit
fe53ca54270a ("mm: use early_pfn_to_nid in page_ext_init") avoided the
underlying issue differently and moved the page_ext_init() call back to where
it was before.

However, there are two problems with the current code:
- on very large machines, page_ext_init() may fail to allocate the page_ext
structures, because deferred struct page init hasn't yet started, and the
pre-inited part might be too small.
This has been observed with a 3TB machine with page_owner=on. Although it
was an older kernel where page_owner hasn't yet been converted to stack depot,
thus page_ext was larger, the fundamental problem is still in mainline.
- page_owner's init_pages_in_zone() is called before deferred struct page init
has started, so it will encounter unitialized struct pages. This currently
happens to cause no harm, because the memmap array is are pre-zeroed on
allocation and thus the "if (page_zone(page) != zone)" check is negative, but
that pre-zeroing guarantee might change soon.

The second problem could be also solved by limiting init_page_in_zone() by
pgdat->first_deferred_pfn, but fixing the first issue would be more
problematic. So this patch again moves page_ext_init() to wait for deferred
struct page init to finish. This has some performance implications for boot
time, which should be acceptable when enabling debugging functionality. We
however keep the benefits of parallel initialization (one kthread per node) so
it's better than e.g. disabling DEFERRED_STRUCT_PAGE_INIT completely when
page_ext is being used.

This effectively reverts commit fe53ca54270a757f0a28ee6bf3a54d952b550ed0.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 init/main.c   | 3 ++-
 mm/page_ext.c | 4 +---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/init/main.c b/init/main.c
index f866510472d7..7b6517fe0980 100644
--- a/init/main.c
+++ b/init/main.c
@@ -628,7 +628,6 @@ asmlinkage __visible void __init start_kernel(void)
 		initrd_start = 0;
 	}
 #endif
-	page_ext_init();
 	debug_objects_mem_init();
 	kmemleak_init();
 	setup_per_cpu_pageset();
@@ -1035,6 +1034,8 @@ static noinline void __init kernel_init_freeable(void)
 	sched_init_smp();
 
 	page_alloc_init_late();
+	/* Initialize page ext after all struct pages are initializaed */
+	page_ext_init();
 
 	do_basic_setup();
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 24cf8abefc8d..8522ebd784ac 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -402,10 +402,8 @@ void __init page_ext_init(void)
 			 * We know some arch can have a nodes layout such as
 			 * -------------pfn-------------->
 			 * N0 | N1 | N2 | N0 | N1 | N2|....
-			 *
-			 * Take into account DEFERRED_STRUCT_PAGE_INIT.
 			 */
-			if (early_pfn_to_nid(pfn) != nid)
+			if (pfn_to_nid(pfn) != nid)
 				continue;
 			if (init_section_page_ext(pfn, nid))
 				goto oom;
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
