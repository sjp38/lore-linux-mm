Date: Mon, 25 Feb 2008 12:12:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] radix-tree based page_cgroup. [2/7] charge/uncharge
Message-Id: <20080225121212.491ab2cd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, taka@valinux.co.jp, Andi Kleen <ak@suse.de>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Chagnges in Core Logic....charge and uncharge.

Because bit spin lock is removed and spinlock is added to page_cgroup.
There are some amount of changes.

This patch does
	- modified charge/uncharge
	- removed add_list/remove_list function. Just added stat functions
	- Added simple lock rule comments.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 mm/memcontrol.c |  173 +++++++++++++++++++++++---------------------------------
 1 file changed, 74 insertions(+), 99 deletions(-)

Index: linux-2.6.25-rc2/mm/memcontrol.c
===================================================================
--- linux-2.6.25-rc2.orig/mm/memcontrol.c
+++ linux-2.6.25-rc2/mm/memcontrol.c
@@ -34,6 +34,16 @@
 
 #include <asm/uaccess.h>
 
+/*
+ * Lock Rule
+ * zone->lru_lcok (global LRU)
+ *	-> mz->lru_lock (mem_cgroup's per_zone lock.)
+ *		-> pc->lock (page_cgroup's lock)
+ *
+ * mz->lru_lock and pc->lock should be acquired irq off.
+ *
+ */
+
 struct cgroup_subsys mem_cgroup_subsys;
 static const int MEM_CGROUP_RECLAIM_RETRIES = 5;
 
@@ -243,33 +253,29 @@ void mm_free_cgroup(struct mm_struct *mm
 	css_put(&mm->mem_cgroup->css);
 }
 
-static void __mem_cgroup_remove_list(struct page_cgroup *pc)
+static void mem_cgroup_dec_stat(struct mem_cgroup *mem,
+		struct mem_cgroup_per_zone *mz, unsigned long pc_flags)
 {
-	int from = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
-	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
+	int from = pc_flags & PAGE_CGROUP_FLAG_ACTIVE;
 
 	if (from)
 		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE) -= 1;
 	else
 		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) -= 1;
 
-	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, false);
-	list_del_init(&pc->lru);
+	mem_cgroup_charge_statistics(mem, pc_flags, false);
 }
 
-static void __mem_cgroup_add_list(struct page_cgroup *pc)
+static void mem_cgroup_inc_stat(struct mem_cgroup *mem,
+			struct mem_cgroup_per_zone *mz, unsigned long pc_flags)
 {
-	int to = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
-	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
+	int to = pc_flags & PAGE_CGROUP_FLAG_ACTIVE;
 
-	if (!to) {
+	if (!to)
 		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) += 1;
-		list_add(&pc->lru, &mz->inactive_list);
-	} else {
+	else
 		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE) += 1;
-		list_add(&pc->lru, &mz->active_list);
-	}
-	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, true);
+	mem_cgroup_charge_statistics(mem, pc_flags, true);
 }
 
 static void __mem_cgroup_move_lists(struct page_cgroup *pc, bool active)
@@ -478,38 +484,22 @@ static int mem_cgroup_charge_common(stru
 	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup_per_zone *mz;
 
+	pc = get_page_cgroup(page, gfp_mask);
+	if (!pc || IS_ERR(pc))
+		return PTR_ERR(pc);
+
+	spin_lock_irqsave(&pc->lock, flags);
+
+	if (pc->refcnt > 0) {
+		++pc->refcnt;
+		spin_unlock_irqrestore(&pc->lock, flags);
+		return 0;
+	}
 	/*
-	 * Should page_cgroup's go to their own slab?
-	 * One could optimize the performance of the charging routine
-	 * by saving a bit in the page_flags and using it as a lock
-	 * to see if the cgroup page already has a page_cgroup associated
-	 * with it
+	 * Note: refcnt is still 0 here. We charge resource usage
+	 * before increment refcnt.
 	 */
-retry:
-	if (page) {
-		lock_page_cgroup(page);
-		pc = page_get_page_cgroup(page);
-		/*
-		 * The page_cgroup exists and
-		 * the page has already been accounted.
-		 */
-		if (pc) {
-			if (unlikely(!atomic_inc_not_zero(&pc->ref_cnt))) {
-				/* this page is under being uncharged ? */
-				unlock_page_cgroup(page);
-				cpu_relax();
-				goto retry;
-			} else {
-				unlock_page_cgroup(page);
-				goto done;
-			}
-		}
-		unlock_page_cgroup(page);
-	}
-
-	pc = kzalloc(sizeof(struct page_cgroup), gfp_mask);
-	if (pc == NULL)
-		goto err;
+	spin_unlock_irqrestore(&pc->lock, flags);
 
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
@@ -522,11 +512,6 @@ retry:
 
 	rcu_read_lock();
 	mem = rcu_dereference(mm->mem_cgroup);
-	/*
-	 * For every charge from the cgroup, increment reference
-	 * count
-	 */
-	css_get(&mem->css);
 	rcu_read_unlock();
 
 	/*
@@ -535,7 +520,7 @@ retry:
 	 */
 	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
 		if (!(gfp_mask & __GFP_WAIT))
-			goto out;
+			goto nomem;
 
 		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
 			continue;
@@ -552,44 +537,41 @@ retry:
 
 		if (!nr_retries--) {
 			mem_cgroup_out_of_memory(mem, gfp_mask);
-			goto out;
+			goto nomem;
 		}
 		congestion_wait(WRITE, HZ/10);
 	}
 
