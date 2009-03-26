Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5C0336B003D
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 23:30:48 -0400 (EDT)
Date: Thu, 26 Mar 2009 13:08:21 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][BUGFIX][PATCH] memcg: fix shrink_usage
Message-Id: <20090326130821.40c26cf1.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@in.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This is another bug I've working on recently.

I want this (and the stale swapcache problem) to be fixed for 2.6.30.

Any comments?

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Current mem_cgroup_shrink_usage has two problems.

1. It doesn't call mem_cgroup_out_of_memory and doesn't update last_oom_jiffies,
   so pagefault_out_of_memory invokes global OOM.
2. Considering hierarchy, shrinking has to be done from the mem_over_limit,
   not from the memcg where the page to be charged to.

I think these problems can be solved easily by making shrink_usage
call charge and uncharge.
Actually, it is the old behavior before commit c9b0ed51.

Instead of going back to old behavior, this patch:

- adds a new arg to mem_cgroup_try_charge to store mem_over_limit.
- defines new function add_to_page_cache_store_memcg, which behaves
  like add_to_page_cache_locked but uses try_charge_swapin/commit_charge_swapin
  and stores mem_over_limit on failure of try_charge_swapin.
- makes shmem_getpage use add_to_page_cache_store_memcg, and pass
  the mem_over_limit to shrink_usage.
- makes shrink_usage call mem_cgroup_out_of_memory and record_last_oom.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/memcontrol.h |   15 ++++++----
 include/linux/pagemap.h    |   13 ++++++++
 mm/filemap.c               |   67 ++++++++++++++++++++++++++++++++++++++++++++
 mm/memcontrol.c            |   62 +++++++++++++++++++++++-----------------
 mm/memory.c                |    2 +-
 mm/shmem.c                 |   22 ++++++--------
 mm/swapfile.c              |    3 +-
 7 files changed, 137 insertions(+), 47 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 18146c9..f926912 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -41,9 +41,12 @@ extern int mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
 /* for swap handling */
 extern int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
-		struct page *page, gfp_t mask, struct mem_cgroup **ptr);
+		struct page *page, gfp_t mask,
+		struct mem_cgroup **ptr, struct mem_cgroup **fail_ptr);
 extern void mem_cgroup_commit_charge_swapin(struct page *page,
 					struct mem_cgroup *ptr);
+extern void mem_cgroup_commit_cache_charge_swapin(struct page *page,
+					struct mem_cgroup *ptr);
 extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *ptr);
 
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
@@ -56,8 +59,7 @@ extern void mem_cgroup_move_lists(struct page *page,
 				  enum lru_list from, enum lru_list to);
 extern void mem_cgroup_uncharge_page(struct page *page);
 extern void mem_cgroup_uncharge_cache_page(struct page *page);
-extern int mem_cgroup_shrink_usage(struct page *page,
-			struct mm_struct *mm, gfp_t gfp_mask);
+extern int mem_cgroup_shrink_usage(struct mem_cgroup *mem, gfp_t gfp_mask);
 
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
@@ -133,7 +135,8 @@ static inline int mem_cgroup_cache_charge(struct page *page,
 }
 
 static inline int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
-		struct page *page, gfp_t gfp_mask, struct mem_cgroup **ptr)
+			struct page *page, gfp_t gfp_mask,
+			struct mem_cgroup **ptr, struct mem_cgroup **fail_ptr)
 {
 	return 0;
 }
@@ -155,8 +158,8 @@ static inline void mem_cgroup_uncharge_cache_page(struct page *page)
 {
 }
 
