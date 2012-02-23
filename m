Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 0B68F6B0101
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:53:13 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1365307bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 05:53:13 -0800 (PST)
Subject: [PATCH v3 17/21] mm: handle lruvec relock in memory controller
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 23 Feb 2012 17:53:10 +0400
Message-ID: <20120223135310.12988.46867.stgit@zurg>
In-Reply-To: <20120223133728.12988.5432.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>

Carefully relock lruvec lru lock at page memory cgroup change.

* In free_pn_rcu() wait for lruvec lock release.
  Locking primitives keep lruvec pointer after successful lock held.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/memcontrol.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index aed1360..230f434 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2542,7 +2542,6 @@ __mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
 					enum charge_type ctype)
 {
 	struct page_cgroup *pc = lookup_page_cgroup(page);
-	struct zone *zone = page_zone(page);
 	struct lruvec *lruvec;
 	unsigned long flags;
 	bool removed = false;
@@ -2552,20 +2551,19 @@ __mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
 	 * is already on LRU. It means the page may on some other page_cgroup's
 	 * LRU. Take care of it.
 	 */
-	spin_lock_irqsave(&zone->lru_lock, flags);
+	lruvec = lock_page_lruvec(page, &flags);
 	if (PageLRU(page)) {
-		lruvec = page_lruvec(page);
 		del_page_from_lru_list(lruvec, page, page_lru(page));
 		ClearPageLRU(page);
 		removed = true;
 	}
 	__mem_cgroup_commit_charge(memcg, page, 1, pc, ctype);
 	if (removed) {
-		lruvec = page_lruvec(page);
+		lruvec = __relock_page_lruvec(lruvec, page);
 		add_page_to_lru_list(lruvec, page, page_lru(page));
 		SetPageLRU(page);
 	}
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
+	unlock_lruvec(lruvec, &flags);
 }
 
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
@@ -4624,7 +4622,16 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 
 static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
-	kfree(memcg->info.nodeinfo[node]);
+	struct mem_cgroup_per_node *pn = memcg->info.nodeinfo[node];
+	int zone;
+
+	if (!pn)
+		return;
+
+	for (zone = 0; zone < MAX_NR_ZONES; zone++)
+		wait_lruvec_unlock(&pn->zoneinfo[zone].lruvec);
+
+	kfree(pn);
 }
 
 static struct mem_cgroup *mem_cgroup_alloc(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
