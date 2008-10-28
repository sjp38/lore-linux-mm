Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9SAG2hS030749
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Oct 2008 19:16:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C3EF2AC029
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 19:16:02 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F170812C0A7
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 19:16:01 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id D60181DB803F
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 19:16:01 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 86B4B1DB803A
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 19:16:01 +0900 (JST)
Date: Tue, 28 Oct 2008 19:15:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/4][mmotm] memcg: simple migration handling
Message-Id: <20081028191532.e2cb2f03.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081028190911.6857b0a6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081028190911.6857b0a6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

Now, management of "charge" under page migration is done under following
manner. (Assume migrate page contents from oldpage to newpage)

 before
  - "newpage" is charged before migration.
 at success.
  - "oldpage" is uncharged at somewhere(unmap, radix-tree-replace)
 at failure
  - "newpage" is uncharged.
  - "oldpage" is charged if necessary (*1)

But (*1) is not reliable....because of GFP_ATOMIC.

This patch tries to change behavior as following by charge/commit/cancel ops.

 before
  - charge PAGE_SIZE (no target page)
 success
  - commit charge against "newpage".
 failure
  - commit charge against "oldpage".
    (PCG_USED bit works effectively to avoid double-counting)
  - if "oldpage" is obsolete, cancel charge of PAGE_SIZE.

Changelog: v8 -> v9
 - fixed text.
Changelog: v7 -> v8
 - fixed memcg==NULL case in migration handling.
  
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/memcontrol.h |   19 ++-----
 mm/memcontrol.c            |  108 +++++++++++++++++++++------------------------
 mm/migrate.c               |   42 +++++------------
 3 files changed, 73 insertions(+), 96 deletions(-)

