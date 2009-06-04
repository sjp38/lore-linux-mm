Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 038666B004D
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 23:25:01 -0400 (EDT)
Date: Thu, 4 Jun 2009 11:24:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler
	in the VM v5
Message-ID: <20090604032441.GC5740@localhost>
References: <20090603846.816684333@firstfloor.org> <20090603184648.2E2131D028F@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090603184648.2E2131D028F@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "npiggin@suse.de" <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 02:46:47AM +0800, Andi Kleen wrote:

[snip]

This patch is full of this style error (the old version didn't have
this problem though):

        ERROR: code indent should use tabs where possible

> +/*
> + * Clean (or cleaned) page cache page.
> + */
> +static int me_pagecache_clean(struct page *p, unsigned long pfn)
> +{
> +       struct address_space *mapping;
> +
> +       if (!isolate_lru_page(p))
> +               page_cache_release(p);
> +
> +       /*
> +        * Now truncate the page in the page cache. This is really
> +        * more like a "temporary hole punch"
> +        * Don't do this for block devices when someone else
> +        * has a reference, because it could be file system metadata
> +        * and that's not safe to truncate.
> +        */
> +       mapping = page_mapping(p);
> +       if (mapping && S_ISBLK(mapping->host->i_mode) && page_count(p) > 1) {

Shall use (page_count > 2) to count for the page cache reference.

Or can we base the test on busy buffers instead of page count?  Nick?

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -347,7 +347,7 @@ static int me_free(struct page *p)
  */
 static int me_pagecache_clean(struct page *p)
 {
-	struct address_space *mapping;
+	struct address_space *mapping = page_mapping(p);
 
 	if (!isolate_lru_page(p))
 		page_cache_release(p);
@@ -355,18 +355,17 @@ static int me_pagecache_clean(struct pag
 	/*
 	 * Now truncate the page in the page cache. This is really
 	 * more like a "temporary hole punch"
-	 * Don't do this for block devices when someone else
-	 * has a reference, because it could be file system metadata
-	 * and that's not safe to truncate.
+	 * Don't do this for block device pages with busy buffers,
+	 * because file system metadata may not be safe to truncate.
 	 */
-	mapping = page_mapping(p);
-	if (mapping && S_ISBLK(mapping->host->i_mode) && page_count(p) > 1)
-		return FAILED;
 	if (mapping) {
+		if (S_ISBLK(mapping->host->i_mode) &&
+		    !try_to_release_page(p, GFP_NOIO))
+			return FAILED;
 		truncate_inode_page(mapping, p);
 		if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO)) {
-			pr_debug(KERN_ERR "MCE %#lx: failed to release buffers\n",
-				 page_to_pfn(p));
+			dprintk(KERN_ERR "MCE %#lx: failed to release buffers\n",
+				page_to_pfn(p));
 			return FAILED;
 		}
 	}

> +               printk(KERN_ERR
> +                       "MCE %#lx: page looks like a unsupported file system metadata page\n",
> +                       pfn);
> +               return FAILED;
> +       }
> +       if (mapping) {
> +               truncate_inode_page(mapping, p);
> +               if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO)) {
> +                       pr_debug(KERN_ERR "MCE %#lx: failed to release buffers\n",
> +                               pfn);
> +                       return FAILED;
> +               }
> +       }
> +       return RECOVERED;
> +}
> +
> +/*
> + * Dirty cache page page
> + * Issues: when the error hit a hole page the error is not properly
> + * propagated.
> + */
> +static int me_pagecache_dirty(struct page *p, unsigned long pfn)
> +{
> +       struct address_space *mapping = page_mapping(p);
> +
> +       SetPageError(p);
> +       /* TBD: print more information about the file. */
> +       if (mapping) {
> +               /*
> +                * IO error will be reported by write(), fsync(), etc.
> +                * who check the mapping.

btw, here are some side notes on EIO.

close() *may* also report it. NFS will sync file on close.

> +                * This way the application knows that something went
> +                * wrong with its dirty file data.
> +                *
> +                * There's one open issue:
> +                *
> +                * The EIO will be only reported on the next IO
> +                * operation and then cleared through the IO map.

The report is not reliable in two ways:

- IO error may occur in a previous session
  close() will or will not clear IO error depending on filesystem,
  so IO error in this session may be seen by a following session.

- IO error may be cleared by a concurrent operation in another process
  mapping->flags is shared between file handles, so fsync() on another
  process will clear and report the IO error bits that was produced in
  this process.

> +                * Normally Linux has two mechanisms to pass IO error
> +                * first through the AS_EIO flag in the address space
> +                * and then through the PageError flag in the page.
> +                * Since we drop pages on memory failure handling the
> +                * only mechanism open to use is through AS_AIO.

We have to isolate the poisoned page from page cache, otherwise we'll
have to insert PageHWPoison() tests to dozens of places.

It's fine to keep poisoned pages in swap cache, because they are
referenced in a very limited scope.

> +                *
> +                * This has the disadvantage that it gets cleared on
> +                * the first operation that returns an error, while
> +                * the PageError bit is more sticky and only cleared
> +                * when the page is reread or dropped.  If an
> +                * application assumes it will always get error on
> +                * fsync, but does other operations on the fd before
> +                * and the page is dropped inbetween then the error
> +                * will not be properly reported.
> +                *
> +                * This can already happen even without hwpoisoned
> +                * pages: first on metadata IO errors (which only
> +                * report through AS_EIO) or when the page is dropped
> +                * at the wrong time.
> +                *
> +                * So right now we assume that the application DTRT on

DTRT = do the return value test?

> +                * the first EIO, but we're not worse than other parts
> +                * of the kernel.
> +                */
> +               mapping_set_error(mapping, EIO);
> +       }
> +
> +       return me_pagecache_clean(p, pfn);
> +}
> +
> +/*
> + * Clean and dirty swap cache.
> + *
> + * Dirty swap cache page is tricky to handle. The page could live both in page
> + * cache and swap cache(ie. page is freshly swapped in). So it could be
> + * referenced concurrently by 2 types of PTEs:
> + * normal PTEs and swap PTEs. We try to handle them consistently by calling u

s/ u$//

> + * try_to_unmap(TTU_IGNORE_HWPOISON) to convert the normal PTEs to swap PTEs,
> + * and then
> + *      - clear dirty bit to prevent IO
> + *      - remove from LRU
> + *      - but keep in the swap cache, so that when we return to it on
> + *        a later page fault, we know the application is accessing
> + *        corrupted data and shall be killed (we installed simple
> + *        interception code in do_swap_page to catch it).
> + *
> + * Clean swap cache pages can be directly isolated. A later page fault will
> + * bring in the known good data from disk.
> + */
> +static int me_swapcache_dirty(struct page *p, unsigned long pfn)
> +{
> +       ClearPageDirty(p);
> +       /* Trigger EIO in shmem: */
> +       ClearPageUptodate(p);

style nitpick:

       ClearPageDirty(p);     /* don't start IO on me */
       ClearPageUptodate(p);  /* to trigger EIO in shmem */

> +
> +       if (!isolate_lru_page(p))
> +               page_cache_release(p);
> +
> +       return DELAYED;
> +}
> +
> +static int me_swapcache_clean(struct page *p, unsigned long pfn)
> +{
> +       if (!isolate_lru_page(p))
> +               page_cache_release(p);
> +
> +       delete_from_swap_cache(p);
> +
> +       return RECOVERED;
> +}
> +
> +/*
> + * Huge pages. Needs work.
> + * Issues:
> + * No rmap support so we cannot find the original mapper. In theory could walk
> + * all MMs and look for the mappings, but that would be non atomic and racy.
> + * Need rmap for hugepages for this. Alternatively we could employ a heuristic,
> + * like just walking the current process and hoping it has it mapped (that
> + * should be usually true for the common "shared database cache" case)
> + * Should handle free huge pages and dequeue them too, but this needs to
> + * handle huge page accounting correctly.
> + */
> +static int me_huge_page(struct page *p, unsigned long pfn)
> +{
> +       return FAILED;
> +}
> +
> +/*
> + * Various page states we can handle.
> + *
> + * A page state is defined by its current page->flags bits.
> + * The table matches them in order and calls the right handler.
> + *
> + * This is quite tricky because we can access page at any time
> + * in its live cycle, so all accesses have to be extremly careful.
> + *
> + * This is not complete. More states could be added.
> + * For any missing state don't attempt recovery.
> + */
> +
> +#define dirty          (1UL << PG_dirty)
> +#define sc             (1UL << PG_swapcache)
> +#define unevict                (1UL << PG_unevictable)
> +#define mlock          (1UL << PG_mlocked)
> +#define writeback      (1UL << PG_writeback)
> +#define lru            (1UL << PG_lru)
> +#define swapbacked     (1UL << PG_swapbacked)
> +#define head           (1UL << PG_head)
> +#define tail           (1UL << PG_tail)
> +#define compound       (1UL << PG_compound)
> +#define slab           (1UL << PG_slab)
> +#define buddy          (1UL << PG_buddy)
> +#define reserved       (1UL << PG_reserved)
> +
> +static struct page_state {
> +       unsigned long mask;
> +       unsigned long res;
> +       char *msg;
> +       int (*action)(struct page *p, unsigned long pfn);
> +} error_states[] = {
> +       { reserved,     reserved,       "reserved kernel",      me_ignore },
> +       { buddy,        buddy,          "free kernel",  me_free },
> +
> +       /*
> +        * Could in theory check if slab page is free or if we can drop
> +        * currently unused objects without touching them. But just
> +        * treat it as standard kernel for now.
> +        */
> +       { slab,         slab,           "kernel slab",  me_kernel },
> +
> +#ifdef CONFIG_PAGEFLAGS_EXTENDED
> +       { head,         head,           "huge",         me_huge_page },
> +       { tail,         tail,           "huge",         me_huge_page },
> +#else
> +       { compound,     compound,       "huge",         me_huge_page },
> +#endif
> +
> +       { sc|dirty,     sc|dirty,       "swapcache",    me_swapcache_dirty },
> +       { sc|dirty,     sc,             "swapcache",    me_swapcache_clean },
> +
> +#ifdef CONFIG_UNEVICTABLE_LRU
> +       { unevict|dirty, unevict|dirty, "unevictable LRU", me_pagecache_dirty},
> +       { unevict,      unevict,        "unevictable LRU", me_pagecache_clean},
> +#endif
> +
> +#ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
> +       { mlock|dirty,  mlock|dirty,    "mlocked LRU",  me_pagecache_dirty },
> +       { mlock,        mlock,          "mlocked LRU",  me_pagecache_clean },
> +#endif
> +
> +       { lru|dirty,    lru|dirty,      "LRU",          me_pagecache_dirty },
> +       { lru|dirty,    lru,            "clean LRU",    me_pagecache_clean },
> +       { swapbacked,   swapbacked,     "anonymous",    me_pagecache_clean },
> +
> +       /*
> +        * Catchall entry: must be at end.
> +        */
> +       { 0,            0,              "unknown page state",   me_unknown },
> +};
> +
> +static void action_result(unsigned long pfn, char *msg, int ret)

