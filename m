Subject: Re: [patch] mm: NUMA replicated pagecache
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070213060924.GB20644@wotan.suse.de>
References: <20070213060924.GB20644@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 14 Feb 2007 15:32:04 -0500
Message-Id: <1171485124.5099.43.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-02-13 at 07:09 +0100, Nick Piggin wrote:
> Hi,
> 
> Just tinkering around with this and got something working, so I'll see
> if anyone else wants to try it.
> 
> Not proposing for inclusion, but I'd be interested in comments or results.
> 
> Thanks,
> Nick

I've included a small patch below that allow me to build and boot with
these patches on an HP NUMA platform.  I'm still seeing an "unable to
handle paging request" fault from within find_get_page_readonly() at
some point after boot--investigating.  [NULL pcd from radix_tree_lookup
in find_get_page_readonly()].

More comments below.

Lee
> 
> --
> 
> Page-based NUMA pagecache replication.
> 
> This is a scheme for page replication replicates read-only pagecache pages
> opportunistically, at pagecache lookup time (at points where we know the
> page is being looked up for read only).
> 
> The page will be replicated if it resides on a different node to what the
> requesting CPU is on. Also, the original page must meet some conditions:
> it must be clean, uptodate, not under writeback, and not have an elevated
> refcount or filesystem private data. However it is allowed to be mapped
> into pagetables.
> 
> Replication is done at the pagecache level, where a replicated pagecache
> (inode,offset) key will have its radix-tree entry specially tagged, and its
> radix-tree page will be replaced with a descriptor. Most importantly, this
> descriptor has another radix-tree which is keyed by node.
> 
> Writes into pagetables are caught by having a filemap_mkwrite function,
> which collapses the replication before proceeding. After collapsing the
> replication, all process page tables are unmapped, so that any processes
> mapping discarded pages will refault in the correct one.
> 
> /proc/vmstat has nr_repl_pages, which is the number of _additional_ pages
> replicated, beyond the first.
> 
> Status:
> At the moment, this is just a fun hack I made up while my internet was
> down yesterday from storms on the weekend. It is *very* unoptimised, especially
> because I did not want to modify the radix-tree at all, and I didn't want to
> add another page flag. I also wanted to put in a lot of debug checks to start
> with. So not meant for conclusion yet, but it might be interesting to some
> people to test.
> 
> Also, some of my replication interfaces and locking are a little bit awkward,
> which should be cleaned up and optimised.
> 
> At the moment the code is a bit ugly, but it won't take much to make it a
> completely standalone ~400 line module with just a handful of hooks into
> the core mm. So if anyone really wants it, it could be quite realistic to
> get into an includable form.
> 
> At some point I did take a look at Dave Hansen's page replication patch for
> ideas, but didn't get far because he was doing a per-inode scheme and I was
> doing per-page. No judgments on which approach is better, but I feel this
> per-page patch is quite neat.
> 
> Issues:
> - Not commented. I want to change the interfaces around anyway.
> - Breaks filesystems that use filemap_nopage, but don't call filemap_mkwrite
>   (eg. XFS). Fix is trivial for most cases.
> - Haven't tested NUMA yet (only tested via a hack to do per-CPU replication)
In progress...

> - Would like to be able to control replication via userspace, and maybe
>   even internally to the kernel.
How about per cpuset?  Consider a cpuset, on a NUMA system, with cpus
and memories from a specific set of nodes.  One might choose to have
page cache pages referenced by tasks in this cpuset to be pulled into
the cpuset's memories for local access.  The remainder of the system may
choose not to replicate page cache pages--e.g., to conserve memory.
However, "unreplicating" on write would still need to work system wide.

But, note:  may [probably] want option to disable replication for shmem
pages?  I'm thinking here of large data base shmem regions that, at any
time, might have a lot of pages accessed "read only".  Probably wouldn't
want a lot of replication/unreplication happening behind the scene. 

> - Ideally, reclaim might reclaim replicated pages preferentially, however
>   I aim to be _minimally_ intrusive.
> - Would like to replicate PagePrivate, but filesystem may dirty page via
>   buffers. Any solutions? (currently should mount with 'nobh').
Linux migrates pages with PagePrivate using a per mapping migratepage
address space op to handle the buffers.  File systems can provide their
own or use a generic version.  How about a "replicatepage" aop?