Index: mmotm-2.6.28rc2+/mm/migrate.c
===================================================================
--- mmotm-2.6.28rc2+.orig/mm/migrate.c
+++ mmotm-2.6.28rc2+/mm/migrate.c
@@ -121,20 +121,6 @@ static void remove_migration_pte(struct 
 	if (!is_migration_entry(entry) || migration_entry_to_page(entry) != old)
 		goto out;
 
-	/*
-	 * Yes, ignore the return value from a GFP_ATOMIC mem_cgroup_charge.
-	 * Failure is not an option here: we're now expected to remove every
-	 * migration pte, and will cause crashes otherwise.  Normally this
-	 * is not an issue: mem_cgroup_prepare_migration bumped up the old
-	 * page_cgroup count for safety, that's now attached to the new page,
-	 * so this charge should just be another incrementation of the count,
-	 * to keep in balance with rmap.c's mem_cgroup_uncharging.  But if
-	 * there's been a force_empty, those reference counts may no longer
-	 * be reliable, and this charge can actually fail: oh well, we don't
-	 * make the situation any worse by proceeding as if it had succeeded.
-	 */
-	mem_cgroup_charge_migrate_fixup(new, mm, GFP_ATOMIC);
-
 	get_page(new);
 	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
 	if (is_write_migration_entry(entry))
@@ -382,9 +368,6 @@ static void migrate_page_copy(struct pag
 	anon = PageAnon(page);
 	page->mapping = NULL;
 
-	if (!anon) /* This page was removed from radix-tree. */
-		mem_cgroup_uncharge_cache_page(page);
-
 	/*
 	 * If any waiters have accumulated on the new page then
 	 * wake them up.
@@ -621,6 +604,7 @@ static int unmap_and_move(new_page_t get
 	struct page *newpage = get_new_page(page, private, &result);
 	int rcu_locked = 0;
 	int charge = 0;
+	struct mem_cgroup *mem;
 
 	if (!newpage)
 		return -ENOMEM;
@@ -630,24 +614,26 @@ static int unmap_and_move(new_page_t get
 		goto move_newpage;
 	}
 
-	charge = mem_cgroup_prepare_migration(page, newpage);
-	if (charge == -ENOMEM) {
-		rc = -ENOMEM;
-		goto move_newpage;
-	}
 	/* prepare cgroup just returns 0 or -ENOMEM */
-	BUG_ON(charge);
-
 	rc = -EAGAIN;
+
 	if (!trylock_page(page)) {
 		if (!force)
 			goto move_newpage;
 		lock_page(page);
 	}
 
+	/* charge against new page */
+	charge = mem_cgroup_prepare_migration(page, &mem);
+	if (charge == -ENOMEM) {
+		rc = -ENOMEM;
+		goto unlock;
+	}
+	BUG_ON(charge);
+
 	if (PageWriteback(page)) {
 		if (!force)
-			goto unlock;
+			goto uncharge;
 		wait_on_page_writeback(page);
 	}
 	/*
@@ -700,7 +686,9 @@ static int unmap_and_move(new_page_t get
 rcu_unlock:
 	if (rcu_locked)
 		rcu_read_unlock();
-
+uncharge:
+	if (!charge)
+		mem_cgroup_end_migration(mem, page, newpage);
 unlock:
 	unlock_page(page);
 
@@ -716,8 +704,6 @@ unlock:
 	}
 
 move_newpage:
-	if (!charge)
-		mem_cgroup_end_migration(newpage);
 
 	/*
 	 * Move the new page to the LRU. If migration was not successful
Index: mmotm-2.6.28rc2+/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.28rc2+.orig/include/linux/memcontrol.h
+++ mmotm-2.6.28rc2+/include/linux/memcontrol.h
@@ -29,8 +29,6 @@ struct mm_struct;
 
 extern int mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
-extern int mem_cgroup_charge_migrate_fixup(struct page *page,
-				struct mm_struct *mm, gfp_t gfp_mask);
 /* for swap handling */
 extern int mem_cgroup_try_charge(struct mm_struct *mm,
 		gfp_t gfp_mask, struct mem_cgroup **ptr);
@@ -60,8 +58,9 @@ extern struct mem_cgroup *mem_cgroup_fro
 	((cgroup) == mem_cgroup_from_task((mm)->owner))
 
 extern int
-mem_cgroup_prepare_migration(struct page *page, struct page *newpage);
-extern void mem_cgroup_end_migration(struct page *page);
+mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr);
+extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
+	struct page *oldpage, struct page *newpage);
 
 /*
  * For memory reclaim.
@@ -94,12 +93,6 @@ static inline int mem_cgroup_cache_charg
 	return 0;
 }
 
-static inline int mem_cgroup_charge_migrate_fixup(struct page *page,
-					struct mm_struct *mm, gfp_t gfp_mask)
-{
-	return 0;
-}
-
 static int mem_cgroup_try_charge(struct mm_struct *mm,
 				gfp_t gfp_mask, struct mem_cgroup **ptr)
 {
@@ -143,12 +136,14 @@ static inline int task_in_mem_cgroup(str
 }
 
 static inline int
-mem_cgroup_prepare_migration(struct page *page, struct page *newpage)
+mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
 {
 	return 0;
 }
 
-static inline void mem_cgroup_end_migration(struct page *page)
+static inline void mem_cgroup_end_migration(struct mem_cgroup *mem,
+					struct page *oldpage,
+					struct page *newpage)
 {
 }
 
Index: mmotm-2.6.28rc2+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28rc2+.orig/mm/memcontrol.c
+++ mmotm-2.6.28rc2+/mm/memcontrol.c
@@ -627,34 +627,6 @@ int mem_cgroup_newpage_charge(struct pag
 				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
 }
 
-/*
- * same as mem_cgroup_newpage_charge(), now.
- * But what we assume is different from newpage, and this is special case.
- * treat this in special function. easy for maintenance.
- */
-
-int mem_cgroup_charge_migrate_fixup(struct page *page,
-				struct mm_struct *mm, gfp_t gfp_mask)
-{
-	if (mem_cgroup_subsys.disabled)
-		return 0;
-
-	if (PageCompound(page))
-		return 0;
-
-	if (page_mapped(page) || (page->mapping && !PageAnon(page)))
-		return 0;
-
-	if (unlikely(!mm))
-		mm = &init_mm;
-
-	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
-}
-
-
-
-
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
@@ -697,7 +669,6 @@ int mem_cgroup_cache_charge(struct page 
 				MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
 }
 
