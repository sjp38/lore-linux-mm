Date: Wed, 24 Nov 2004 19:21:56 +0900 (JST)
Message-Id: <20041124.192156.73388074.taka@valinux.co.jp>
Subject: Re: migration cache, updated
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20041123121447.GE4524@logos.cnet>
References: <20041105151631.GA19473@logos.cnet>
	<20041116.130718.34767806.taka@valinux.co.jp>
	<20041123121447.GE4524@logos.cnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi Marcelo,

> > Hi Marcelo,
> > 
> > I've been testing the memory migration code with your patch.
> > I found problems and I think the attached patch would
> > fix some of them.
> > 
> > One of the problems is a race condition between add_to_migration_cache()
> > and try_to_unmap(). Some pages in the migration cache cannot
> > be removed with the current implementation. Please suppose
> > a process space might be removed between them. In this case
> > no one can remove pages the process had from the migration cache,
> > because they can be removed only when the pagetables pointed
> > the pages.
> 
> I guess I dont fully understand you Hirokazu.
> 
> unmap_vmas function (called by exit_mmap) calls zap_pte_range, 
> and that does:
> 
>                         if (pte_is_migration(pte)) {
>                                 migration_remove_entry(swp_entry);
>                         } else
>                                 free_swap_and_cache(swp_entry);
> 
> migration_remove_entry should decrease the IDR counter, and 
> remove the migration cache page on zero reference.
> 
> Am I missing something?

That's true only if the pte points a migration entry.
However, the pte may not point it when zap_pte_range() is called
in some case.

Please suppose the following flow.
Any process may exit or munmap during memory migration
before calling set_pte(migration entry). This will
keep some unreferenced pages in the migration cache.
No one can remove these pages.

  <start page migration>                  <Process A>
        |                                      |
        |                                      |
        |                                      |
 add_to_migration_cache()                      |
    insert a page of Process A  ----------->   |
    in the migration cache.                    |
        |                                      |
        |                               zap_pte_range()
        |                   X <------------ migration_remove_entry()
        |                      the pte associated with the page doesn't
        |                      point any migration entries.
        |
        |
 try_to_unmap() -----------------------> X
     migration_duplicate()       no pte mapping the page can be found.
     set_pte(migration entry)
        |
        |
 migrate_fn()
        |
        |
    <finish>
         the page still remains in the migration cache.
	 the page may be referred by no process.


> I assume you are seeing this problems in practice?

Yes, it often happens without the patch.

> Sorry for the delay, been busy with other things.

No problem. Everyone knows you're doing hard work!

