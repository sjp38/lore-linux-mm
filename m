Date: Wed, 12 Mar 2008 10:59:26 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mmotm] mm: fix various kernel-doc comments
Message-Id: <20080312105926.32415996.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <randy.dunlap@oracle.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Fix various kernel-doc notation in mm/:

filemap.c: add function short description; convert 2 to kernel-doc
fremap.c: change parameter 'prot' to @prot
pagewalk.c: change "-" in function parameters to ":"
slab.c: fix short description of kmem_ptr_validate()
swap.c: fix description & parameters of put_pages_list()
swap_state.c: fix function parameters
vmalloc.c: change "@returns" to "Returns:" since that is not a parameter



Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/filemap.c    |   20 +++++++++++++++++---
 mm/fremap.c     |    2 +-
 mm/pagewalk.c   |   10 +++++-----
 mm/slab.c       |    5 ++---
 mm/swap.c       |    5 ++---
 mm/swap_state.c |    2 ++
 mm/vmalloc.c    |    6 ++++--
 7 files changed, 33 insertions(+), 17 deletions(-)

--- lin2625-rc5-mmotm.orig/mm/filemap.c
+++ lin2625-rc5-mmotm/mm/filemap.c
@@ -344,7 +344,7 @@ int sync_page_range(struct inode *inode,
 EXPORT_SYMBOL(sync_page_range);
 
 /**
- * sync_page_range_nolock
+ * sync_page_range_nolock - write & wait on all pages in the passed range without locking
  * @inode:	target inode
  * @mapping:	target address_space
  * @pos:	beginning offset in pages to write
@@ -612,7 +612,10 @@ int __lock_page_killable(struct page *pa
 					sync_page_killable, TASK_KILLABLE);
 }
 
-/*
+/**
+ * __lock_page_nosync - get a lock on the page, without calling sync_page()
+ * @page: the page to lock
+ *
  * Variant of lock_page that does not require the caller to hold a reference
  * on the page's mapping.
  */
@@ -1540,9 +1543,20 @@ repeat:
 	return page;
 }
 
-/*
+/**
+ * read_cache_page_async - read into page cache, fill it if needed
+ * @mapping:	the page's address_space
+ * @index:	the page index
+ * @filler:	function to perform the read
+ * @data:	destination for read data
+ *
  * Same as read_cache_page, but don't wait for page to become unlocked
  * after submitting it to the filler.
+ *
+ * Read into the page cache. If a page already exists, and PageUptodate() is
+ * not set, try to fill the page but don't wait for it to become unlocked.
+ *
+ * If the page does not get brought uptodate, return -EIO.
  */
 struct page *read_cache_page_async(struct address_space *mapping,
 				pgoff_t index,
--- lin2625-rc5-mmotm.orig/mm/fremap.c
+++ lin2625-rc5-mmotm/mm/fremap.c
@@ -113,7 +113,7 @@ static int populate_range(struct mm_stru
  * mmap()/mremap() it does not create any new vmas. The new mappings are
  * also safe across swapout.
  *
- * NOTE: the 'prot' parameter right now is ignored (but must be zero),
+ * NOTE: the @prot parameter right now is ignored (but must be zero),
  * and the vma's default protection is used. Arbitrary protections
  * might be implemented in the future.
  */
--- lin2625-rc5-mmotm.orig/mm/pagewalk.c
+++ lin2625-rc5-mmotm/mm/pagewalk.c
@@ -77,11 +77,11 @@ static int walk_pud_range(pgd_t *pgd, un
 
 /**
  * walk_page_range - walk a memory map's page tables with a callback
- * @mm - memory map to walk
- * @addr - starting address
- * @end - ending address
- * @walk - set of callbacks to invoke for each level of the tree
- * @private - private data passed to the callback function
+ * @mm: memory map to walk
+ * @addr: starting address
+ * @end: ending address
+ * @walk: set of callbacks to invoke for each level of the tree
+ * @private: private data passed to the callback function
  *
  * Recursively walk the page table for the memory area in a VMA,
  * calling supplied callbacks. Callbacks are called in-order (first
--- lin2625-rc5-mmotm.orig/mm/slab.c
+++ lin2625-rc5-mmotm/mm/slab.c
@@ -3621,12 +3621,11 @@ void *kmem_cache_alloc(struct kmem_cache
 EXPORT_SYMBOL(kmem_cache_alloc);
 
 /**
- * kmem_ptr_validate - check if an untrusted pointer might
- *	be a slab entry.
+ * kmem_ptr_validate - check if an untrusted pointer might be a slab entry.
  * @cachep: the cache we're checking against
  * @ptr: pointer to validate
  *
- * This verifies that the untrusted pointer looks sane:
+ * This verifies that the untrusted pointer looks sane;
  * it is _not_ a guarantee that the pointer is actually
  * part of the slab cache in question, but it at least
  * validates that the pointer can be dereferenced and
--- lin2625-rc5-mmotm.orig/mm/swap.c
+++ lin2625-rc5-mmotm/mm/swap.c
@@ -78,12 +78,11 @@ void put_page(struct page *page)
 EXPORT_SYMBOL(put_page);
 
 /**
- * put_pages_list(): release a list of pages
+ * put_pages_list() - release a list of pages
+ * @pages: list of pages threaded on page->lru
  *
  * Release a list of pages which are strung together on page.lru.  Currently
  * used by read_cache_pages() and related error recovery code.
- *
- * @pages: list of pages threaded on page->lru
  */
 void put_pages_list(struct list_head *pages)
 {
--- lin2625-rc5-mmotm.orig/mm/swap_state.c
+++ lin2625-rc5-mmotm/mm/swap_state.c
@@ -115,6 +115,7 @@ void __delete_from_swap_cache(struct pag
 /**
  * add_to_swap - allocate swap space for a page
  * @page: page we want to move to swap
+ * @gfp_mask: memory allocation flags
  *
  * Allocate swap space for the page and add the page to the
  * swap cache.  Caller needs to hold the page lock. 
@@ -315,6 +316,7 @@ struct page *read_swap_cache_async(swp_e
 /**
  * swapin_readahead - swap in pages in hope we need them soon
  * @entry: swap entry of this memory
+ * @gfp_mask: memory allocation flags
  * @vma: user vma this address belongs to
  * @addr: target address for mempolicy
  *
--- lin2625-rc5-mmotm.orig/mm/vmalloc.c
+++ lin2625-rc5-mmotm/mm/vmalloc.c
@@ -757,7 +757,8 @@ finished:
  *	@vma:		vma to cover (map full range of vma)
  *	@addr:		vmalloc memory
  *	@pgoff:		number of pages into addr before first page to map
- *	@returns:	0 for success, -Exxx on failure
+ *
+ *	Returns:	0 for success, -Exxx on failure
  *
  *	This function checks that addr is a valid vmalloc'ed area, and
  *	that it is big enough to cover the vma. Will return failure if
@@ -829,7 +830,8 @@ static int f(pte_t *pte, pgtable_t table
 /**
  *	alloc_vm_area - allocate a range of kernel address space
  *	@size:		size of the area
- *	@returns:	NULL on failure, vm_struct on success
+ *
+ *	Returns:	NULL on failure, vm_struct on success
  *
  *	This function reserves a range of kernel address space, and
  *	allocates pagetables to map that range.  No actual mappings

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
