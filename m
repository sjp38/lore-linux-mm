Subject: Re: [patch 3/3] update ctime and mtime for mmaped write
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1HVERx-0006gx-00@dorka.pomaz.szeredi.hu>
References: <E1HVEOB-0006fX-00@dorka.pomaz.szeredi.hu>
	 <E1HVERx-0006gx-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Sun, 25 Mar 2007 14:12:36 +0200
Message-Id: <1174824756.5149.29.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2007-03-24 at 23:11 +0100, Miklos Szeredi wrote:
> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> Changes:
> v3:
>  o rename is_page_modified to test_clear_page_modified
> v2:
>  o set AS_CMTIME flag in clear_page_dirty_for_io() too
>  o don't clear AS_CMTIME in file_update_time()
>  o check the dirty bit in the page tables
> v1:
>  o moved check from __fput() to remove_vma(), which is more logical
>  o changed set_page_dirty() to set_page_dirty_mapping in hugetlb.c
>  o cleaned up #ifdef CONFIG_BLOCK mess
> 
> This patch makes writing to shared memory mappings update st_ctime and
> st_mtime as defined by SUSv3:
> 
>    The st_ctime and st_mtime fields of a file that is mapped with
>    MAP_SHARED and PROT_WRITE shall be marked for update at some point
>    in the interval between a write reference to the mapped region and
>    the next call to msync() with MS_ASYNC or MS_SYNC for that portion
>    of the file by any process. If there is no such call and if the
>    underlying file is modified as a result of a write reference, then
>    these fields shall be marked for update at some time after the
>    write reference.
> 
> A new address_space flag is introduced: AS_CMTIME.  This is set each
> time a page is dirtied through a userspace memory mapping.  This
> includes write accesses via get_user_pages().
> 
> Note, the flag is set unconditionally, even if the page is already
> dirty.  This is important, because the page might have been dirtied
> earlier by a non-mmap write.
> 
> This flag is checked in msync() and munmap()/mremap(), and if set, the
> file times are updated and the flag is cleared.
> 
> Msync also needs to check the dirty bit in the page tables, because
> the data might change again after an msync(MS_ASYNC), while the page
> is already dirty and read-write.  This also makes the time updating
> work for memory backed filesystems such as tmpfs.
> 
> This implementation walks the pages in the synced range, and uses rmap
> to find all the ptes for each page.  Non-linear vmas are ignored,
> since the ptes can only be found by scanning the whole vma, which is
> very inefficient.
> 
> As an optimization, if dirty pages are accounted, then only walk the
> dirty pages, since the clean pages necessarily have clean ptes.  This
> doesn't work for memory backed filesystems, where no dirty accounting
> is done.
> 
> An alternative implementation could check for all intersecting vmas in
> the mapping and walk the page tables for each.  This would probably be
> more efficient for memory backed filesystems and if the number of
> dirty pages is near the total number of pages in the range.
> 
> Fixes Novell Bugzilla #206431.
> 
> Inspired by Peter Staubach's patch and the resulting comments.
> 
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> ---

A few comments..

> Index: linux-2.6.21-rc4-mm1/mm/rmap.c
> ===================================================================
> --- linux-2.6.21-rc4-mm1.orig/mm/rmap.c	2007-03-24 19:03:11.000000000 +0100
> +++ linux-2.6.21-rc4-mm1/mm/rmap.c	2007-03-24 19:34:30.000000000 +0100
> @@ -507,6 +507,43 @@ int page_mkclean(struct page *page)
>  EXPORT_SYMBOL_GPL(page_mkclean);
>  
>  /**
> + * test_clear_page_modified - check and clear the dirty bit for all mappings of a page
> + * @page:	the page to check
> + */
> +bool test_clear_page_modified(struct page *page)
> +{
> +	struct address_space *mapping = page->mapping;

page_mapping(page)? Otherwise that BUG_ON(!mapping) a few lines down
isn't of much use.

> +	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> +	struct vm_area_struct *vma;
> +	struct prio_tree_iter iter;
> +	bool modified = false;
> +
> +	BUG_ON(!mapping);
> +	BUG_ON(!page_mapped(page));
> +
> +	spin_lock(&mapping->i_mmap_lock);
> +	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
> +		if (vma->vm_flags & VM_SHARED) {
> +			struct mm_struct *mm = vma->vm_mm;
> +			unsigned long addr = vma_address(page, vma);
> +			pte_t *pte;
> +			spinlock_t *ptl;
> +
> +			if (addr != -EFAULT &&
> +			    (pte = page_check_address(page, mm, addr, &ptl))) {
> +				if (ptep_clear_flush_dirty(vma, addr, pte))
> +					modified = true;
> +				pte_unmap_unlock(pte, ptl);
> +			}

Its against coding style to do assignments in conditionals.

> +		}
> +	}
> +	spin_unlock(&mapping->i_mmap_lock);
> +	if (page_test_and_clear_dirty(page))
> +		modified = true;
> +	return modified;
> +}

Why not parametrize page_mkclean() to conditionally wrprotect clean
pages? Something like:

--- mm/rmap.c~	2007-03-11 17:52:20.000000000 +0100
+++ mm/rmap.c	2007-03-25 14:01:55.000000000 +0200
@@ -432,7 +432,8 @@
 	return referenced;
 }
 
