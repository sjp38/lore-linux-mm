Message-Id: <200405222208.i4MM8Lr13357@mail.osdl.org>
Subject: [patch 28/57] numa api: Add policy support to anonymous  memory
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:07:51 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@suse.de>

Change to core VM to use alloc_page_vma() instead of alloc_page().

Change the swap readahead to follow the policy of the VMA.


---

 25-akpm/include/linux/swap.h |    7 ++++---
 25-akpm/mm/memory.c          |   43 ++++++++++++++++++++++++++++++++++++-------
 25-akpm/mm/swap_state.c      |    5 +++--
 25-akpm/mm/swapfile.c        |    2 +-
 4 files changed, 44 insertions(+), 13 deletions(-)

diff -puN include/linux/swap.h~numa-api-anon-memory-policy include/linux/swap.h
--- 25/include/linux/swap.h~numa-api-anon-memory-policy	2004-05-22 14:56:26.041132672 -0700
+++ 25-akpm/include/linux/swap.h	2004-05-22 14:56:26.049131456 -0700
@@ -151,7 +151,7 @@ struct swap_list_t {
 extern void out_of_memory(void);
 
 /* linux/mm/memory.c */
-extern void swapin_readahead(swp_entry_t);
+extern void swapin_readahead(swp_entry_t, unsigned long, struct vm_area_struct *);
 
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
@@ -202,7 +202,8 @@ extern int move_from_swap_cache(struct p
 extern void free_page_and_swap_cache(struct page *);
 extern void free_pages_and_swap_cache(struct page **, int);
 extern struct page * lookup_swap_cache(swp_entry_t);
-extern struct page * read_swap_cache_async(swp_entry_t);
+extern struct page * read_swap_cache_async(swp_entry_t, struct vm_area_struct *vma,
+					   unsigned long addr);
 
 /* linux/mm/swapfile.c */
 extern int total_swap_pages;
@@ -244,7 +245,7 @@ extern spinlock_t swaplock;
 #define free_swap_and_cache(swp)		/*NOTHING*/
 #define swap_duplicate(swp)			/*NOTHING*/
 #define swap_free(swp)				/*NOTHING*/
-#define read_swap_cache_async(swp)		NULL
+#define read_swap_cache_async(swp,vma,addr)	NULL
 #define lookup_swap_cache(swp)			NULL
 #define valid_swaphandles(swp, off)		0
 #define can_share_swap_page(p)			0
diff -puN mm/memory.c~numa-api-anon-memory-policy mm/memory.c
--- 25/mm/memory.c~numa-api-anon-memory-policy	2004-05-22 14:56:26.042132520 -0700
+++ 25-akpm/mm/memory.c	2004-05-22 14:59:39.624703496 -0700
@@ -1071,7 +1071,7 @@ static int do_wp_page(struct mm_struct *
 	page_cache_get(old_page);
 	spin_unlock(&mm->page_table_lock);
 
-	new_page = alloc_page(GFP_HIGHUSER);
+	new_page = alloc_page_vma(GFP_HIGHUSER, vma, address);
 	if (!new_page)
 		goto no_new_page;
 	copy_cow_page(old_page,new_page,address);
@@ -1237,9 +1237,17 @@ EXPORT_SYMBOL(vmtruncate);
  * (1 << page_cluster) entries in the swap area. This method is chosen
  * because it doesn't cost us any seek time.  We also make sure to queue
  * the 'original' request together with the readahead ones...  
+ *
+ * This has been extended to use the NUMA policies from the mm triggering
+ * the readahead.
+ *
+ * Caller must hold down_read on the vma->vm_mm if vma is not NULL.
  */
-void swapin_readahead(swp_entry_t entry)
+void swapin_readahead(swp_entry_t entry, unsigned long addr,struct vm_area_struct *vma)
 {
+#ifdef CONFIG_NUMA
+	struct vm_area_struct *next_vma = vma ? vma->vm_next : NULL;
+#endif
 	int i, num;
 	struct page *new_page;
 	unsigned long offset;
@@ -1251,10 +1259,31 @@ void swapin_readahead(swp_entry_t entry)
 	for (i = 0; i < num; offset++, i++) {
 		/* Ok, do the async read-ahead now */
 		new_page = read_swap_cache_async(swp_entry(swp_type(entry),
-						offset));
+							   offset), vma, addr);
 		if (!new_page)
 			break;
 		page_cache_release(new_page);
+#ifdef CONFIG_NUMA
+		/*
+		 * Find the next applicable VMA for the NUMA policy.
+		 */
+		addr += PAGE_SIZE;
+		if (addr == 0)
+			vma = NULL;
+		if (vma) {
+			if (addr >= vma->vm_end) {
+				vma = next_vma;
+				next_vma = vma ? vma->vm_next : NULL;
+			}
+			if (vma && addr < vma->vm_start)
+				vma = NULL;
+		} else {
+			if (next_vma && addr >= next_vma->vm_start) {
+				vma = next_vma;
+				next_vma = vma->vm_next;
+			}
+		}
+#endif
 	}
 	lru_add_drain();	/* Push any new pages onto the LRU now */
 }
@@ -1276,8 +1305,8 @@ static int do_swap_page(struct mm_struct
 	spin_unlock(&mm->page_table_lock);
 	page = lookup_swap_cache(entry);
 	if (!page) {
-		swapin_readahead(entry);
-		page = read_swap_cache_async(entry);
+ 		swapin_readahead(entry, address, vma);
+ 		page = read_swap_cache_async(entry, vma, address);
 		if (!page) {
 			/*
 			 * Back out if somebody else faulted in this pte while
@@ -1372,7 +1401,7 @@ do_anonymous_page(struct mm_struct *mm, 
 		pte_unmap(page_table);
 		spin_unlock(&mm->page_table_lock);
 
-		page = alloc_page(GFP_HIGHUSER);
+		page = alloc_page_vma(GFP_HIGHUSER, vma, addr);
 		if (!page)
 			goto no_mem;
 		clear_user_highpage(page, addr);
@@ -1454,7 +1483,7 @@ retry:
 	 * Should we do an early C-O-W break?
 	 */
 	if (write_access && !(vma->vm_flags & VM_SHARED)) {
-		struct page * page = alloc_page(GFP_HIGHUSER);
+		struct page *page = alloc_page_vma(GFP_HIGHUSER, vma, address);
 		if (!page)
 			goto oom;
 		copy_user_highpage(page, new_page, address);
diff -puN mm/swapfile.c~numa-api-anon-memory-policy mm/swapfile.c
--- 25/mm/swapfile.c~numa-api-anon-memory-policy	2004-05-22 14:56:26.044132216 -0700
+++ 25-akpm/mm/swapfile.c	2004-05-22 14:59:35.972258752 -0700
@@ -657,7 +657,7 @@ static int try_to_unuse(unsigned int typ
 		 */
 		swap_map = &si->swap_map[i];
 		entry = swp_entry(type, i);
-		page = read_swap_cache_async(entry);
+		page = read_swap_cache_async(entry, NULL, 0);
 		if (!page) {
 			/*
 			 * Either swap_duplicate() failed because entry
diff -puN mm/swap_state.c~numa-api-anon-memory-policy mm/swap_state.c
--- 25/mm/swap_state.c~numa-api-anon-memory-policy	2004-05-22 14:56:26.045132064 -0700
+++ 25-akpm/mm/swap_state.c	2004-05-22 14:56:26.052131000 -0700
@@ -327,7 +327,8 @@ struct page * lookup_swap_cache(swp_entr
  * A failure return means that either the page allocation failed or that
  * the swap entry is no longer in use.
  */
-struct page * read_swap_cache_async(swp_entry_t entry)
+struct page *read_swap_cache_async(swp_entry_t entry,
+			struct vm_area_struct *vma, unsigned long addr)
 {
 	struct page *found_page, *new_page = NULL;
 	int err;
@@ -351,7 +352,7 @@ struct page * read_swap_cache_async(swp_
 		 * Get a new page to read into from swap.
 		 */
 		if (!new_page) {
-			new_page = alloc_page(GFP_HIGHUSER);
+			new_page = alloc_page_vma(GFP_HIGHUSER, vma, addr);
 			if (!new_page)
 				break;		/* Out of memory */
 		}

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