-	atomic_set(&pc->ref_cnt, 1);
+	spin_lock_irqsave(&pc->lock, flags);
+	if (pc->refcnt) { /* Someone charged before me. */
+		++pc->refcnt;
+		spin_unlock_irqrestore(&pc->lock, flags);
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		return 0;
+	}
+	pc->refcnt = 1;
 	pc->mem_cgroup = mem;
-	pc->page = page;
 	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
 		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
+	spin_unlock_irqrestore(&pc->lock, flags);
 
-	if (!page || page_cgroup_assign_new_page_cgroup(page, pc)) {
-		/*
-		 * Another charge has been added to this page already.
-		 * We take lock_page_cgroup(page) again and read
-		 * page->cgroup, increment refcnt.... just retry is OK.
-		 */
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
-		css_put(&mem->css);
-		kfree(pc);
-		if (!page)
-			goto done;
-		goto retry;
-	}
+	css_get(&mem->css);
+	/*
+	 * Check uncharge is finished..
+	 */
+	while (unlikely(!list_empty(&pc->lru)))
+		smp_rmb();
 
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	/* Update statistics vector */
-	__mem_cgroup_add_list(pc);
+	mem_cgroup_inc_stat(mem, mz, pc->flags);
+	list_add(&pc->lru, &mz->active_list);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
-done:
 	return 0;
-out:
-	css_put(&mem->css);
-	kfree(pc);
-err:
+nomem:
 	return -ENOMEM;
 }
 
@@ -623,41 +605,34 @@ void mem_cgroup_uncharge(struct page_cgr
 {
 	struct mem_cgroup *mem;
 	struct mem_cgroup_per_zone *mz;
-	struct page *page;
-	unsigned long flags;
+	unsigned long flags, pc_flags;
 
-	/*
-	 * Check if our page_cgroup is valid
-	 */
 	if (!pc)
 		return;
-
-	if (atomic_dec_and_test(&pc->ref_cnt)) {
-		page = pc->page;
-		mz = page_cgroup_zoneinfo(pc);
-		/*
-		 * get page->cgroup and clear it under lock.
-		 * force_empty can drop page->cgroup without checking refcnt.
-		 */
-		unlock_page_cgroup(page);
-		if (clear_page_cgroup(page, pc) == pc) {
-			mem = pc->mem_cgroup;
-			css_put(&mem->css);
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
-			spin_lock_irqsave(&mz->lru_lock, flags);
-			__mem_cgroup_remove_list(pc);
-			spin_unlock_irqrestore(&mz->lru_lock, flags);
-			kfree(pc);
-		}
-		lock_page_cgroup(page);
+	spin_lock_irqsave(&pc->lock, flags);
+	if (!pc->refcnt || --pc->refcnt) {
+		spin_unlock_irqrestore(&pc->lock, flags);
+		return;
 	}
+	mz = page_cgroup_zoneinfo(pc);
+	mem = pc->mem_cgroup;
+	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	css_put(&mem->css);
+	pc_flags = pc->flags;
+	pc->flags = 0;
+	pc->mem_cgroup = NULL;
+	spin_unlock_irqrestore(&pc->lock, flags);
+
+	spin_lock_irqsave(&mz->lru_lock, flags);
+	mem_cgroup_dec_stat(mem, mz, pc_flags);
+	list_del_init(&pc->lru);
+	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	css_put(&mem->css);
 }
 
 void mem_cgroup_uncharge_page(struct page *page)
 {
-	lock_page_cgroup(page);
-	mem_cgroup_uncharge(page_get_page_cgroup(page));
-	unlock_page_cgroup(page);
+	mem_cgroup_uncharge(get_page_cgroup(page, 0));
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
