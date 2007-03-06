Subject: Re: [rfc][patch 2/2] mm: mlocked pages off LRU
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070306143045.GA28629@wotan.suse.de>
References: <20070305161746.GD8128@wotan.suse.de>
	 <Pine.LNX.4.64.0703050948040.6620@schroedinger.engr.sgi.com>
	 <20070306010529.GB23845@wotan.suse.de>
	 <Pine.LNX.4.64.0703051723240.16842@schroedinger.engr.sgi.com>
	 <20070306014403.GD23845@wotan.suse.de>
	 <Pine.LNX.4.64.0703051753070.16964@schroedinger.engr.sgi.com>
	 <20070306021307.GE23845@wotan.suse.de>
	 <Pine.LNX.4.64.0703051845050.17203@schroedinger.engr.sgi.com>
	 <20070306025016.GA1912@wotan.suse.de>
	 <20070306143045.GA28629@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 06 Mar 2007 17:23:55 -0500
Message-Id: <1173219835.20580.15.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Christoph Lameter <clameter@engr.sgi.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-03-06 at 15:30 +0100, Nick Piggin wrote: 
> New core patch. This one is actually tested and works, and you can see
> the mlocked pages being accounted.
> 
> Same basic idea. Too many fixes and changes to list. Haven't taken up
> Christoph's idea to do a union in struct page, but it could be a followup.
> 
> Most importantly (aside from crashes and obvious bugs), it should correctly
> synchronise munlock vs vmscan lazy mlock now. Before this, it was possible
> to have pages leak. This took me a bit of thinking to get right, but was
> rather simple in the end.
> 
> Memory migration should work now, too, but not tested.
> 
> What do people think? Yes? No?

Nick:  I've grabbed your 2 patches in this series and rebased them to
21-rc2-mm2 so I can test them and compare with Christoph's [which I've
also rebased to -mm2].  I had to fix up the ia32_setup_arg_pages() for
ia64 to track the change you made to install_new_arg_page.  Patch
included below.  Some comments in-line below, as well.

Now builds, boots, and successfully builds a kernel with Christoph's
series.  Some basic testing with memtoy [see link below] shows pages
being locked according to the /proc/meminfo stats, but the counts don't
decrease when I unmap the segment nor when I exit the task.  I'll
investigate why and let you know how further testing goes.  After that,
I plan to merge both series with my page migration series and your page
cache replication patch to test the effects there.  Should be
"interesting".

If you're interested, I have a little tool/toy for testing mm stuff at:
http://free.linux.hp.com/~lts/Tools/memtoy-latest.tar.gz
I recently added a lock()/unlock() command for testing locking of memory
regions.  It could use more [a lot more] documentation, but there it
does have a README and internal help.

Lee


