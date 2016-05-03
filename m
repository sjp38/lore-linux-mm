Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 95EF66B0265
	for <linux-mm@kvack.org>; Tue,  3 May 2016 17:02:49 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id yl2so43165576pac.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 14:02:49 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id vh16si323550pab.164.2016.05.03.14.02.48
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 14:02:48 -0700 (PDT)
Message-ID: <1462309367.21143.12.camel@linux.intel.com>
Subject: [PATCH 5/7] mm: Batch addtion of pages to swap cache
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 03 May 2016 14:02:47 -0700
In-Reply-To: <cover.1462306228.git.tim.c.chen@linux.intel.com>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>
Cc: "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

When a page is to be swapped, it needed to be added to the swap cache
and then removed after the paging has been completed.A A A swap partition's
mapping tree lock is acquired for each anonymous page's addition to the
swap cache.

This patch created new functions add_to_swap_batch and
__add_to_swap_cache_batch that allows multiple pages destinied for the
same swap partition to be added to that swap partition's swap cache in
one acquisition of the mapping tree lock.A A These functions extend the
original add_to_swap and __add_to_swap_cache. This reduces the contention
of the swap partition's mapping tree lock when we are actively reclaiming
memory and swapping pages

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
A include/linux/swap.h |A A A 2 +
A mm/swap_state.cA A A A A A | 248 +++++++++++++++++++++++++++++++++++++--------------
A mm/vmscan.cA A A A A A A A A A |A A 19 ++--
A 3 files changed, 196 insertions(+), 73 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index da6d994..cd06f2a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -373,6 +373,8 @@ extern unsigned long total_swapcache_pages(void);
A extern void show_swap_cache_info(void);
A extern int add_to_swap(struct page *, struct list_head *list,
A 			swp_entry_t *entry);
+extern void add_to_swap_batch(struct page *pages[], struct list_head *list,
+			swp_entry_t entries[], int ret_codes[], int nr);
A extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
A extern int __add_to_swap_cache(struct page *page, swp_entry_t entry);
A extern void __delete_from_swap_cache(struct page *);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index bad02c1..ce02024 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -72,49 +72,94 @@ void show_swap_cache_info(void)
A 	printk("Total swap = %lukB\n", total_swap_pages << (PAGE_SHIFT - 10));
A }
A 
-/*
- * __add_to_swap_cache resembles add_to_page_cache_locked on swapper_space,
- * but sets SwapCache flag and private instead of mapping and index.
- */
-int __add_to_swap_cache(struct page *page, swp_entry_t entry)
+void __add_to_swap_cache_batch(struct page *pages[], swp_entry_t entries[],
+				int ret[], int nr)
A {
-	int error;
+	int error, i;
A 	struct address_space *address_space;
+	struct address_space *prev;
+	struct page *page;
+	swp_entry_t entry;
A 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(PageSwapCache(page), page);
-	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+	prev = NULL;
+	address_space = NULL;
+	for (i = 0; i < nr; ++i) {
+		/* error at pre-processing stage, swap entry already released */
+		if (ret[i] == -ENOENT)
+			continue;
A 
-	get_page(page);
-	SetPageSwapCache(page);
-	set_page_private(page, entry.val);
+		page = pages[i];
+		entry = entries[i];
A 
-	address_space = swap_address_space(entry);
-	spin_lock_irq(&address_space->tree_lock);
-	error = radix_tree_insert(&address_space->page_tree,
-					entry.val, page);
-	if (likely(!error)) {
-		address_space->nrpages++;
-		__inc_zone_page_state(page, NR_FILE_PAGES);
-		INC_CACHE_INFO(add_total);
-	}
-	spin_unlock_irq(&address_space->tree_lock);
+		VM_BUG_ON_PAGE(!PageLocked(page), page);
+		VM_BUG_ON_PAGE(PageSwapCache(page), page);
+		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
A 
-	if (unlikely(error)) {
-		/*
-		A * Only the context which have set SWAP_HAS_CACHE flag
-		A * would call add_to_swap_cache().
-		A * So add_to_swap_cache() doesn't returns -EEXIST.
-		A */
-		VM_BUG_ON(error == -EEXIST);
-		set_page_private(page, 0UL);
-		ClearPageSwapCache(page);
-		put_page(page);
+		get_page(page);
+		SetPageSwapCache(page);
+		set_page_private(page, entry.val);
+
+		address_space = swap_address_space(entry);
+		if (prev != address_space) {
+			if (prev)
+				spin_unlock_irq(&prev->tree_lock);
+			spin_lock_irq(&address_space->tree_lock);
+		}
+		error = radix_tree_insert(&address_space->page_tree,
+				entry.val, page);
+		if (likely(!error)) {
+			address_space->nrpages++;
+			__inc_zone_page_state(page, NR_FILE_PAGES);
+			INC_CACHE_INFO(add_total);
+		}
+
+		if (unlikely(error)) {
+			spin_unlock_irq(&address_space->tree_lock);
+			address_space = NULL;
+			/*
+			A * Only the context which have set SWAP_HAS_CACHE flag
+			A * would call add_to_swap_cache().
+			A * So add_to_swap_cache() doesn't returns -EEXIST.
+			A */
+			VM_BUG_ON(error == -EEXIST);
+			set_page_private(page, 0UL);
+			ClearPageSwapCache(page);
+			put_page(page);
+		}
+		prev = address_space;
+		ret[i] = error;
A 	}
+	if (address_space)
+		spin_unlock_irq(&address_space->tree_lock);
+}
A 
-	return error;
+/*
+ * __add_to_swap_cache resembles add_to_page_cache_locked on swapper_space,
+ * but sets SwapCache flag and private instead of mapping and index.
+ */
+int __add_to_swap_cache(struct page *page, swp_entry_t entry)
+{
+	swp_entry_t	entries[1];
+	struct page	*pages[1];
+	int	ret[1];
+
+	pages[0] = page;
+	entries[0] = entry;
+	__add_to_swap_cache_batch(pages, entries, ret, 1);
+	return ret[0];
A }
A 
+void add_to_swap_cache_batch(struct page *pages[], swp_entry_t entries[],
+				gfp_t gfp_mask, int ret[], int nr)
+{
+	int error;
+
+	error = radix_tree_maybe_preload(gfp_mask);
+	if (!error) {
+		__add_to_swap_cache_batch(pages, entries, ret, nr);
+		radix_tree_preload_end();
+	}
+}
A 
A int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
A {
@@ -151,6 +196,73 @@ void __delete_from_swap_cache(struct page *page)
A 	INC_CACHE_INFO(del_total);
A }
A 
+void add_to_swap_batch(struct page *pages[], struct list_head *list,
+			swp_entry_t entries[], int ret_codes[], int nr)
+{
+	swp_entry_t *entry;
+	struct page *page;
+	int i;
+
+	for (i = 0; i < nr; ++i) {
+		entry = &entries[i];
+		page = pages[i];
+
+		VM_BUG_ON_PAGE(!PageLocked(page), page);
+		VM_BUG_ON_PAGE(!PageUptodate(page), page);
+
+		ret_codes[i] = 1;
+
+		if (!entry->val)
+			ret_codes[i] = -ENOENT;
+
+		if (mem_cgroup_try_charge_swap(page, *entry)) {
+			swapcache_free(*entry);
+			ret_codes[i] = 0;
+		}
+
+		if (unlikely(PageTransHuge(page)))
+			if (unlikely(split_huge_page_to_list(page, list))) {
+				swapcache_free(*entry);
+				ret_codes[i] = -ENOENT;
+				continue;
+			}
+	}
+
+	/*
+	A * Radix-tree node allocations from PF_MEMALLOC contexts could
+	A * completely exhaust the page allocator. __GFP_NOMEMALLOC
+	A * stops emergency reserves from being allocated.
+	A *
+	A * TODO: this could cause a theoretical memory reclaim
+	A * deadlock in the swap out path.
+	A */
+	/*
+	A * Add it to the swap cache
+	A */
+	add_to_swap_cache_batch(pages, entries,
+			__GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN,
+				ret_codes, nr);
+
+	for (i = 0; i < nr; ++i) {
+		entry = &entries[i];
+		page = pages[i];
+
+		if (!ret_codes[i]) {A A A A /* Success */
+			ret_codes[i] = 1;
+			continue;
+		} else {A A A A A A A A /* -ENOMEM radix-tree allocation failure */
+			/*
+			A * add_to_swap_cache() doesn't return -EEXIST,
+			A * so we can safely clear SWAP_HAS_CACHE flag.
+			A */
+			if (ret_codes[i] != -ENOENT)
+				swapcache_free(*entry);
+			ret_codes[i] = 0;
+			continue;
+		}
+	}
+}
+
A /**
A  * add_to_swap - allocate swap space for a page
A  * @page: page we want to move to swap
@@ -161,54 +273,56 @@ void __delete_from_swap_cache(struct page *page)
A  */
A int add_to_swap(struct page *page, struct list_head *list, swp_entry_t *entry)
A {
-	int err;
-	swp_entry_t ent;
+	int ret[1];
+	swp_entry_t ent[1];
A 
A 	VM_BUG_ON_PAGE(!PageLocked(page), page);
A 	VM_BUG_ON_PAGE(!PageUptodate(page), page);
A 
A 	if (!entry) {
-		ent = get_swap_page();
-		entry = &ent;
+		ent[0] = get_swap_page();
+		entry = &ent[0];
A 	}
A 
A 	if (entry && !entry->val)
A 		return 0;
A 
-	if (mem_cgroup_try_charge_swap(page, *entry)) {
-		swapcache_free(*entry);
-		return 0;
-	}
+	add_to_swap_batch(&page, list, entry, ret, 1);
+	return ret[0];
+}
A 
-	if (unlikely(PageTransHuge(page)))
-		if (unlikely(split_huge_page_to_list(page, list))) {
-			swapcache_free(*entry);
-			return 0;
+void delete_from_swap_cache_batch(struct page pages[], int nr)
+{
+	struct page *page;
+	swp_entry_t entry;
+	struct address_space *address_space, *prev;
+	int i;
+
+	prev = NULL;
+	address_space = NULL;
+	for (i = 0; i < nr; ++i) {
+		page = &pages[i];
+		entry.val = page_private(page);
+
+		address_space = swap_address_space(entry);
+		if (address_space != prev) {
+			if (prev)
+				spin_unlock_irq(&prev->tree_lock);
+			spin_lock_irq(&address_space->tree_lock);
A 		}
+		__delete_from_swap_cache(page);
+		prev = address_space;
+	}
+	if (address_space)
+		spin_unlock_irq(&address_space->tree_lock);
A 
-	/*
-	A * Radix-tree node allocations from PF_MEMALLOC contexts could
-	A * completely exhaust the page allocator. __GFP_NOMEMALLOC
-	A * stops emergency reserves from being allocated.
-	A *
-	A * TODO: this could cause a theoretical memory reclaim
-	A * deadlock in the swap out path.
-	A */
-	/*
-	A * Add it to the swap cache.
-	A */
-	err = add_to_swap_cache(page, *entry,
-			__GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN);
+	for (i = 0; i < nr; ++i) {
+		page = &pages[i];
+		entry.val = page_private(page);
A 
-	if (!err) {
-		return 1;
-	} else {	/* -ENOMEM radix-tree allocation failure */
-		/*
-		A * add_to_swap_cache() doesn't return -EEXIST, so we can safely
-		A * clear SWAP_HAS_CACHE flag.
-		A */
-		swapcache_free(*entry);
-		return 0;
+		/* can batch this */
+		swapcache_free(entry);
+		put_page(page);
A 	}
A }
A 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 310e2b2..fab61f1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1097,8 +1097,9 @@ static unsigned long shrink_anon_page_list(struct list_head *page_list,
A 	unsigned long nr_reclaimed = 0;
A 	enum pg_result pg_dispose;
A 	swp_entry_t swp_entries[SWAP_BATCH];
+	struct page *pages[SWAP_BATCH];
+	int m, i, k, ret[SWAP_BATCH];
A 	struct page *page;
-	int m, i, k;
A 
A 	while (n > 0) {
A 		int swap_ret = SWAP_SUCCESS;
@@ -1117,13 +1118,19 @@ static unsigned long shrink_anon_page_list(struct list_head *page_list,
A 			page = lru_to_page(swap_pages);
A 
A 			list_del(&page->lru);
+			pages[i] = page;
+		}
A 
-			/*
-			* Anonymous process memory has backing store?
-			* Try to allocate it some swap space here.
-			*/
+		/*
+		* Anonymous process memory has backing store?
+		* Try to allocate it some swap space here.
+		*/
+		add_to_swap_batch(pages, page_list, swp_entries, ret, m);
+
+		for (i = 0; i < m; ++i) {
+			page = pages[i];
A 
-			if (!add_to_swap(page, page_list, NULL)) {
+			if (!ret[i]) {
A 				pg_finish(page, PG_ACTIVATE_LOCKED, swap_ret,
A 						&nr_reclaimed, pgactivate,
A 						ret_pages, free_pages);
--A 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