-static inline int mem_cgroup_shrink_usage(struct page *page,
-			struct mm_struct *mm, gfp_t gfp_mask)
+static inline
+int mem_cgroup_shrink_usage(struct mem_cgroup *mem, gfp_t gfp_mask)
 {
 	return 0;
 }
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 135028e..715236e 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -453,6 +453,19 @@ static inline int fault_in_pages_readable(const char __user *uaddr, int size)
 
 int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+int add_to_page_cache_store_memcg(struct page *page,
+			struct address_space *mapping, pgoff_t index,
+			gfp_t gfp_mask, struct mem_cgroup **ptr);
+#else
+static inline int add_to_page_cache_store_memcg(struct page *page,
+			struct address_space *mapping, pgoff_t index,
+			gfp_t gfp_mask, struct mem_cgroup **ptr)
+{
+	*ptr = NULL;
+	return add_to_page_cache_locked(page, mapping, index, gfp_mask);
+}
+#endif
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 extern void remove_from_page_cache(struct page *page);
diff --git a/mm/filemap.c b/mm/filemap.c
index c41782c..9960250 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -490,6 +490,73 @@ out:
 }
 EXPORT_SYMBOL(add_to_page_cache_locked);
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+/**
+ * add_to_page_cache_store_memcg - add a page to the pagecache and store memcg
+ * @page:	page to add
+ * @mapping:	the page's address_space
+ * @offset:	page index
+ * @gfp_mask:	page allocation mode
+ * @ptr:	store mem_cgroup where charge was failed
+ *
+ * This function is used to add a page to the pagecache. It must be locked.
+ * This function does not add the page to the LRU.  The caller must do that.
+ * Unlike add_to_page_cache_locked, this function uses try_charge/commit_charge
+ * scheme and stores memcg where charge was failed.
+ * This function is called only from shmem_getpage, and it passes this memcg
+ * to shrink_usage. Extra refcnt of this memcg is decremented in shrink_usage.
+ */
+int add_to_page_cache_store_memcg(struct page *page,
+				struct address_space *mapping, pgoff_t offset,
+				gfp_t gfp_mask, struct mem_cgroup **ptr)
+{
+	struct mem_cgroup *mem = NULL;
+	struct mem_cgroup *fail = NULL;
+	int error;
+
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!ptr);
+
+	error = mem_cgroup_try_charge_swapin(current->mm, page,
+					gfp_mask & GFP_RECLAIM_MASK,
+					&mem, &fail);
+	if (error) {
+		VM_BUG_ON(error != -ENOMEM);
+		VM_BUG_ON(!fail);
+		*ptr = fail;
+		goto out;
+	}
+
+	*ptr = NULL;
+	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
+	if (error == 0) {
+		page_cache_get(page);
+		page->mapping = mapping;
+		page->index = offset;
+
+		spin_lock_irq(&mapping->tree_lock);
+		error = radix_tree_insert(&mapping->page_tree, offset, page);
+		if (likely(!error)) {
+			mapping->nrpages++;
+			__inc_zone_page_state(page, NR_FILE_PAGES);
+		} else {
+			page->mapping = NULL;
+			mem_cgroup_cancel_charge_swapin(mem);
+			page_cache_release(page);
+		}
+		spin_unlock_irq(&mapping->tree_lock);
+		radix_tree_preload_end();
+
+		if (likely(!error))
+			mem_cgroup_commit_cache_charge_swapin(page, mem);
+	} else
+		mem_cgroup_cancel_charge_swapin(mem);
+out:
+	return error;
+}
+EXPORT_SYMBOL(add_to_page_cache_store_memcg);
+#endif
+
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t offset, gfp_t gfp_mask)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3492286..7d3078c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -940,7 +940,7 @@ static void record_last_oom(struct mem_cgroup *mem)
  */
 static int __mem_cgroup_try_charge(struct mm_struct *mm,
 			gfp_t gfp_mask, struct mem_cgroup **memcg,
-			bool oom)
+			struct mem_cgroup **fail, bool oom)
 {
 	struct mem_cgroup *mem, *mem_over_limit;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
@@ -1023,6 +1023,10 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 	}
 	return 0;
 nomem:
+	if (fail) {
+		css_get(&mem_over_limit->css); /* Callers should call css_put */
+		*fail = mem_over_limit;
+	}
 	css_put(&mem->css);
 	return -ENOMEM;
 }
@@ -1187,7 +1191,7 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
 	parent = mem_cgroup_from_cont(pcg);
 
 
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false);
+	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, NULL, false);
 	if (ret || !parent)
 		return ret;
 
@@ -1244,7 +1248,7 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 	prefetchw(pc);
 
 	mem = memcg;
-	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true);
+	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, NULL, true);
 	if (ret || !mem)
 		return ret;
 
@@ -1274,10 +1278,6 @@ int mem_cgroup_newpage_charge(struct page *page,
 				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
 }
 
-static void
-__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
-					enum charge_type ctype);
-
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
@@ -1323,10 +1323,10 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 
 	/* shmem */
 	if (PageSwapCache(page)) {
-		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &mem);
+		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask,
+							&mem, NULL);
 		if (!ret)
-			__mem_cgroup_commit_charge_swapin(page, mem,
-					MEM_CGROUP_CHARGE_TYPE_SHMEM);
+			mem_cgroup_commit_cache_charge_swapin(page, mem);
 	} else
 		ret = mem_cgroup_charge_common(page, mm, gfp_mask,
 					MEM_CGROUP_CHARGE_TYPE_SHMEM, mem);
@@ -1341,8 +1341,9 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
  * "commit()" or removed by "cancel()"
  */
 int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
-				 struct page *page,
-				 gfp_t mask, struct mem_cgroup **ptr)
+				 struct page *page, gfp_t mask,
+				 struct mem_cgroup **ptr,
+				 struct mem_cgroup **fail_ptr)
 {
 	struct mem_cgroup *mem;
 	int ret;
@@ -1363,14 +1364,14 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 	if (!mem)
 		goto charge_cur_mm;
 	*ptr = mem;
-	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true);
+	ret = __mem_cgroup_try_charge(NULL, mask, ptr, fail_ptr, true);
 	/* drop extra refcnt from tryget */
 	css_put(&mem->css);
 	return ret;
 charge_cur_mm:
 	if (unlikely(!mm))
 		mm = &init_mm;
-	return __mem_cgroup_try_charge(mm, mask, ptr, true);
+	return __mem_cgroup_try_charge(mm, mask, ptr, fail_ptr, true);
 }
 
 static void
