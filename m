Date: Tue, 26 Oct 2004 09:41:16 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: migration cache, updated
Message-ID: <20041026114116.GB27014@logos.cnet>
References: <20041025213923.GD23133@logos.cnet> <20041026.153731.38067476.taka@valinux.co.jp> <20041026092011.GD24462@logos.cnet> <20041026.224550.109999656.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041026.224550.109999656.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Tue, Oct 26, 2004 at 10:45:50PM +0900, Hirokazu Takahashi wrote:
> Hi,
> 
> > > The previous code will cause deadlock, as the page is already locked.
> > 
> > Actually this one is fine - the page is not locked (its locked
> > by the SwapCache pte path - not migration path)
> > 
> > if (pte_is_migration(pte)) 
> > 	lookup_migration_cache
> > else 
> > 	old lookup swap cache
> > 	lock_page
> > 
> > if (pte_is_migration(pte))
> > 	mark_page_accessed
> > 	lock_page
> 
> Oh, I understand.
> 
> > Can you please try the tests with the following updated patch
> > 
> > Works for me
> 
> It didn't work without one fix.
> 
> +void remove_from_migration_cache(struct page *page, int id)
> +{
> +	write_lock_irq(&migration_space.tree_lock);
> +        idr_remove(&migration_idr, id);
> +	radix_tree_delete(&migration_space.page_tree, id);
> +	ClearPageSwapCache(page);
> +	page->private = NULL;
> +	write_unlock_irq(&migration_space.tree_lock);
> +}
> 
> +int migration_remove_reference(struct page *page)
> +{
> +	struct counter *c;
> +	swp_entry_t entry;
> +
> +	entry.val = page->private;
> +
> +	read_lock_irq(&migration_space.tree_lock);
> +
> +	c = idr_find(&migration_idr, swp_offset(entry));
> +
> +	read_unlock_irq(&migration_space.tree_lock);
> +
> +	if (!c->i)
> +		BUG();
> +
> +	c->i--;
> +
> +	if (!c->i) {
> +		remove_from_migration_cache(page, page->private);
> +		kfree(c);
> 
> page_cache_release(page) should be invoked here, as the count for
> the migration cache must be decreased.
> With this fix, your migration cache started to work very fine!

Oh yes, I removed that by accident.

> +	}
> +		
> +}
> 
> 
> 
> The attached patch is what I ported your patch to the latest version
> and I fixed the bug.

It seems a hunk from your own tree leaked into this patch?

See above

> @@ -367,11 +527,6 @@ generic_migrate_page(struct page *page, 
>  
>  	/* map the newpage where the old page have been mapped. */
>  	touch_unmapped_address(&vlist);
> -	if (PageSwapCache(newpage)) {
> -		lock_page(newpage);
> -		__remove_exclusive_swap_page(newpage, 1);
> -		unlock_page(newpage);
> -	}
>  
>  	page->mapping = NULL;
>  	unlock_page(page);
> @@ -383,11 +538,6 @@ out_busy:
>  	/* Roll back all operations. */
>  	rewind_page(page, newpage);
>  	touch_unmapped_address(&vlist);
> -	if (PageSwapCache(page)) {
> -		lock_page(page);
> -		__remove_exclusive_swap_page(page, 1);
> -		unlock_page(page);
> -	}
>  	return ret;

This two hunks?

OK fine I'll update the patch with all fixes to 
the newer version of -mhp, and start working 
on the nonblocking version of the migration 
functions.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
