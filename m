Date: Thu, 15 May 2008 18:27:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH -mm 1/5] memcg: remove refcnt from page_cgroup
Message-Id: <20080515182759.fedcdc1e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080515182516.763967cc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080515182516.763967cc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

This patch removes refcnt from page_cgroup().

After this,

 * A page is charged only when !page_mapped() && no page_cgroup is assigned.
	* Anon page is newly mapped.
	* File page is added to mapping->tree.

 * A page is uncharged only when
	* Anon page is fully unmapped.
	* File page is removed from LRU.

There is no change in behavior from user's view.

This patch also removes unnecessary calls in rmap.c which was used only for
refcnt mangement.

Changelog v3->v4:
  - adjusted to 2.6.26-rc2-mm1.
  - fixed shmem handling.
  - fixed __mem_cgroup_uncharge_common() as static.

Changelog: v2->v3
  - adjusted to 2.6.26-rc2
  - Avoid accounting !Anon page in mem_cgroup_charge_page().
    mapped-file pages must be accounted as file cache before here.
  - Fixed shmem's page_cgroup refcnt handling. (but it's still complicated...)
  - added detect-already-accounted-file-cache check to mem_cgroup_charge().

Changelog: v1->v2
  adjusted to 2.6.25-mm1.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/memcontrol.h |   10 ++--
 mm/filemap.c               |    6 +-
 mm/memcontrol.c            |   97 +++++++++++++++++++++++----------------------
 mm/migrate.c               |    3 -
 mm/rmap.c                  |   14 ------
 mm/shmem.c                 |   42 +++++++++++++------
 6 files changed, 90 insertions(+), 82 deletions(-)

Index: mm-2.6.26-rc2-mm1/mm/memcontrol.c
===================================================================
--- mm-2.6.26-rc2-mm1.orig/mm/memcontrol.c
+++ mm-2.6.26-rc2-mm1/mm/memcontrol.c
@@ -166,7 +166,6 @@ struct page_cgroup {
 	struct list_head lru;		/* per cgroup LRU list */
 	struct page *page;
 	struct mem_cgroup *mem_cgroup;
-	int ref_cnt;			/* cached, mapped, migrating */
 	int flags;
 };
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
@@ -185,6 +184,7 @@ static enum zone_type page_cgroup_zid(st
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
+	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
 };
 
 /*
@@ -552,9 +552,7 @@ retry:
 	 */
 	if (pc) {
 		VM_BUG_ON(pc->page != page);
-		VM_BUG_ON(pc->ref_cnt <= 0);
-
-		pc->ref_cnt++;
+		VM_BUG_ON(!pc->mem_cgroup);
 		unlock_page_cgroup(page);
 		goto done;
 	}
@@ -570,10 +568,7 @@ retry:
 	 * thread group leader migrates. It's possible that mm is not
 	 * set, if so charge the init_mm (happens for pagecache usage).
 	 */