@@ -1432,6 +1433,13 @@ void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 					MEM_CGROUP_CHARGE_TYPE_MAPPED);
 }
 
+void mem_cgroup_commit_cache_charge_swapin(struct page *page,
+					struct mem_cgroup *ptr)
+{
+	__mem_cgroup_commit_charge_swapin(page, ptr,
+					MEM_CGROUP_CHARGE_TYPE_SHMEM);
+}
+
 void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
 {
 	if (mem_cgroup_disabled())
@@ -1604,7 +1612,8 @@ int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
 	unlock_page_cgroup(pc);
 
 	if (mem) {
-		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
+		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, NULL,
+						false);
 		css_put(&mem->css);
 	}
 	*ptr = mem;
@@ -1668,22 +1677,15 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
  * This is typically used for page reclaiming for shmem for reducing side
  * effect of page allocation from shmem, which is used by some mem_cgroup.
  */
-int mem_cgroup_shrink_usage(struct page *page,
-			    struct mm_struct *mm,
-			    gfp_t gfp_mask)
+int mem_cgroup_shrink_usage(struct mem_cgroup *mem, gfp_t gfp_mask)
 {
-	struct mem_cgroup *mem = NULL;
 	int progress = 0;
 	int retry = MEM_CGROUP_RECLAIM_RETRIES;
 
+	VM_BUG_ON(!mem);
+
 	if (mem_cgroup_disabled())
 		return 0;
-	if (page)
-		mem = try_get_mem_cgroup_from_swapcache(page);
-	if (!mem && mm)
-		mem = try_get_mem_cgroup_from_mm(mm);
-	if (unlikely(!mem))
-		return 0;
 
 	do {
 		progress = mem_cgroup_hierarchical_reclaim(mem,
@@ -1691,9 +1693,15 @@ int mem_cgroup_shrink_usage(struct page *page,
 		progress += mem_cgroup_check_under_limit(mem);
 	} while (!progress && --retry);
 
-	css_put(&mem->css);
-	if (!retry)
+	if (!retry) {
+		mutex_lock(&memcg_tasklist);
+		mem_cgroup_out_of_memory(mem, gfp_mask);
+		mutex_unlock(&memcg_tasklist);
+		record_last_oom(mem);
+		css_put(&mem->css);	/* got when try_charge failed */
 		return -ENOMEM;
+	}
+	css_put(&mem->css);	/* got when try_charge failed */
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 28f1e70..b5fa0c6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2456,7 +2456,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	lock_page(page);
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 
-	if (mem_cgroup_try_charge_swapin(mm, page, GFP_KERNEL, &ptr)) {
+	if (mem_cgroup_try_charge_swapin(mm, page, GFP_KERNEL, &ptr, NULL)) {
 		ret = VM_FAULT_OOM;
 		unlock_page(page);
 		goto out;
diff --git a/mm/shmem.c b/mm/shmem.c
index a5a30fd..ca7751f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1196,6 +1196,7 @@ static int shmem_getpage(struct inode *inode, unsigned long long idx,
 	struct shmem_sb_info *sbinfo;
 	struct page *filepage = *pagep;
 	struct page *swappage;
+	struct mem_cgroup *mem = NULL;
 	swp_entry_t *entry;
 	swp_entry_t swap;
 	gfp_t gfp;
@@ -1312,8 +1313,8 @@ repeat:
 			SetPageUptodate(filepage);
 			set_page_dirty(filepage);
 			swap_free(swap);
-		} else if (!(error = add_to_page_cache_locked(swappage, mapping,
-					idx, GFP_NOWAIT))) {
+		} else if (!(error = add_to_page_cache_store_memcg(swappage,
+					mapping, idx, GFP_NOWAIT, &mem))) {
 			info->flags |= SHMEM_PAGEIN;
 			shmem_swp_set(info, entry, 0);
 			shmem_swp_unmap(entry);
@@ -1325,19 +1326,16 @@ repeat:
 		} else {
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
+			unlock_page(swappage);
+			page_cache_release(swappage);
 			if (error == -ENOMEM) {
-				/* allow reclaim from this memory cgroup */
-				error = mem_cgroup_shrink_usage(swappage,
-								current->mm,
-								gfp);
-				if (error) {
-					unlock_page(swappage);
-					page_cache_release(swappage);
+				if (mem)
+					/* reclaim from this memory cgroup */
+					error = mem_cgroup_shrink_usage(mem,
+									gfp);
+				if (error)
 					goto failed;
-				}
 			}
-			unlock_page(swappage);
-			page_cache_release(swappage);
 			goto repeat;
 		}
 	} else if (sgp == SGP_READ && !filepage) {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 312fafe..3c6d8f6 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -698,7 +698,8 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	pte_t *pte;
 	int ret = 1;
 
-	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page, GFP_KERNEL, &ptr)) {
+	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page, GFP_KERNEL,
+					&ptr, NULL)) {
 		ret = -ENOMEM;
 		goto out_nolock;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
