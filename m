Date: Thu, 21 Oct 2004 08:30:05 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] Migration cache
Message-ID: <20041021103005.GA18917@logos.cnet>
References: <20041014192240.GA6899@logos.cnet> <20041021.021044.85414770.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041021.021044.85414770.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: haveblue@us.ibm.com, iwamoto@valinux.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hirokazu!

On Thu, Oct 21, 2004 at 02:10:44AM +0900, Hirokazu Takahashi wrote:
> Hi, Marcelo,
> 
> > So as I've said before in my opinion moving pages to the swapcache 
> > to migrate them is unnacceptable for several reasons. Not to mention 
> > live memory defragmentation.
> > 
> > So the following patch, on top of the v2.6 -memoryhotplug tree, 
> > creates a migration cache - which is basically a swapcache without 
> > using the swap map - it instead uses a on-memory idr structure.
> > 
> > For that we decrease SWP_TYPE_SHIFT from 5 to 4, and use that now-free
> > bit to indicate pte's which point to pages on the migration cache.
> 
> I guess it would be better to reserve one swap type for the migration
> cache instead of reserving the bit to reduce the impact of the maximum
> number of swap types.
> However, I think your approach is good enough for the first implementation.

By reserving one swap type we would also use a bit. Using a swap type is 
the same thing as using a bit in the swap pagetableentry. (the swap type 
has 5 bits reserved for swap devices, 2^5 = 32 swap devices).

?

> > Comments are very welcome 
> 
> I'll continue to check the code.
> 
> 
> > diff -Nur linux-2.6.9-rc2-mm4.mhp.orig/include/linux/swapops.h linux-2.6.9-rc2-mm4.build/include/linux/swapops.h
> > --- linux-2.6.9-rc2-mm4.mhp.orig/include/linux/swapops.h	2004-10-14 17:22:26.000000000 -0300
> > +++ linux-2.6.9-rc2-mm4.build/include/linux/swapops.h	2004-10-14 17:44:00.022925568 -0300
> > @@ -19,7 +19,7 @@
> >  {
> >  	swp_entry_t ret;
> >  
> > -	ret.val = (type << SWP_TYPE_SHIFT(ret)) |
> > +	ret.val = type << SWP_TYPE_SHIFT(ret) |
> 
> I guess it's just for cleanups to remove the brackets, right?

Actually its just because I've been messing around with this code. 

It shouldnt be changed in the final patch :)

