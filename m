Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 6F6AD6B005A
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 12:47:16 -0400 (EDT)
Subject: Re: [RFC PATCH 2/2] mm: Batch page_check_references in
 shrink_page_list sharing the same i_mmap_mutex
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <1345251998.13492.235.camel@schen9-DESK>
References: <1345251998.13492.235.camel@schen9-DESK>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 20 Aug 2012 09:43:02 -0700
Message-ID: <1345480982.13492.239.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>

On Fri, 2012-08-17 at 18:06 -0700, Tim Chen wrote:
> In shrink_page_list, call to page_referenced_file will causes the
> acquisition/release of mapping->i_mmap_mutex for each page in the page
> list.  However, it is very likely that successive pages in the list
> share the same mapping and we can reduce the frequency of i_mmap_mutex
> acquisition by holding the mutex in shrink_page_list. This improves the
> performance when the system has a lot page reclamations for file mapped
> pages if workloads are using a lot of memory for page cache.
> 
> Tim
> 
> ---

The patch I sent previously was generated against an intermediate tree.
Here's the correct version.

Thanks.

Tim

---
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index fd07c45..f0174ae 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -156,8 +156,8 @@ static inline void page_dup_rmap(struct page *page)
 /*
  * Called from mm/vmscan.c to handle paging out
  */
-int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *memcg, unsigned long *vm_flags);
+int page_referenced(struct page *, int is_locked, struct mem_cgroup *memcg,
+				unsigned long *vm_flags, int mmap_mutex_locked);
 int page_referenced_one(struct page *, struct vm_area_struct *,
 	unsigned long address, unsigned int *mapcount, unsigned long *vm_flags);
 
@@ -175,7 +175,7 @@ enum ttu_flags {
 
 bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
-int try_to_unmap(struct page *, enum ttu_flags flags);
+int try_to_unmap(struct page *, enum ttu_flags flags, int mmap_mutex_locked);
 int try_to_unmap_one(struct page *, struct vm_area_struct *,
 			unsigned long address, enum ttu_flags flags);
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 97cc273..5f162c7 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -953,7 +953,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	if (hpage != ppage)
 		lock_page(ppage);
 
-	ret = try_to_unmap(ppage, ttu);
+	ret = try_to_unmap(ppage, ttu, 0);
 	if (ret != SWAP_SUCCESS)
 		printk(KERN_ERR "MCE %#lx: failed to unmap page (mapcount=%d)\n",
 				pfn, page_mapcount(ppage));
diff --git a/mm/migrate.c b/mm/migrate.c
index 1107238..1aa37b1 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -802,7 +802,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	}
 
 	/* Establish migration ptes or remove ptes */
-	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS, 0);
 
 skip_unmap:
 	if (!page_mapped(page))
@@ -918,7 +918,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	if (PageAnon(hpage))
 		anon_vma = page_get_anon_vma(hpage);
 
-	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+	try_to_unmap(hpage,
+		     TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS, 0);
 
 	if (!page_mapped(hpage))
 		rc = move_to_new_page(new_hpage, hpage, 1, mode);
