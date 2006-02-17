Subject: [RFC] 2/4 Migration Cache - add mm checks
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Fri, 17 Feb 2006 10:37:11 -0500
Message-Id: <1140190631.5219.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Migration Cache "V8" 2/4

This patch add the necessary checks for whether a page that
appears to be in the swap cache is really in the migration
cache.  Most of these checks are hidden behind the normal
swap interfaces, and are, thus, limited to the swap sources.
However, a couple of them spill over into mm/memory.c and
vmscan.c.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc3-mm1/mm/memory.c
===================================================================
--- linux-2.6.16-rc3-mm1.orig/mm/memory.c	2006-02-15 10:50:43.000000000 -0500
+++ linux-2.6.16-rc3-mm1/mm/memory.c	2006-02-15 10:50:53.000000000 -0500
@@ -1825,6 +1825,14 @@ void swapin_readahead(swp_entry_t entry,
 	unsigned long offset;
 
 	/*
+	 * no-op for migration cache entries.
+	 * do_swap_page() or shmem_getpage() might hand us one of these.
+TODO:   should be BUG_ON()?
+	 */
+	if (migration_type(swp_type(entry)))
+		return;
+
+	/*
 	 * Get the number of handles we should do readahead io to.
 	 */
 	num = valid_swaphandles(entry, &offset);
Index: linux-2.6.16-rc3-mm1/mm/swap_state.c
===================================================================
--- linux-2.6.16-rc3-mm1.orig/mm/swap_state.c	2006-02-15 10:50:47.000000000 -0500
+++ linux-2.6.16-rc3-mm1/mm/swap_state.c	2006-02-15 10:50:53.000000000 -0500
@@ -393,6 +393,7 @@ int add_to_swap(struct page * page, gfp_
 
 	if (!PageLocked(page))
 		BUG();
+	BUG_ON(page_is_migration(page));
 
 	for (;;) {
 		entry = get_swap_page();
@@ -543,6 +544,11 @@ struct page * lookup_swap_cache(swp_entr
 {
 	struct page *page;
 
+	if (migration_type(swp_type(entry))) {
+		page = lookup_migration_cache(entry);
+		return page;
+	}
+
 	page = find_get_page(&swapper_space, entry.val);
 
 	if (page)
@@ -564,6 +570,14 @@ struct page *read_swap_cache_async(swp_e
 	struct page *found_page, *new_page = NULL;
 	int err;
 
+	/*
+	 * return NULL for migration cache entries.
+	 * do_swap_page() or shmem_swapin() might hand us one of these.
+TODO:  should be BUG_ON() ?
+	 */
+	if (migration_type(swp_type(entry)))
+		return NULL;
+
 	do {
 		/*
 		 * First check the swap cache.  Since this is normally
Index: linux-2.6.16-rc3-mm1/mm/swapfile.c
===================================================================
--- linux-2.6.16-rc3-mm1.orig/mm/swapfile.c	2006-02-15 10:50:43.000000000 -0500
+++ linux-2.6.16-rc3-mm1/mm/swapfile.c	2006-02-15 10:50:53.000000000 -0500
@@ -298,6 +298,11 @@ void swap_free(swp_entry_t entry)
 {
 	struct swap_info_struct * p;
 
+	if (unlikely(migration_type(swp_type(entry)))) {
+		migration_remove_entry(entry, 1);
+		return;
+	}
+
 	p = swap_info_get(entry);
 	if (p) {
 		swap_entry_free(p, swp_offset(entry));
@@ -315,6 +320,10 @@ static inline int page_swapcount(struct 
 	swp_entry_t entry;
 
 	entry.val = page_private(page);
+
+	if (unlikely(migration_type(swp_type(entry))))
+		return migration_ref_count(entry);
+
 	p = swap_info_get(entry);
 	if (p) {
 		/* Subtract the 1 for the swap cache itself */
@@ -360,6 +369,24 @@ int remove_exclusive_swap_page(struct pa
 		return 0;
 
 	entry.val = page_private(page);
+	/*
+	 * Don't call swap_info_get() for migration type.
+	 */
+	if (unlikely(migration_type(swp_type(entry)))) {
+		/*
+TODO: following applies to "lazy page migration" only:
+		 * If we get here with a migration cache page,
+		 * do_swap_page() has handled a migration cache page and
+		 * swap is > 1/2 full, or we are in exit/unmap path, and
+		 * page is already present in current's pte.  The reason
+		 * it is still in the migration cache is because the
+		 * page is shared by other processes [ancestors or
+		 * decendants].  So, just ignore it.
+		 * TODO: page_cache_release?
+		 */
+		return 0;
+	}
+
 	p = swap_info_get(entry);
 	if (!p)
 		return 0;
@@ -395,6 +422,11 @@ void free_swap_and_cache(swp_entry_t ent
 	struct swap_info_struct * p;
 	struct page *page = NULL;
 
+	if (unlikely(migration_type(swp_type(entry)))) {
+		migration_remove_entry(entry, 0);
+		return;
+	}
+
 	p = swap_info_get(entry);
 	if (p) {
 		if (swap_entry_free(p, swp_offset(entry)) == 1)
@@ -1415,6 +1447,15 @@ asmlinkage long sys_swapon(const char __
 		spin_unlock(&swap_lock);
 		goto out;
 	}
+
+	/*
+	 * MIGRATION_TYPE is reserved for [stolen by] the migration cache
+	 */
+	if (migration_type(type)) {
+		spin_unlock(&swap_lock);
+		goto out;
+	}
+
 	if (type >= nr_swapfiles)
 		nr_swapfiles = type+1;
 	INIT_LIST_HEAD(&p->extent_list);
@@ -1702,6 +1743,12 @@ int swap_duplicate(swp_entry_t entry)
 	int result = 0;
 
 	type = swp_type(entry);
+
+	if (unlikely(migration_type(type))) {
+		migration_duplicate(entry);
+		return 1;
+	}
+
 	if (type >= nr_swapfiles)
 		goto bad_file;
 	p = type + swap_info;
Index: linux-2.6.16-rc3-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.16-rc3-mm1.orig/include/linux/mm.h	2006-02-15 10:50:43.000000000 -0500
+++ linux-2.6.16-rc3-mm1/include/linux/mm.h	2006-02-15 10:50:53.000000000 -0500
@@ -547,6 +547,14 @@ void page_address_init(void);
 #define page_address_init()  do { } while(0)
 #endif
 
+#ifdef CONFIG_MIGRATION
+//TODO:  can I make this 'static inline' here?  header dependencies?
+extern int page_is_migration(struct page *);
+extern struct address_space migration_space;
+#else
+#define page_is_migration(p) (0)
+#endif
+
 /*
  * On an anonymous page mapped into a user virtual memory area,
  * page->mapping points to its anon_vma, not to a struct address_space;
@@ -563,9 +571,12 @@ static inline struct address_space *page
 {
 	struct address_space *mapping = page->mapping;
 
-	if (unlikely(PageSwapCache(page)))
-		mapping = &swapper_space;
-	else if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
+	if (unlikely(PageSwapCache(page))) {
+		if (unlikely(page_is_migration(page)))
+			mapping = &migration_space;
+		else
+			mapping = &swapper_space;
+	} else if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
 		mapping = NULL;
 	return mapping;
 }
Index: linux-2.6.16-rc3-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc3-mm1.orig/mm/vmscan.c	2006-02-15 10:50:43.000000000 -0500
+++ linux-2.6.16-rc3-mm1/mm/vmscan.c	2006-02-15 10:50:53.000000000 -0500
@@ -457,11 +457,19 @@ static unsigned long shrink_page_list(st
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page)) {
-			if (!sc->may_swap)
+		if (PageAnon(page)) {
+			if (!PageSwapCache(page)) {
+				if (!sc->may_swap)
+					goto keep_locked;
+				if (!add_to_swap(page, GFP_ATOMIC))
+					goto activate_locked;
+			} else if (page_is_migration(page)) {
+				/*
+				 * For now, skip migration cache pages.
+				 * TODO:  move to swap cache [difficult?]
+				 */
 				goto keep_locked;
-			if (!add_to_swap(page, GFP_ATOMIC))
-				goto activate_locked;
+			}
 		}
 #endif /* CONFIG_SWAP */
 
Index: linux-2.6.16-rc3-mm1/mm/rmap.c
===================================================================
--- linux-2.6.16-rc3-mm1.orig/mm/rmap.c	2006-02-15 10:50:43.000000000 -0500
+++ linux-2.6.16-rc3-mm1/mm/rmap.c	2006-02-15 10:50:53.000000000 -0500
@@ -232,7 +232,13 @@ void remove_from_swap(struct page *page)
 
 	spin_unlock(&anon_vma->lock);
 
-	delete_from_swap_cache(page);
+	if (PageSwapCache(page))
+		delete_from_swap_cache(page);
+	/*
+	 * if page was in migration cache, it will have been
+	 * removed when the last swap pte referencing the entry
+	 * was removed by the loop above.
+	 */
 }
 EXPORT_SYMBOL(remove_from_swap);
 #endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
