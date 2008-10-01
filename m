Date: Wed, 1 Oct 2008 16:59:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/6] memcg: new force_empty and move_account
Message-Id: <20081001165912.236af3e7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch provides a function to move account information of a page between
mem_cgroups and rewrite force_empty to make use of this.

This moving of page_cgroup is done under
 - lru_lock of source/destination mem_cgroup is held.
 - lock_page_cgroup() is held.

Then, a routine which touches pc->mem_cgroup without lock_page_cgroup() should
confirm pc->mem_cgroup is still valid or not. Typlical code can be following.

(while page is not under lock_page())
	mem = pc->mem_cgroup;
	mz = page_cgroup_zoneinfo(pc)
	spin_lock_irqsave(&mz->lru_lock);
	if (pc->mem_cgroup == mem)
		...../* some list handling */
	spin_unlock_irq(&mz->lru_lock);

Of course, better way is
	lock_page_cgroup(pc);
	....
	unlock_page_cgroup(pc);

But you should confirm the nest of lock and avoid deadlock.

If you treats page_cgroup from mem_cgroup's LRU under mz->lru_lock,
you don't have to worry about what pc->mem_cgroup points to.
moved pages are added to head of lru, not to tail.

Expected users of this routine is:
  - force_empty (rmdir)
  - moving tasks between cgroup (for moving account information.)
  - hierarchy (maybe useful.)

force_empty(rmdir) uses this move_account and move pages to its parent.
This "move" will not cause OOM (I added "oom" parameter to try_charge().)

If the parent is busy (not enough memory), force_empty calls try_to_free_page()
and reduce usage.

Purpose of this behavior is
  - Fix "forget all" behavior of force_empty and avoid leak of accounting.
  - By "moving first, free if necessary", keep pages on memory as much as
    possible.

Adding a switch to change behavior of force_empty to
  - free first, move if necessary
  - free all, if there is mlocked/busy pages, return -EBUSY.
is under consideration.

Changelog: (v5) -> (v6)
  - removed unnecessary check.
  - do all under lock_page_cgroup().
  - removed res_counter_charge() from move function itself.
    (and modifies try_charge() function.)
  - add argument to add_list() to specify to add page_cgroup head or tail.
  - merged with force_empty patch. (to answer who is user? question)

Changelog: (v4) -> (v5)
  - check for lock_page() is removed.
  - rewrote description.

Changelog: (v2) -> (v4)
  - added lock_page_cgroup().
  - splitted out from new-force-empty patch.
  - added how-to-use text.
  - fixed race in __mem_cgroup_uncharge_common().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 Documentation/controllers/memory.txt |   10 -
 mm/memcontrol.c                      |  267 +++++++++++++++++++++++++++--------
 2 files changed, 216 insertions(+), 61 deletions(-)

Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc7+/mm/memcontrol.c
@@ -257,7 +257,7 @@ static void __mem_cgroup_remove_list(str
 }
 
 static void __mem_cgroup_add_list(struct mem_cgroup_per_zone *mz,
-				struct page_cgroup *pc)
+				struct page_cgroup *pc, bool hot)
 {
 	int lru = LRU_BASE;
 
@@ -271,7 +271,10 @@ static void __mem_cgroup_add_list(struct
 	}
 
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
-	list_add(&pc->lru, &mz->lists[lru]);
+	if (hot)
+		list_add(&pc->lru, &mz->lists[lru]);
+	else
+		list_add_tail(&pc->lru, &mz->lists[lru]);
 
 	mem_cgroup_charge_statistics(pc->mem_cgroup, pc, true);
 }
@@ -467,21 +470,12 @@ unsigned long mem_cgroup_isolate_pages(u
 	return nr_taken;
 }
 
-
-/**
- * mem_cgroup_try_charge - get charge of PAGE_SIZE.
- * @mm: an mm_struct which is charged against. (when *memcg is NULL)
- * @gfp_mask: gfp_mask for reclaim.
- * @memcg: a pointer to memory cgroup which is charged against.
- *
- * charge aginst memory cgroup pointed by *memcg. if *memcg == NULL, estimated
- * memory cgroup from @mm is got and stored in *memcg.
- *
- * Retruns 0 if success. -ENOMEM at failure.
+/*
+ * Unlike exported interface, "oom" parameter is added. if oom==true,
+ * oom-killer can be invoked.
  */