-	if (!memcg) {
-		if (!mm)
-			mm = &init_mm;
-
+	if (likely(!memcg)) {
 		rcu_read_lock();
 		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
 		/*
@@ -609,7 +604,6 @@ retry:
 		}
 	}
 
-	pc->ref_cnt = 1;
 	pc->mem_cgroup = mem;
 	pc->page = page;
 	/*
@@ -653,6 +647,17 @@ err:
 
 int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
 {
+	/*
+	 * If already mapped, we don't have to account.
+	 * If page cache, page->mapping has address_space.
+	 * But page->mapping may have out-of-use anon_vma pointer,
+	 * detecit it by PageAnon() check. newly-mapped-anon's page->mapping
+	 * is NULL.
+  	 */
+	if (page_mapped(page) || (page->mapping && !PageAnon(page)))
+		return 0;
+	if (unlikely(!mm))
+		mm = &init_mm;
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
 				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
 }
@@ -660,32 +665,17 @@ int mem_cgroup_charge(struct page *page,
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
-	if (!mm)
+	if (unlikely(!mm))
 		mm = &init_mm;
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
 				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
 }
 
-int mem_cgroup_getref(struct page *page)
-{
-	struct page_cgroup *pc;
-
-	if (mem_cgroup_subsys.disabled)
-		return 0;
-
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	VM_BUG_ON(!pc);
-	pc->ref_cnt++;
-	unlock_page_cgroup(page);
-	return 0;
-}
-
 /*
- * Uncharging is always a welcome operation, we never complain, simply
- * uncharge.
+ * uncharge if !page_mapped(page)
  */
-void mem_cgroup_uncharge_page(struct page *page)
+static void
+__mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem;
@@ -704,29 +694,41 @@ void mem_cgroup_uncharge_page(struct pag
 		goto unlock;
 
 	VM_BUG_ON(pc->page != page);
-	VM_BUG_ON(pc->ref_cnt <= 0);
 
-	if (--(pc->ref_cnt) == 0) {
-		mz = page_cgroup_zoneinfo(pc);
-		spin_lock_irqsave(&mz->lru_lock, flags);
-		__mem_cgroup_remove_list(mz, pc);
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
+	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
+	    && ((pc->flags & PAGE_CGROUP_FLAG_CACHE)
+		|| page_mapped(page)))
+		goto unlock;
 
-		page_assign_page_cgroup(page, NULL);
-		unlock_page_cgroup(page);
+	mz = page_cgroup_zoneinfo(pc);
+	spin_lock_irqsave(&mz->lru_lock, flags);
+	__mem_cgroup_remove_list(mz, pc);
+	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
-		mem = pc->mem_cgroup;
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
-		css_put(&mem->css);
+	page_assign_page_cgroup(page, NULL);
+	unlock_page_cgroup(page);
 
-		kmem_cache_free(page_cgroup_cache, pc);
-		return;
-	}
+	mem = pc->mem_cgroup;
+	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	css_put(&mem->css);
 
+	kmem_cache_free(page_cgroup_cache, pc);
+	return;
 unlock:
 	unlock_page_cgroup(page);
 }
 
+void mem_cgroup_uncharge_page(struct page *page)
+{
+	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_MAPPED);
+}
+
+void mem_cgroup_uncharge_cache_page(struct page *page)
+{
+	VM_BUG_ON(page_mapped(page));
+	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
+}
+
 /*
  * Before starting migration, account against new page.
  */
@@ -757,15 +759,17 @@ int mem_cgroup_prepare_migration(struct 
 	return ret;
 }
 
-/* remove redundant charge */
+/* remove redundant charge if migration failed*/
 void mem_cgroup_end_migration(struct page *newpage)
 {
-	mem_cgroup_uncharge_page(newpage);
+	/* At success, page->mapping is not NULL */
+	if (newpage->mapping)
+		__mem_cgroup_uncharge_common(newpage,
+					 MEM_CGROUP_CHARGE_TYPE_FORCE);
 }
 
 /*
  * This routine traverse page_cgroup in given list and drop them all.
- * This routine ignores page_cgroup->ref_cnt.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
  */
 #define FORCE_UNCHARGE_BATCH	(128)