diff --git a/mm/rmap.c b/mm/rmap.c
index 5b5ad58..63fc84b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -820,7 +820,7 @@ static int page_referenced_anon(struct page *page,
  */
 static int page_referenced_file(struct page *page,
 				struct mem_cgroup *memcg,
-				unsigned long *vm_flags)
+				unsigned long *vm_flags, int mmap_mutex_locked)
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
@@ -844,7 +844,8 @@ static int page_referenced_file(struct page *page,
 	 */
 	BUG_ON(!PageLocked(page));
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	if (!mmap_mutex_locked)
+		mutex_lock(&mapping->i_mmap_mutex);
 
 	/*
 	 * i_mmap_mutex does not stabilize mapcount at all, but mapcount
@@ -869,7 +870,8 @@ static int page_referenced_file(struct page *page,
 			break;
 	}
 
-	mutex_unlock(&mapping->i_mmap_mutex);
+	if (!mmap_mutex_locked)
+		mutex_unlock(&mapping->i_mmap_mutex);
 	return referenced;
 }
 
@@ -886,7 +888,7 @@ static int page_referenced_file(struct page *page,
 int page_referenced(struct page *page,
 		    int is_locked,
 		    struct mem_cgroup *memcg,
-		    unsigned long *vm_flags)
+		    unsigned long *vm_flags, int mmap_mutex_locked)
 {
 	int referenced = 0;
 	int we_locked = 0;
@@ -908,7 +910,7 @@ int page_referenced(struct page *page,
 								vm_flags);
 		else if (page->mapping)
 			referenced += page_referenced_file(page, memcg,
-								vm_flags);
+						 vm_flags, mmap_mutex_locked);
 		if (we_locked)
 			unlock_page(page);
 
@@ -1548,7 +1550,8 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
  * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
  * 'LOCKED.
  */
-static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
+static int try_to_unmap_file(struct page *page, enum ttu_flags flags,
+				int mmap_mutex_locked)
 {
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -1560,7 +1563,8 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	if (!mmap_mutex_locked)
+		mutex_lock(&mapping->i_mmap_mutex);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
@@ -1640,7 +1644,8 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
 		vma->vm_private_data = NULL;
 out:
-	mutex_unlock(&mapping->i_mmap_mutex);
+	if (!mmap_mutex_locked)
+		mutex_unlock(&mapping->i_mmap_mutex);
 	return ret;
 }
 
@@ -1658,7 +1663,7 @@ out:
  * SWAP_FAIL	- the page is unswappable
  * SWAP_MLOCK	- page is mlocked.
  */
-int try_to_unmap(struct page *page, enum ttu_flags flags)
+int try_to_unmap(struct page *page, enum ttu_flags flags, int mmap_mutex_locked)
 {
 	int ret;
 
@@ -1670,7 +1675,7 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 	else if (PageAnon(page))
 		ret = try_to_unmap_anon(page, flags);
 	else
-		ret = try_to_unmap_file(page, flags);
+		ret = try_to_unmap_file(page, flags, mmap_mutex_locked);
 	if (ret != SWAP_MLOCK && !page_mapped(page))
 		ret = SWAP_SUCCESS;
 	return ret;
@@ -1700,7 +1705,7 @@ int try_to_munlock(struct page *page)
 	else if (PageAnon(page))
 		return try_to_unmap_anon(page, TTU_MUNLOCK);
 	else
-		return try_to_unmap_file(page, TTU_MUNLOCK);
+		return try_to_unmap_file(page, TTU_MUNLOCK, 0);
 }
 
 void __put_anon_vma(struct anon_vma *anon_vma)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a538565..1af1f1c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -27,6 +27,7 @@
 					buffer_heads_over_limit */
 #include <linux/mm_inline.h>
 #include <linux/backing-dev.h>
+#include <linux/ksm.h>
 #include <linux/rmap.h>
 #include <linux/topology.h>
 #include <linux/cpu.h>
@@ -781,12 +782,14 @@ enum page_references {
 
 static enum page_references page_check_references(struct page *page,
 						  struct mem_cgroup_zone *mz,
-						  struct scan_control *sc)
+						  struct scan_control *sc,
+						  int mmap_mutex_locked)
 {
 	int referenced_ptes, referenced_page;
 	unsigned long vm_flags;
 
-	referenced_ptes = page_referenced(page, 1, mz->mem_cgroup, &vm_flags);
+	referenced_ptes = page_referenced(page, 1, mz->mem_cgroup, &vm_flags,
+					  mmap_mutex_locked);
 	referenced_page = TestClearPageReferenced(page);
 
 	/* Lumpy reclaim - ignore references */
@@ -856,6 +859,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	unsigned long nr_congested = 0;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_writeback = 0;
+	struct mutex *i_mmap_mutex = NULL;
 
 	cond_resched();
 
@@ -865,12 +869,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
+		int mmap_mutex_locked;
 
 		cond_resched();
 
 		page = lru_to_page(page_list);
 		list_del(&page->lru);
 
+		mmap_mutex_locked = 0;
 		if (!trylock_page(page))
 			goto keep;
 
@@ -909,7 +915,23 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		references = page_check_references(page, mz, sc);
+		if (page->mapping) {
+			if (i_mmap_mutex == &page->mapping->i_mmap_mutex) {
+				mmap_mutex_locked = 1;
+			} else {
+				if (page_mapped(page) && page_rmapping(page)
+					&& !PageKsm(page) && !PageAnon(page)) {
+					if (i_mmap_mutex)
+						mutex_unlock(i_mmap_mutex);
+					i_mmap_mutex = &page->mapping->i_mmap_mutex;
+					mutex_lock(i_mmap_mutex);
+					mmap_mutex_locked = 1;
+				}
+			}
+		}
+
+		references = page_check_references(page, mz, sc,
+						   mmap_mutex_locked);
 		switch (references) {
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
@@ -939,7 +961,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page) && mapping) {
-			switch (try_to_unmap(page, TTU_UNMAP)) {
+			switch (try_to_unmap(page, TTU_UNMAP,
+						mmap_mutex_locked)) {
 			case SWAP_FAIL:
 				goto activate_locked;
 			case SWAP_AGAIN:
@@ -1090,6 +1113,8 @@ keep_lumpy:
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
 
+	if (i_mmap_mutex)
+		mutex_unlock(i_mmap_mutex);
 	nr_reclaimed += __remove_mapping_batch(&unmap_pages, &ret_pages,
 					       &free_pages);
 
@@ -1818,7 +1843,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 			}
 		}
 
-		if (page_referenced(page, 0, mz->mem_cgroup, &vm_flags)) {
+		if (page_referenced(page, 0, mz->mem_cgroup, &vm_flags, 0)) {
 			nr_rotated += hpage_nr_pages(page);
 			/*
 			 * Identify referenced, file-backed active pages and


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