> > diff -Nur linux-2.6.9-rc2-mm4.mhp.orig/mm/memory.c linux-2.6.9-rc2-mm4.build/mm/memory.c
> > --- linux-2.6.9-rc2-mm4.mhp.orig/mm/memory.c	2004-10-14 17:21:52.000000000 -0300
> > +++ linux-2.6.9-rc2-mm4.build/mm/memory.c	2004-10-14 17:43:06.703031424 -0300
> > @@ -1433,7 +1441,6 @@
> >  		inc_page_state(pgmajfault);
> >  		grab_swap_token();
> >  	}
> > -
> >  	mark_page_accessed(page);
> >  	lock_page(page);
> >  	if (!PageSwapCache(page)) {
> 
> I think the previous line should be
>  	if (!PageSwapCache(page) && !PageMigration(page)) {
> 
> This line means to redo everything from the beginning if the page is not
> either in the swap-cache or in the migration-cache.

Right. Added to the todo list.

> > @@ -1442,6 +1449,13 @@
> >  		page_cache_release(page);
> >  		goto again;
> >  	}
> > +	}
> > +
> > +
> > +	if (pte_is_migration(orig_pte)) {
> > +		mark_page_accessed(page);
> > +		lock_page(page);
> > +	}
> >  
> >  	/*
> >  	 * Back out if somebody else faulted in this pte while we
> 
> > diff -Nur linux-2.6.9-rc2-mm4.mhp.orig/mm/mmigrate.c linux-2.6.9-rc2-mm4.build/mm/mmigrate.c
> > --- linux-2.6.9-rc2-mm4.mhp.orig/mm/mmigrate.c	2004-10-14 17:21:52.000000000 -0300
> > +++ linux-2.6.9-rc2-mm4.build/mm/mmigrate.c	2004-10-14 17:43:06.621043888 -0300
> 
> > +int migration_remove_entry(swp_entry_t entry)
> > +{
> > +	struct page *page;
> > +	
> > +	page = find_trylock_page(&migration_space, entry.val);
> 
> I guess there exits a race condition here.
> If the page is locked unfortunately at this moment, who release it?
> Another process on another CPU may be handling page-fault against the page
> if it is shared with other processes.
> 
> The following code would be better?
> 	page = find_get_page(&migration_space, entry.val);
> 	if (page)
> 		lock_page(page);

Correct! Now I also noticed that locking of the IDR structure needs to be 
done correctly for eg migration_remove_reference does
idr_find() without any lock.

> > +
> > +
> > +	if (printk_ratelimit())
> > +		printk(KERN_ERR "remove_from_migration_cache!!\n");
> > +
> > +
> > +	if (page) {
> > +		migration_remove_reference(page);
> > +		unlock_page(page);
> > +		page_cache_release(page);
> > +	}
> > +
> > +}
> 
> 
> > +int add_to_migration_cache(struct page *page, int gfp_mask) 
> > +{
> > +	int error, offset;
> > +	struct counter *counter;
> > +
> > +	BUG_ON(PageSwapCache(page));
> > +	BUG_ON(PagePrivate(page));
> > +	BUG_ON(PageMigration(page));
> > +
> > +        if (idr_pre_get(&migration_idr, GFP_ATOMIC) == 0)
> > +                return -ENOMEM;
> 
> GFP_KERNEL would be appropriate for the memory migration code, 
> because the swap-code will make free pages in case of low memory.
> This is one of the different points from the swap-code, which 
> can't specify such gfp_mask, as no one can prepare free pages
> for it.

OK!

> 
> > +
> > +	error = radix_tree_preload(gfp_mask);
> > +
> > +	counter = kmalloc(sizeof(struct counter), GFP_KERNEL);
> 
> kmalloc() should be called before radix_tree_preload()
> because radix_tree_preload() disables preemption not to switch
> other processes during handling radix trees. However kmalloc()
> with GFP_KERNEL may be blocked to break this assumption.

OK!

> > +
> > +	counter->i = 0;
> > +	counter->magic = 0xdeadbeef;
> > +
> > +	if (!error) {
> > +		write_lock_irq(&migration_space.tree_lock);
> > +	        error = idr_get_new_above(&migration_idr, counter, 1, &offset);
> > +
> > +		if (error < 0)
> > +			BUG();
> > +
> > +		error = radix_tree_insert(&migration_space.page_tree, offset,
> > +							page);
> > +
> > +		if (!error) {
> > +			page_cache_get(page);
> > +			SetPageLocked(page);
> > +			page->private = offset;
> > +//			page->mapping = &migration_space;
> > +			SetPageMigration(page);
> > +		}
> > +		write_unlock_irq(&migration_space.tree_lock);
> > +                radix_tree_preload_end();
> > +
> > +	}
> > +
> > +	return error;
> > +}
> 
> 
> > @@ -399,11 +571,15 @@
> >  	 * Put the page in a radix tree if it isn't in the tree yet.
> >  	 */
> >  #ifdef CONFIG_SWAP
> > -	if (PageAnon(page) && !PageSwapCache(page))
> > -		if (!add_to_swap(page, GFP_KERNEL)) {
> > +	if (PageAnon(page) && !PageSwapCache(page) && !PageMigration(page))
> 
> I guess calling BUG() would be good if the page is already in the
> migration cache.

Sure, can be done.

> 
> > +		if (!add_to_migration_cache(page, GFP_KERNEL)) {
> >  			unlock_page(page);
> >  			return ERR_PTR(-ENOSPC);
> >  		}
> > +/*		if (!add_to_swap(page, GFP_KERNEL)) {
> > +			unlock_page(page);
> > +			return ERR_PTR(-ENOSPC);
> > +		} */
> >  #endif /* CONFIG_SWAP */
> >  	if ((mapping = page_mapping(page)) == NULL) {
> >  		/* truncation is in progress */
> 
> > diff -Nur linux-2.6.9-rc2-mm4.mhp.orig/mm/vmscan.c linux-2.6.9-rc2-mm4.build/mm/vmscan.c
> > --- linux-2.6.9-rc2-mm4.mhp.orig/mm/vmscan.c	2004-10-14 17:21:52.000000000 -0300
> > +++ linux-2.6.9-rc2-mm4.build/mm/vmscan.c	2004-10-14 17:43:06.426073528 -0300
> > @@ -354,7 +354,7 @@
> >  		 * Anonymous process memory has backing store?
> >  		 * Try to allocate it some swap space here.
> >  		 */
> > -		if (PageAnon(page) && !PageSwapCache(page)) {
> > +		if (PageAnon(page) && !PageSwapCache(page) && !PageMigration(page)) {
> 
> BUG_ON(PageMigration(page)) would be better, because it must not exist
> in the LRU. Target pages to migrate must have been removed from the LRU
> lists in advance, so that the swap code never grabs them.

OK too!

> >  			if (!add_to_swap(page, GFP_ATOMIC))
> >  				goto activate_locked;
> >  		}

I'm working on something else today and probably tomorrow,
later on I'll be making the changes you suggest and find any 
remaining bugs (I didnt mention but this is still oopsing for some reason 
in odd places).

So then we do some wider testing and merge it in the mainline -mhp patch! 

Thanks for your comments.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
