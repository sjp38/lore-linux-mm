Date: Wed, 1 Dec 2004 18:21:02 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: migration cache, updated
Message-ID: <20041201202101.GB5459@dmt.cyclades>
References: <20041105151631.GA19473@logos.cnet> <20041116.130718.34767806.taka@valinux.co.jp> <20041123121447.GE4524@logos.cnet> <20041124.192156.73388074.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041124.192156.73388074.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Wed, Nov 24, 2004 at 07:21:56PM +0900, Hirokazu Takahashi wrote:
> Hi Marcelo,

Hi again Hirokazu, finally found sometime to think about this.

> > > Hi Marcelo,
> > > 
> > > I've been testing the memory migration code with your patch.
> > > I found problems and I think the attached patch would
> > > fix some of them.
> > > 
> > > One of the problems is a race condition between add_to_migration_cache()
> > > and try_to_unmap(). Some pages in the migration cache cannot
> > > be removed with the current implementation. Please suppose
> > > a process space might be removed between them. In this case
> > > no one can remove pages the process had from the migration cache,
> > > because they can be removed only when the pagetables pointed
> > > the pages.
> > 
> > I guess I dont fully understand you Hirokazu.
> > 
> > unmap_vmas function (called by exit_mmap) calls zap_pte_range, 
> > and that does:
> > 
> >                         if (pte_is_migration(pte)) {
> >                                 migration_remove_entry(swp_entry);
> >                         } else
> >                                 free_swap_and_cache(swp_entry);
> > 
> > migration_remove_entry should decrease the IDR counter, and 
> > remove the migration cache page on zero reference.
> > 
> > Am I missing something?
> 
> That's true only if the pte points a migration entry.
> However, the pte may not point it when zap_pte_range() is called
> in some case.
> 
> Please suppose the following flow.
> Any process may exit or munmap during memory migration
> before calling set_pte(migration entry). This will
> keep some unreferenced pages in the migration cache.
> No one can remove these pages.
> 
>   <start page migration>                  <Process A>
>         |                                      |
>         |                                      |
>         |                                      |
>  add_to_migration_cache()                      |
>     insert a page of Process A  ----------->   |
>     in the migration cache.                    |
>         |                                      |
>         |                               zap_pte_range()
>         |                   X <------------ migration_remove_entry()
>         |                      the pte associated with the page doesn't
>         |                      point any migration entries.

OK, I see it, its the "normal" anonymous pte which will be removed at
this point.

>         |
>         |
>  try_to_unmap() -----------------------> X
>      migration_duplicate()       no pte mapping the page can be found.
>      set_pte(migration entry)
>         |
>         |
>  migrate_fn()
>         |
>         |
>     <finish>
>          the page still remains in the migration cache.
> 	 the page may be referred by no process.
> 
> 
> > I assume you are seeing this problems in practice?
> 
> Yes, it often happens without the patch.
> 
> > Sorry for the delay, been busy with other things.
> 
> No problem. Everyone knows you're doing hard work!
> 
> > > Therefore, I made pages removed from the migration cache
> > > at the end of generic_migrate_page() if they remain in the cache.

OK, removing migration pages at end of generic_migrate_page() should 
avoid the leak - that part of your patch is fine to me!

> > > The another is a fork() related problem. If fork() has occurred
> > > during page migration, the previous work may not go well.
> > > pages may not be removed from the migration cache.

Can you please expand on that one? I assume it works fine because 
copy_page_range() duplicates the migration page reference (and the 
migration pte), meaning that on exit (zap_pte_range) the migration
pages should be removed through migration_remove_entry(). 

I dont see the problem - please correct me.

> > > So I made the swapcode ignore pages in the migration cache.
> > > However, as you know this is just a workaround and not a correct
> > > way to fix it.

What this has to do with fork()? I can't understand.

Your patch is correct here also - we can't reclaim migration cache 
pages.

+	if (PageMigration(page)) {
+		write_unlock_irq(&mapping->tree_lock);
+		goto keep_locked;
+	}

An enhancement would be to force pagefault of all pte's
mapping to a migration cache page on shrink_list.  

similar to rmap.c's try_to_unmap_anon() but intented to create the pte 
instead of unmapping it

        anon_vma = page_lock_anon_vma(page);

        list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
		ret = try_to_faultin(page, vma);

And try_to_faultin() calling handle_mm_fault()...

Is that what you mean?

Anyways, does the migration cache survive your stress testing now 
with these changes ? 

I've coded the beginning of skeleton for the nonblocking version of migrate_onepage().

Can you generate a new migration cache patch on top of linux-2.6.10-rc1-mm2-mhp2 
with your fixes ?

Thanks!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
