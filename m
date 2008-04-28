Date: Mon, 28 Apr 2008 20:22:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/8] memcg: migration handling
Message-Id: <20080428202214.1172f4f2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080428201900.ae25e086.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080428201900.ae25e086.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch changes migration path to assign page_cgroup of new page
at allocation.

Pros:
 - We can avoid compliated lock depndencies.
Cons:
 - new param to mem_cgroup_charge_common().

Changlog:
 - adjusted to 2.6.25-mm1.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Index: mm-2.6.25-mm1/mm/memcontrol.c
===================================================================
--- mm-2.6.25-mm1.orig/mm/memcontrol.c
+++ mm-2.6.25-mm1/mm/memcontrol.c
@@ -515,7 +515,8 @@ unsigned long mem_cgroup_isolate_pages(u
  * < 0 if the cgroup is over its limit
  */
 static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
-				gfp_t gfp_mask, enum charge_type ctype)
+				gfp_t gfp_mask, enum charge_type ctype,
+				struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
@@ -560,16 +561,21 @@ retry:
 	 * thread group leader migrates. It's possible that mm is not
 	 * set, if so charge the init_mm (happens for pagecache usage).
 	 */
-	if (!mm)
-		mm = &init_mm;
+	if (!memcg) {
+		if (!mm)
+			mm = &init_mm;
 
-	rcu_read_lock();
-	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-	/*
-	 * For every charge from the cgroup, increment reference count
-	 */
-	css_get(&mem->css);
-	rcu_read_unlock();
+		rcu_read_lock();
+		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
+		/*
+	 	 * For every charge from the cgroup, increment reference count
+	 	 */
+		css_get(&mem->css);
+		rcu_read_unlock();
+	} else {
+		mem = memcg;
+		css_get(&memcg->css);
+	}
 
 	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
 		if (!(gfp_mask & __GFP_WAIT))
@@ -634,7 +640,7 @@ err:
 int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
 {
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_MAPPED);
+				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
 }
 
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
@@ -643,7 +649,22 @@ int mem_cgroup_cache_charge(struct page 
 	if (!mm)
 		mm = &init_mm;
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_CACHE);
+				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
+}
+
+int mem_cgroup_getref(struct page *page)
+{
+	struct page_cgroup *pc;
+
+	if (mem_cgroup_subsys.disabled)
+		return 0;
+
+	lock_page_cgroup(page);
+	pc = page_get_page_cgroup(page);
+	VM_BUG_ON(!pc);
+	pc->ref_cnt++;
+	unlock_page_cgroup(page);
+	return 0;
 }
 
 /*
@@ -693,65 +714,39 @@ unlock:
 }
 
 /*
- * Returns non-zero if a page (under migration) has valid page_cgroup member.
- * Refcnt of page_cgroup is incremented.
+ * Before starting migration, account against new page.
  */
-int mem_cgroup_prepare_migration(struct page *page)
+int mem_cgroup_prepare_migration(struct page *page, struct page *newpage)
 {
 	struct page_cgroup *pc;
+	struct mem_cgroup *mem = NULL;
+	enum charge_type ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
+	int ret = 0;
 
 	if (mem_cgroup_subsys.disabled)
 		return 0;
 
 	lock_page_cgroup(page);
 	pc = page_get_page_cgroup(page);
-	if (pc)
-		pc->ref_cnt++;
+	if (pc) {
+		mem = pc->mem_cgroup;
+		css_get(&mem->css);
+		if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
+			ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
+	}
 	unlock_page_cgroup(page);
-	return pc != NULL;
-}
-
-void mem_cgroup_end_migration(struct page *page)
-{
-	mem_cgroup_uncharge_page(page);
+	if (mem) {
+		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
+			ctype, mem);
+		css_put(&mem->css);
+	}
+	return ret;
 }
 
