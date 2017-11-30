Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9F46B0253
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 17:15:32 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y23so4677402wra.16
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 14:15:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v205si3646175wmb.181.2017.11.30.14.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 14:15:31 -0800 (PST)
Date: Thu, 30 Nov 2017 14:15:28 -0800
From: akpm@linux-foundation.org
Subject: [patch 06/15] mm: memcontrol: implement lruvec stat functions on
 top of each other
Message-ID: <5a208300.vqwGf0+RdT8mDEMq%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.com, vdavydov.dev@gmail.com

From: Johannes Weiner <hannes@cmpxchg.org>
Subject: mm: memcontrol: implement lruvec stat functions on top of each other

The implementation of the lruvec stat functions and their variants for
accounting through a page, or accounting from a preemptible context, are
mostly identical and needlessly repetitive.

Implement the lruvec_page functions by looking up the page's lruvec and
then using the lruvec function.

Implement the functions for preemptible contexts by disabling preemption
before calling the atomic context functions.

Link: http://lkml.kernel.org/r/20171103153336.24044-2-hannes@cmpxchg.org
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/memcontrol.h |   44 +++++++++++++++++------------------
 1 file changed, 22 insertions(+), 22 deletions(-)

diff -puN include/linux/memcontrol.h~mm-memcontrol-implement-lruvec-stat-functions-on-top-of-each-other include/linux/memcontrol.h
--- a/include/linux/memcontrol.h~mm-memcontrol-implement-lruvec-stat-functions-on-top-of-each-other
+++ a/include/linux/memcontrol.h
@@ -569,51 +569,51 @@ static inline void __mod_lruvec_state(st
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
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