-static int page_mkclean_one(struct page *page, struct vm_area_struct *vma)
+static int
+page_mkclean_one(struct page *page, struct vm_area_struct *vma, int prot)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
@@ -448,12 +449,13 @@
 	if (!pte)
 		goto out;
 
-	if (pte_dirty(*pte) || pte_write(*pte)) {
+	if (pte_dirty(*pte) || (prot && pte_write(*pte))) {
 		pte_t entry;
 
 		flush_cache_page(vma, address, pte_pfn(*pte));
 		entry = ptep_clear_flush(vma, address, pte);
-		entry = pte_wrprotect(entry);
+		if (prot)
+			entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
 		lazy_mmu_prot_update(entry);
@@ -465,7 +467,8 @@
 	return ret;
 }
 
-static int page_mkclean_file(struct address_space *mapping, struct page *page)
+static int
+page_mkclean_file(struct address_space *mapping, struct page *page, int prot)
 {
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
@@ -477,13 +480,13 @@
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		if (vma->vm_flags & VM_SHARED)
-			ret += page_mkclean_one(page, vma);
+			ret += page_mkclean_one(page, vma, prot);
 	}
 	spin_unlock(&mapping->i_mmap_lock);
 	return ret;
 }
 
-int page_mkclean(struct page *page)
+int page_mkclean(struct page *page, int prot)
 {
 	int ret = 0;
 
@@ -492,7 +495,7 @@
 	if (page_mapped(page)) {
 		struct address_space *mapping = page_mapping(page);
 		if (mapping)
-			ret = page_mkclean_file(mapping, page);
+			ret = page_mkclean_file(mapping, page, prot);
 	}
 	if (page_test_and_clear_dirty(page))
 		ret = 1;

> Index: linux-2.6.21-rc4-mm1/mm/msync.c
> ===================================================================
> --- linux-2.6.21-rc4-mm1.orig/mm/msync.c	2007-02-04 19:44:54.000000000 +0100
> +++ linux-2.6.21-rc4-mm1/mm/msync.c	2007-03-24 19:34:30.000000000 +0100
> @@ -12,6 +12,85 @@
>  #include <linux/mman.h>
>  #include <linux/file.h>
>  #include <linux/syscalls.h>
> +#include <linux/pagemap.h>
> +#include <linux/rmap.h>
> +#include <linux/pagevec.h>
> +
> +/*
> + * Update ctime/mtime on msync().
> + *
> + * POSIX requires, that the times are updated between a modification
> + * of the file through a memory mapping and the next msync for a
> + * region containing the modification.  The wording implies that this
> + * must be done even if the modification was through a different
> + * address space.  Ugh.
> + *
> + * Non-linear vmas are too hard to handle and they are non-standard
> + * anyway, so they are ignored for now.
> + *
> + * The "file modified" info is collected from two places:
> + *
> + *  - AS_CMTIME flag of the mapping
> + *  - the dirty bit of the ptes
> + *
> + * For memory backed filesystems all the pages in the range need to be
> + * examined.  In other cases, since dirty pages are accurately
> + * tracked, it is enough to look at the pages with the dirty tag.
> + */
> +static void msync_update_file_time(struct vm_area_struct *vma,
> +				   unsigned long start, unsigned long end)
> +{
> +	struct address_space *mapping;
> +	struct pagevec pvec;
> +	pgoff_t index;
> +	pgoff_t end_index;
> +	bool modified;
> +
> +	if (!vma->vm_file || !(vma->vm_flags & VM_SHARED) ||
> +	    (vma->vm_flags & VM_NONLINEAR))
> +		return;
> +
> +	mapping = vma->vm_file->f_mapping;
> +	modified = test_and_clear_bit(AS_CMTIME, &mapping->flags);
> +
> +	pagevec_init(&pvec, 0);
> +	index = linear_page_index(vma, start);
> +	end_index = linear_page_index(vma, end);
> +	while (index < end_index) {
> +		int i;
> +		int nr_pages = min(end_index - index, (pgoff_t) PAGEVEC_SIZE);
> +
> +		if (mapping_cap_account_dirty(mapping))
> +			nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
> +					PAGECACHE_TAG_DIRTY, nr_pages);
> +		else
> +			nr_pages = pagevec_lookup(&pvec, mapping, index,
> +						  nr_pages);
> +		if (!nr_pages)
> +			break;
> +
> +		for (i = 0; i < nr_pages; i++) {
> +			struct page *page = pvec.pages[i];
> +
> +			/* Skip pages which are just being read */
> +			if (!PageUptodate(page))
> +				continue;
> +
> +			lock_page(page);
> +			index = page->index + 1;
> +			if (page->mapping == mapping &&
> +			    test_clear_page_modified(page)) {

page_mkclean(page, 0)

> +				set_page_dirty(page);

set_page_dirty_mapping() ?

> +				modified = true;
> +			}
> +			unlock_page(page);
> +		}
> +		pagevec_release(&pvec);
> +	}
> +
> +	if (modified)
> +		file_update_time(vma->vm_file);
> +}
>  
>  /*
>   * MS_SYNC syncs the entire file - including mappings.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
