Date: Thu, 6 Mar 2008 09:28:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [Preview] [PATCH] radix tree based page cgroup [4/6] migraton
Message-Id: <20080306092823.44fee9e3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080305205137.5c744097.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080305205137.5c744097.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "taka@valinux.co.jp" <taka@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Sorry..this one has been slept on my PC...

For page migration.

Changes from current codes.
  - adds new arg to mem_cgroup_charge_common to pass mem_cgroup itself
    as its argument. This is used when mm is NULL.
  - igonore pc->refcnt == 0 case in prepare_migration
  - uncharge old page and add new charge to new page in page migration.

There is an algorithm change, so please see carefully....

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 mm/memcontrol.c |   91 +++++++++++++++++++++++++++++++-------------------------
 1 files changed, 51 insertions(+), 40 deletions(-)

Index: linux-2.6.25-rc4/mm/memcontrol.c
===================================================================
--- linux-2.6.25-rc4.orig/mm/memcontrol.c
+++ linux-2.6.25-rc4/mm/memcontrol.c
@@ -480,7 +480,8 @@ unsigned long mem_cgroup_isolate_pages(u
  * < 0 if the cgroup is over its limit
  */
 static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
-				gfp_t gfp_mask, enum charge_type ctype)
+				gfp_t gfp_mask, enum charge_type ctype,
+				struct mem_cgroup *memcgrp)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
@@ -511,16 +512,21 @@ static int mem_cgroup_charge_common(stru
 	 * thread group leader migrates. It's possible that mm is not
 	 * set, if so charge the init_mm (happens for pagecache usage).
 	 */
-	if (!mm)
+	if (!mm && !memcgrp) {
 		mm = &init_mm;
-
-	rcu_read_lock();
-	mem = rcu_dereference(mm->mem_cgroup);
-	/*
-	 * For every charge from the cgroup, increment reference count
-	 */
-	css_get(&mem->css);
-	rcu_read_unlock();
+	}
+	if (mm) {
+		rcu_read_lock();
+		mem = rcu_dereference(mm->mem_cgroup);
+		/*
+	 	* For every charge from the cgroup, increment reference count
+	 	*/
+		css_get(&mem->css);
+		rcu_read_unlock();
+	} else {
+		mem = memcgrp;
+		css_get(&mem->css);
+	}
 
 	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
 		if (!(gfp_mask & __GFP_WAIT))
@@ -581,7 +587,7 @@ nomem:
 int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
 {
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_MAPPED);
+				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
 }
 
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
@@ -590,7 +596,7 @@ int mem_cgroup_cache_charge(struct page 
 	if (!mm)
 		mm = &init_mm;
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_CACHE);
+				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
 }
 
 /*
@@ -637,13 +643,20 @@ void mem_cgroup_uncharge_page(struct pag
 int mem_cgroup_prepare_migration(struct page *page)
 {
 	struct page_cgroup *pc;
-
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	if (pc)
-		pc->ref_cnt++;
-	unlock_page_cgroup(page);
-	return pc != NULL;
+	int ret = 0;
+	unsigned long flags;
+	/* returns NULL if not exist */
+	pc = get_page_cgroup(page, GFP_ATOMIC, false);
+	if (pc == NULL)
+		return ret;
+	
+	spin_lock_irqsave(&pc->lock, flags);
+	if (pc->refcnt) {
+		pc->refcnt++;
+		ret = 1;
+	}
+	spin_unlock_irqrestore(&pc->lock, flags);
+	return ret;
 }
 
 void mem_cgroup_end_migration(struct page *page)
@@ -655,38 +668,36 @@ void mem_cgroup_end_migration(struct pag
  * We know both *page* and *newpage* are now not-on-LRU and PG_locked.
  * And no race with uncharge() routines because page_cgroup for *page*
  * has extra one reference by mem_cgroup_prepare_migration.
+ *
+ * This drops charge on old page and add new charge to new page.
+ * mem_cgroup is copied.
  */
 void mem_cgroup_page_migration(struct page *page, struct page *newpage)
 {
 	struct page_cgroup *pc;
-	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup *mem = NULL;
 	unsigned long flags;
+	enum charge_type type;
 
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	if (!pc) {
-		unlock_page_cgroup(page);
+	pc = get_page_cgroup(page, GFP_ATOMIC, false);
+	if (!pc)
 		return;
+	spin_lock_irqsave(&pc->lock, flags);
+	if (pc->refcnt) {
+		VM_BUG_ON(!pc->mem_cgroup);
+		mem = pc->mem_cgroup;
+		type = (pc->flags & PAGE_CGROUP_FLAG_CACHE)?
+			MEM_CGROUP_CHARGE_TYPE_CACHE :
+			MEM_CGROUP_CHARGE_TYPE_MAPPED;
+		css_get(&mem->css);
 	}
+	spin_unlock_irqrestore(&pc->lock, flags);
+	if (!mem)
+		return;
+	mem_cgroup_uncharge_page(page);
 
-	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_remove_list(pc);
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
-	__mem_cgroup_add_list(pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
-
-	unlock_page_cgroup(newpage);
+	mem_cgroup_charge_common(newpage, NULL, GFP_ATOMIC, type, mem);
+	css_put(&mem->css);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