rename 'ret' to 'action'?

> +{
> +       printk(KERN_ERR "MCE %#lx: %s page recovery: %s%s\n",
> +               pfn, PageDirty(pfn_to_page(pfn)) ? "dirty " : "",
> +               msg, action_name[ret]);

ditto.

> +}
> +
> +static void page_action(struct page_state *ps, struct page *p,
> +                       unsigned long pfn)
> +{
> +       int ret;

ditto.

> +
> +       ret = ps->action(p, pfn);
> +       action_result(pfn, ps->msg, ret);

ditto.

> +       if (page_count(p) != 1)
> +               printk(KERN_ERR
> +                      "MCE %#lx: %s page still referenced by %d users\n",
> +                      pfn, ps->msg, page_count(p) - 1);
> +
> +       /* Could do more checks here if page looks ok */
> +       atomic_long_add(1, &mce_bad_pages);
> +
> +       /*
> +        * Could adjust zone counters here to correct for the missing page.
> +        */
> +}
> +
> +#define N_UNMAP_TRIES 5
> +
> +/*
> + * Do all that is necessary to remove user space mappings. Unmap
> + * the pages and send SIGBUS to the processes if the data was dirty.
> + */
> +static void hwpoison_user_mappings(struct page *p, unsigned long pfn,
> +                                 int trapno)
> +{
> +       enum ttu_flags ttu = TTU_UNMAP | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
> +       int kill = sysctl_memory_failure_early_kill;
> +       struct address_space *mapping;
> +       LIST_HEAD(tokill);
> +       int ret;
> +       int i;
> +
> +       if (PageReserved(p) || PageCompound(p) || PageSlab(p))
> +               return;
> +
> +       if (!PageLRU(p))
> +               lru_add_drain();
> +
> +       /*
> +        * This check implies we don't kill processes if their pages
> +        * are in the swap cache early. Those are always late kills.
> +        */
> +       if (!page_mapped(p))
> +               return;
> +
> +       if (PageSwapCache(p)) {
> +               printk(KERN_ERR
> +                      "MCE %#lx: keeping poisoned page in swap cache\n", pfn);
> +               ttu |= TTU_IGNORE_HWPOISON;
> +       }
> +
> +       /*
> +        * Propagate the dirty bit from PTEs to struct pagefirst, because we
> +        * need this to decide if we should kill or just drop the page.
> +        */
> +       mapping = page_mapping(p);
> +       if (!PageDirty(p) && !PageAnon(p) && !PageSwapBacked(p) &&

!PageAnon(p) could be removed: the below non-zero mapping check will
do the work implicitly.

> +           mapping && mapping_cap_account_dirty(mapping)) {
> +               if (page_mkclean(p))
> +                       SetPageDirty(p);
> +               else {
> +                       kill = 0;
> +                       printk(KERN_INFO
> +       "MCE %#lx: corrupted page was clean: dropped without side effects\n",
> +                               pfn);
> +                       ttu |= TTU_IGNORE_HWPOISON;

Why not put the two assignment lines together? :)

> +               }
> +       }
> +
> +       /*
> +        * First collect all the processes that have the page
> +        * mapped.  This has to be done before try_to_unmap,
> +        * because ttu takes the rmap data structures down.
> +        *
> +        * This also has the side effect to propagate the dirty
> +        * bit from PTEs into the struct page. This is needed
> +        * to actually decide if something needs to be killed
> +        * or errored, or if it's ok to just drop the page.
> +        *
> +        * Error handling: We ignore errors here because
> +        * there's nothing that can be done.
> +        */
> +       if (kill)
> +               collect_procs(p, &tokill);
> +
> +       /*
> +        * try_to_unmap can fail temporarily due to races.
> +        * Try a few times (RED-PEN better strategy?)
> +        */
> +       for (i = 0; i < N_UNMAP_TRIES; i++) {
> +               ret = try_to_unmap(p, ttu);
> +               if (ret == SWAP_SUCCESS)
> +                       break;
> +               pr_debug("MCE %#lx: try_to_unmap retry needed %d\n", pfn,  ret);

Can we make it a printk? This is a serious accident.

> +       }
> +
> +       /*
> +        * Now that the dirty bit has been propagated to the
> +        * struct page and all unmaps done we can decide if
> +        * killing is needed or not.  Only kill when the page
> +        * was dirty, otherwise the tokill list is merely
> +        * freed.  When there was a problem unmapping earlier
> +        * use a more force-full uncatchable kill to prevent
> +        * any accesses to the poisoned memory.
> +        */
> +       kill_procs_ao(&tokill, !!PageDirty(p), trapno,
> +                     ret != SWAP_SUCCESS, pfn);
> +}
> +
> +/**
> + * memory_failure - Handle memory failure of a page.
> + * @pfn: Page Number of the corrupted page
> + * @trapno: Trap number reported in the signal to user space.
> + *
> + * This function is called by the low level machine check code
> + * of an architecture when it detects hardware memory corruption
> + * of a page. It tries its best to recover, which includes
> + * dropping pages, killing processes etc.
> + *
> + * The function is primarily of use for corruptions that
> + * happen outside the current execution context (e.g. when
> + * detected by a background scrubber)
> + *
> + * Must run in process context (e.g. a work queue) with interrupts
> + * enabled and no spinlocks hold.
> + */
> +void memory_failure(unsigned long pfn, int trapno)
> +{
> +       struct page_state *ps;
> +       struct page *p;
> +
> +       if (!pfn_valid(pfn)) {
> +               action_result(pfn, "memory outside kernel control", IGNORED);
> +               return;
> +       }
> +
> +

A bonus blank line.

> +       p = pfn_to_page(pfn);
> +       if (TestSetPageHWPoison(p)) {
> +               action_result(pfn, "already hardware poisoned", IGNORED);
> +               return;
> +       }
> +
> +       /*
> +        * We need/can do nothing about count=0 pages.
> +        * 1) it's a free page, and therefore in safe hand:
> +        *    prep_new_page() will be the gate keeper.
> +        * 2) it's part of a non-compound high order page.
> +        *    Implies some kernel user: cannot stop them from
> +        *    R/W the page; let's pray that the page has been
> +        *    used and will be freed some time later.
> +        * In fact it's dangerous to directly bump up page count from 0,
> +        * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
> +        */
> +       if (!get_page_unless_zero(compound_head(p))) {
> +               action_result(pfn, "free or high order kernel", IGNORED);
> +               return;
> +       }
> +
> +       /*
> +        * Lock the page and wait for writeback to finish.
> +        * It's very difficult to mess with pages currently under IO
> +        * and in many cases impossible, so we just avoid it here.
> +        */
> +       lock_page_nosync(p);
> +       wait_on_page_writeback(p);
> +
> +       /*
> +        * Now take care of user space mappings.
> +        */
> +       hwpoison_user_mappings(p, pfn, trapno);
> +
> +       /*
> +        * Torn down by someone else?
> +        */
> +       if (PageLRU(p) && !PageSwapCache(p) && p->mapping == NULL) {
> +               action_result(pfn, "already unmapped LRU", IGNORED);

"NULL mapping LRU" or "already truncated page"?
At least page_mapped != page_mapping.

> +               goto out;
> +       }
> +
> +       for (ps = error_states;; ps++) {
> +               if ((p->flags & ps->mask) == ps->res) {
> +                       page_action(ps, p, pfn);
> +                       break;
> +               }
> +       }
> +out:
> +       unlock_page(p);
> +}
> Index: linux/include/linux/mm.h
> ===================================================================
> --- linux.orig/include/linux/mm.h       2009-06-03 20:13:43.000000000 +0200
> +++ linux/include/linux/mm.h    2009-06-03 20:13:43.000000000 +0200
> @@ -1326,5 +1326,10 @@
>  extern int account_locked_memory(struct mm_struct *mm, struct rlimit *rlim,
>                                  size_t size);
>  extern void refund_locked_memory(struct mm_struct *mm, size_t size);
> +
> +extern void memory_failure(unsigned long pfn, int trapno);
> +extern int sysctl_memory_failure_early_kill;
> +extern atomic_long_t mce_bad_pages;
> +
>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_MM_H */
> Index: linux/kernel/sysctl.c
> ===================================================================
> --- linux.orig/kernel/sysctl.c  2009-06-03 19:37:38.000000000 +0200
> +++ linux/kernel/sysctl.c       2009-06-03 20:13:43.000000000 +0200
> @@ -1311,6 +1311,20 @@
>                 .mode           = 0644,
>                 .proc_handler   = &scan_unevictable_handler,
>         },
> +#ifdef CONFIG_MEMORY_FAILURE
> +       {
> +               .ctl_name       = CTL_UNNUMBERED,
> +               .procname       = "memory_failure_early_kill",
> +               .data           = &sysctl_memory_failure_early_kill,
> +               .maxlen         = sizeof(vm_highmem_is_dirtyable),

s/vm_highmem_is_dirtyable/sysctl_memory_failure_early_kill/

> +               .mode           = 0644,
> +               .proc_handler   = &proc_dointvec_minmax,
> +               .strategy       = &sysctl_intvec,
> +               .extra1         = &zero,
> +               .extra2         = &one,
> +       },
> +#endif
> +
>  /*
>   * NOTE: do not add new entries to this table unless you have read
>   * Documentation/sysctl/ctl_unnumbered.txt
> Index: linux/fs/proc/meminfo.c
> ===================================================================
> --- linux.orig/fs/proc/meminfo.c        2009-06-03 19:37:38.000000000 +0200
> +++ linux/fs/proc/meminfo.c     2009-06-03 20:13:43.000000000 +0200
> @@ -95,7 +95,11 @@
>                 "Committed_AS:   %8lu kB\n"
>                 "VmallocTotal:   %8lu kB\n"
>                 "VmallocUsed:    %8lu kB\n"
> -               "VmallocChunk:   %8lu kB\n",
> +               "VmallocChunk:   %8lu kB\n"
> +#ifdef CONFIG_MEMORY_FAILURE
> +               "BadPages:       %8lu kB\n"

"HWPoison:" or something like that? 
People is more likely to misinterpret "BadPages".

> +#endif
> +               ,
>                 K(i.totalram),
>                 K(i.freeram),
>                 K(i.bufferram),
> @@ -140,6 +144,9 @@
>                 (unsigned long)VMALLOC_TOTAL >> 10,
>                 vmi.used >> 10,
>                 vmi.largest_chunk >> 10
> +#ifdef CONFIG_MEMORY_FAILURE
> +               ,atomic_long_read(&mce_bad_pages) << (PAGE_SHIFT - 10)

ERROR: space required after that ','

> +#endif
>                 );
> 
>         hugetlb_report_meminfo(m);
> Index: linux/mm/Kconfig
> ===================================================================
> --- linux.orig/mm/Kconfig       2009-06-03 19:37:38.000000000 +0200
> +++ linux/mm/Kconfig    2009-06-03 20:39:48.000000000 +0200
> @@ -220,6 +220,9 @@
>           Enable the KSM kernel module to allow page sharing of equal pages
>           among different tasks.
> 
> +config MEMORY_FAILURE
> +       bool
> +

Do we have code to automatically enable/disable CONFIG_MEMORY_FAILURE
based on hardware capability?

>  config NOMMU_INITIAL_TRIM_EXCESS
>         int "Turn on mmap() excess space trimming before booting"
>         depends on !MMU
> Index: linux/Documentation/sysctl/vm.txt
> ===================================================================
> --- linux.orig/Documentation/sysctl/vm.txt      2009-06-03 19:37:38.000000000 +0200
> +++ linux/Documentation/sysctl/vm.txt   2009-06-03 20:13:43.000000000 +0200
> @@ -32,6 +32,7 @@
>  - legacy_va_layout
>  - lowmem_reserve_ratio
>  - max_map_count
> +- memory_failure_early_kill
>  - min_free_kbytes
>  - min_slab_ratio
>  - min_unmapped_ratio
> @@ -53,7 +54,6 @@
>  - vfs_cache_pressure
>  - zone_reclaim_mode
> 
> -
>  ==============================================================
> 
>  block_dump
> @@ -275,6 +275,25 @@
> 
>  The default value is 65536.
> 
> +=============================================================
> +
> +memory_failure_early_kill:
> +
> +Control how to kill processes when uncorrected memory error (typically
> +a 2bit error in a memory module) is detected in the background by hardware.
> +
> +1: Kill all processes that have the corrupted page mapped as soon as the
> +corruption is detected.
> +
> +0: Only unmap the page from all processes and only kill a process
> +who tries to access it.

Note that
- no process will be killed if the page data is clean and can be
  safely reloaded from disk
- pages in swap cache is always late killed.

Thanks,
Fengguang

> +The kill is done using a catchable SIGBUS, so processes can handle this
> +if they want to.
> +
> +This is only active on architectures/platforms with advanced machine
> +check handling and depends on the hardware capabilities.
> +
>  ==============================================================
> 
>  min_free_kbytes:
> Index: linux/mm/filemap.c
> ===================================================================
> --- linux.orig/mm/filemap.c     2009-06-03 19:37:38.000000000 +0200
> +++ linux/mm/filemap.c  2009-06-03 20:13:43.000000000 +0200
> @@ -105,6 +105,10 @@
>   *
>   *  ->task->proc_lock
>   *    ->dcache_lock            (proc_pid_lookup)
> + *
> + *  (code doesn't rely on that order, so you could switch it around)
> + *  ->tasklist_lock             (memory_failure, collect_procs_ao)
> + *    ->i_mmap_lock
>   */
> 
>  /*
> Index: linux/mm/rmap.c
> ===================================================================
> --- linux.orig/mm/rmap.c        2009-06-03 19:37:38.000000000 +0200
> +++ linux/mm/rmap.c     2009-06-03 20:13:43.000000000 +0200
> @@ -36,6 +36,10 @@
>   *                 mapping->tree_lock (widely used, in set_page_dirty,
>   *                           in arch-dependent flush_dcache_mmap_lock,
>   *                           within inode_lock in __sync_single_inode)
> + *
> + * (code doesn't rely on that order so it could be switched around)
> + * ->tasklist_lock
> + *   anon_vma->lock      (memory_failure, collect_procs_anon)
>   */
> 
>  #include <linux/mm.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
