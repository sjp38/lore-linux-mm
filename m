Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 02DB26B0007
	for <linux-mm@kvack.org>; Wed, 30 May 2018 02:12:23 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id h62-v6so6958566vke.1
        for <linux-mm@kvack.org>; Tue, 29 May 2018 23:12:22 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f2-v6sor16565528uac.170.2018.05.29.23.12.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 23:12:21 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 29 May 2018 23:12:12 -0700
In-Reply-To: <20180529025722.GA25784@bombadil.infradead.org>
Message-Id: <20180530061212.84915-1-gthelen@google.com>
References: <20180529025722.GA25784@bombadil.infradead.org>
Subject: [PATCH v2] mm: condense scan_control
From: Greg Thelen <gthelen@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

Use smaller scan_control fields for order, priority, and reclaim_idx.
Convert fields from int => s8.  All easily fit within a byte:
* allocation order range: 0..MAX_ORDER(64?)
* priority range:         0..12(DEF_PRIORITY)
* reclaim_idx range:      0..6(__MAX_NR_ZONES)

Since commit 6538b8ea886e ("x86_64: expand kernel stack to 16K") x86_64
stack overflows are not an issue.  But it's inefficient to use ints.

Use s8 (signed byte) rather than u8 to allow for loops like:
	do {
		...
	} while (--sc.priority >= 0);

Add BUILD_BUG_ON to verify that s8 is capable of storing max values.

This reduces sizeof(struct scan_control):
* 96 => 80 bytes (x86_64)
* 68 => 56 bytes (i386)

scan_control structure field order is changed to utilize padding.
After this patch there is 1 bit of scan_control padding.

Signed-off-by: Greg Thelen <gthelen@google.com>
Suggested-by: Matthew Wilcox <willy@infradead.org>
---
 mm/vmscan.c | 32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9b697323a88c..42731faea306 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -65,12 +65,6 @@ struct scan_control {
 	/* How many pages shrink_list() should reclaim */
 	unsigned long nr_to_reclaim;
 
-	/* This context's GFP mask */
-	gfp_t gfp_mask;
-
-	/* Allocation order */
-	int order;
-
 	/*
 	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
 	 * are scanned.
@@ -83,12 +77,6 @@ struct scan_control {
 	 */
 	struct mem_cgroup *target_mem_cgroup;
 
-	/* Scan (total_size >> priority) pages at once */
-	int priority;
-
-	/* The highest zone to isolate pages for reclaim from */
-	enum zone_type reclaim_idx;
-
 	/* Writepage batching in laptop mode; RECLAIM_WRITE */
 	unsigned int may_writepage:1;
 
@@ -111,6 +99,18 @@ struct scan_control {
 	/* One of the zones is ready for compaction */
 	unsigned int compaction_ready:1;
 
+	/* Allocation order */
+	s8 order;
+
+	/* Scan (total_size >> priority) pages at once */
+	s8 priority;
+
+	/* The highest zone to isolate pages for reclaim from */
+	s8 reclaim_idx;
+
+	/* This context's GFP mask */
+	gfp_t gfp_mask;
+
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
 
@@ -3047,6 +3047,14 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.may_swap = 1,
 	};
 
+	/*
+	 * scan_control uses s8 fields for order, priority, and reclaim_idx.
+	 * Confirm they are large enough for max values.
+	 */
+	BUILD_BUG_ON(MAX_ORDER > S8_MAX);
+	BUILD_BUG_ON(DEF_PRIORITY > S8_MAX);
+	BUILD_BUG_ON(MAX_NR_ZONES > S8_MAX);
+
 	/*
 	 * Do not enter reclaim if fatal signal was delivered while throttled.
 	 * 1 is returned so that the page allocator does not OOM kill at this
-- 
2.17.0.921.gf22659ad46-goog
