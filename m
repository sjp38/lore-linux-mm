Date: Wed, 14 May 2008 17:07:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC/PATCH 2/6] memcg: remove refcnt
Message-Id: <20080514170703.db2d9802.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080514170236.23c9ddd7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080514170236.23c9ddd7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

major changes in shmem handling.

==
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

Changelog: v2->v3
  - adjusted to 2.6.26-rc2
  - Fixed shmem's page_cgroup refcnt handling. (but it's still complicated...)
  - added detect-already-accounted-file-cache check to mem_cgroup_charge().

Changelog: v1->v2
  adjusted to 2.6.25-mm1.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/memcontrol.h |    9 +---
 mm/filemap.c               |    6 +-
 mm/memcontrol.c            |   94 ++++++++++++++++++++++-----------------------
 mm/migrate.c               |    3 -
 mm/rmap.c                  |   14 ------
 mm/shmem.c                 |    8 +--
 6 files changed, 61 insertions(+), 73 deletions(-)

Index: linux-2.6.26-rc2/mm/memcontrol.c
===================================================================
--- linux-2.6.26-rc2.orig/mm/memcontrol.c
+++ linux-2.6.26-rc2/mm/memcontrol.c
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
@@ -660,32 +665,16 @@ int mem_cgroup_charge(struct page *page,
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
+void __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem;
@@ -704,29 +693,41 @@ void mem_cgroup_uncharge_page(struct pag
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
@@ -757,10 +758,13 @@ int mem_cgroup_prepare_migration(struct 
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
 
 
@@ -779,7 +783,6 @@ static void mem_cgroup_drop_all_pages(st
 
 /*
  * This routine traverse page_cgroup in given list and drop them all.
- * This routine ignores page_cgroup->ref_cnt.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
  */
 #define FORCE_UNCHARGE_BATCH	(128)
@@ -809,7 +812,8 @@ static void mem_cgroup_force_empty_list(
 		 * if it's under page migration.
 		 */
 		if (PageLRU(page)) {
-			mem_cgroup_uncharge_page(page);
+			__mem_cgroup_uncharge_common(page,
+					MEM_CGROUP_CHARGE_TYPE_FORCE);
 			put_page(page);
 			if (--count <= 0) {
 				count = FORCE_UNCHARGE_BATCH;
Index: linux-2.6.26-rc2/mm/filemap.c
===================================================================
--- linux-2.6.26-rc2.orig/mm/filemap.c
+++ linux-2.6.26-rc2/mm/filemap.c
@@ -118,7 +118,7 @@ void __remove_from_page_cache(struct pag
 {
 	struct address_space *mapping = page->mapping;
 
-	mem_cgroup_uncharge_page(page);
+	mem_cgroup_uncharge_cache_page(page);
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	mapping->nrpages--;
@@ -476,12 +476,12 @@ int add_to_page_cache(struct page *page,
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
Index: linux-2.6.26-rc2/mm/migrate.c
===================================================================
--- linux-2.6.26-rc2.orig/mm/migrate.c
+++ linux-2.6.26-rc2/mm/migrate.c
@@ -358,8 +358,7 @@ static int migrate_page_move_mapping(str
 
 	write_unlock_irq(&mapping->tree_lock);
 	if (!PageSwapCache(newpage)) {
-		mem_cgroup_uncharge_page(page);
-		mem_cgroup_getref(newpage);
+		mem_cgroup_uncharge_cache_page(page);
 	}
 
 	return 0;
Index: linux-2.6.26-rc2/include/linux/memcontrol.h
===================================================================
--- linux-2.6.26-rc2.orig/include/linux/memcontrol.h
+++ linux-2.6.26-rc2/include/linux/memcontrol.h
@@ -35,6 +35,8 @@ extern int mem_cgroup_charge(struct page
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
 extern void mem_cgroup_uncharge_page(struct page *page);
+extern void mem_cgroup_uncharge_cache_page(struct page *page);
+extern int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask);
 extern void mem_cgroup_move_lists(struct page *page, bool active);
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
@@ -53,7 +55,6 @@ extern struct mem_cgroup *mem_cgroup_fro
 extern int
 mem_cgroup_prepare_migration(struct page *page, struct page *newpage);
 extern void mem_cgroup_end_migration(struct page *page);
-extern int mem_cgroup_getref(struct page *page);
 
 /*
  * For memory reclaim.
@@ -97,6 +98,14 @@ static inline int mem_cgroup_cache_charg
 static inline void mem_cgroup_uncharge_page(struct page *page)
 {
 }
+static inline void mem_cgroup_uncharge_cache_page(struct page *page)
+{
+}
+
+static int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask);
+{
+	return 0;
+}
 
 static inline void mem_cgroup_move_lists(struct page *page, bool active)
 {
@@ -123,10 +132,6 @@ static inline void mem_cgroup_end_migrat
 {
 }
 
-static inline void mem_cgroup_getref(struct page *page)
-{
-}
-
 static inline int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
 {
 	return 0;
Index: linux-2.6.26-rc2/mm/rmap.c
===================================================================
--- linux-2.6.26-rc2.orig/mm/rmap.c
+++ linux-2.6.26-rc2/mm/rmap.c
@@ -576,14 +576,8 @@ void page_add_anon_rmap(struct page *pag
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
@@ -614,12 +608,6 @@ void page_add_file_rmap(struct page *pag
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
Index: linux-2.6.26-rc2/mm/shmem.c
===================================================================
--- linux-2.6.26-rc2.orig/mm/shmem.c
+++ linux-2.6.26-rc2/mm/shmem.c
@@ -961,13 +961,14 @@ found:
 		shmem_swp_unmap(ptr);
 	spin_unlock(&info->lock);
 	radix_tree_preload_end();
-uncharge:
-	mem_cgroup_uncharge_page(page);
 out:
 	unlock_page(page);
 	page_cache_release(page);
 	iput(inode);		/* allows for NULL */
 	return error;
+uncharge:
+	mem_cgroup_uncharge_cache_page(page);
+	goto out;
 }
 
 /*
@@ -1319,7 +1320,7 @@ repeat:
 					page_cache_release(swappage);
 					goto failed;
 				}
-				mem_cgroup_uncharge_page(swappage);
+				mem_cgroup_uncharge_cache_page(swappage);
 			}
 			page_cache_release(swappage);
 			goto repeat;
@@ -1389,7 +1390,7 @@ repeat:
 			if (error || swap.val || 0 != add_to_page_cache_lru(
 					filepage, mapping, idx, GFP_NOWAIT)) {
 				spin_unlock(&info->lock);
-				mem_cgroup_uncharge_page(filepage);
+				mem_cgroup_uncharge_cache_page(filepage);
 				page_cache_release(filepage);
 				shmem_unacct_blocks(info->flags, 1);
 				shmem_free_blocks(inode, 1);
@@ -1398,7 +1399,6 @@ repeat:
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