> - Would be nice to transfer master on reclaim. This should be quite easy,
>   must transfer relevant flags, and only if !PagePrivate (which reclaim
>   takes care of).
> - Replication on elevated mapcount could be racy because we don't lock
>   page over fault handler (but I want to, for other reasons).
> - PG_replicated flag for optimisations (eg. reclaim, unreplicate range)
> - optimise gang operations better (eg. PG_replicated)
> - Must optimise radix-tree manipulations far far better, and handle failures
>   of radix-tree operations (most memory failures will be solved by replacing
>   element rather than delete+insert).
> - Should go nicely with lockless pagecache, but haven't merged them yet.
> 
>  include/linux/fs.h         |    1 
>  include/linux/mm.h         |    1 
>  include/linux/mm_types.h   |    8 
>  include/linux/mmzone.h     |    1 
>  include/linux/radix-tree.h |    2 
>  init/main.c                |    1 
>  mm/filemap.c               |  373 ++++++++++++++++++++++++++++++++++++++-------
>  mm/internal.h              |    4 
>  mm/vmscan.c                |   12 +
>  mm/vmstat.c                |    1 
>  10 files changed, 346 insertions(+), 58 deletions(-)
> 
> Index: linux-2.6/include/linux/mm_types.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm_types.h
> +++ linux-2.6/include/linux/mm_types.h
> @@ -5,6 +5,8 @@
>  #include <linux/threads.h>
>  #include <linux/list.h>
>  #include <linux/spinlock.h>
> +#include <linux/radix-tree.h>
> +#include <linux/nodemask.h>
>  
>  struct address_space;
>  
> @@ -64,4 +66,10 @@ struct page {
>  #endif /* WANT_PAGE_VIRTUAL */
>  };
>  
> +struct pcache_desc {
> +	struct page *master;
> +	nodemask_t nodes_present;
> +	struct radix_tree_root page_tree;
> +};
> +
>  #endif /* _LINUX_MM_TYPES_H */
> Index: linux-2.6/include/linux/fs.h
> ===================================================================
> --- linux-2.6.orig/include/linux/fs.h
> +++ linux-2.6/include/linux/fs.h
> @@ -490,6 +490,7 @@ struct block_device {
>   */
>  #define PAGECACHE_TAG_DIRTY	0
>  #define PAGECACHE_TAG_WRITEBACK	1
> +#define PAGECACHE_TAG_REPLICATED 2
>  
>  int mapping_tagged(struct address_space *mapping, int tag);
>  
> Index: linux-2.6/include/linux/radix-tree.h
> ===================================================================
> --- linux-2.6.orig/include/linux/radix-tree.h
> +++ linux-2.6/include/linux/radix-tree.h
> @@ -52,7 +52,7 @@ static inline int radix_tree_is_direct_p
>  
>  /*** radix-tree API starts here ***/
>  
> -#define RADIX_TREE_MAX_TAGS 2
> +#define RADIX_TREE_MAX_TAGS 3
>  
>  /* root tags are stored in gfp_mask, shifted by __GFP_BITS_SHIFT */
>  struct radix_tree_root {
> Index: linux-2.6/mm/filemap.c
> ===================================================================
> --- linux-2.6.orig/mm/filemap.c
> +++ linux-2.6/mm/filemap.c
> @@ -584,6 +584,238 @@ void fastcall __lock_page_nosync(struct 
>  							TASK_UNINTERRUPTIBLE);
>  }
>  
> +static struct kmem_cache *pcache_desc_cachep;
> +
> +void __init filemap_init(void)
> +{
> +	pcache_desc_cachep = kmem_cache_create("pcache_desc",
> +					sizeof(struct pcache_desc),
> +					0, SLAB_PANIC, NULL, NULL);
> +}
> +
> +static struct pcache_desc *alloc_pcache_desc(void)
> +{
> +	struct pcache_desc *ret;
> +
> +	ret = kmem_cache_alloc(pcache_desc_cachep, GFP_ATOMIC);
> +	if (ret) {
> +		memset(ret, 0, sizeof(struct pcache_desc));
> +		INIT_RADIX_TREE(&ret->page_tree, GFP_ATOMIC);
> +	}
> +	return ret;
> +}
> +
> +static void free_pcache_desc(struct pcache_desc *pcd)
> +{
> +	kmem_cache_free(pcache_desc_cachep, pcd);
> +}
> +
> +static void release_pcache_desc(struct pcache_desc *pcd)
> +{
> +	int i;
> +
> +	page_cache_get(pcd->master);
> +	for_each_node_mask(i, pcd->nodes_present) {
> +		struct page *page;
> +
> +		page = radix_tree_delete(&pcd->page_tree, i);
> +		BUG_ON(!page);
> +		if (page != pcd->master) {
> +			BUG_ON(PageDirty(page));
> +			BUG_ON(!PageUptodate(page));
> +			BUG_ON(page_mapped(page));
> +			__dec_zone_page_state(page, NR_REPL_PAGES);
> +		}
> +		page_cache_release(page);
> +	}
> +	free_pcache_desc(pcd);
> +}
> +
> +static int __replicate_pcache(struct page *page, struct address_space *mapping, unsigned long offset)
> +{
> +	struct pcache_desc *pcd;
> +	int nid, page_node;
> +	int writelock = 0;
> +	int ret = 0;
> +
> +	if (unlikely(PageSwapCache(page)))
> +		goto out;
> +
> +	page_node = page_to_nid(page);
> +again:
> +	nid = numa_node_id();
> +	if (nid == page_node)
> +		goto out;
> +
> +	if (page_count(page) != 1 + page_mapcount(page))
> +		goto out;
> +	smp_rmb();
> +	if (!PageUptodate(page) || PageDirty(page) || PageWriteback(page) || PagePrivate(page))
> +		goto out;
> +
> +	if (!writelock) {
> +		read_unlock_irq(&mapping->tree_lock);
> +		lock_page(page);
> +		if (!page->mapping) {
> +			unlock_page(page);
> +			return 0;
> +		}
> +		write_lock_irq(&mapping->tree_lock);
> +		writelock = 1;
> +		if (radix_tree_tag_get(&mapping->page_tree, offset,
> +					PAGECACHE_TAG_REPLICATED))
> +			goto out;
> +		goto again;
> +	}
> +
> +	pcd = alloc_pcache_desc();
> +	if (!pcd)
> +		goto out;
> +
> +	pcd->master = page;
> +	node_set(page_node, pcd->nodes_present);
> +	if (radix_tree_insert(&pcd->page_tree, nid, page)) {
need to insert using 'page_node' rather than 'nid'.  [attached patch]

> +		free_pcache_desc(pcd);
> +		goto out;
> +	}
> +
> +	BUG_ON(radix_tree_delete(&mapping->page_tree, offset) != page);
> +	BUG_ON(radix_tree_insert(&mapping->page_tree, offset, pcd));
> +	radix_tree_tag_set(&mapping->page_tree, offset,
> +					PAGECACHE_TAG_REPLICATED);
> +	ret = 1;
> +out:
> +	if (writelock) {
> +		write_unlock_irq(&mapping->tree_lock);
> +		unlock_page(page);
> +		read_lock_irq(&mapping->tree_lock);
> +	}
> +
> +	return ret;
> +}
> +
> +void __unreplicate_pcache(struct address_space *mapping, unsigned long offset)
> +{
> +	struct pcache_desc *pcd;
> +	struct page *page;
> +
> +	if (unlikely(!radix_tree_tag_get(&mapping->page_tree, offset,
> +					PAGECACHE_TAG_REPLICATED))) {
> +		write_unlock_irq(&mapping->tree_lock);
> +		return;
> +	}
> +
> +	pcd = radix_tree_lookup(&mapping->page_tree, offset);
> +	BUG_ON(!pcd);
> +
> +	page = pcd->master;
> +	BUG_ON(PageDirty(page));
> +	BUG_ON(!PageUptodate(page));
> +
> +	radix_tree_tag_clear(&mapping->page_tree, offset,
> +					PAGECACHE_TAG_REPLICATED);
> +	BUG_ON(!radix_tree_delete(&mapping->page_tree, offset));
> +	BUG_ON(radix_tree_insert(&mapping->page_tree, offset, page));
> +
> +	write_unlock_irq(&mapping->tree_lock);
> +	unmap_mapping_range(mapping, (loff_t)offset<<PAGE_CACHE_SHIFT,
> +					PAGE_CACHE_SIZE, 0);
> +	release_pcache_desc(pcd);
> +}
> +
> +static void __insert_replicated_page(struct page *page, struct address_space *mapping, unsigned long offset, int nid)
> +{
> +	struct pcache_desc *pcd;
> +
> +	if (unlikely(!radix_tree_tag_get(&mapping->page_tree, offset,
> +					PAGECACHE_TAG_REPLICATED))) {
> +		page_cache_release(page);
> +		return;
> +	}
> +
> +	pcd = radix_tree_lookup(&mapping->page_tree, offset);
> +	BUG_ON(!pcd);
> +
> +	if (node_isset(nid, pcd->nodes_present)) {
> +		page_cache_release(page);
> +		return;
> +	}
> +
> +	BUG_ON(radix_tree_insert(&pcd->page_tree, nid, page));
> +	node_set(nid, pcd->nodes_present);
> +	__inc_zone_page_state(page, NR_REPL_PAGES);
> +
> +	lru_cache_add(page);
> +}
> +
> +void __remove_replicated_page(struct pcache_desc *pcd, struct page *page,
> +			struct address_space *mapping, unsigned long offset)
> +{
> +	int nid = page_to_nid(page);
> +	/* XXX: page->mapping = NULL; ? */
> +	BUG_ON(node_isset(nid, pcd->nodes_present));
> +	BUG_ON(radix_tree_delete(&pcd->page_tree, nid) != page);
> +	node_clear(nid, pcd->nodes_present);
> +	__dec_zone_page_state(page, NR_REPL_PAGES);
> +}
> +
> +/**
> + * find_get_page - find and get a page reference
> + * @mapping: the address_space to search
> + * @offset: the page index
> + *
> + * Is there a pagecache struct page at the given (mapping, offset) tuple?
> + * If yes, increment its refcount and return it; if no, return NULL.
> + */
> +struct page * find_get_page_readonly(struct address_space *mapping, unsigned long offset)
> +{
> +	struct page *page;
> +
> +retry:
> +	read_lock_irq(&mapping->tree_lock);
> +	if (radix_tree_tag_get(&mapping->page_tree, offset,
> +					PAGECACHE_TAG_REPLICATED)) {
> +		int nid;
> +		struct pcache_desc *pcd;
> +replicated:
> +		nid = numa_node_id();
> +		pcd = radix_tree_lookup(&mapping->page_tree, offset);
??? possible NULL pcd?  I believe I'm seeing one here...

> +		if (!node_isset(nid, pcd->nodes_present)) {
Do this check [and possible replicate] only if replication enabled
[system wide?, per cpuset?  based on explicit replication policy?, ...]?

> +			struct page *repl_page;
> +
> +			page = pcd->master;
> +			page_cache_get(page);
> +			read_unlock_irq(&mapping->tree_lock);
> +			repl_page = alloc_pages_node(nid,
> +					mapping_gfp_mask(mapping), 0);
??? don't try to hard to allocate page, as it's only a performance
optimization.  E.g., add in GFP_THISNODE and remove and __GFP_WAIT?

> +			if (!repl_page)
> +				return page;
> +			copy_highpage(repl_page, page);
> +			flush_dcache_page(repl_page);
> +			page->mapping = mapping;
> +			page->index = offset;
> +			SetPageUptodate(repl_page); /* XXX: nonatomic */
> +			page_cache_release(page);
> +			write_lock_irq(&mapping->tree_lock);
> +			__insert_replicated_page(repl_page, mapping, offset, nid);
??? can this fail due to race?  Don't care because we retry the lookup?
page freed [released] in the function...

> +			write_unlock_irq(&mapping->tree_lock);
> +			goto retry;
> +		}
> +		page = radix_tree_lookup(&pcd->page_tree, nid);
> +		BUG_ON(!page);
> +		page_cache_get(page);
> +	} else {
> +		page = radix_tree_lookup(&mapping->page_tree, offset);
> +		if (page) {
> +			if (__replicate_pcache(page, mapping, offset))
> +				goto replicated;
> +			page_cache_get(page);
> +		}
> +	}
> +	read_unlock_irq(&mapping->tree_lock);
> +	return page;
> +}
> +
>  /**
>   * find_get_page - find and get a page reference
>   * @mapping: the address_space to search
> @@ -596,11 +828,20 @@ struct page * find_get_page(struct addre
>  {
>  	struct page *page;
>  
> +retry:
>  	read_lock_irq(&mapping->tree_lock);
> +	if (radix_tree_tag_get(&mapping->page_tree, offset,
> +					PAGECACHE_TAG_REPLICATED)) {
> +		read_unlock(&mapping->tree_lock);
> +		write_lock(&mapping->tree_lock);
> +		__unreplicate_pcache(mapping, offset);
> +		goto retry;
> +	}
>  	page = radix_tree_lookup(&mapping->page_tree, offset);
>  	if (page)
>  		page_cache_get(page);
>  	read_unlock_irq(&mapping->tree_lock);
> +
>  	return page;
>  }
>  EXPORT_SYMBOL(find_get_page);
> @@ -620,26 +861,16 @@ struct page *find_lock_page(struct addre
>  {
>  	struct page *page;
>  
> -	read_lock_irq(&mapping->tree_lock);
>  repeat:
> -	page = radix_tree_lookup(&mapping->page_tree, offset);
> +	page = find_get_page(mapping, offset);
>  	if (page) {
> -		page_cache_get(page);
> -		if (TestSetPageLocked(page)) {
> -			read_unlock_irq(&mapping->tree_lock);
> -			__lock_page(page);
> -			read_lock_irq(&mapping->tree_lock);
> -
> -			/* Has the page been truncated while we slept? */
> -			if (unlikely(page->mapping != mapping ||
> -				     page->index != offset)) {
> -				unlock_page(page);
> -				page_cache_release(page);
> -				goto repeat;
> -			}
> +		lock_page(page);
> +		if (unlikely(page->mapping != mapping)) {
> +			unlock_page(page);
> +			page_cache_release(page);
> +			goto repeat;
>  		}
>  	}
> -	read_unlock_irq(&mapping->tree_lock);
>  	return page;
>  }
>  EXPORT_SYMBOL(find_lock_page);
??? should find_trylock_page() handle potential replicated page?
    until it is removed, anyway?  

