Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3BE6B0008
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 14:48:19 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id z8-v6so1159620ybo.17
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 11:48:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r5-v6sor8451987ybb.198.2018.10.09.11.48.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 11:48:15 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/4] mm: workingset: don't drop refault information prematurely fix
Date: Tue,  9 Oct 2018 14:47:30 -0400
Message-Id: <20181009184732.762-2-hannes@cmpxchg.org>
In-Reply-To: <20181009184732.762-1-hannes@cmpxchg.org>
References: <20181009184732.762-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The shadow shrinker is invoked per NUMA node, but the shadow limit
enforced for cgroups is based on the page counter, which isn't NUMA
aware. Instead of shrinking shadow pages to desired_size, we end up
with desired_size * nr_online_nodes.

Switch to NUMA-aware lru and slab counters to approximate cgroup size.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/workingset.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index 1d111913929d..e5c70bc94077 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -418,9 +418,15 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	 * PAGE_SIZE / xa_nodes / node_entries * 8 / PAGE_SIZE
 	 */
 #ifdef CONFIG_MEMCG
-	if (sc->memcg)
-		pages = page_counter_read(&sc->memcg->memory);
-	else
+	if (sc->memcg) {
+		struct lruvec *lruvec;
+
+		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
+						     LRU_ALL);
+		lruvec = mem_cgroup_lruvec(NODE_DATA(sc->nid), sc->memcg);
+		pages += lruvec_page_state(lruvec, NR_SLAB_RECLAIMABLE);
+		pages += lruvec_page_state(lruvec, NR_SLAB_UNRECLAIMABLE);
+	} else
 #endif
 		pages = node_present_pages(sc->nid);
 
-- 
2.19.0