-/*
- * We know both *page* and *newpage* are now not-on-LRU and PG_locked.
- * And no race with uncharge() routines because page_cgroup for *page*
- * has extra one reference by mem_cgroup_prepare_migration.
- */
-void mem_cgroup_page_migration(struct page *page, struct page *newpage)
+/* remove redundant charge */
+void mem_cgroup_end_migration(struct page *newpage)
 {
-	struct page_cgroup *pc;
-	struct mem_cgroup_per_zone *mz;
-	unsigned long flags;
-
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	if (!pc) {
-		unlock_page_cgroup(page);
-		return;
-	}
-
-	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_remove_list(mz, pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
-
-	page_assign_page_cgroup(page, NULL);
-	unlock_page_cgroup(page);
-
-	pc->page = newpage;
-	lock_page_cgroup(newpage);
-	page_assign_page_cgroup(newpage, pc);
-
-	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_add_list(mz, pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
-
-	unlock_page_cgroup(newpage);
+	mem_cgroup_uncharge_page(newpage);
 }
 
 /*
@@ -781,12 +776,19 @@ static void mem_cgroup_force_empty_list(
 		page = pc->page;
 		get_page(page);
 		spin_unlock_irqrestore(&mz->lru_lock, flags);
-		mem_cgroup_uncharge_page(page);
-		put_page(page);
-		if (--count <= 0) {
-			count = FORCE_UNCHARGE_BATCH;
+		/*
+		 * Check if this page is on LRU. !LRU page can be found
+		 * if it's under page migration.
+		 */
+		if (PageLRU(page)) {
+			mem_cgroup_uncharge_page(page);
+			put_page(page);
+			if (--count <= 0) {
+				count = FORCE_UNCHARGE_BATCH;
+				cond_resched();
+			}
+		} else
 			cond_resched();
-		}
 		spin_lock_irqsave(&mz->lru_lock, flags);
 	}
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
Index: mm-2.6.25-mm1/include/linux/memcontrol.h
===================================================================
--- mm-2.6.25-mm1.orig/include/linux/memcontrol.h
+++ mm-2.6.25-mm1/include/linux/memcontrol.h
@@ -50,9 +50,10 @@ extern struct mem_cgroup *mem_cgroup_fro
 #define mm_match_cgroup(mm, cgroup)	\
 	((cgroup) == mem_cgroup_from_task((mm)->owner))
 
-extern int mem_cgroup_prepare_migration(struct page *page);
+extern int
+mem_cgroup_prepare_migration(struct page *page, struct page *newpage);
 extern void mem_cgroup_end_migration(struct page *page);
-extern void mem_cgroup_page_migration(struct page *page, struct page *newpage);
+extern int mem_cgroup_getref(struct page *page);
 
 /*
  * For memory reclaim.
@@ -112,7 +113,8 @@ static inline int task_in_mem_cgroup(str
 	return 1;
 }
 
-static inline int mem_cgroup_prepare_migration(struct page *page)
+static inline int
+mem_cgroup_prepare_migration(struct page *page, struct page *newpage)
 {
 	return 0;
 }
@@ -121,8 +123,7 @@ static inline void mem_cgroup_end_migrat
 {
 }
 
-static inline void
-mem_cgroup_page_migration(struct page *page, struct page *newpage)
+static inline void mem_cgroup_getref(struct page *page)
 {
 }
 
Index: mm-2.6.25-mm1/mm/migrate.c
===================================================================
--- mm-2.6.25-mm1.orig/mm/migrate.c
+++ mm-2.6.25-mm1/mm/migrate.c
@@ -357,6 +357,10 @@ static int migrate_page_move_mapping(str
 	__inc_zone_page_state(newpage, NR_FILE_PAGES);
 
 	write_unlock_irq(&mapping->tree_lock);
+	if (!PageSwapCache(newpage)) {
+		mem_cgroup_uncharge_page(page);
+		mem_cgroup_getref(newpage);
+	}
 
 	return 0;
 }
@@ -603,7 +607,6 @@ static int move_to_new_page(struct page 
 		rc = fallback_migrate_page(mapping, newpage, page);
 
 	if (!rc) {
-		mem_cgroup_page_migration(page, newpage);
 		remove_migration_ptes(page, newpage);
 	} else
 		newpage->mapping = NULL;
@@ -633,6 +636,12 @@ static int unmap_and_move(new_page_t get
 		/* page was freed from under us. So we are done. */
 		goto move_newpage;
 
+	charge = mem_cgroup_prepare_migration(page, newpage);
+	if (charge == -ENOMEM) {
+		rc = -ENOMEM;
+		goto move_newpage;
+	}
+
 	rc = -EAGAIN;
 	if (TestSetPageLocked(page)) {
 		if (!force)
@@ -684,19 +693,14 @@ static int unmap_and_move(new_page_t get
 		goto rcu_unlock;
 	}
 
-	charge = mem_cgroup_prepare_migration(page);
 	/* Establish migration ptes or remove ptes */
 	try_to_unmap(page, 1);
 
 	if (!page_mapped(page))
 		rc = move_to_new_page(newpage, page);
 
-	if (rc) {
+	if (rc)
 		remove_migration_ptes(page, page);
-		if (charge)
-			mem_cgroup_end_migration(page);
-	} else if (charge)
- 		mem_cgroup_end_migration(newpage);
 rcu_unlock:
 	if (rcu_locked)
 		rcu_read_unlock();
@@ -717,6 +721,8 @@ unlock:
 	}
 
 move_newpage:
+	if (!charge)
+		mem_cgroup_end_migration(newpage);
 	/*
 	 * Move the new page to the LRU. If migration was not successful
 	 * then this will free the page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