-
-int mem_cgroup_try_charge(struct mm_struct *mm,
-			gfp_t gfp_mask, struct mem_cgroup **memcg)
+static int __mem_cgroup_try_charge(struct mm_struct *mm,
+			gfp_t gfp_mask, struct mem_cgroup **memcg, bool oom)
 {
 	struct mem_cgroup *mem;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
@@ -528,7 +522,8 @@ int mem_cgroup_try_charge(struct mm_stru
 			continue;
 
 		if (!nr_retries--) {
-			mem_cgroup_out_of_memory(mem, gfp_mask);
+			if (oom)
+				mem_cgroup_out_of_memory(mem, gfp_mask);
 			goto nomem;
 		}
 	}
@@ -538,6 +533,24 @@ nomem:
 	return -ENOMEM;
 }
 
+/**
+ * mem_cgroup_try_charge - get charge of PAGE_SIZE.
+ * @mm: an mm_struct which is charged against. (when *memcg is NULL)
+ * @gfp_mask: gfp_mask for reclaim.
+ * @memcg: a pointer to memory cgroup which is charged against.
+ *
+ * charge aginst memory cgroup pointed by *memcg. if *memcg == NULL, estimated
+ * memory cgroup from @mm is got and stored in *memcg.
+ *
+ * Retruns 0 if success. -ENOMEM at failure.
+ */
+
+int mem_cgroup_try_charge(struct mm_struct *mm,
+			  gfp_t mask, struct mem_cgroup **memcg)
+{
+	return __mem_cgroup_try_charge(mm, mask, memcg, false);
+}
+
 /*
  * commit a charge got by mem_cgroup_try_charge() and makes page_cgroup to be
  * USED state. If already USED, uncharge and return.
@@ -567,11 +580,109 @@ static void __mem_cgroup_commit_charge(s
 	mz = page_cgroup_zoneinfo(pc);
 
 	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_add_list(mz, pc);
+	__mem_cgroup_add_list(mz, pc, true);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 	unlock_page_cgroup(pc);
 }
 
+/**
+ * mem_cgroup_move_account - move account of the page
+ * @pc   ... page_cgroup of the page.
+ * @from ... mem_cgroup which the page is moved from.
+ * @to   ... mem_cgroup which the page is moved to. @from != @to.
+ *
+ * The caller must confirm following.
+ * 1. disable irq.
+ * 2. lru_lock of old mem_cgroup(@from) should be held.
+ *
+ * returns 0 at success,
+ * returns -EBUSY when lock is busy or "pc" is unstable.
+ *
+ * This function do "uncharge" from old cgroup but doesn't do "charge" to
+ * new cgroup. It should be done by a caller.
+ */
+
+static int mem_cgroup_move_account(struct page_cgroup *pc,
+	struct mem_cgroup *from, struct mem_cgroup *to)
+{
+	struct mem_cgroup_per_zone *from_mz, *to_mz;
+	int nid, zid;
+	int ret = -EBUSY;
+
+	VM_BUG_ON(!irqs_disabled());
+	VM_BUG_ON(from == to);
+
+	nid = page_cgroup_nid(pc);
+	zid = page_cgroup_zid(pc);
+	from_mz =  mem_cgroup_zoneinfo(from, nid, zid);
+	to_mz =  mem_cgroup_zoneinfo(to, nid, zid);
+
+
+	if (!trylock_page_cgroup(pc))
+		return ret;
+
+	if (!PageCgroupUsed(pc))
+		goto out;
+
+	if (pc->mem_cgroup != from)
+		goto out;
+
+	if (spin_trylock(&to_mz->lru_lock)) {
+		__mem_cgroup_remove_list(from_mz, pc);
+		css_put(&from->css);
+		res_counter_uncharge(&from->res, PAGE_SIZE);
+		pc->mem_cgroup = to;
+		css_get(&to->css);
+		__mem_cgroup_add_list(to_mz, pc, false);
+		ret = 0;
+		spin_unlock(&to_mz->lru_lock);
+	}
+out:
+	unlock_page_cgroup(pc);
+	return ret;
+}
+
+/*
+ * move charges to its parent.
+ */
+
+static int mem_cgroup_move_parent(struct page_cgroup *pc,
+				  struct mem_cgroup *child,
+				  gfp_t gfp_mask)
+{
+	struct cgroup *cg = child->css.cgroup;
+	struct cgroup *pcg = cg->parent;
+	struct mem_cgroup *parent;
+	struct mem_cgroup_per_zone *mz;
+	unsigned long flags;
+	int ret;
+
+	/* Is ROOT ? */
+	if (!pcg)
+		return -EINVAL;
+
+	parent = mem_cgroup_from_cont(pcg);
+
+	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false);
+	if (ret)
+		return ret;
+
+	mz = mem_cgroup_zoneinfo(child,
+			page_cgroup_nid(pc), page_cgroup_zid(pc));
+
+	spin_lock_irqsave(&mz->lru_lock, flags);
+	ret = mem_cgroup_move_account(pc, child, parent);
+	spin_unlock_irqrestore(&mz->lru_lock, flags);
+
+	/* drop extra refcnt */
+	css_put(&parent->css);
+	/* uncharge if move fails */
+	if (ret)
+		res_counter_uncharge(&parent->res, PAGE_SIZE);
+
+	return ret;
+}
+
 /*
  * Charge the memory controller for page usage.
  * Return
@@ -593,7 +704,7 @@ static int mem_cgroup_charge_common(stru
 	prefetchw(pc);
 
 	mem = memcg;
-	ret = mem_cgroup_try_charge(mm, gfp_mask, &mem);
+	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true);
 	if (ret)
 		return ret;
 
@@ -896,46 +1007,52 @@ int mem_cgroup_resize_limit(struct mem_c
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
  */
