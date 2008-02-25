Date: Mon, 25 Feb 2008 12:14:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] radix-tree based page_cgroup. [4/7] migration
Message-Id: <20080225121424.28816516.kamezawa.hiroyu@jp.fujitsu.com>
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

Changes in page migraion handler.

How migration works is.
  1. unmap all
  2. replace trees and copies contents.
  3. map all again.

1. and 3. can drop all charges and a page will lose cgroup information.

For preventing that,
  * increment refcnt before unmap all.
  * At the end of copying, set newpage to be under oldpage's cgroup.
  * drop extra-refcnt

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



 mm/memcontrol.c |   93 +++++++++++++++++++++++++-------------------------------
 1 file changed, 43 insertions(+), 50 deletions(-)

Index: linux-2.6.25-rc2/mm/memcontrol.c
===================================================================
--- linux-2.6.25-rc2.orig/mm/memcontrol.c
+++ linux-2.6.25-rc2/mm/memcontrol.c
@@ -480,9 +480,9 @@ static struct page_cgroup *page_cgroup_g
  * < 0 if the cgroup is over its limit
  */
 static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
-				gfp_t gfp_mask, enum charge_type ctype)
+				gfp_t gfp_mask, enum charge_type ctype,
+				struct mem_cgroup *mem)
 {
-	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
 	unsigned long flags;
 	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
@@ -505,18 +505,20 @@ static int mem_cgroup_charge_common(stru
 	 */
 	spin_unlock_irqrestore(&pc->lock, flags);
 
-	/*
-	 * We always charge the cgroup the mm_struct belongs to.
-	 * The mm_struct's mem_cgroup changes on task migration if the
-	 * thread group leader migrates. It's possible that mm is not
-	 * set, if so charge the init_mm (happens for pagecache usage).
-	 */
-	if (!mm)
-		mm = &init_mm;
+	if (likely(!mem)) {
+		/*
+		 * We always charge the cgroup the mm_struct belongs to.
+		 * The mm_struct's mem_cgroup changes on task migration if the
+		 * thread group leader migrates. It's possible that mm is not
+		 * set, if so charge the init_mm (happens for pagecache usage).
+		 */
+		if (!mm)
+			mm = &init_mm;
 
-	rcu_read_lock();
-	mem = rcu_dereference(mm->mem_cgroup);
-	rcu_read_unlock();
+		rcu_read_lock();
+		mem = rcu_dereference(mm->mem_cgroup);
+		rcu_read_unlock();
+	}
 
 	/*
 	 * If we created the page_cgroup, we should free it on exceeding
@@ -583,7 +585,7 @@ int mem_cgroup_charge(struct page *page,
 			gfp_t gfp_mask)
 {
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-			MEM_CGROUP_CHARGE_TYPE_MAPPED);
+			MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
 }
 
 /*
@@ -597,7 +599,7 @@ int mem_cgroup_cache_charge(struct page 
 		mm = &init_mm;
 
 	ret = mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_CACHE);
+				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
 	return ret;
 }
 
@@ -668,24 +670,12 @@ void mem_cgroup_move_lists(struct page *
 
 int mem_cgroup_prepare_migration(struct page *page)
 {
-	struct page_cgroup *pc;
-	int ret = 0;
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	if (pc && atomic_inc_not_zero(&pc->ref_cnt))
-		ret = 1;
-	unlock_page_cgroup(page);
-	return ret;
+	return page_cgroup_getref(page)? 1 : 0;
 }
 
 void mem_cgroup_end_migration(struct page *page)
 {
-	struct page_cgroup *pc;
-
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	mem_cgroup_uncharge(pc);
-	unlock_page_cgroup(page);
+	mem_cgroup_uncharge_page(page);
 }
 /*
  * We know both *page* and *newpage* are now not-on-LRU and Pg_locked.
@@ -696,31 +686,34 @@ void mem_cgroup_end_migration(struct pag
 void mem_cgroup_page_migration(struct page *page, struct page *newpage)
 {
 	struct page_cgroup *pc;
-	struct mem_cgroup *mem;
-	unsigned long flags;
-	struct mem_cgroup_per_zone *mz;
-retry:
-	pc = page_get_page_cgroup(page);
+	struct mem_cgroup *mem = NULL;
+	unsigned long flags, pc_flags;
+
+	/* This is done under RCU read lock */
+	pc = get_page_cgroup(page, 0);
 	if (!pc)
 		return;
-	mem = pc->mem_cgroup;
-	mz = page_cgroup_zoneinfo(pc);
-	if (clear_page_cgroup(page, pc) != pc)
-		goto retry;
-	spin_lock_irqsave(&mz->lru_lock, flags);
-
-	__mem_cgroup_remove_list(pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	spin_lock_irqsave(&pc->lock, flags);
+	if (pc->refcnt) {
+		mem = pc->mem_cgroup;
+		pc_flags = pc->flags;
+		css_get(&mem->css);
+	}
+	spin_unlock_irqrestore(&pc->lock, flags);
+	if (!mem)
+		return;
 
-	pc->page = newpage;
-	lock_page_cgroup(newpage);
-	page_assign_page_cgroup(newpage, pc);
-	unlock_page_cgroup(newpage);
+	/* We got all necessary information */
+	mem_cgroup_uncharge_page(page);
 
-	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_add_list(pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	/* Following extra charge will be dropped by end_migraion */
+	if (pc_flags & PAGE_CGROUP_FLAG_CACHE)
+		mem_cgroup_charge_common(newpage, NULL, GFP_ATOMIC,
+				MEM_CGROUP_CHARGE_TYPE_CACHE, mem);
+	else
+		mem_cgroup_charge_common(newpage, NULL,  GFP_ATOMIC,
+				MEM_CGROUP_CHARGE_TYPE_MAPPED, mem);
+	css_put(&mem->css);
 	return;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
