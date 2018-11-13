Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 56CE76B026A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 03:04:53 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id z22-v6so9009084pfi.0
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 00:04:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b23-v6sor14393473pls.11.2018.11.13.00.04.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 00:04:52 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v2] vmscan: return NODE_RECLAIM_NOSCAN in node_reclaim() when CONFIG_NUMA is n
Date: Tue, 13 Nov 2018 16:04:36 +0800
Message-Id: <20181113080436.22078-1-richard.weiyang@gmail.com>
In-Reply-To: <20181113041750.20784-1-richard.weiyang@gmail.com>
References: <20181113041750.20784-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@techsingularity.net
Cc: willy@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

Commit fa5e084e43eb ("vmscan: do not unconditionally treat zones that
fail zone_reclaim() as full") changed the return value of node_reclaim().
The original return value 0 means NODE_RECLAIM_SOME after this commit.

While the return value of node_reclaim() when CONFIG_NUMA is n is not
changed. This will leads to call zone_watermark_ok() again.

This patch fix the return value by adjusting to NODE_RECLAIM_NOSCAN. Since
node_reclaim() is only called in page_alloc.c, move it to mm/internal.h.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
v2:  move node_reclaim() to mm/internal.h
---
 include/linux/swap.h |  6 ------
 mm/internal.h        | 10 ++++++++++
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index d8a07a4f171d..065988c27373 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -358,14 +358,8 @@ extern unsigned long vm_total_pages;
 extern int node_reclaim_mode;
 extern int sysctl_min_unmapped_ratio;
 extern int sysctl_min_slab_ratio;
-extern int node_reclaim(struct pglist_data *, gfp_t, unsigned int);
 #else
 #define node_reclaim_mode 0
-static inline int node_reclaim(struct pglist_data *pgdat, gfp_t mask,
-				unsigned int order)
-{
-	return 0;
-}
 #endif
 
 extern int page_evictable(struct page *page);
diff --git a/mm/internal.h b/mm/internal.h
index 291eb2b6d1d8..6a57811ae47d 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -444,6 +444,16 @@ static inline void mminit_validate_memmodel_limits(unsigned long *start_pfn,
 #define NODE_RECLAIM_SOME	0
 #define NODE_RECLAIM_SUCCESS	1
 
+#ifdef CONFIG_NUMA
+extern int node_reclaim(struct pglist_data *, gfp_t, unsigned int);
+#else
+static inline int node_reclaim(struct pglist_data *pgdat, gfp_t mask,
+				unsigned int order)
+{
+	return NODE_RECLAIM_NOSCAN;
+}
+#endif
+
 extern int hwpoison_filter(struct page *p);
 
 extern u32 hwpoison_filter_dev_major;
-- 
2.15.1
