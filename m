Date: Mon, 25 Feb 2008 23:49:04 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 13/15] memcg: fix mem_cgroup_move_lists locking
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252347160.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ever since the VM_BUG_ON(page_get_page_cgroup(page)) (now Bad page state)
went into page freeing, I've hit it from time to time in testing on some
machines, sometimes only after many days.  Recently found a machine which
could usually produce it within a few hours, which got me there at last.

The culprit is mem_cgroup_move_lists, whose locking is inadequate; and
the arrangement of structures was such that you got page_cgroups from
the lru list neatly put on to SLUB's freelist.  Kamezawa-san identified
the same hole independently.

The main problem was that it was missing the lock_page_cgroup it needs
to safely page_get_page_cgroup; but it's tricky to go beyond that too,
and I couldn't do it with SLAB_DESTROY_BY_RCU as I'd expected.
See the code for comments on the constraints.

This patch immediately gets replaced by a simpler one from Hirokazu-san;
but is it just foolish pride that tells me to put this one on record,
in case we need to come back to it later?

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/memcontrol.c |   49 ++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 43 insertions(+), 6 deletions(-)

--- memcg12/mm/memcontrol.c	2008-02-25 14:06:21.000000000 +0000
+++ memcg13/mm/memcontrol.c	2008-02-25 14:06:25.000000000 +0000
@@ -277,6 +277,11 @@ static void lock_page_cgroup(struct page
 	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
 }
 
+static int try_lock_page_cgroup(struct page *page)
+{
+	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+}
+
 static void unlock_page_cgroup(struct page *page)
 {
 	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
@@ -348,17 +353,49 @@ int task_in_mem_cgroup(struct task_struc
 void mem_cgroup_move_lists(struct page *page, bool active)
 {
 	struct page_cgroup *pc;
+	struct mem_cgroup *mem;
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
 
-	pc = page_get_page_cgroup(page);
-	if (!pc)
+	/*
+	 * We cannot lock_page_cgroup while holding zone's lru_lock,
+	 * because other holders of lock_page_cgroup can be interrupted
+	 * with an attempt to rotate_reclaimable_page.  But we cannot
+	 * safely get to page_cgroup without it, so just try_lock it:
+	 * mem_cgroup_isolate_pages allows for page left on wrong list.
+	 */
+	if (!try_lock_page_cgroup(page))
 		return;
 
-	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_move_lists(pc, active);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	/*
+	 * Now page_cgroup is stable, but we cannot acquire mz->lru_lock
+	 * while holding it, because mem_cgroup_force_empty_list does the
+	 * reverse.  Get a hold on the mem_cgroup before unlocking, so that
+	 * the zoneinfo remains stable, then take mz->lru_lock; then check
+	 * that page still points to pc and pc (even if freed and reassigned
+	 * to that same page meanwhile) still points to the same mem_cgroup.
+	 * Then we know mz still points to the right spinlock, so it's safe
+	 * to move_lists (page->page_cgroup might be reset while we do so, but
+	 * that doesn't matter: pc->page is stable till we drop mz->lru_lock).
+	 * We're being a little naughty not to try_lock_page_cgroup again
+	 * inside there, but we are safe, aren't we?  Aren't we?  Whistle...
+	 */
+	pc = page_get_page_cgroup(page);
+	if (pc) {
+		mem = pc->mem_cgroup;
+		mz = page_cgroup_zoneinfo(pc);
+		css_get(&mem->css);
+
+		unlock_page_cgroup(page);
+
+		spin_lock_irqsave(&mz->lru_lock, flags);
+		if (page_get_page_cgroup(page) == pc && pc->mem_cgroup == mem)
+			__mem_cgroup_move_lists(pc, active);
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
+
+		css_put(&mem->css);
+	} else
+		unlock_page_cgroup(page);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
