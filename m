Date: Thu, 03 Feb 2005 11:49:39 +0900 (JST)
Message-Id: <20050203.114939.26983020.taka@valinux.co.jp>
Subject: Re: migration cache, updated
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20050117095955.GC18785@logos.cnet>
References: <20041201202101.GB5459@dmt.cyclades>
	<20041208.222307.64517559.taka@valinux.co.jp>
	<20050117095955.GC18785@logos.cnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi Marcelo,

Very sorry for the delayed response.

> Hi Hirokazu,
> 
> On Wed, Dec 08, 2004 at 10:23:07PM +0900, Hirokazu Takahashi wrote:
> > Hi Marcelo,
> > > > > Sorry for the delay, been busy with other things.
> > > > 
> > > > No problem. Everyone knows you're doing hard work!
> > 
> > > > > > Therefore, I made pages removed from the migration cache
> > > > > > at the end of generic_migrate_page() if they remain in the cache.
> > > 
> > > OK, removing migration pages at end of generic_migrate_page() should 
> > > avoid the leak - that part of your patch is fine to me!
> > > 
> > > > > > The another is a fork() related problem. If fork() has occurred
> > > > > > during page migrationa, the previous work may not go well.
> > > > > > pages may not be removed from the migration cache.
> > > 
> > > Can you please expand on that one? I assume it works fine because 
> > > copy_page_range() duplicates the migration page reference (and the 
> > > migration pte), meaning that on exit (zap_pte_range) the migration
> > > pages should be removed through migration_remove_entry(). 
> > 
> > Yes, that's true.
> > 
> > > I dont see the problem - please correct me.
> > 
> > However, once the page is moved into the migration cache,
> > no one can make it swapped out. This problem may be solved
> > by your approach described below.
> > 
> > > > > > So I made the swapcode ignore pages in the migration cache.
> > > > > > However, as you know this is just a workaround and not a correct
> > > > > > way to fix it.
> > > 
> > > What this has to do with fork()? I can't understand.
> > 
> > fork() may leave some pages in the migration cache with my
> > latest implementation, though the memory migration code
> > tries to remove them from the migration cache by forcible
> > pagefault in touch_unmapped_address().
> 
> Why are record_unmapped_address/touch_unmapped_address needed ? 

There are two reasons.
  1. Migrated pages should be mapped to the process space soon
     if they're mlocked. Or the pages might be swapped out as
     the swap code doesn't care about them if they aren't mapped.

  2. Without this, migrated pages will consume entries of
     the migration cache until the process which the pages
     belong to has died.
     And if they're kept in the migration cache, the pages cannot
     be swapped out even if free pages might become few, as you
     mentioned below.

     Previously this is designed to not consume swap entries
     on real devices.

> I started investigating the issue which migration pages couldnt 
> be swapped out, but found out that migration pages are never left 
> in the cache because touch_unmapped_address recreates the ptes removing
> the pages from the migration cache.

Yes. This is the one of the purpose.

> That means we have no problem with migration cache pages left pinned 
> (unswappable) in memory, which means it is fully functional AFAICT.
> 
> However, I thought the intent was to fault the pages on demand? 

Yes, you're absolutely right.
If there is another better way, I'm pleased to replace it.

> I even wrote this to be called at vmscan() time but touch_unmapped_address 
> already has similar functionality at migration time.

Interesting.
It would work pretty good if fork() is invoked during memory migration.
My touch_unmapped_address approach can't handle this case.

But I'm worried about two things.

 - I wonder if mlocked pages can be handled correctly.
   What would happen if the page has been mlocked and it also belongs
   to the swap cache even though this case is very very rare?

 - I'm not sure deriving anon_vma from the page is always correct
   while it isn't mapped to anywhere.

> int try_to_faultin(struct page *page)
> {
>         struct anon_vma *anon_vma;
>         struct vm_area_struct *vma;
>         unsigned long address;
>         int ret = 0;
> 
> restart:
>         anon_vma = page_lock_anon_vma(page);
>         if (!anon_vma)
>                 return ret;
> 
>         list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
>                 address = vma_address(page, vma);
>                 // handle if (address = -EFAULT) ? 
>                 if (!follow_and_check_present(vma->vm_mm, address))
>                         continue;
> 
>                 spin_unlock(&anon_vma->lock);
>                 switch (handle_mm_fault(vma->vm_mm, vma, address, 0)) {
>                 case VM_FAULT_MINOR:
>                         goto restart;
>                 case VM_FAULT_MAJOR:
>                         BUG();
>                 case VM_FAULT_SIGBUS:
>                 case VM_FAULT_OOM:
>                         goto out_unlock;
>                 }
>         }
>         ret = 1;
>         printk(KERN_ERR "faulted migration page in!\n");
> 
> out_unlock:
>         spin_unlock(&anon_vma->lock);
>         return ret;
> 
> }
> 
> 
> > 
> > However, touch_unmapped_address() doesn't know that the
> > migration page has been duplicated.
> > 
> > > Your patch is correct here also - we can't reclaim migration cache 
> > > pages.
> > > 
> > > +	if (PageMigration(page)) {
> > > +		write_unlock_irq(&mapping->tree_lock);
> > > +		goto keep_locked;
> > > +	}
> > > 
> > > An enhancement would be to force pagefault of all pte's
> > > mapping to a migration cache page on shrink_list.  
> > >
> > > similar to rmap.c's try_to_unmap_anon() but intented to create the pte 
> > > instead of unmapping it
> > 
> > If it works as we expect, this code can be called at the end of
> > generic_migrate_page() I guess.
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
