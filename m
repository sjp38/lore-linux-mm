Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id CB31C6B0009
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 05:25:28 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id uo5so419728pbc.39
        for <linux-mm@kvack.org>; Thu, 24 Jan 2013 02:25:28 -0800 (PST)
Date: Thu, 24 Jan 2013 18:24:14 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch 2/3 v2]swap: make each swap partition have one
 address_space
Message-ID: <20130124102414.GA10025@kernel.org>
References: <20130122022951.GB12293@kernel.org>
 <20130123061645.GF2723@blaptop>
 <20130123073655.GA31672@kernel.org>
 <20130123080420.GI2723@blaptop>
 <1358991596.3351.9.camel@kernel>
 <20130124022241.GB22654@blaptop>
 <20130124024311.GA26602@kernel.org>
 <20130124051910.GD22654@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130124051910.GD22654@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Simon Jeons <simon.jeons@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, riel@redhat.com

On Thu, Jan 24, 2013 at 02:19:10PM +0900, Minchan Kim wrote:
> On Thu, Jan 24, 2013 at 10:43:11AM +0800, Shaohua Li wrote:
> > On Thu, Jan 24, 2013 at 11:22:41AM +0900, Minchan Kim wrote:
> > > Hi Simon,
> > > 
> > > On Wed, Jan 23, 2013 at 07:39:56PM -0600, Simon Jeons wrote:
> > > > On Wed, 2013-01-23 at 17:04 +0900, Minchan Kim wrote:
> > > > > On Wed, Jan 23, 2013 at 03:36:55PM +0800, Shaohua Li wrote:
> > > > > > On Wed, Jan 23, 2013 at 03:16:45PM +0900, Minchan Kim wrote:
> > > > > > > Looks good to me. Below just nitpicks.
> > > > > > > I saw Andrew already took this into mmotm so I'm not sure he or you will do
> > > > > > > next spin but anyway, review goes. Just nitpicks and a question.
> > > > > > > 
> > > > > > > On Tue, Jan 22, 2013 at 10:29:51AM +0800, Shaohua Li wrote:
> > > > > > > > 
> > > > > > > > When I use several fast SSD to do swap, swapper_space.tree_lock is heavily
> > > > > > > > contended. This makes each swap partition have one address_space to reduce the
> > > > > > > > lock contention. There is an array of address_space for swap. The swap entry
> > > > > > > > type is the index to the array.
> > > > > > > > 
> > > > > > > > In my test with 3 SSD, this increases the swapout throughput 20%.
> > > > > > > > 
> > > > > > > > V1->V2: simplify code
> > > > > > > > 
> > > > > > > > Signed-off-by: Shaohua Li <shli@fusionio.com>
> > > > > > > 
> > > > > > > Acked-by: Minchan Kim <minchan@kernel.org>
> > > > > > > 
> > > > > > > > ---
> > > > > > > >  fs/proc/meminfo.c    |    4 +--
> > > > > > > >  include/linux/swap.h |    9 ++++----
> > > > > > > >  mm/memcontrol.c      |    4 +--
> > > > > > > >  mm/mincore.c         |    5 ++--
> > > > > > > >  mm/swap.c            |    9 ++++++--
> > > > > > > >  mm/swap_state.c      |   57 ++++++++++++++++++++++++++++++++++-----------------
> > > > > > > >  mm/swapfile.c        |    5 ++--
> > > > > > > >  mm/util.c            |   10 ++++++--
> > > > > > > >  8 files changed, 68 insertions(+), 35 deletions(-)
> > > > > > > > 
> > > > > > > > Index: linux/include/linux/swap.h
> > > > > > > > ===================================================================
> > > > > > > > --- linux.orig/include/linux/swap.h	2013-01-22 09:13:14.000000000 +0800
> > > > > > > > +++ linux/include/linux/swap.h	2013-01-22 09:34:44.923011706 +0800
> > > > > > > > @@ -8,7 +8,7 @@
> > > > > > > >  #include <linux/memcontrol.h>
> > > > > > > >  #include <linux/sched.h>
> > > > > > > >  #include <linux/node.h>
> > > > > > > > -
> > > > > > > > +#include <linux/fs.h>
> > > > > > > >  #include <linux/atomic.h>
> > > > > > > >  #include <asm/page.h>
> > > > > > > >  
> > > > > > > > @@ -330,8 +330,9 @@ int generic_swapfile_activate(struct swa
> > > > > > > >  		sector_t *);
> > > > > > > >  
> > > > > > > >  /* linux/mm/swap_state.c */
> > > > > > > > -extern struct address_space swapper_space;
> > > > > > > > -#define total_swapcache_pages  swapper_space.nrpages
> > > > > > > > +extern struct address_space swapper_spaces[];
> > > > > > > > +#define swap_address_space(entry) (&swapper_spaces[swp_type(entry)])
> > > > > > > 
> > > > > > > How about this naming?
> > > > > > > 
> > > > > > > #define swapper_space(entry) (&swapper_spaces[swp_type(entry)])
> > > > > > > 
> > > > > > > > +extern unsigned long total_swapcache_pages(void);
> > > > > > > >  extern void show_swap_cache_info(void);
> > > > > > > >  extern int add_to_swap(struct page *);
> > > > > > > >  extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
> > > > > > > > @@ -382,7 +383,7 @@ mem_cgroup_uncharge_swapcache(struct pag
> > > > > > > >  
> > > > > > > >  #define nr_swap_pages				0L
> > > > > > > >  #define total_swap_pages			0L
> > > > > > > > -#define total_swapcache_pages			0UL
> > > > > > > > +#define total_swapcache_pages()			0UL
> > > > > > > >  
> > > > > > > >  #define si_swapinfo(val) \
> > > > > > > >  	do { (val)->freeswap = (val)->totalswap = 0; } while (0)
> > > > > > > > Index: linux/mm/memcontrol.c
> > > > > > > > ===================================================================
> > > > > > > > --- linux.orig/mm/memcontrol.c	2013-01-22 09:13:14.000000000 +0800
> > > > > > > Acked-by: Minchan Kim <minchan@kernel.org>
> > > > > > > 
> > > > > > > > +++ linux/mm/memcontrol.c	2013-01-22 09:29:29.374977700 +0800
> > > > > > > > @@ -6279,7 +6279,7 @@ static struct page *mc_handle_swap_pte(s
> > > > > > > >  	 * Because lookup_swap_cache() updates some statistics counter,
> > > > > > > >  	 * we call find_get_page() with swapper_space directly.
> > > > > > > >  	 */
> > > > > > > > -	page = find_get_page(&swapper_space, ent.val);
> > > > > > > > +	page = find_get_page(swap_address_space(ent), ent.val);
> > > > > > > >  	if (do_swap_account)
> > > > > > > >  		entry->val = ent.val;
> > > > > > > >  
> > > > > > > > @@ -6320,7 +6320,7 @@ static struct page *mc_handle_file_pte(s
> > > > > > > >  		swp_entry_t swap = radix_to_swp_entry(page);
> > > > > > > >  		if (do_swap_account)
> > > > > > > >  			*entry = swap;
> > > > > > > > -		page = find_get_page(&swapper_space, swap.val);
> > > > > > > > +		page = find_get_page(swap_address_space(swap), swap.val);
> > > > > > > >  	}
> > > > > > > >  #endif
> > > > > > > >  	return page;
> > > > > > > > Index: linux/mm/mincore.c
> > > > > > > > ===================================================================
> > > > > > > > --- linux.orig/mm/mincore.c	2013-01-22 09:13:14.000000000 +0800
> > > > > > > > +++ linux/mm/mincore.c	2013-01-22 09:29:29.378977649 +0800
> > > > > > > > @@ -75,7 +75,7 @@ static unsigned char mincore_page(struct
> > > > > > > >  	/* shmem/tmpfs may return swap: account for swapcache page too. */
> > > > > > > >  	if (radix_tree_exceptional_entry(page)) {
> > > > > > > >  		swp_entry_t swap = radix_to_swp_entry(page);
> > > > > > > > -		page = find_get_page(&swapper_space, swap.val);
> > > > > > > > +		page = find_get_page(swap_address_space(swap), swap.val);
> > > > > > > >  	}
> > > > > > > >  #endif
> > > > > > > >  	if (page) {
> > > > > > > > @@ -135,7 +135,8 @@ static void mincore_pte_range(struct vm_
> > > > > > > >  			} else {
> > > > > > > >  #ifdef CONFIG_SWAP
> > > > > > > >  				pgoff = entry.val;
> > > > > > > > -				*vec = mincore_page(&swapper_space, pgoff);
> > > > > > > > +				*vec = mincore_page(swap_address_space(entry),
> > > > > > > > +					pgoff);
> > > > > > > >  #else
> > > > > > > >  				WARN_ON(1);
> > > > > > > >  				*vec = 1;
> > > > > > > > Index: linux/mm/swap.c
> > > > > > > > ===================================================================
> > > > > > > > --- linux.orig/mm/swap.c	2013-01-22 09:13:14.000000000 +0800
> > > > > > > > +++ linux/mm/swap.c	2013-01-22 09:29:29.378977649 +0800
> > > > > > > > @@ -855,9 +855,14 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
> > > > > > > >  void __init swap_setup(void)
> > > > > > > >  {
> > > > > > > >  	unsigned long megs = totalram_pages >> (20 - PAGE_SHIFT);
> > > > > > > > -
> > > > > > > >  #ifdef CONFIG_SWAP
> > > > > > > > -	bdi_init(swapper_space.backing_dev_info);
> > > > > > > > +	int i;
> > > > > > > > +
> > > > > > > > +	for (i = 0; i < MAX_SWAPFILES; i++) {
> > > > > > > > +		bdi_init(swapper_spaces[i].backing_dev_info);
> > > > > > > > +		spin_lock_init(&swapper_spaces[i].tree_lock);
> > > > > > > > +		INIT_LIST_HEAD(&swapper_spaces[i].i_mmap_nonlinear);
> > > > > > > > +	}
> > > > > > > >  #endif
> > > > > > > >  
> > > > > > > >  	/* Use a smaller cluster for small-memory machines */
> > > > > > > > Index: linux/mm/swap_state.c
> > > > > > > > ===================================================================
> > > > > > > > --- linux.orig/mm/swap_state.c	2013-01-22 09:13:14.000000000 +0800
> > > > > > > > +++ linux/mm/swap_state.c	2013-01-22 09:29:29.378977649 +0800
> > > > > > > > @@ -36,12 +36,12 @@ static struct backing_dev_info swap_back
> > > > > > > >  	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK | BDI_CAP_SWAP_BACKED,
> > > > > > > >  };
> > > > > > > >  
> > > > > > > > -struct address_space swapper_space = {
> > > > > > > > -	.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
> > > > > > > > -	.tree_lock	= __SPIN_LOCK_UNLOCKED(swapper_space.tree_lock),
> > > > > > > > -	.a_ops		= &swap_aops,
> > > > > > > > -	.i_mmap_nonlinear = LIST_HEAD_INIT(swapper_space.i_mmap_nonlinear),
> > > > > > > > -	.backing_dev_info = &swap_backing_dev_info,
> > > > > > > > +struct address_space swapper_spaces[MAX_SWAPFILES] = {
> > > > > > > > +	[0 ... MAX_SWAPFILES - 1] = {
> > > > > > > > +		.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
> > > > > > > > +		.a_ops		= &swap_aops,
> > > > > > > > +		.backing_dev_info = &swap_backing_dev_info,
> > > > > > > > +	}
> > > > > > > >  };
> > > > > > > >  
> > > > > > > >  #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
> > > > > > > > @@ -53,9 +53,19 @@ static struct {
> > > > > > > >  	unsigned long find_total;
> > > > > > > >  } swap_cache_info;
> > > > > > > >  
> > > > > > > > +unsigned long total_swapcache_pages(void)
> > > > > > > > +{
> > > > > > > > +	int i;
> > > > > > > > +	unsigned long ret = 0;
> > > > > > > > +
> > > > > > > > +	for (i = 0; i < MAX_SWAPFILES; i++)
> > > > > > > > +		ret += swapper_spaces[i].nrpages;
> > > > > > > > +	return ret;
> > > > > > > > +}
> > > > > > > > +
> > > > > > > >  void show_swap_cache_info(void)
> > > > > > > >  {
> > > > > > > > -	printk("%lu pages in swap cache\n", total_swapcache_pages);
> > > > > > > > +	printk("%lu pages in swap cache\n", total_swapcache_pages());
> > > > > > > >  	printk("Swap cache stats: add %lu, delete %lu, find %lu/%lu\n",
> > > > > > > >  		swap_cache_info.add_total, swap_cache_info.del_total,
> > > > > > > >  		swap_cache_info.find_success, swap_cache_info.find_total);
> > > > > > > > @@ -70,23 +80,26 @@ void show_swap_cache_info(void)
> > > > > > > >  static int __add_to_swap_cache(struct page *page, swp_entry_t entry)
> > > > > > > >  {
> > > > > > > >  	int error;
> > > > > > > > +	struct address_space *address_space;
> > > > > > > >  
> > > > > > > >  	VM_BUG_ON(!PageLocked(page));
> > > > > > > >  	VM_BUG_ON(PageSwapCache(page));
> > > > > > > >  	VM_BUG_ON(!PageSwapBacked(page));
> > > > > > > >  
> > > > > > > >  	page_cache_get(page);
> > > > > > > > -	SetPageSwapCache(page);
> > > > > > > >  	set_page_private(page, entry.val);
> > > > > > > > +	SetPageSwapCache(page);
> > > > > > > 
> > > > > > > Why did you move this line? Is there any special reason?
> > > > > > 
> > > > > > Originally I'm afraid page_mapping() gets invalid page_private(), but I then
> > > > > > realized we hold page lock. There are some places we don't hold page lock.
> > > > > > either such page isn't swap page or the caller can tolerate race. I forgot
> > > > > > removing this change in the patch. But I certainly can be wrong. We can add
> > > > > > memory barrier if required.
> > > > > 
> > > > > Yeb. While I reviewed the patch, I was concern about that but I fail to find
> > > > > a problem, too. But maybe it's valuable to add comment about that race
> > > > > (!PageSwapCache(page) but page_mapping could return swapper_space) in page_mapping.
> > > > 
> > > > Hi Minchan,
> > > > 
> > > > If the race Shaohua mentioned should be PageSwapCache(page) but
> > > > page_mapping couldn't return swapper_space since page_mapping() gets
> > > > invalid page_private().
> > > 
> > > Right you are. In such case, it could be a problem.
> > > Let's see following case.
> > > 
> > > isolate_migratepages_range
> > > __isolate_lru_page
> > >                                         __add_to_swap_cache
> > >                                         set_page_private(page, entry.val)
> > >                                         SetPageSwapCache(page)
> > > PageSwapCache
> > > entry.val = page_private(page);
> > > mapping = swap_address_space(entry);
> > > 
> > > In this case, if memory ordering happens, mapping would be dangling pointer,
> > > One of the problem by dangling mapping is the page could be passed into
> > > shrink_page_list and try to pageout with dangling mapping. Of course,
> > > we have many locks until reaching the page_mapping in shrink_page_list so
> > > the problem will not happen but we shouldn't depends on such implicit locks
> > > instead of explicit memory barrier because we could remove all locks in reclaim
> > > path if super hero comes in or new user of page_mapping would do new something
> > > to make a problem. :)
> > > 
> > > I will send a patch if anyone doesn't oppose.
> > 
> > That't fine in the case, because page private 0 still return a valide mapping,
> > and we only check mapping here. But I agree this is too subtle. Adding memory
> 
> It could try to do many things with wrong address_space so it is very error-prone.
> 
> > fence is safer. I had this yesterday if you don't mind:
> 
> Of course. Below just some nitpicks.
> 
> > 
> > 
> > Subject: mm: add memory to prevent SwapCache bit and page private out of order
> 
>            mm: Get rid of memory reordering of SwapCache and PagePrivate
> > 
> > page_mapping() checks SwapCache bit first and then read page private. Adding
> > memory barrier so page private has correct value before SwapCache bit set.
> 
> Please write down the problem if we don't apply the patch.
> 
> > 
> > Signed-off-by: Shaohua Li <shli@fusionio.com>
> Acked-by: Minchan Kim <minchan@kernel.org>
> 
> > ---
> >  mm/swap_state.c |    7 +++++--
> >  mm/util.c       |    6 ++++++
> >  2 files changed, 11 insertions(+), 2 deletions(-)
> > 
> > Index: linux/mm/swap_state.c
> > ===================================================================
> > --- linux.orig/mm/swap_state.c	2013-01-22 10:12:33.514490665 +0800
> > +++ linux/mm/swap_state.c	2013-01-23 15:42:00.737459987 +0800
> > @@ -89,6 +89,7 @@ static int __add_to_swap_cache(struct pa
> >  
> >  	page_cache_get(page);
> >  	set_page_private(page, entry.val);
> > +	smp_wmb();
> >  	SetPageSwapCache(page);
> >  
> >  	address_space = swap_address_space(entry);
> > @@ -109,8 +110,9 @@ static int __add_to_swap_cache(struct pa
> >  		 * So add_to_swap_cache() doesn't returns -EEXIST.
> >  		 */
> >  		VM_BUG_ON(error == -EEXIST);
> > -		set_page_private(page, 0UL);
> >  		ClearPageSwapCache(page);
> > +		smp_mb__after_clear_bit();
> 
> Could you use smp_wmb() instead of smp_mb__after_clear_bit?
> Yes. ClearPageSwapCache does clear_bit so it's okay now but we might change it
> in future so let's not make unnecessary dependency. It's not really hot path.

Ok, that's fine, not big deal anyway. Updated the patch.

 
Subject: mm: add memory barrier to prevent SwapCache bit and page private out of order

page_mapping() checks SwapCache bit first and then read page private. Adding
memory barrier so page private has correct value before SwapCache bit set.

In some cases, page_mapping() isn't called with page locked. Without doing
this, we might get a wrong swap address space with SwapCache bit set. Though I
didn't found a problem with this so far (such code typically only checks if the
page has mapping or the mapping can be dirty or migrated), this is too subtle
and error-prone, so we want to avoid it.

Signed-off-by: Shaohua Li <shli@fusionio.com>
Acked-by: Minchan Kim <minchan@kernel.org>
---
 mm/swap_state.c |    7 +++++--
 mm/util.c       |    6 ++++++
 2 files changed, 11 insertions(+), 2 deletions(-)

Index: linux/mm/swap_state.c
===================================================================
--- linux.orig/mm/swap_state.c	2013-01-22 10:12:33.514490665 +0800
+++ linux/mm/swap_state.c	2013-01-24 18:08:05.149390977 +0800
@@ -89,6 +89,7 @@ static int __add_to_swap_cache(struct pa
 
 	page_cache_get(page);
 	set_page_private(page, entry.val);
+	smp_wmb();
 	SetPageSwapCache(page);
 
 	address_space = swap_address_space(entry);
@@ -109,8 +110,9 @@ static int __add_to_swap_cache(struct pa
 		 * So add_to_swap_cache() doesn't returns -EEXIST.
 		 */
 		VM_BUG_ON(error == -EEXIST);
-		set_page_private(page, 0UL);
 		ClearPageSwapCache(page);
+		smp_wmb();
+		set_page_private(page, 0UL);
 		page_cache_release(page);
 	}
 
@@ -146,8 +148,9 @@ void __delete_from_swap_cache(struct pag
 	entry.val = page_private(page);
 	address_space = swap_address_space(entry);
 	radix_tree_delete(&address_space->page_tree, page_private(page));
-	set_page_private(page, 0);
 	ClearPageSwapCache(page);
+	smp_wmb();
+	set_page_private(page, 0);
 	address_space->nrpages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	INC_CACHE_INFO(del_total);
Index: linux/mm/util.c
===================================================================
--- linux.orig/mm/util.c	2013-01-22 10:11:58.310933234 +0800
+++ linux/mm/util.c	2013-01-23 15:50:22.147155111 +0800
@@ -389,6 +389,12 @@ struct address_space *page_mapping(struc
 	if (unlikely(PageSwapCache(page))) {
 		swp_entry_t entry;
 
+		/*
+		 * set page_private() first then set SwapCache bit. clearing
+		 * the bit first then zero page private. This memory barrier
+		 * matches the rule.
+		 */
+		smp_rmb();
 		entry.val = page_private(page);
 		mapping = swap_address_space(entry);
 	} else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
