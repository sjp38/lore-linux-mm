Date: Fri, 22 Aug 2008 20:31:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/14] memcg: rewrite force_empty
Message-Id: <20080822203114.bf6f08e4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Current force_empty of memory resource controller just removes page_cgroup.
This maans the page is not accounted at all and create an in-use page which
has no page_cgroup.

This patch tries to move account to "root" cgroup. By this patch, force_empty
doesn't leak an account but move account to "root" cgroup. Maybe someone can
think of other enhancements as

 1. move account to its parent.
 2. move account to default-trash-can-cgroup somewhere.
 3. move account to a cgroup specified by an admin.

I think a routine this patch adds is an enough generic and can be the base
patch for supporting above behavior (if someone wants.). But, for now, just
moves account to root group.

While moving mem_cgroup, lock_page(page) is held. This helps us for avoiding
race condition with accessing page_cgroup->mem_cgroup.
While under lock_page(), page_cgroup->mem_cgroup points to right cgroup.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 Documentation/controllers/memory.txt |    7 +-
 mm/memcontrol.c                      |   85 ++++++++++++++++++++++++++---------
 2 files changed, 69 insertions(+), 23 deletions(-)

Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc3+/mm/memcontrol.c
@@ -368,6 +368,7 @@ int task_in_mem_cgroup(struct task_struc
 void mem_cgroup_move_lists(struct page *page, enum lru_list lru)
 {
 	struct page_cgroup *pc;
+	struct mem_cgroup *mem;
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
 
@@ -386,9 +387,14 @@ void mem_cgroup_move_lists(struct page *
 
 	pc = page_get_page_cgroup(page);
 	if (pc) {
+		mem = pc->mem_cgroup;
 		mz = page_cgroup_zoneinfo(pc);
 		spin_lock_irqsave(&mz->lru_lock, flags);
-		__mem_cgroup_move_lists(pc, lru);
+		/*
+		 * check against the race with force_empty.
+		 */
+		if (likely(mem == pc->mem_cgroup))
+			__mem_cgroup_move_lists(pc, lru);
 		spin_unlock_irqrestore(&mz->lru_lock, flags);
 	}
 	unlock_page_cgroup(page);
@@ -830,19 +836,52 @@ int mem_cgroup_resize_limit(struct mem_c
 	return ret;
 }
 
+int mem_cgroup_move_account(struct page *page, struct page_cgroup *pc,
+	struct mem_cgroup *from, struct mem_cgroup *to)
+{
+	struct mem_cgroup_per_zone *from_mz, *to_mz;
+	int nid, zid;
+	int ret = 1;
+
+	VM_BUG_ON(to->no_limit == 0);
+	VM_BUG_ON(!irqs_disabled());
+	VM_BUG_ON(!PageLocked(page));
+
+	nid = page_to_nid(page);
+	zid = page_zonenum(page);
+	from_mz =  mem_cgroup_zoneinfo(from, nid, zid);
+	to_mz =  mem_cgroup_zoneinfo(to, nid, zid);
+
+	if (res_counter_charge(&to->res, PAGE_SIZE)) {
+		/* Now, we assume no_limit...no failure here. */
+		return ret;
+	}
+
+	if (spin_trylock(&to_mz->lru_lock)) {
+		__mem_cgroup_remove_list(from_mz, pc);
+		css_put(&from->css);
+		res_counter_uncharge(&from->res, PAGE_SIZE);
+		pc->mem_cgroup = to;
+		css_get(&to->css);
+		__mem_cgroup_add_list(to_mz, pc);
+		ret = 0;
+		spin_unlock(&to_mz->lru_lock);
+	} else {
+		res_counter_uncharge(&to->res, PAGE_SIZE);
+	}
+
+	return ret;
+}
 
 /*
- * This routine traverse page_cgroup in given list and drop them all.
- * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
+ * This routine moves all account to root cgroup.
  */
-#define FORCE_UNCHARGE_BATCH	(128)
 static void mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 			    struct mem_cgroup_per_zone *mz,
 			    enum lru_list lru)
 {
 	struct page_cgroup *pc;
 	struct page *page;
-	int count = FORCE_UNCHARGE_BATCH;
 	unsigned long flags;
 	struct list_head *list;
 
@@ -853,22 +892,28 @@ static void mem_cgroup_force_empty_list(
 		pc = list_entry(list->prev, struct page_cgroup, lru);
 		page = pc->page;
 		get_page(page);
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
-		/*
-		 * Check if this page is on LRU. !LRU page can be found
-		 * if it's under page migration.
-		 */
-		if (PageLRU(page)) {
-			__mem_cgroup_uncharge_common(page,
-					MEM_CGROUP_CHARGE_TYPE_FORCE);
+		if (!trylock_page(page)) {
+			list_move(&pc->lru, list);
+			put_page(page):
+			spin_unlock_irqrestore(&mz->lru_lock, flags);
+			yield();
+			spin_lock_irqsave(&mz->lru_lock, flags);
+			continue;
+		}
+		if (mem_cgroup_move_account(page, pc, mem, &init_mem_cgroup)) {
+			/* some confliction */
+			list_move(&pc->lru, list);
+			unlock_page(page);
 			put_page(page);
-			if (--count <= 0) {
-				count = FORCE_UNCHARGE_BATCH;
-				cond_resched();
-			}
-		} else
-			cond_resched();
-		spin_lock_irqsave(&mz->lru_lock, flags);
+			spin_unlock_irqrestore(&mz->lru_lock, flags);
+			yield();
+			spin_lock_irqsave(&mz->lru_lock, flags);
+		} else {
+			unlock_page(page);
+			put_page(page);
+		}
+		if (atomic_read(&mem->css.cgroup->count) > 0)
+			break;
 	}
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 }
Index: mmtom-2.6.27-rc3+/Documentation/controllers/memory.txt
===================================================================
--- mmtom-2.6.27-rc3+.orig/Documentation/controllers/memory.txt
+++ mmtom-2.6.27-rc3+/Documentation/controllers/memory.txt
@@ -207,7 +207,8 @@ The memory.force_empty gives an interfac
 
 # echo 1 > memory.force_empty
 
-will drop all charges in cgroup. Currently, this is maintained for test.
+will drop all charges in cgroup and move to default cgroup.
+Currently, this is maintained for test.
 
 4. Testing
 
@@ -238,8 +239,8 @@ reclaimed.
 
 A cgroup can be removed by rmdir, but as discussed in sections 4.1 and 4.2, a
 cgroup might have some charge associated with it, even though all
-tasks have migrated away from it. Such charges are automatically dropped at
-rmdir() if there are no tasks.
+tasks have migrated away from it. Such charges are automatically moved to
+root cgroup at rmidr() if there are no tasks.
 
 5. TODO
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
