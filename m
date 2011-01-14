Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B8B3D6B00E7
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 20:06:58 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Postfix) with ESMTP id 582D93EE0B3
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 10:06:00 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 32DB52AEA8E
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 10:06:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 17BAF45DE56
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 10:06:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 04A791DB804A
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 10:06:00 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B904F1DB804D
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 10:05:59 +0900 (JST)
Date: Fri, 14 Jan 2011 10:00:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3] mm: add replace_page_cache_page() function
Message-Id: <20110114100007.27c9fbce.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <E1PdNKX-0003t5-Rm@pomaz-ex.szeredi.hu>
References: <E1Pcet8-0007kg-3R@pomaz-ex.szeredi.hu>
	<20110111142528.GF2113@barrios-desktop>
	<20110112094453.8197ee36.kamezawa.hiroyu@jp.fujitsu.com>
	<E1Pd1iF-0001jM-CV@pomaz-ex.szeredi.hu>
	<20110113112702.f87d7e29.kamezawa.hiroyu@jp.fujitsu.com>
	<E1PdNKX-0003t5-Rm@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: minchan.kim@gmail.com, akpm@linux-foundation.org, nishimura@mxp.nes.nec.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2011 14:35:09 +0100
Miklos Szeredi <miklos@szeredi.hu> wrote:

> On Thu, 13 Jan 2011, KAMEZAWA Hiroyuki wrote:
> > On Wed, 12 Jan 2011 15:30:11 +0100
> > Miklos Szeredi <miklos@szeredi.hu> wrote:
> > 
> > > On Wed, 12 Jan 2011, KAMEZAWA Hiroyuki wrote:
> > > > On Tue, 11 Jan 2011 23:25:28 +0900
> > > > Minchan Kim <minchan.kim@gmail.com> wrote:
> > > > 
> > > > > On Tue, Jan 11, 2011 at 03:07:54PM +0100, Miklos Szeredi wrote:
> > > > > > (resent with fixed CC list, sorry for the duplicate)
> > > > > > 
> > > > > > Thanks for the review.
> > > > > > 
> > > > > > Here's an updated patch.  Modifications since the last post:
> > > > > > 
> > > > > >  - don't pass gfp_mask (since it's only able to deal with GFP_KERNEL
> > > > > >    anyway)
> > > > > > 
> > > > > 
> > > > > I am not sure it's a good idea.
> > > > > Now if we need just GFP_KERNEL, we can't make sure it in future.
> > > > > Sometime we might need GFP_ATOMIC and friendd functions
> > > > > (ex, add_to_page_cache_lru,add_to_page_cache_locked) already have gfp_mask.
> > > > > It's a exported function so it's hard to modify it in future.
> > > > > 
> > > > > I want to keep it.
> > > > > Instead of removing it, we can change mem_cgroup_prepare_migration as
> > > > > getting gfp_mask.
> > > > > 
> > > > you're right.
> > > 
> > > Okay, makes sense.
> > > 
> > > Here's an updated patch.
> > > 
> > 
> > Seems nicer. But you didn't fixed the caller of prepare_migraton()
> > in mm/migrate.c (I think this is the only caller..)
> > 
> > please modify it, too.
> 
> Right you are.  Thanks for the review.
> 
> Updated patch attached.
> 
> Thanks,
> Miklos
> ---
> 
> 
> From: Miklos Szeredi <mszeredi@suse.cz>
> Subject: mm: add replace_page_cache_page() function
> 
> This function basically does:
> 
>      remove_from_page_cache(old);
>      page_cache_release(old);
>      add_to_page_cache_locked(new);
> 
> Except it does this atomically, so there's no possibility for the
> "add" to fail because of a race.
> 
> This is used by fuse to move pages into the page cache.
> 
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>

Thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

But my last concern is that GFP_KERNEL is ok or not for compaction...
(It was implicitly used.)

Maybe migrate_page() should have gfp_mask but it should be in another work.

Thanks,
-Kame


