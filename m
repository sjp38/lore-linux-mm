Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C6DE76B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:27:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s3-v6so907218eds.15
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 10:27:28 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l8-v6si703621edb.188.2018.07.12.10.27.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Jul 2018 10:27:27 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 01/10] mm: workingset: don't drop refault information prematurely
Date: Thu, 12 Jul 2018 13:29:33 -0400
Message-Id: <20180712172942.10094-2-hannes@cmpxchg.org>
In-Reply-To: <20180712172942.10094-1-hannes@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <jweiner@fb.com>

If we just keep enough refault information to match the CURRENT page
cache during reclaim time, we could lose a lot of events when there is
only a temporary spike in non-cache memory consumption that pushes out
all the cache. Once cache comes back, we won't see those refaults.
They might not be actionable for LRU aging, but we want to know about
them for measuring memory pressure.

Signed-off-by: Johannes Weiner <jweiner@fb.com>
---
 mm/workingset.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index 40ee02c83978..53759a3cf99a 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -364,7 +364,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 {
 	unsigned long max_nodes;
 	unsigned long nodes;
-	unsigned long cache;
+	unsigned long pages;
 
 	/* list_lru lock nests inside the IRQ-safe i_pages lock */
 	local_irq_disable();
@@ -393,14 +393,14 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	 *
 	 * PAGE_SIZE / radix_tree_nodes / node_entries * 8 / PAGE_SIZE
 	 */
-	if (sc->memcg) {
-		cache = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
-						     LRU_ALL_FILE);
-	} else {
-		cache = node_page_state(NODE_DATA(sc->nid), NR_ACTIVE_FILE) +
-			node_page_state(NODE_DATA(sc->nid), NR_INACTIVE_FILE);
-	}
-	max_nodes = cache >> (RADIX_TREE_MAP_SHIFT - 3);
+#ifdef CONFIG_MEMCG
+	if (sc->memcg)
+		pages = page_counter_read(&sc->memcg->memory);
+	else
+#endif
+		pages = node_present_pages(sc->nid);
+
+	max_nodes = pages >> (RADIX_TREE_MAP_SHIFT - 3);
 
 	if (nodes <= max_nodes)
 		return 0;
-- 
2.18.0
