Date: Sat, 14 Aug 2004 10:37:17 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: __set_page_dirty_nobuffers superfluous check
Message-ID: <20040814133717.GA32755@logos.cnet>
References: <20040813180504.GB29875@logos.cnet> <Pine.LNX.4.44.0408140745280.20187-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0408140745280.20187-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh!

Thanks for writing this down :)

On Sat, Aug 14, 2004 at 07:46:45AM +0100, Hugh Dickins wrote:
> On Fri, 13 Aug 2004, Marcelo Tosatti wrote:
> 
> > While wandering through mm/page-writeback.c I noticed
> > __set_page_dirty_nobuffers does:
> > 
> > int __set_page_dirty_nobuffers(struct page *page)
> > {
> >         int ret = 0;
> >                                                                                          
> >         if (!TestSetPageDirty(page)) {
> >                 struct address_space *mapping = page_mapping(page);
> >                                                                                          
> >                 if (mapping) {
> >                         spin_lock_irq(&mapping->tree_lock);
> >                         mapping = page_mapping(page);
> >                         if (page_mapping(page)) { /* Race with truncate? */
> >                                 BUG_ON(page_mapping(page) != mapping);    <------------------
> >                                 if (!mapping->backing_dev_info->memory_backed)
> >                                         inc_page_state(nr_dirty);
> >                                 radix_tree_tag_set(&mapping->page_tree,
> >                                         page_index(page), PAGECACHE_TAG_DIRTY);
> >                         }
> > 
> > How could the mapping ever change if we have tree_lock?
> > 
> > Its basically a check which assumes there might be 
> > buggy page->mapping writers who do so without the lock, yes?
> 
> Nicely observed - and four evaluations of page_mapping(page)
> within seven lines is two too many, even if optimized away.
> 
> But actually your interpretation is wrong: because this has evolved
> from a sensible check on something seriously in doubt,
> to a pointless duplication of effort.
> 
> It makes sense if you look at the original, in 2.6.6 or earlier:
> 
> 	if (!TestSetPageDirty(page)) {
> 		struct address_space *mapping = page->mapping;
> 
> 		if (mapping) {
> 			spin_lock_irq(&mapping->tree_lock);
> 			if (page->mapping) {	/* Race with truncate? */
> 				BUG_ON(page->mapping != mapping);
> 				if (!mapping->backing_dev_info->memory_backed)
> 
> What this is actually worrying about (along with truncation suddenly
> setting page->mapping to NULL, won't happen without tree_lock) is
> tmpfs swizzling page->mapping between a tmpfs struct address_space *
> and &swapper_space (move_to/from_swap_cache in swap_state.c); or
> (more distant concern) the page getting reused while we're in here,
> coming in with one page->mapping and then suddenly another.
> 
> It's not doubting that tree_lock protects against that, but _which_
> tree_lock?  If page->mapping suddenly changes underneath us, then
> the spin_lock_irq(&mapping->tree_lock) may have been done on the
> wrong mapping->tree_lock - to lock "mapping->tree_lock" you have
> to choose "mapping" first, but perhaps that's not stable without
> its tree_lock.
> 
> In most cases, the (assumed) hold on the page in question prevents
> page->mapping from changing from one non-NULL to another non-NULL
> here, even without the tree_lock.  But that's not enough to protect
> against the tmpfs swizzling: what protects against that?  Er, er,
> it's the way tmpfs pages only go to swap when not in use, and are
> brought back from swap before being used, and shmem.c insists on
> page lock in each direction; but really it needs an audit of every
> use of set_page_dirty to be sure.  Though I've never heard of the
> (earlier, useful) BUG_ON actually firing.
> 
> And I think you'll find that in practice it's just a waste for ramfs,
> tmpfs and swap to be coming through __set_page_dirty_nobuffers at all:
> since we don't do mpage operations on the "memory_backed" filesystems,
> all the radix-tree tagging and dirty-inode operations on them are just
> a waste of time?  and they'd do better to use a .set_page_dirty which
> just does SetPageDirty.  But akpm does wonder from time to time whether
> to reintroduce mpage operations on at least swap, so may resist such a
> simplification.

Makes sense, why arent tmpfs/swap using mpage operations? 

> Anyway, perhaps a suitable patch to make sense of that BUG_ON would be:
> 
> --- 2.6.8/mm/page-writeback.c	2004-08-10 05:40:21.000000000 +0100
> +++ linux/mm/page-writeback.c	2004-08-14 07:21:58.744468256 +0100
> @@ -580,12 +580,13 @@ int __set_page_dirty_nobuffers(struct pa
>  
>  	if (!TestSetPageDirty(page)) {
>  		struct address_space *mapping = page_mapping(page);
> +		struct address_space *mapping2;
>  
>  		if (mapping) {
>  			spin_lock_irq(&mapping->tree_lock);
> -			mapping = page_mapping(page);
> -			if (page_mapping(page)) { /* Race with truncate? */
> -				BUG_ON(page_mapping(page) != mapping);
> +			mapping2 = page_mapping(page);
> +			if (mapping2) { /* Race with truncate? */
> +				BUG_ON(mapping2 != mapping);
>  				if (!mapping->backing_dev_info->memory_backed)
>  					inc_page_state(nr_dirty);
>  				radix_tree_tag_set(&mapping->page_tree,

I see.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
