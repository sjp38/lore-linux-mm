Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id F42256B00FC
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:23:49 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:23:49 -0800 (PST)
Subject: [PATCH v2 19/22] mm: handle lruvec relock in memory controller
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:23:47 +0400
Message-ID: <20120220172347.22196.22182.stgit@zurg>
In-Reply-To: <20120220171138.22196.65847.stgit@zurg>
References: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Carefully relock lruvec lru lock at page memory cgroup change.

* Stabilize PageLRU() sign with  __wait_lruvec_unlock(old_lruvec)
  It must be called between each pc->mem_cgroup change and
  page putback into new lruvec, otherwise someone else can lock old lruvec and
  see PageLRU(), while page already moved into other lruvec.
* In free_pn_rcu() wait for lruvec lock release.
  Locking primitives keep lruvec pointer after successful lock held.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/memcontrol.c |   36 ++++++++++++++++++++++++++++--------
 1 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 40e1a66..69763da 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2368,6 +2368,7 @@ static int mem_cgroup_move_account(struct page *page,
 	unsigned long flags;
 	int ret;
 	bool anon = PageAnon(page);
+	struct lruvec *old_lruvec;
 
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(page));
@@ -2397,12 +2398,24 @@ static int mem_cgroup_move_account(struct page *page,
 		preempt_enable();
 	}
 	mem_cgroup_charge_statistics(from, anon, -nr_pages);
+
+	/* charge keep old lruvec alive */
+	old_lruvec = page_lruvec(page);
+
+	/* caller should have done css_get */
+	pc->mem_cgroup = to;
+
+	/*
+	 * Stabilize PageLRU() sing for old_lruvec lock holder.
+	 * Do not putback page while someone hold old_lruvec lock,
+	 * otherwise it can think it catched page in old_lruvec lru.
+	 */
+	__wait_lruvec_unlock(old_lruvec);
+
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
 		__mem_cgroup_cancel_charge(from, nr_pages);
 
-	/* caller should have done css_get */
-	pc->mem_cgroup = to;
 	mem_cgroup_charge_statistics(to, anon, nr_pages);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
@@ -2528,7 +2541,6 @@ __mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
 					enum charge_type ctype)
 {
 	struct page_cgroup *pc = lookup_page_cgroup(page);
-	struct zone *zone = page_zone(page);
 	struct lruvec *lruvec;
 	unsigned long flags;
 	bool removed = false;
@@ -2538,20 +2550,19 @@ __mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
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
@@ -4648,7 +4659,16 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 
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