@@ -795,7 +799,8 @@ static void mem_cgroup_force_empty_list(
 		 * if it's under page migration.
 		 */
 		if (PageLRU(page)) {
-			mem_cgroup_uncharge_page(page);
+			__mem_cgroup_uncharge_common(page,
+					MEM_CGROUP_CHARGE_TYPE_FORCE);
 			put_page(page);
 			if (--count <= 0) {
 				count = FORCE_UNCHARGE_BATCH;
Index: mm-2.6.26-rc2-mm1/mm/filemap.c
===================================================================
--- mm-2.6.26-rc2-mm1.orig/mm/filemap.c
+++ mm-2.6.26-rc2-mm1/mm/filemap.c
@@ -115,7 +115,7 @@ void __remove_from_page_cache(struct pag
 {
 	struct address_space *mapping = page->mapping;
 
-	mem_cgroup_uncharge_page(page);
+	mem_cgroup_uncharge_cache_page(page);
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	mapping->nrpages--;
@@ -474,12 +474,12 @@ int add_to_page_cache(struct page *page,
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		} else
-			mem_cgroup_uncharge_page(page);
+			mem_cgroup_uncharge_cache_page(page);
 
 		write_unlock_irq(&mapping->tree_lock);
 		radix_tree_preload_end();
 	} else
-		mem_cgroup_uncharge_page(page);
+		mem_cgroup_uncharge_cache_page(page);
 out:
 	return error;
 }
Index: mm-2.6.26-rc2-mm1/mm/migrate.c
===================================================================
--- mm-2.6.26-rc2-mm1.orig/mm/migrate.c
+++ mm-2.6.26-rc2-mm1/mm/migrate.c
@@ -359,8 +359,7 @@ static int migrate_page_move_mapping(str
 
 	write_unlock_irq(&mapping->tree_lock);
 	if (!PageSwapCache(newpage)) {
-		mem_cgroup_uncharge_page(page);
-		mem_cgroup_getref(newpage);
+		mem_cgroup_uncharge_cache_page(page);
 	}
 
 	return 0;
Index: mm-2.6.26-rc2-mm1/include/linux/memcontrol.h
===================================================================
--- mm-2.6.26-rc2-mm1.orig/include/linux/memcontrol.h
+++ mm-2.6.26-rc2-mm1/include/linux/memcontrol.h
@@ -35,6 +35,7 @@ extern int mem_cgroup_charge(struct page
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
 extern void mem_cgroup_uncharge_page(struct page *page);
+extern void mem_cgroup_uncharge_cache_page(struct page *page);
 extern void mem_cgroup_move_lists(struct page *page, bool active);
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
@@ -53,7 +54,6 @@ extern struct mem_cgroup *mem_cgroup_fro
 extern int
 mem_cgroup_prepare_migration(struct page *page, struct page *newpage);
 extern void mem_cgroup_end_migration(struct page *page);
-extern int mem_cgroup_getref(struct page *page);
 
 /*
  * For memory reclaim.
@@ -98,6 +98,10 @@ static inline void mem_cgroup_uncharge_p
 {
 }
 
+static inline void mem_cgroup_uncharge_cache_page(struct page *page)
+{
+}
+
 static inline void mem_cgroup_move_lists(struct page *page, bool active)
 {
 }
@@ -123,10 +127,6 @@ static inline void mem_cgroup_end_migrat
 {
 }
 
-static inline void mem_cgroup_getref(struct page *page)
-{
-}
-
 static inline int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
 {
 	return 0;
Index: mm-2.6.26-rc2-mm1/mm/rmap.c
===================================================================
--- mm-2.6.26-rc2-mm1.orig/mm/rmap.c
+++ mm-2.6.26-rc2-mm1/mm/rmap.c
@@ -586,14 +586,8 @@ void page_add_anon_rmap(struct page *pag
 	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 	if (atomic_inc_and_test(&page->_mapcount))
 		__page_set_anon_rmap(page, vma, address);
-	else {
+	else
 		__page_check_anon_rmap(page, vma, address);
-		/*
-		 * We unconditionally charged during prepare, we uncharge here
-		 * This takes care of balancing the reference counts
-		 */
-		mem_cgroup_uncharge_page(page);
-	}
 }
 
 /**
@@ -624,12 +618,6 @@ void page_add_file_rmap(struct page *pag
 {
 	if (atomic_inc_and_test(&page->_mapcount))
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-	else
-		/*
-		 * We unconditionally charged during prepare, we uncharge here
-		 * This takes care of balancing the reference counts
-		 */
-		mem_cgroup_uncharge_page(page);
 }
 
 #ifdef CONFIG_DEBUG_VM
Index: mm-2.6.26-rc2-mm1/mm/shmem.c
===================================================================
--- mm-2.6.26-rc2-mm1.orig/mm/shmem.c
+++ mm-2.6.26-rc2-mm1/mm/shmem.c
@@ -922,20 +922,29 @@ found:
 	error = 1;
 	if (!inode)
 		goto out;
-	/* Precharge page while we can wait, compensate afterwards */
-	error = mem_cgroup_cache_charge(page, current->mm, GFP_KERNEL);
+	error = radix_tree_preload(GFP_KERNEL);
 	if (error)
 		goto out;
-	error = radix_tree_preload(GFP_KERNEL);
+	/*
+	 * Because we use GFP_NOWAIT in add_to_page_cache(), we can see -ENOMEM
+	 * failure because of memory pressure in memory resource controller.
+	 * Then, precharge page while we can wait, uncharge at failure will be
+	 * automatically done in add_to_page_cache()
+	 */
+	error = mem_cgroup_cache_charge(page, current->mm, GFP_KERNEL);
 	if (error)
-		goto uncharge;
+		goto preload_out;
+
 	error = 1;
 
 	spin_lock(&info->lock);
 	ptr = shmem_swp_entry(info, idx, NULL);
 	if (ptr && ptr->val == entry.val)
-		error = add_to_page_cache(page, inode->i_mapping,
-						idx, GFP_NOWAIT);
+		error = add_to_page_cache(page, inode->i_mapping, idx,
+					GFP_NOWAIT);
+	else /* we don't have to account this page. */
+		mem_cgroup_uncharge_cache_page(page);
+
 	if (error == -EEXIST) {
 		struct page *filepage = find_get_page(inode->i_mapping, idx);
 		error = 1;
@@ -960,9 +969,8 @@ found:
 	if (ptr)
 		shmem_swp_unmap(ptr);
 	spin_unlock(&info->lock);
+preload_out:
 	radix_tree_preload_end();
-uncharge:
-	mem_cgroup_uncharge_page(page);
 out:
 	unlock_page(page);
 	page_cache_release(page);
@@ -1319,7 +1327,7 @@ repeat:
 					page_cache_release(swappage);
 					goto failed;
 				}
-				mem_cgroup_uncharge_page(swappage);
+				mem_cgroup_uncharge_cache_page(swappage);
 			}
 			page_cache_release(swappage);
 			goto repeat;
@@ -1358,6 +1366,8 @@ repeat:
 		}
 
 		if (!filepage) {
+			int ret;
+
 			spin_unlock(&info->lock);
 			filepage = shmem_alloc_page(gfp, info, idx);
 			if (!filepage) {
@@ -1386,10 +1396,17 @@ repeat:
 				swap = *entry;
 				shmem_swp_unmap(entry);
 			}
-			if (error || swap.val || 0 != add_to_page_cache_lru(
-					filepage, mapping, idx, GFP_NOWAIT)) {
+			if (error || swap.val)
+				mem_cgroup_uncharge_cache_page(filepage);
+			else
+				ret = add_to_page_cache_lru(filepage, mapping,
+						idx, GFP_NOWAIT);
+			/*
+			 * At add_to_page_cache_lru() failure, uncharge will
+			 * be done automatically.
+			 */
+			if (error || swap.val || ret) {
 				spin_unlock(&info->lock);
-				mem_cgroup_uncharge_page(filepage);
 				page_cache_release(filepage);
 				shmem_unacct_blocks(info->flags, 1);
 				shmem_free_blocks(inode, 1);
@@ -1398,7 +1415,6 @@ repeat:
 					goto failed;
 				goto repeat;
 			}
-			mem_cgroup_uncharge_page(filepage);
 			info->flags |= SHMEM_PAGEIN;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