-
 void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 {
 	struct page_cgroup *pc;
@@ -782,13 +753,13 @@ void mem_cgroup_uncharge_cache_page(stru
 }
 
 /*
- * Before starting migration, account against new page.
+ * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
+ * page belongs to.
  */
-int mem_cgroup_prepare_migration(struct page *page, struct page *newpage)
+int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
-	enum charge_type ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
 	int ret = 0;
 
 	if (mem_cgroup_subsys.disabled)
@@ -799,42 +770,67 @@ int mem_cgroup_prepare_migration(struct 
 	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
-		if (PageCgroupCache(pc)) {
-			if (page_is_file_cache(page))
-				ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
-			else
-				ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
-		}
 	}
 	unlock_page_cgroup(pc);
+
 	if (mem) {
-		ret = mem_cgroup_charge_common(newpage, NULL,
-					GFP_HIGHUSER_MOVABLE,
-					ctype, mem);
+		ret = mem_cgroup_try_charge(NULL, GFP_HIGHUSER_MOVABLE, &mem);
 		css_put(&mem->css);
 	}
+	*ptr = mem;
 	return ret;
 }
 
 /* remove redundant charge if migration failed*/
-void mem_cgroup_end_migration(struct page *newpage)
+void mem_cgroup_end_migration(struct mem_cgroup *mem,
+		struct page *oldpage, struct page *newpage)
 {
+	struct page *target, *unused;
+	struct page_cgroup *pc;
+	enum charge_type ctype;
+
+	if (!mem)
+		return;
+
+	/* at migration success, oldpage->mapping is NULL. */
+	if (oldpage->mapping) {
+		target = oldpage;
+		unused = NULL;
+	} else {
+		target = newpage;
+		unused = oldpage;
+	}
+
+	if (PageAnon(target))
+		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
+	else if (page_is_file_cache(target))
+		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
+	else
+		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
+
+	/* unused page is not on radix-tree now. */
+	if (unused && ctype != MEM_CGROUP_CHARGE_TYPE_MAPPED)
+		__mem_cgroup_uncharge_common(unused, ctype);
+
+	pc = lookup_page_cgroup(target);
 	/*
-	 * At success, page->mapping is not NULL.
-	 * special rollback care is necessary when
-	 * 1. at migration failure. (newpage->mapping is cleared in this case)
-	 * 2. the newpage was moved but not remapped again because the task
-	 *    exits and the newpage is obsolete. In this case, the new page
-	 *    may be a swapcache. So, we just call mem_cgroup_uncharge_page()
-	 *    always for avoiding mess. The  page_cgroup will be removed if
-	 *    unnecessary. File cache pages is still on radix-tree. Don't
-	 *    care it.
+	 * __mem_cgroup_commit_charge() check PCG_USED bit of page_cgroup.
+	 * So, double-counting is effectively avoided.
+	 */
+	__mem_cgroup_commit_charge(mem, pc, ctype);
+
+	/*
+	 * Both of oldpage and newpage are still under lock_page().
+	 * Then, we don't have to care about race in radix-tree.
+	 * But we have to be careful that this page is unmapped or not.
+	 *
+	 * There is a case for !page_mapped(). At the start of
+	 * migration, oldpage was mapped. But now, it's zapped.
+	 * But we know *target* page is not freed/reused under us.
+	 * mem_cgroup_uncharge_page() does all necessary checks.
 	 */
-	if (!newpage->mapping)
-		__mem_cgroup_uncharge_common(newpage,
-				MEM_CGROUP_CHARGE_TYPE_FORCE);
-	else if (PageAnon(newpage))
-		mem_cgroup_uncharge_page(newpage);
+	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
+		mem_cgroup_uncharge_page(target);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