> 
> --
> 
> Index: linux-2.6/mm/mlock.c
> ===================================================================
> --- linux-2.6.orig/mm/mlock.c
> +++ linux-2.6/mm/mlock.c
> @@ -8,17 +8,204 @@
>  #include <linux/capability.h>
>  #include <linux/mman.h>
>  #include <linux/mm.h>
> +#include <linux/swap.h>
> +#include <linux/pagemap.h>
>  #include <linux/mempolicy.h>
>  #include <linux/syscalls.h>
>  
> +#include "internal.h"
> +
> +#define page_mlock_count(page)		(*(unsigned long *)&(page)->lru.next)
> +#define set_page_mlock_count(page, v)	(page_mlock_count(page) = (v))
> +#define inc_page_mlock_count(page)	(page_mlock_count(page)++)
> +#define dec_page_mlock_count(page)	(page_mlock_count(page)--)
> +
> +/*
> + * A page's mlock_count is kept in page->lru.next as an unsigned long.
> + * Access to this count is serialised with the page lock (or, in the
> + * case of mlock_page, virtue that there are no other references to
> + * the page).
> + *
> + * mlock counts are incremented at mlock, mmap, mremap, and new anon page
> + * faults, and lazily via vmscan. Decremented at munlock, munmap, and exit.
> + * mlock is not inherited across fork or exec, so we're safe there.
> + *
> + * If PageMLock is set, then the page is removed from the LRU list, and
> + * has its refcount incremented. This increment prevents the page from being
> + * freed until the mlock_count is decremented to zero and PageMLock is cleared.
> + *
> + * When lazy incrementing via vmscan, it is important to ensure that the
> + * vma's VM_LOCKED status is not concurrently being modified, otherwise we
> + * may have elevated mlock_count of a page that is being munlocked. So lazy
> + * mlocked must take the mmap_sem for read, and verify that the vma really
> + * is locked (see mm/rmap.c).
> + */
> +
> +/*
> + * Marks a page, belonging to the given mlocked vma, as mlocked.
> + *
> + * The page must be either locked or new, and must not be on the LRU.
> + */
> +static void __set_page_mlock(struct page *page)
> +{
> +	BUG_ON(PageLRU(page));
> +	BUG_ON(PageMLock(page));
> +	/* BUG_ON(!list_empty(&page->lru)); -- if we always did list_del_init */
> +
> +	SetPageMLock(page);
> +	get_page(page);
> +	inc_zone_page_state(page, NR_MLOCK);
> +	set_page_mlock_count(page, 1);
> +}
> +
> +static void __clear_page_mlock(struct page *page)
> +{
> +	BUG_ON(!PageMLock(page));
> +	BUG_ON(PageLRU(page));
> +	BUG_ON(page_mlock_count(page));
> +
> +	dec_zone_page_state(page, NR_MLOCK);
> +	ClearPageMLock(page);
> +	lru_cache_add_active(page);
> +	put_page(page);
> +}
> +
> +/*
> + * Zero the page's mlock_count. This can be useful in a situation where
> + * we want to unconditionally remove a page from the pagecache.
> + *
> + * It is not illegal to call this function for any page, mlocked or not.
Maybe "It is legal ..."  ???

> + * If called for a page that is still mapped by mlocked vmas, all we do
> + * is revert to lazy LRU behaviour -- semantics are not broken.
> + */
> +void clear_page_mlock(struct page *page)
> +{
> +	BUG_ON(!PageLocked(page));
> +
> +	if (likely(!PageMLock(page)))
> +		return;
> +	BUG_ON(!page_mlock_count(page));
> +	set_page_mlock_count(page, 0);
> +	__clear_page_mlock(page);
> +}
> +
<snip>

> Index: linux-2.6/include/linux/page-flags.h
> ===================================================================
> --- linux-2.6.orig/include/linux/page-flags.h
> +++ linux-2.6/include/linux/page-flags.h
> @@ -91,6 +91,7 @@
>  #define PG_nosave_free		18	/* Used for system suspend/resume */
>  #define PG_buddy		19	/* Page is free, on buddy lists */
>  
> +#define PG_mlock		20	/* Page has mlocked vmas */