-#define FORCE_UNCHARGE_BATCH	(128)
-static void mem_cgroup_force_empty_list(struct mem_cgroup *mem,
+static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 			    struct mem_cgroup_per_zone *mz,
 			    enum lru_list lru)
 {
-	struct page_cgroup *pc;
-	struct page *page;
-	int count = FORCE_UNCHARGE_BATCH;
+	struct page_cgroup *pc, *busy;
 	unsigned long flags;
+	unsigned long loop;
 	struct list_head *list;
+	int ret = 0;
 
 	list = &mz->lists[lru];
 
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	while (!list_empty(list)) {
-		pc = list_entry(list->prev, struct page_cgroup, lru);
-		page = pc->page;
-		if (!PageCgroupUsed(pc))
+	loop = MEM_CGROUP_ZSTAT(mz, lru);
+	/* give some margin against EBUSY etc...*/
+	loop += 256;
+	busy = NULL;
+	while (loop--) {
+		ret = 0;
+		spin_lock_irqsave(&mz->lru_lock, flags);
+		if (list_empty(list)) {
+			spin_unlock_irqrestore(&mz->lru_lock, flags);
 			break;
-		get_page(page);
+		}
+		pc = list_entry(list->prev, struct page_cgroup, lru);
+		if (busy == pc) {
+			list_move(&pc->lru, list);
+			busy = 0;
+			spin_unlock_irqrestore(&mz->lru_lock, flags);
+			continue;
+		}
 		spin_unlock_irqrestore(&mz->lru_lock, flags);
-		/*
-		 * Check if this page is on LRU. !LRU page can be found
-		 * if it's under page migration.
-		 */
-		if (PageLRU(page)) {
-			__mem_cgroup_uncharge_common(page,
-					MEM_CGROUP_CHARGE_TYPE_FORCE);
-			put_page(page);
-			if (--count <= 0) {
-				count = FORCE_UNCHARGE_BATCH;
-				cond_resched();
-			}
-		} else {
-			spin_lock_irqsave(&mz->lru_lock, flags);
+
+		ret = mem_cgroup_move_parent(pc, mem, GFP_HIGHUSER_MOVABLE);
+		if (ret == -ENOMEM)
 			break;
-		}
-		spin_lock_irqsave(&mz->lru_lock, flags);
+
+		if (ret == -EBUSY || ret == -EINVAL) {
+			/* found lock contention or "pc" is obsolete. */
+			busy = pc;
+			cond_resched();
+		} else
+			busy = NULL;
 	}
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	if (!ret && !list_empty(list))
+		return -EBUSY;
+	return ret;
 }
 
 /*
@@ -944,32 +1061,66 @@ static void mem_cgroup_force_empty_list(
  */
 static int mem_cgroup_force_empty(struct mem_cgroup *mem)
 {
-	int ret = -EBUSY;
-	int node, zid;
+	int ret;
+	int node, zid, shrink;
+	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 
 	css_get(&mem->css);
-	/*
-	 * page reclaim code (kswapd etc..) will move pages between
-	 * active_list <-> inactive_list while we don't take a lock.
-	 * So, we have to do loop here until all lists are empty.
-	 */
+
+	shrink = 0;
+move_account:
 	while (mem->res.usage > 0) {
+		ret = -EBUSY;
 		if (atomic_read(&mem->css.cgroup->count) > 0)
 			goto out;
-		for_each_node_state(node, N_POSSIBLE)
-			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+
+		ret = 0;
+		for_each_node_state(node, N_POSSIBLE) {
+			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
 				struct mem_cgroup_per_zone *mz;
 				enum lru_list l;
 				mz = mem_cgroup_zoneinfo(mem, node, zid);
-				for_each_lru(l)
-					mem_cgroup_force_empty_list(mem, mz, l);
+				for_each_lru(l) {
+					ret = mem_cgroup_force_empty_list(mem,
+								  mz, l);
+					if (ret)
+						break;
+				}
 			}
+			if (ret)
+				break;
+		}
+		/* it seems parent cgroup doesn't have enough mem */
+		if (ret == -ENOMEM)
+			goto try_to_free;
 		cond_resched();
 	}
 	ret = 0;
 out:
 	css_put(&mem->css);
 	return ret;
+
+try_to_free:
+	/* returns EBUSY if we come here twice. */
+	if (shrink)  {
+		ret = -EBUSY;
+		goto out;
+	}
+	/* try to free all pages in this cgroup */
+	shrink = 1;
+	while (nr_retries && mem->res.usage > 0) {
+		int progress;
+		progress = try_to_free_mem_cgroup_pages(mem,
+						  GFP_HIGHUSER_MOVABLE);
+		if (!progress)
+			nr_retries--;
+
+	}
+	/* try move_account...there may be some *locked* pages. */
+	if (mem->res.usage)
+		goto move_account;
+	ret = 0;
+	goto out;
 }
 
 static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
Index: mmotm-2.6.27-rc7+/Documentation/controllers/memory.txt
===================================================================
--- mmotm-2.6.27-rc7+.orig/Documentation/controllers/memory.txt
+++ mmotm-2.6.27-rc7+/Documentation/controllers/memory.txt
@@ -211,7 +211,9 @@ The memory.force_empty gives an interfac
 
 # echo 1 > memory.force_empty
 
-will drop all charges in cgroup. Currently, this is maintained for test.
+Will move account to parent. if parenet is full, will try to free pages.
+If both of a parent and a child are busy, return -EBUSY;
+This file, memory.force_empty, is just for debug purpose.
 
 4. Testing
 
@@ -242,8 +244,10 @@ reclaimed.
 
 A cgroup can be removed by rmdir, but as discussed in sections 4.1 and 4.2, a
 cgroup might have some charge associated with it, even though all
-tasks have migrated away from it. Such charges are automatically dropped at
-rmdir() if there are no tasks.
+tasks have migrated away from it.
+Such charges are moved to its parent as mush as possible and freed if parent
+seems to be full. (see force_empty)
+If both of them are busy, rmdir() returns -EBUSY.
 
 5. TODO
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