> ---
>  fs/fuse/dev.c              |   10 ++----
>  include/linux/memcontrol.h |    4 +-
>  include/linux/pagemap.h    |    1 
>  mm/filemap.c               |   65 +++++++++++++++++++++++++++++++++++++++++++++
>  mm/memcontrol.c            |    4 +-
>  mm/migrate.c               |    2 -
>  6 files changed, 75 insertions(+), 11 deletions(-)
> 
> Index: linux-2.6/mm/filemap.c
> ===================================================================
> --- linux-2.6.orig/mm/filemap.c	2011-01-12 15:28:56.000000000 +0100
> +++ linux-2.6/mm/filemap.c	2011-01-13 13:37:41.000000000 +0100
> @@ -387,6 +387,71 @@ int filemap_write_and_wait_range(struct
>  EXPORT_SYMBOL(filemap_write_and_wait_range);
>  
>  /**
> + * replace_page_cache_page - replace a pagecache page with a new one
> + * @old:	page to be replaced
> + * @new:	page to replace with
> + * @gfp_mask:	allocation mode
> + *
> + * This function replaces a page in the pagecache with a new one.  On
> + * success it acquires the pagecache reference for the new page and
> + * drops it for the old page.  Both the old and new pages must be
> + * locked.  This function does not add the new page to the LRU, the
> + * caller must do that.
> + *
> + * The remove + add is atomic.  The only way this function can fail is
> + * memory allocation failure.
> + */
> +int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
> +{
> +	int error;
> +	struct mem_cgroup *memcg = NULL;
> +
> +	VM_BUG_ON(!PageLocked(old));
> +	VM_BUG_ON(!PageLocked(new));
> +	VM_BUG_ON(new->mapping);
> +
> +	/*
> +	 * This is not page migration, but prepare_migration and
> +	 * end_migration does enough work for charge replacement.
> +	 *
> +	 * In the longer term we probably want a specialized function
> +	 * for moving the charge from old to new in a more efficient
> +	 * manner.
> +	 */
> +	error = mem_cgroup_prepare_migration(old, new, &memcg, gfp_mask);
> +	if (error)
> +		return error;
> +
> +	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> +	if (!error) {
> +		struct address_space *mapping = old->mapping;
> +		pgoff_t offset = old->index;
> +
> +		page_cache_get(new);
> +		new->mapping = mapping;
> +		new->index = offset;
> +
> +		spin_lock_irq(&mapping->tree_lock);
> +		__remove_from_page_cache(old);
> +		error = radix_tree_insert(&mapping->page_tree, offset, new);
> +		BUG_ON(error);
> +		mapping->nrpages++;
> +		__inc_zone_page_state(new, NR_FILE_PAGES);
> +		if (PageSwapBacked(new))
> +			__inc_zone_page_state(new, NR_SHMEM);
> +		spin_unlock_irq(&mapping->tree_lock);
> +		radix_tree_preload_end();
> +		page_cache_release(old);
> +		mem_cgroup_end_migration(memcg, old, new, true);
> +	} else {
> +		mem_cgroup_end_migration(memcg, old, new, false);
> +	}
> +
> +	return error;
> +}
> +EXPORT_SYMBOL_GPL(replace_page_cache_page);
> +
> +/**
>   * add_to_page_cache_locked - add a locked page to the pagecache
>   * @page:	page to add
>   * @mapping:	the page's address_space
> Index: linux-2.6/include/linux/pagemap.h
> ===================================================================
> --- linux-2.6.orig/include/linux/pagemap.h	2011-01-12 15:28:56.000000000 +0100
> +++ linux-2.6/include/linux/pagemap.h	2011-01-13 13:37:41.000000000 +0100
> @@ -457,6 +457,7 @@ int add_to_page_cache_lru(struct page *p
>  				pgoff_t index, gfp_t gfp_mask);
>  extern void remove_from_page_cache(struct page *page);
>  extern void __remove_from_page_cache(struct page *page);
> +int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
>  
>  /*
>   * Like add_to_page_cache_locked, but used to add newly allocated pages:
> Index: linux-2.6/fs/fuse/dev.c
> ===================================================================
> --- linux-2.6.orig/fs/fuse/dev.c	2011-01-12 15:28:56.000000000 +0100
> +++ linux-2.6/fs/fuse/dev.c	2011-01-13 13:37:41.000000000 +0100
> @@ -737,14 +737,12 @@ static int fuse_try_move_page(struct fus
>  	if (WARN_ON(PageMlocked(oldpage)))
>  		goto out_fallback_unlock;
>  
> -	remove_from_page_cache(oldpage);
> -	page_cache_release(oldpage);
> -
> -	err = add_to_page_cache_locked(newpage, mapping, index, GFP_KERNEL);
> +	err = replace_page_cache_page(oldpage, newpage, GFP_KERNEL);
>  	if (err) {
> -		printk(KERN_WARNING "fuse_try_move_page: failed to add page");
> -		goto out_fallback_unlock;
> +		unlock_page(newpage);
> +		return err;
>  	}
> +
>  	page_cache_get(newpage);
>  
>  	if (!(buf->flags & PIPE_BUF_FLAG_LRU))
> Index: linux-2.6/include/linux/memcontrol.h
> ===================================================================
> --- linux-2.6.orig/include/linux/memcontrol.h	2011-01-13 13:37:40.000000000 +0100
> +++ linux-2.6/include/linux/memcontrol.h	2011-01-13 13:37:41.000000000 +0100
> @@ -91,7 +91,7 @@ extern struct cgroup_subsys_state *mem_c
>  
>  extern int
>  mem_cgroup_prepare_migration(struct page *page,
> -	struct page *newpage, struct mem_cgroup **ptr);
> +	struct page *newpage, struct mem_cgroup **ptr, gfp_t gfp_mask);
>  extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
>  	struct page *oldpage, struct page *newpage, bool migration_ok);
>  
> @@ -225,7 +225,7 @@ static inline struct cgroup_subsys_state
>  
>  static inline int
>  mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
> -	struct mem_cgroup **ptr)
> +	struct mem_cgroup **ptr, gfp_t gfp_mask)
>  {
>  	return 0;
>  }
> Index: linux-2.6/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.orig/mm/memcontrol.c	2011-01-13 13:37:40.000000000 +0100
> +++ linux-2.6/mm/memcontrol.c	2011-01-13 13:37:41.000000000 +0100
> @@ -2767,7 +2767,7 @@ static inline int mem_cgroup_move_swap_a
>   * page belongs to.
>   */
>  int mem_cgroup_prepare_migration(struct page *page,
> -	struct page *newpage, struct mem_cgroup **ptr)
> +	struct page *newpage, struct mem_cgroup **ptr, gfp_t gfp_mask)
>  {
>  	struct page_cgroup *pc;
>  	struct mem_cgroup *mem = NULL;
> @@ -2823,7 +2823,7 @@ int mem_cgroup_prepare_migration(struct
>  		return 0;
>  
>  	*ptr = mem;
> -	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, ptr, false);
> +	ret = __mem_cgroup_try_charge(NULL, gfp_mask, ptr, false);
>  	css_put(&mem->css);/* drop extra refcnt */
>  	if (ret || *ptr == NULL) {
>  		if (PageAnon(page)) {
> Index: linux-2.6/mm/migrate.c
> ===================================================================
> --- linux-2.6.orig/mm/migrate.c	2011-01-13 13:37:40.000000000 +0100
> +++ linux-2.6/mm/migrate.c	2011-01-13 13:38:55.000000000 +0100
> @@ -657,7 +657,7 @@ static int unmap_and_move(new_page_t get
>  	}
>  
>  	/* charge against new page */
> -	charge = mem_cgroup_prepare_migration(page, newpage, &mem);
> +	charge = mem_cgroup_prepare_migration(page, newpage, &mem, GFP_KERNEL);
>  	if (charge == -ENOMEM) {
>  		rc = -ENOMEM;
>  		goto unlock;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