Conflicts with PG_readahead in 21-rc2-mm2.  I temporarily used bit
30--valid only for 64-bit systems.  [Same in Christoph's series.]

>  
>  #if (BITS_PER_LONG > 32)
>  /*
> @@ -247,6 +248,10 @@ static inline void SetPageUptodate(struc
>  #define PageSwapCache(page)	0
>  #endif
>  
> +#define PageMLock(page)		test_bit(PG_mlock, &(page)->flags)
> +#define SetPageMLock(page)	set_bit(PG_mlock, &(page)->flags)
> +#define ClearPageMLock(page)	clear_bit(PG_mlock, &(page)->flags)
> +
>  #define PageUncached(page)	test_bit(PG_uncached, &(page)->flags)
>  #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
>  #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -203,7 +203,8 @@ static void bad_page(struct page *page)
>  			1 << PG_slab    |
>  			1 << PG_swapcache |
>  			1 << PG_writeback |
> -			1 << PG_buddy );
> +			1 << PG_buddy |
> +			1 << PG_mlock );
>  	set_page_count(page, 0);
>  	reset_page_mapcount(page);
>  	page->mapping = NULL;
> @@ -438,7 +439,8 @@ static inline int free_pages_check(struc
>  			1 << PG_swapcache |
>  			1 << PG_writeback |
>  			1 << PG_reserved |
> -			1 << PG_buddy ))))
> +			1 << PG_buddy |
> +			1 << PG_mlock ))))
>  		bad_page(page);
>  	if (PageDirty(page))
>  		__ClearPageDirty(page);
> @@ -588,7 +590,8 @@ static int prep_new_page(struct page *pa
>  			1 << PG_swapcache |
>  			1 << PG_writeback |
>  			1 << PG_reserved |
> -			1 << PG_buddy ))))
> +			1 << PG_buddy |
> +			1 << PG_mlock ))))
>  		bad_page(page);
>  
>  	/*
> Index: linux-2.6/fs/exec.c
> ===================================================================
> --- linux-2.6.orig/fs/exec.c
> +++ linux-2.6/fs/exec.c
> @@ -297,44 +297,6 @@ int copy_strings_kernel(int argc,char **
>  EXPORT_SYMBOL(copy_strings_kernel);
>  
>  #ifdef CONFIG_MMU
> -/*
> - * This routine is used to map in a page into an address space: needed by
> - * execve() for the initial stack and environment pages.
> - *
> - * vma->vm_mm->mmap_sem is held for writing.
> - */
> -void install_arg_page(struct vm_area_struct *vma,
> -			struct page *page, unsigned long address)
> -{
> -	struct mm_struct *mm = vma->vm_mm;
> -	pte_t * pte;
> -	spinlock_t *ptl;
> -
> -	if (unlikely(anon_vma_prepare(vma)))
> -		goto out;
> -
> -	flush_dcache_page(page);
> -	pte = get_locked_pte(mm, address, &ptl);
> -	if (!pte)
> -		goto out;
> -	if (!pte_none(*pte)) {
> -		pte_unmap_unlock(pte, ptl);
> -		goto out;
> -	}
> -	inc_mm_counter(mm, anon_rss);
> -	lru_cache_add_active(page);
> -	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
> -					page, vma->vm_page_prot))));
> -	page_add_new_anon_rmap(page, vma, address);
> -	pte_unmap_unlock(pte, ptl);
> -
> -	/* no need for flush_tlb */
> -	return;
> -out:
> -	__free_page(page);
> -	force_sig(SIGKILL, current);
> -}
> -
>  #define EXTRA_STACK_VM_PAGES	20	/* random */
>  
>  int setup_arg_pages(struct linux_binprm *bprm,
> @@ -438,17 +400,25 @@ int setup_arg_pages(struct linux_binprm 
>  		mm->stack_vm = mm->total_vm = vma_pages(mpnt);
>  	}
>  
> +	ret = 0;
>  	for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
>  		struct page *page = bprm->page[i];
>  		if (page) {
>  			bprm->page[i] = NULL;
> -			install_arg_page(mpnt, page, stack_base);
> +			if (!ret)
> +				ret = install_new_anon_page(mpnt, page,
> +								stack_base);
> +			if (ret)
> +				put_page(page);

Need similar mod in arch/ia64/ia32/binfmt_elf32.c:ia32_setup_arg_pages()
Patch included below.

>  		}
>  		stack_base += PAGE_SIZE;
>  	}
>  	up_write(&mm->mmap_sem);
> -	
> -	return 0;
> +
> +	if (ret)
> +		do_munmap(mm, mpnt->vm_start, mpnt->vm_start - mpnt->vm_end);
> +
> +	return ret;
>  }
>  
>  EXPORT_SYMBOL(setup_arg_pages);

