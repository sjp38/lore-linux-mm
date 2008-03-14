Date: Fri, 14 Mar 2008 19:07:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/7] memcg: move_lists
Message-Id: <20080314190731.b3635ae9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Modifies mem_cgroup_move_lists() to use get_page_cgroup().
No major algorithm changes just adjusted to new locks.

Signed-off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memcontrol.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

Index: mm-2.6.25-rc5-mm1/mm/memcontrol.c
===================================================================
--- mm-2.6.25-rc5-mm1.orig/mm/memcontrol.c
+++ mm-2.6.25-rc5-mm1/mm/memcontrol.c
@@ -309,6 +309,10 @@ void mem_cgroup_move_lists(struct page *
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
 
+	/* This GFP will be ignored..*/
+	pc = get_page_cgroup(page, GFP_ATOMIC, false);
+	if (!pc)
+		return;
 	/*
 	 * We cannot lock_page_cgroup while holding zone's lru_lock,
 	 * because other holders of lock_page_cgroup can be interrupted
@@ -316,17 +320,15 @@ void mem_cgroup_move_lists(struct page *
 	 * safely get to page_cgroup without it, so just try_lock it:
 	 * mem_cgroup_isolate_pages allows for page left on wrong list.
 	 */
-	if (!try_lock_page_cgroup(page))
+	if (!spin_trylock_irqsave(&pc->lock, flags))
 		return;
-
-	pc = page_get_page_cgroup(page);
-	if (pc) {
+	if (pc->refcnt) {
 		mz = page_cgroup_zoneinfo(pc);
-		spin_lock_irqsave(&mz->lru_lock, flags);
+		spin_lock(&mz->lru_lock);
 		__mem_cgroup_move_lists(pc, active);
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
+		spin_unlock(&mz->lru_lock);
 	}
-	unlock_page_cgroup(page);
+	spin_unlock_irqrestore(&pc->lock, flags);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
