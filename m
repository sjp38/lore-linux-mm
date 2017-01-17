Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C71406B0253
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 04:15:54 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r144so32167233wme.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:15:54 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id o131si9457367wmd.167.2017.01.17.01.15.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 01:15:53 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id c85so4419065wmi.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:15:53 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/4] mm, page_alloc: warn_alloc print nodemask
Date: Tue, 17 Jan 2017 10:15:41 +0100
Message-Id: <20170117091543.25850-3-mhocko@kernel.org>
In-Reply-To: <20170117091543.25850-1-mhocko@kernel.org>
References: <20170117091543.25850-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

warn_alloc is currently used for to report an allocation failure or an
allocation stall. We print some details of the allocation request like
the gfp mask and the request order. We do not print the allocation
nodemask which is important when debugging the reason for the allocation
failure as well. We alreaddy print the nodemask in the OOM report.

Add nodemask to warn_alloc and print it in warn_alloc as well.

Changes since v1
- print cpusets as well - Vlastimil

Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm.h |  4 ++--
 mm/page_alloc.c    | 10 ++++++----
 mm/vmalloc.c       |  4 ++--
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 57dc3c3b53c1..3e35eb04a28a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1912,8 +1912,8 @@ extern void si_meminfo_node(struct sysinfo *val, int nid);
 extern unsigned long arch_reserved_kernel_pages(void);
 #endif
 
-extern __printf(2, 3)
-void warn_alloc(gfp_t gfp_mask, const char *fmt, ...);
+extern __printf(3, 4)
+void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...);
 
 extern void setup_per_cpu_pageset(void);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8f4f306d804c..7f9c0ee18ae0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3031,12 +3031,13 @@ static void warn_alloc_show_mem(gfp_t gfp_mask)
 	show_mem(filter);
 }
 
-void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
+void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 {
 	struct va_format vaf;
 	va_list args;
 	static DEFINE_RATELIMIT_STATE(nopage_rs, DEFAULT_RATELIMIT_INTERVAL,
 				      DEFAULT_RATELIMIT_BURST);
+	nodemask_t *nm = (nodemask) ? nodemask : &cpuset_current_mems_allowed;
 
 	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
 	    debug_guardpage_minorder() > 0)
@@ -3050,7 +3051,8 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 	pr_cont("%pV", &vaf);
 	va_end(args);
 
-	pr_cont(", mode:%#x(%pGg)\n", gfp_mask, &gfp_mask);
+	pr_cont(", mode:%#x(%pGg), nodemask=%*pbl\n", gfp_mask, &gfp_mask, nodemask_pr_args(nm));
+	cpuset_print_current_mems_allowed();
 
 	dump_stack();
 	warn_alloc_show_mem(gfp_mask);
@@ -3709,7 +3711,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 	/* Make sure we know about allocations which stall for too long */
 	if (time_after(jiffies, alloc_start + stall_timeout)) {
-		warn_alloc(gfp_mask,
+		warn_alloc(gfp_mask, ac->nodemask,
 			"page allocation stalls for %ums, order:%u",
 			jiffies_to_msecs(jiffies-alloc_start), order);
 		stall_timeout += 10 * HZ;
@@ -3743,7 +3745,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	}
 
 nopage:
-	warn_alloc(gfp_mask,
+	warn_alloc(gfp_mask, ac->nodemask,
 			"page allocation failure: order:%u", order);
 got_pg:
 	return page;
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index b9999fc44aa6..0600bbbd1080 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1662,7 +1662,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	return area->addr;
 
 fail:
-	warn_alloc(gfp_mask,
+	warn_alloc(gfp_mask, NULL,
 			  "vmalloc: allocation failure, allocated %ld of %ld bytes",
 			  (area->nr_pages*PAGE_SIZE), area->size);
 	vfree(area->addr);
@@ -1724,7 +1724,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	return addr;
 
 fail:
-	warn_alloc(gfp_mask,
+	warn_alloc(gfp_mask, NULL,
 			  "vmalloc: allocation failure: %lu bytes", real_size);
 	return NULL;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
