Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85ED16B0260
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 11:33:43 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r79so1769923wrb.7
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 08:33:43 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m43si5928722edm.154.2017.11.03.08.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 03 Nov 2017 08:33:42 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/3] mm: memcontrol: implement lruvec stat functions on top of each other
Date: Fri,  3 Nov 2017 11:33:35 -0400
Message-Id: <20171103153336.24044-2-hannes@cmpxchg.org>
In-Reply-To: <20171103153336.24044-1-hannes@cmpxchg.org>
References: <20171103153336.24044-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com

The implementation of the lruvec stat functions and their variants for
accounting through a page, or accounting from a preemptible context,
are mostly identical and needlessly repetitive.

Implement the lruvec_page functions by looking up the page's lruvec
and then using the lruvec function.

Implement the functions for preemptible contexts by disabling
preemption before calling the atomic context functions.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 44 ++++++++++++++++++++++----------------------
 1 file changed, 22 insertions(+), 22 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 2c80b69dd266..1ffc54ac4cc9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -569,51 +569,51 @@ static inline void __mod_lruvec_state(struct lruvec *lruvec,
 {
 	struct mem_cgroup_per_node *pn;
 
+	/* Update node */
 	__mod_node_page_state(lruvec_pgdat(lruvec), idx, val);
+
 	if (mem_cgroup_disabled())
 		return;
+
 	pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
+
+	/* Update memcg */
 	__mod_memcg_state(pn->memcg, idx, val);
+
+	/* Update lruvec */
 	__this_cpu_add(pn->lruvec_stat->count[idx], val);
 }
 
 static inline void mod_lruvec_state(struct lruvec *lruvec,
 				    enum node_stat_item idx, int val)
 {
-	struct mem_cgroup_per_node *pn;
-
-	mod_node_page_state(lruvec_pgdat(lruvec), idx, val);
-	if (mem_cgroup_disabled())
-		return;
-	pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
-	mod_memcg_state(pn->memcg, idx, val);
-	this_cpu_add(pn->lruvec_stat->count[idx], val);
+	preempt_disable();
+	__mod_lruvec_state(lruvec, idx, val);
+	preempt_enable();
 }
 
 static inline void __mod_lruvec_page_state(struct page *page,
 					   enum node_stat_item idx, int val)
 {
-	struct mem_cgroup_per_node *pn;
+	pg_data_t *pgdat = page_pgdat(page);
+	struct lruvec *lruvec;
 
-	__mod_node_page_state(page_pgdat(page), idx, val);
-	if (mem_cgroup_disabled() || !page->mem_cgroup)
+	/* Untracked pages have no memcg, no lruvec. Update only the node */
+	if (!page->mem_cgroup) {
+		__mod_node_page_state(pgdat, idx, val);
 		return;
-	__mod_memcg_state(page->mem_cgroup, idx, val);
-	pn = page->mem_cgroup->nodeinfo[page_to_nid(page)];
-	__this_cpu_add(pn->lruvec_stat->count[idx], val);
+	}
+
+	lruvec = mem_cgroup_lruvec(pgdat, page->mem_cgroup);
+	__mod_lruvec_state(lruvec, idx, val);
 }
 
 static inline void mod_lruvec_page_state(struct page *page,
 					 enum node_stat_item idx, int val)
 {
-	struct mem_cgroup_per_node *pn;
-
-	mod_node_page_state(page_pgdat(page), idx, val);
-	if (mem_cgroup_disabled() || !page->mem_cgroup)
-		return;
-	mod_memcg_state(page->mem_cgroup, idx, val);
-	pn = page->mem_cgroup->nodeinfo[page_to_nid(page)];
-	this_cpu_add(pn->lruvec_stat->count[idx], val);
+	preempt_disable();
+	__mod_lruvec_page_state(page, idx, val);
+	preempt_enable();
 }
 
 unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
