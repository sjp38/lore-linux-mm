Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBC906B7E28
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 07:43:55 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g5-v6so7163730pgq.5
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 04:43:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g16-v6sor1378994pgg.427.2018.09.07.04.43.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 04:43:54 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] mm, page_alloc: drop should_suppress_show_mem
Date: Fri,  7 Sep 2018 13:43:34 +0200
Message-Id: <20180907114334.7088-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

should_suppress_show_mem has been introduced to reduce the overhead of
show_mem on large NUMA systems. Things have changed since then though.
Namely c78e93630d15 ("mm: do not walk all of system memory during
show_mem") has reduced the overhead considerably.

Moreover warn_alloc_show_mem clears SHOW_MEM_FILTER_NODES when called
from the IRQ context already so we are not printing per node stats.

Remove should_suppress_show_mem because we are losing potentially
interesting information about allocation failures. We have seen a bug
report where system gets unresponsive under memory pressure and there
is only
kernel: [2032243.696888] qlge 0000:8b:00.1 ql1: Could not get a page chunk, i=8, clean_idx =200 .
kernel: [2032243.710725] swapper/7: page allocation failure: order:1, mode:0x1084120(GFP_ATOMIC|__GFP_COLD|__GFP_COMP)

without an additional information for debugging. It would be great to
see the state of the page allocator at the moment.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 16 +---------------
 1 file changed, 1 insertion(+), 15 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 89d2a2ab3fe6..025f23dc282e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3366,26 +3366,12 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	return NULL;
 }
 
-/*
- * Large machines with many possible nodes should not always dump per-node
- * meminfo in irq context.
- */
-static inline bool should_suppress_show_mem(void)
-{
-	bool ret = false;
-
-#if NODES_SHIFT > 8
-	ret = in_interrupt();
-#endif
-	return ret;
-}
-
 static void warn_alloc_show_mem(gfp_t gfp_mask, nodemask_t *nodemask)
 {
 	unsigned int filter = SHOW_MEM_FILTER_NODES;
 	static DEFINE_RATELIMIT_STATE(show_mem_rs, HZ, 1);
 
-	if (should_suppress_show_mem() || !__ratelimit(&show_mem_rs))
+	if (!__ratelimit(&show_mem_rs))
 		return;
 
 	/*
-- 
2.18.0
