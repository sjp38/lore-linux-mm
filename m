Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 95AB528025C
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 04:44:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b4so6646509wmb.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 01:44:23 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id fo2si13541834wjb.71.2016.09.29.01.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 01:44:20 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id b184so9581237wma.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 01:44:20 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm: consolidate warn_alloc_failed users
Date: Thu, 29 Sep 2016 10:44:06 +0200
Message-Id: <20160929084407.7004-2-mhocko@kernel.org>
In-Reply-To: <20160929084407.7004-1-mhocko@kernel.org>
References: <20160923081555.14645-1-mhocko@kernel.org>
 <20160929084407.7004-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

warn_alloc_failed is currently used from the page and vmalloc
allocators. This is a good reuse of the code except that vmalloc would
appreciate a slightly different warning message. This is already handled
by the fmt parameter except that

"%s: page allocation failure: order:%u, mode:%#x(%pGg)"

is printed anyway. This might be quite misleading because it might be
a vmalloc failure which leads to the warning while the page allocator is
not the culprit here. Fix this by always using the fmt string and only
print the context that makes sense for the particular context (e.g.
order makes only very little sense for the vmalloc context). Rename
the function to not miss any user and also because a later patch will
reuse it also for !failure cases.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm.h |  5 ++---
 mm/page_alloc.c    | 27 ++++++++++++---------------
 mm/vmalloc.c       | 14 ++++++--------
 3 files changed, 20 insertions(+), 26 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5db886915265..df4a6c02e421 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1916,9 +1916,8 @@ extern void si_meminfo_node(struct sysinfo *val, int nid);
 extern unsigned long arch_reserved_kernel_pages(void);
 #endif
 
-extern __printf(3, 4)
-void warn_alloc_failed(gfp_t gfp_mask, unsigned int order,
-		const char *fmt, ...);
+extern __printf(2, 3)
+void warn_alloc(gfp_t gfp_mask, const char *fmt, ...);
 
 extern void setup_per_cpu_pageset(void);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fab8b6913179..969ffc97045b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2981,9 +2981,11 @@ static DEFINE_RATELIMIT_STATE(nopage_rs,
 		DEFAULT_RATELIMIT_INTERVAL,
 		DEFAULT_RATELIMIT_BURST);
 
-void warn_alloc_failed(gfp_t gfp_mask, unsigned int order, const char *fmt, ...)
+void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 {
 	unsigned int filter = SHOW_MEM_FILTER_NODES;
+	struct va_format vaf;
+	va_list args;
 
 	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
 	    debug_guardpage_minorder() > 0)
@@ -3001,22 +3003,16 @@ void warn_alloc_failed(gfp_t gfp_mask, unsigned int order, const char *fmt, ...)
 	if (in_interrupt() || !(gfp_mask & __GFP_DIRECT_RECLAIM))
 		filter &= ~SHOW_MEM_FILTER_NODES;
 
-	if (fmt) {
-		struct va_format vaf;
-		va_list args;
+	pr_warn("%s: ", current->comm);
 
-		va_start(args, fmt);
+	va_start(args, fmt);
+	vaf.fmt = fmt;
+	vaf.va = &args;
+	pr_cont("%pV", &vaf);
+	va_end(args);
 
-		vaf.fmt = fmt;
-		vaf.va = &args;
+	pr_cont(", mode:%#x(%pGg)\n", gfp_mask, &gfp_mask);
 
-		pr_warn("%pV", &vaf);
-
-		va_end(args);
-	}
-
-	pr_warn("%s: page allocation failure: order:%u, mode:%#x(%pGg)\n",
-		current->comm, order, gfp_mask, &gfp_mask);
 	dump_stack();
 	if (!should_suppress_show_mem())
 		show_mem(filter);
@@ -3682,7 +3678,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	}
 
 nopage:
-	warn_alloc_failed(gfp_mask, order, NULL);
+	warn_alloc(gfp_mask,
+			"page allocation failure: order:%u", order);
 got_pg:
 	return page;
 }
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 80660a0f989b..f2481cb4e6b2 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1601,7 +1601,6 @@ static void *__vmalloc_node(unsigned long size, unsigned long align,
 static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 				 pgprot_t prot, int node)
 {
-	const int order = 0;
 	struct page **pages;
 	unsigned int nr_pages, array_size, i;
 	const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
@@ -1629,9 +1628,9 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 		struct page *page;
 
 		if (node == NUMA_NO_NODE)
-			page = alloc_pages(alloc_mask, order);
+			page = alloc_page(alloc_mask);
 		else
-			page = alloc_pages_node(node, alloc_mask, order);
+			page = alloc_pages_node(node, alloc_mask, 0);
 
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
@@ -1648,8 +1647,8 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	return area->addr;
 
 fail:
-	warn_alloc_failed(gfp_mask, order,
-			  "vmalloc: allocation failure, allocated %ld of %ld bytes\n",
+	warn_alloc(gfp_mask,
+			  "vmalloc: allocation failure, allocated %ld of %ld bytes",
 			  (area->nr_pages*PAGE_SIZE), area->size);
 	vfree(area->addr);
 	return NULL;
@@ -1710,9 +1709,8 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	return addr;
 
 fail:
-	warn_alloc_failed(gfp_mask, 0,
-			  "vmalloc: allocation failure: %lu bytes\n",
-			  real_size);
+	warn_alloc(gfp_mask,
+			  "vmalloc: allocation failure: %lu bytes", real_size);
 	return NULL;
 }
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