> > Therefore, I made pages removed from the migration cache
> > at the end of generic_migrate_page() if they remain in the cache.
> > 
> > The another is a fork() related problem. If fork() has occurred
> > during page migration, the previous work may not go well.
> > pages may not be removed from the migration cache.
> > 
> > So I made the swapcode ignore pages in the migration cache.
> > However, as you know this is just a workaround and not a correct
> > way to fix it.
> > 
> > > Hi Hirokazu!
> > > 
> > > The problem is that another thread can fault in the pte 
> > > (removing the radix tree entry) while the current thread dropped the 
> > > page_table_lock - which explains the NULL lookup_migration_cache. 
> > > The swap code handles this situation, but I've completly missed it. 
> > > 
> > > Updated patch attached.
> > > 
> > > Extreme thanks for your testing, its being crucial! 
> > > 
> > > We're getting there.
> > > 
> > > do_swap_page now does:
> > > 
> > >  again:
> > > +       if (pte_is_migration(orig_pte)) {
> > > +               page = lookup_migration_cache(entry.val);
> > > +               if (!page) {
> > > +                       spin_lock(&mm->page_table_lock);
> > > +                       page_table = pte_offset_map(pmd, address);
> > > +                       if (likely(pte_same(*page_table, orig_pte)))
> > > +                               ret = VM_FAULT_OOM;
> > > +                       else
> > > +                               ret = VM_FAULT_MINOR;
> > > +                       pte_unmap(page_table);
> > > +                       spin_unlock(&mm->page_table_lock);
> > > +                       goto out;
> > > +               }
> > > +       } else {
> > > 
> > 
> > 
> > 
> > Signed-off-by: Hirokazu Takahashi <taka@valinux.co.jp>
> > ---
> > 
> >  linux-2.6.9-rc4-taka/mm/memory.c   |    2 +-
> >  linux-2.6.9-rc4-taka/mm/mmigrate.c |   28 +++++++++++++++++++++-------
> >  linux-2.6.9-rc4-taka/mm/vmscan.c   |    4 ++++
> >  3 files changed, 26 insertions, 8 deletions
> > 
> > diff -puN mm/mmigrate.c~marcelo-FIX1 mm/mmigrate.c
> > --- linux-2.6.9-rc4/mm/mmigrate.c~marcelo-FIX1	Tue Nov 16 10:43:56 2004
> > +++ linux-2.6.9-rc4-taka/mm/mmigrate.c	Tue Nov 16 11:07:10 2004
> > @@ -114,14 +114,14 @@ int migration_remove_entry(swp_entry_t e
> >  
> >  	lock_page(page);	
> >  
> > -	migration_remove_reference(page);
> > +	migration_remove_reference(page, 1);
> >  
> >  	unlock_page(page);
> >  
> >  	page_cache_release(page);
> >  }
> >  
> > -int migration_remove_reference(struct page *page)
> > +int migration_remove_reference(struct page *page, int dec)
> >  {
> >  	struct counter *c;
> >  	swp_entry_t entry;
> > @@ -134,10 +134,9 @@ int migration_remove_reference(struct pa
> >  
> >  	read_unlock_irq(&migration_space.tree_lock);
> >  
> > -	if (!c->i)
> > -		BUG();
> > +	BUG_ON(c->i < dec);
> >  
> > -	c->i--;
> > +	c->i -= dec;
> >  
> >  	if (!c->i) {
> >  		remove_from_migration_cache(page, page->private);
> > @@ -146,6 +145,15 @@ int migration_remove_reference(struct pa
> >  	}
> >  }
> >  
> > +int detach_from_migration_cache(struct page *page)
> > +{
> > +	lock_page(page);	
> > +	migration_remove_reference(page, 0);
> > +	unlock_page(page);
> > +
> > +	return 0;
> > +}
> > +
> >  int add_to_migration_cache(struct page *page, int gfp_mask) 
> >  {
> >  	int error, offset;
> > @@ -522,7 +530,9 @@ generic_migrate_page(struct page *page, 
> >  
> >  	/* map the newpage where the old page have been mapped. */
> >  	touch_unmapped_address(&vlist);
> > -	if (PageSwapCache(newpage)) {
> > +	if (PageMigration(newpage))
> > +		detach_from_migration_cache(newpage);
> > +	else if (PageSwapCache(newpage)) {
> >  		lock_page(newpage);
> >  		__remove_exclusive_swap_page(newpage, 1);
> >  		unlock_page(newpage);
> 
> I dont see this code on 2.6.9-rc2-mm4-mhp, I should upgrade.
> 
> > @@ -538,7 +548,9 @@ out_busy:
> >  	/* Roll back all operations. */
> >  	unwind_page(page, newpage);
> >  	touch_unmapped_address(&vlist);
> > -	if (PageSwapCache(page)) {
> > +	if (PageMigration(page))
> > +		detach_from_migration_cache(page);
> > +	else if (PageSwapCache(page)) {
> >  		lock_page(page);
> >  		__remove_exclusive_swap_page(page, 1);
> >  		unlock_page(page);
> > @@ -550,6 +562,8 @@ out_removing:
> >  		BUG();
> >  	unlock_page(page);
> >  	unlock_page(newpage);
> > +	if (PageMigration(page))
> > +		detach_from_migration_cache(page);
> >  	return ret;
> >  }
> >  
> > diff -puN mm/vmscan.c~marcelo-FIX1 mm/vmscan.c
> > --- linux-2.6.9-rc4/mm/vmscan.c~marcelo-FIX1	Mon Nov 15 12:20:35 2004
> > +++ linux-2.6.9-rc4-taka/mm/vmscan.c	Tue Nov 16 11:06:06 2004
> > @@ -459,6 +459,10 @@ int shrink_list(struct list_head *page_l
> >  			goto keep_locked;
> >  		}
> >  
> > +		if (PageMigration(page)) {
> > +			write_unlock_irq(&mapping->tree_lock);
> > +			goto keep_locked;
> > +		}
> >  #ifdef CONFIG_SWAP
> >  		if (PageSwapCache(page)) {
> >  			swp_entry_t swap = { .val = page->private };
> > diff -puN mm/memory.c~marcelo-FIX1 mm/memory.c
> > --- linux-2.6.9-rc4/mm/memory.c~marcelo-FIX1	Tue Nov 16 11:06:31 2004
> > +++ linux-2.6.9-rc4-taka/mm/memory.c	Tue Nov 16 11:06:57 2004
> > @@ -1621,7 +1621,7 @@ again:
> >  		if (vm_swap_full())
> >  			remove_exclusive_swap_page(page);
> >  	} else {
> > -		migration_remove_reference(page);
> > +		migration_remove_reference(page, 1);
> >  	}
> >  
> >  	mm->rss++;
> > _
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