> @@ -688,6 +919,31 @@ repeat:
>  }
>  EXPORT_SYMBOL(find_or_create_page);
>  
> +void __unreplicate_pcache_range(struct address_space *mapping, pgoff_t index,
> +			unsigned int nr_pages, struct page **pages)
> +{
> +	unsigned int i;
> +	unsigned int ret;
> +
> +again:
> +	ret = radix_tree_gang_lookup_tag(&mapping->page_tree,
> +				(void **)pages, index, nr_pages,
> +				PAGECACHE_TAG_REPLICATED);
> +	if (ret > 0) {
> +		for (i = 0; i < ret; i++) {
> +			struct pcache_desc *pcd = (struct pcache_desc *)pages[i];
> +			pages[i] = (struct page *)pcd->master->index;
> +		}
> +		read_unlock(&mapping->tree_lock);
> +		for (i = 0; i < ret; i++) {
> +			write_lock(&mapping->tree_lock);
> +			__unreplicate_pcache(mapping, (unsigned long)pages[i]);
> +		}
> +		read_lock_irq(&mapping->tree_lock);
> +		goto again;
> +	}
> +}
> +
>  /**
>   * find_get_pages - gang pagecache lookup
>   * @mapping:	The address_space to search
> @@ -711,6 +967,7 @@ unsigned find_get_pages(struct address_s
>  	unsigned int ret;
>  
>  	read_lock_irq(&mapping->tree_lock);
> +	__unreplicate_pcache_range(mapping, start, nr_pages, pages);
>  	ret = radix_tree_gang_lookup(&mapping->page_tree,
>  				(void **)pages, start, nr_pages);
>  	for (i = 0; i < ret; i++)
> @@ -738,6 +995,7 @@ unsigned find_get_pages_contig(struct ad
>  	unsigned int ret;
>  
>  	read_lock_irq(&mapping->tree_lock);
> +	__unreplicate_pcache_range(mapping, index, nr_pages, pages);
>  	ret = radix_tree_gang_lookup(&mapping->page_tree,
>  				(void **)pages, index, nr_pages);
>  	for (i = 0; i < ret; i++) {
> @@ -769,6 +1027,10 @@ unsigned find_get_pages_tag(struct addre
>  	unsigned int ret;
>  
>  	read_lock_irq(&mapping->tree_lock);
> +	/*
> +	 * Don't need to check for replicated pages, because dirty
> +	 * and writeback pages should never be replicated.
> +	 */
>  	ret = radix_tree_gang_lookup_tag(&mapping->page_tree,
>  				(void **)pages, *index, nr_pages, tag);
>  	for (i = 0; i < ret; i++)
> @@ -907,7 +1169,7 @@ void do_generic_mapping_read(struct addr
>  					index, last_index - index);
>  
>  find_page:
> -		page = find_get_page(mapping, index);
> +		page = find_get_page_readonly(mapping, index);
>  		if (unlikely(page == NULL)) {
>  			handle_ra_miss(mapping, &ra, index);
>  			goto no_cached_page;
> @@ -1007,24 +1269,22 @@ readpage:
>  		 * part of the page is not copied back to userspace (unless
>  		 * another truncate extends the file - this is desired though).
>  		 */
> +		page_cache_release(page);
> +
>  		isize = i_size_read(inode);
>  		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
> -		if (unlikely(!isize || index > end_index)) {
> -			page_cache_release(page);
> +		if (unlikely(!isize || index > end_index))
>  			goto out;
> -		}
>  
>  		/* nr is the maximum number of bytes to copy from this page */
>  		nr = PAGE_CACHE_SIZE;
>  		if (index == end_index) {
>  			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
> -			if (nr <= offset) {
> -				page_cache_release(page);
> +			if (nr <= offset)
>  				goto out;
> -			}
>  		}
>  		nr = nr - offset;
> -		goto page_ok;
> +		goto find_page;
>  
>  readpage_error:
>  		/* UHHUH! A synchronous read error occurred. Report it */
> @@ -1351,7 +1611,7 @@ retry_all:
>  	 * Do we have something in the page cache already?
>  	 */
>  retry_find:
> -	page = find_get_page(mapping, pgoff);
> +	page = find_get_page_readonly(mapping, pgoff);
>  	if (!page) {
>  		unsigned long ra_pages;
>  
> @@ -1400,7 +1660,6 @@ retry_find:
>  	if (!PageUptodate(page))
>  		goto page_not_uptodate;
>  
> -success:
>  	/*
>  	 * Found the page and have a reference on it.
>  	 */
> @@ -1446,30 +1705,6 @@ page_not_uptodate:
>  		majmin = VM_FAULT_MAJOR;
>  		count_vm_event(PGMAJFAULT);
>  	}
> -	lock_page(page);
> -
> -	/* Did it get unhashed while we waited for it? */
> -	if (!page->mapping) {
> -		unlock_page(page);
> -		page_cache_release(page);
> -		goto retry_all;
> -	}
> -
> -	/* Did somebody else get it up-to-date? */
> -	if (PageUptodate(page)) {
> -		unlock_page(page);
> -		goto success;
> -	}
> -
> -	error = mapping->a_ops->readpage(file, page);
> -	if (!error) {
> -		wait_on_page_locked(page);
> -		if (PageUptodate(page))
> -			goto success;
> -	} else if (error == AOP_TRUNCATED_PAGE) {
> -		page_cache_release(page);
> -		goto retry_find;
> -	}
>  
>  	/*
>  	 * Umm, take care of errors if the page isn't up-to-date.
> @@ -1479,24 +1714,27 @@ page_not_uptodate:
>  	 */
>  	lock_page(page);
>  
> -	/* Somebody truncated the page on us? */
> +	/* Did it get unhashed while we waited for it? */
>  	if (!page->mapping) {
>  		unlock_page(page);
>  		page_cache_release(page);
>  		goto retry_all;
>  	}
>  
> -	/* Somebody else successfully read it in? */
> +	/* Did somebody else get it up-to-date? */
>  	if (PageUptodate(page)) {
>  		unlock_page(page);
> -		goto success;
> +		page_cache_release(page);
> +		goto retry_all;
>  	}
> -	ClearPageError(page);
> +
>  	error = mapping->a_ops->readpage(file, page);
>  	if (!error) {
>  		wait_on_page_locked(page);
> -		if (PageUptodate(page))
> -			goto success;
> +		if (PageUptodate(page)) {
> +			page_cache_release(page);
> +			goto retry_find;
> +		}
>  	} else if (error == AOP_TRUNCATED_PAGE) {
>  		page_cache_release(page);
>  		goto retry_find;
> @@ -1685,8 +1923,31 @@ repeat:
>  }
>  EXPORT_SYMBOL(filemap_populate);
>  
> +/*
> + * Collapse a possible page replication. The page is held unreplicated by
> + * the elevated refcount on the passed-in page.
> + */
> +static int filemap_mkwrite(struct vm_area_struct *vma, struct page *page)
> +{
> +	struct address_space *mapping;
> +	struct page *master;
> +	pgoff_t offset;
> +
> +	/* could be broken vs truncate? but at least truncate will remove pte */
> +	offset = page->index;
> +	mapping = page->mapping;
> +	if (!mapping)
> +		return -1;
> +
> +	master = find_get_page(mapping, offset);
> +	if (master)
> +		page_cache_release(master);
> +	return 0;
> +}
> +
>  struct vm_operations_struct generic_file_vm_ops = {
>  	.nopage		= filemap_nopage,
> +	.page_mkwrite	= filemap_mkwrite,
>  	.populate	= filemap_populate,
>  };
>  
> Index: linux-2.6/mm/internal.h
> ===================================================================
> --- linux-2.6.orig/mm/internal.h
> +++ linux-2.6/mm/internal.h
> @@ -37,4 +37,8 @@ static inline void __put_page(struct pag
>  extern void fastcall __init __free_pages_bootmem(struct page *page,
>  						unsigned int order);
>  
> +extern void __unreplicate_pcache(struct address_space *mapping, unsigned long offset);
> +extern void __remove_replicated_page(struct pcache_desc *pcd, struct page *page,
> +			struct address_space *mapping, unsigned long offset);
> +
>  #endif
> Index: linux-2.6/mm/vmscan.c
> ===================================================================
> --- linux-2.6.orig/mm/vmscan.c
> +++ linux-2.6/mm/vmscan.c
> @@ -390,6 +390,7 @@ int remove_mapping(struct address_space 
>  	BUG_ON(!PageLocked(page));
>  	BUG_ON(mapping != page_mapping(page));
>  
> +again:
>  	write_lock_irq(&mapping->tree_lock);
>  	/*
>  	 * The non racy check for a busy page.
> @@ -431,7 +432,16 @@ int remove_mapping(struct address_space 
>  		return 1;
>  	}
>  
> -	__remove_from_page_cache(page);
> +	if (radix_tree_tag_get(&mapping->page_tree, page->index, PAGECACHE_TAG_REPLICATED)) {
> +		struct pcache_desc *pcd;
> +		pcd = radix_tree_lookup(&mapping->page_tree, page->index);
??? possibly NULL pcd?

> +		if (page == pcd->master) {
> +			__unreplicate_pcache(mapping, page->index);
> +			goto again;
> +		} else
> +			__remove_replicated_page(pcd, page, mapping, page->index);
> +	} else
> +		__remove_from_page_cache(page);
>  	write_unlock_irq(&mapping->tree_lock);
>  	__put_page(page);
>  	return 1;
> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h
> +++ linux-2.6/include/linux/mm.h
> @@ -983,6 +983,7 @@ extern void memmap_init_zone(unsigned lo
>  				unsigned long, enum memmap_context);
>  extern void setup_per_zone_pages_min(void);
>  extern void mem_init(void);
> +extern void filemap_init(void);
>  extern void show_mem(void);
>  extern void si_meminfo(struct sysinfo * val);
>  extern void si_meminfo_node(struct sysinfo *val, int nid);
> Index: linux-2.6/init/main.c
> ===================================================================
> --- linux-2.6.orig/init/main.c
> +++ linux-2.6/init/main.c
> @@ -583,6 +583,7 @@ asmlinkage void __init start_kernel(void
>  	kmem_cache_init();
>  	setup_per_cpu_pageset();
>  	numa_policy_init();
> +	filemap_init();
>  	if (late_time_init)
>  		late_time_init();
>  	calibrate_delay();
> Index: linux-2.6/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mmzone.h
> +++ linux-2.6/include/linux/mmzone.h
> @@ -51,6 +51,7 @@ enum zone_stat_item {
>  	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
>  			   only modified from process context */
>  	NR_FILE_PAGES,
> +	NR_REPL_PAGES,
>  	NR_SLAB_RECLAIMABLE,
>  	NR_SLAB_UNRECLAIMABLE,
>  	NR_PAGETABLE,	/* used for pagetables */
> Index: linux-2.6/mm/vmstat.c
> ===================================================================
> --- linux-2.6.orig/mm/vmstat.c
> +++ linux-2.6/mm/vmstat.c
> @@ -457,6 +457,7 @@ static const char * const vmstat_text[] 
>  	"nr_anon_pages",
>  	"nr_mapped",
>  	"nr_file_pages",
> +	"nr_repl_pages",
>  	"nr_slab_reclaimable",
>  	"nr_slab_unreclaimable",
>  	"nr_page_table_pages",
> 

Page Cache Replication Fixes:

Allow radix_tree_tag_get() to be compiled for in kernel use.

Insert "master page" in replicated page descriptor radix tree
using correct node [page_node] as index.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 lib/radix-tree.c |    2 --
 mm/filemap.c     |    8 ++++++--
 2 files changed, 6 insertions(+), 4 deletions(-)

Index: Linux/lib/radix-tree.c
===================================================================
--- Linux.orig/lib/radix-tree.c	2007-02-13 16:53:57.000000000 -0500
+++ Linux/lib/radix-tree.c	2007-02-13 16:54:07.000000000 -0500
@@ -534,7 +534,6 @@ out:
 }
 EXPORT_SYMBOL(radix_tree_tag_clear);
 
-#ifndef __KERNEL__	/* Only the test harness uses this at present */
 /**
  * radix_tree_tag_get - get a tag on a radix tree node
  * @root:		radix tree root
@@ -596,7 +595,6 @@ int radix_tree_tag_get(struct radix_tree
 	}
 }
 EXPORT_SYMBOL(radix_tree_tag_get);
-#endif
 
 static unsigned int
 __lookup(struct radix_tree_node *slot, void **results, unsigned long index,
Index: Linux/mm/filemap.c
===================================================================
--- Linux.orig/mm/filemap.c	2007-02-13 16:53:47.000000000 -0500
+++ Linux/mm/filemap.c	2007-02-13 16:54:26.000000000 -0500
@@ -707,7 +707,7 @@ again:
 
 	pcd->master = page;
 	node_set(page_node, pcd->nodes_present);
-	if (radix_tree_insert(&pcd->page_tree, nid, page)) {
+	if (radix_tree_insert(&pcd->page_tree, page_node, page)) {
 		free_pcache_desc(pcd);
 		goto out;
 	}
@@ -840,8 +840,12 @@ replicated:
 	} else {
 		page = radix_tree_lookup(&mapping->page_tree, offset);
 		if (page) {
+			/*
+			 * page currently NOT replicated.  Check whether
+			 * it should be.
+			 */
 			if (__replicate_pcache(page, mapping, offset))
-				goto replicated;
+				goto replicated;	/* make local replicant */
 			page_cache_get(page);
 		}
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