> Index: linux-2.6/mm/migrate.c
> ===================================================================
> --- linux-2.6.orig/mm/migrate.c
> +++ linux-2.6/mm/migrate.c
> @@ -272,6 +272,8 @@ static int migrate_page_move_mapping(str
>  		return 0;
>  	}
>  
> +	clear_page_mlock(page);
> +
>  	write_lock_irq(&mapping->tree_lock);
>  
>  	pslot = radix_tree_lookup_slot(&mapping->page_tree,
> @@ -775,6 +777,17 @@ static int do_move_pages(struct mm_struc
>  				!migrate_all)
>  			goto put_and_set;
>  
> +		/*
> +		 * Just do the simple thing and put back mlocked pages onto
> +		 * the LRU list so they can be taken off again (inefficient
> +		 * but not a big deal).
> +		 */
> +		if (PageMLock(page)) {
> +			lock_page(page);
> +			clear_page_mlock(page);
Note that this will put the page into the lru pagevec cache
[__clear_page_mlock() above] where isolate_lru_page(), called from
migrate_page_add(), is unlikely to find it.  do_move_pages() has already
called migrate_prep() to drain the lru caches so that it is more likely
to find the pages, as does check_range() when called to collect pages
for migration.  Yes, this is already racy--the target task or other
threads therein can fault additional pages into the lru cache after call
to migrate_prep().  But this almost guarantees we'll miss ~ the last
PAGEVEC_SIZE pages.

> +			unlock_page(page);
> +		}
> +
>  		err = isolate_lru_page(page);
>  		if (err) {
>  put_and_set:
> Index: linux-2.6/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.orig/mm/mempolicy.c
> +++ linux-2.6/mm/mempolicy.c
> @@ -89,6 +89,7 @@
>  #include <linux/migrate.h>
>  #include <linux/rmap.h>
>  #include <linux/security.h>
> +#include <linux/pagemap.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/uaccess.h>
> @@ -224,7 +225,10 @@ static int check_pte_range(struct vm_are
>  	pte_t *orig_pte;
>  	pte_t *pte;
>  	spinlock_t *ptl;
> +	struct page *mlocked;
>  
> +resume:
> +	mlocked = NULL;
>  	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>  	do {
>  		struct page *page;
> @@ -254,12 +258,24 @@ static int check_pte_range(struct vm_are
>  
>  		if (flags & MPOL_MF_STATS)
>  			gather_stats(page, private, pte_dirty(*pte));
> -		else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> +		else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
> +			if (PageMLock(page) && !mlocked) {
> +				mlocked = page;
> +				break;
> +			}
>  			migrate_page_add(page, private, flags);
> -		else
> +		} else
>  			break;
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  	pte_unmap_unlock(orig_pte, ptl);
> +
> +	if (mlocked) {
> +		lock_page(mlocked);
> +		clear_page_mlock(mlocked);

Same comment as for do_move_pages() above.

> +		unlock_page(mlocked);
> +		goto resume;
> +	}
> +
>  	return addr != end;
>  }
>  
> @@ -372,6 +388,7 @@ check_range(struct mm_struct *mm, unsign
>  				endvma = end;
>  			if (vma->vm_start > start)
>  				start = vma->vm_start;
> +
>  			err = check_pgd_range(vma, start, endvma, nodes,
>  						flags, private);
>  			if (err) {

Here's the patch mentioned above:

Need to replace call to install_arg_page() in ia64's
ia32 version of setup_arg_pages() to build 21-rc2-mm2
with Nick's "mlocked pages off LRU" patch on ia64. 

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 arch/ia64/ia32/binfmt_elf32.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Index: Linux/arch/ia64/ia32/binfmt_elf32.c
===================================================================
--- Linux.orig/arch/ia64/ia32/binfmt_elf32.c	2007-03-06 12:16:33.000000000 -0500
+++ Linux/arch/ia64/ia32/binfmt_elf32.c	2007-03-06 15:19:02.000000000 -0500
@@ -240,7 +240,11 @@ ia32_setup_arg_pages (struct linux_binpr
 		struct page *page = bprm->page[i];
 		if (page) {
 			bprm->page[i] = NULL;
-			install_arg_page(mpnt, page, stack_base);
+			if (!ret)
+				ret = install_new_anon_page(mpnt, page,
+								stack_base);
+			if (ret)
+				put_page(page);
 		}
 		stack_base += PAGE_SIZE;
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
