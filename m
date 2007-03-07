Date: Wed, 7 Mar 2007 04:52:35 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/2] mm: mlocked pages off LRU
Message-ID: <20070307035235.GC6054@wotan.suse.de>
References: <Pine.LNX.4.64.0703050948040.6620@schroedinger.engr.sgi.com> <20070306010529.GB23845@wotan.suse.de> <Pine.LNX.4.64.0703051723240.16842@schroedinger.engr.sgi.com> <20070306014403.GD23845@wotan.suse.de> <Pine.LNX.4.64.0703051753070.16964@schroedinger.engr.sgi.com> <20070306021307.GE23845@wotan.suse.de> <Pine.LNX.4.64.0703051845050.17203@schroedinger.engr.sgi.com> <20070306025016.GA1912@wotan.suse.de> <20070306143045.GA28629@wotan.suse.de> <1173219835.20580.15.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1173219835.20580.15.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, Christoph Lameter <clameter@engr.sgi.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 06, 2007 at 05:23:55PM -0500, Lee Schermerhorn wrote:
> On Tue, 2007-03-06 at 15:30 +0100, Nick Piggin wrote: 
> > New core patch. This one is actually tested and works, and you can see
> > the mlocked pages being accounted.
> > 
> > Same basic idea. Too many fixes and changes to list. Haven't taken up
> > Christoph's idea to do a union in struct page, but it could be a followup.
> > 
> > Most importantly (aside from crashes and obvious bugs), it should correctly
> > synchronise munlock vs vmscan lazy mlock now. Before this, it was possible
> > to have pages leak. This took me a bit of thinking to get right, but was
> > rather simple in the end.
> > 
> > Memory migration should work now, too, but not tested.
> > 
> > What do people think? Yes? No?
> 
> Nick:  I've grabbed your 2 patches in this series and rebased them to
> 21-rc2-mm2 so I can test them and compare with Christoph's [which I've
> also rebased to -mm2].  I had to fix up the ia32_setup_arg_pages() for
> ia64 to track the change you made to install_new_arg_page.  Patch
> included below.  Some comments in-line below, as well.

Thanks Lee!

> Now builds, boots, and successfully builds a kernel with Christoph's
> series.  Some basic testing with memtoy [see link below] shows pages
> being locked according to the /proc/meminfo stats, but the counts don't
> decrease when I unmap the segment nor when I exit the task.  I'll
> investigate why and let you know how further testing goes.  After that,

OK, It works here (not memtoy, but a simple mlock/munlock program), so
that's interesting if you can work it out.

> > +/*
> > + * Zero the page's mlock_count. This can be useful in a situation where
> > + * we want to unconditionally remove a page from the pagecache.
> > + *
> > + * It is not illegal to call this function for any page, mlocked or not.
> Maybe "It is legal ..."  ???

Yeah ;)

> > Index: linux-2.6/include/linux/page-flags.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/page-flags.h
> > +++ linux-2.6/include/linux/page-flags.h
> > @@ -91,6 +91,7 @@
> >  #define PG_nosave_free		18	/* Used for system suspend/resume */
> >  #define PG_buddy		19	/* Page is free, on buddy lists */
> >  
> > +#define PG_mlock		20	/* Page has mlocked vmas */
> 
> Conflicts with PG_readahead in 21-rc2-mm2.  I temporarily used bit
> 30--valid only for 64-bit systems.  [Same in Christoph's series.]

OK, I'll sort that out when it gets more merge worthy.

> > @@ -438,17 +400,25 @@ int setup_arg_pages(struct linux_binprm 
> >  		mm->stack_vm = mm->total_vm = vma_pages(mpnt);
> >  	}
> >  
> > +	ret = 0;
> >  	for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
> >  		struct page *page = bprm->page[i];
> >  		if (page) {
> >  			bprm->page[i] = NULL;
> > -			install_arg_page(mpnt, page, stack_base);
> > +			if (!ret)
> > +				ret = install_new_anon_page(mpnt, page,
> > +								stack_base);
> > +			if (ret)
> > +				put_page(page);
> 
> Need similar mod in arch/ia64/ia32/binfmt_elf32.c:ia32_setup_arg_pages()
> Patch included below.

Thanks. I need to split out the install_arg_page change too.

> > @@ -272,6 +272,8 @@ static int migrate_page_move_mapping(str
> >  		return 0;
> >  	}
> >  
> > +	clear_page_mlock(page);
> > +
> >  	write_lock_irq(&mapping->tree_lock);
> >  
> >  	pslot = radix_tree_lookup_slot(&mapping->page_tree,
> > @@ -775,6 +777,17 @@ static int do_move_pages(struct mm_struc
> >  				!migrate_all)
> >  			goto put_and_set;
> >  
> > +		/*
> > +		 * Just do the simple thing and put back mlocked pages onto
> > +		 * the LRU list so they can be taken off again (inefficient
> > +		 * but not a big deal).
> > +		 */
> > +		if (PageMLock(page)) {
> > +			lock_page(page);
> > +			clear_page_mlock(page);
> Note that this will put the page into the lru pagevec cache
> [__clear_page_mlock() above] where isolate_lru_page(), called from
> migrate_page_add(), is unlikely to find it.  do_move_pages() has already
> called migrate_prep() to drain the lru caches so that it is more likely
> to find the pages, as does check_range() when called to collect pages
> for migration.  Yes, this is already racy--the target task or other
> threads therein can fault additional pages into the lru cache after call
> to migrate_prep().  But this almost guarantees we'll miss ~ the last
> PAGEVEC_SIZE pages.

Yeah I realised this :P I guess we could do another flush if the page
was mlocked?

> > @@ -254,12 +258,24 @@ static int check_pte_range(struct vm_are
> >  
> >  		if (flags & MPOL_MF_STATS)
> >  			gather_stats(page, private, pte_dirty(*pte));
> > -		else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> > +		else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
> > +			if (PageMLock(page) && !mlocked) {
> > +				mlocked = page;
> > +				break;
> > +			}
> >  			migrate_page_add(page, private, flags);
> > -		else
> > +		} else
> >  			break;
> >  	} while (pte++, addr += PAGE_SIZE, addr != end);
> >  	pte_unmap_unlock(orig_pte, ptl);
> > +
> > +	if (mlocked) {
> > +		lock_page(mlocked);
> > +		clear_page_mlock(mlocked);
> 
> Same comment as for do_move_pages() above.

Yeah, thanks. I should really also be using a pagevec for these guys,
so that we don't have to break out of the loop so frequently. Not that
I was optimising for mlocked pages, but this loop sucks, as is ;)

> Here's the patch mentioned above:
> 
> Need to replace call to install_arg_page() in ia64's
> ia32 version of setup_arg_pages() to build 21-rc2-mm2
> with Nick's "mlocked pages off LRU" patch on ia64. 
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Cheers, thanks.

> 
>  arch/ia64/ia32/binfmt_elf32.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> Index: Linux/arch/ia64/ia32/binfmt_elf32.c
> ===================================================================
> --- Linux.orig/arch/ia64/ia32/binfmt_elf32.c	2007-03-06 12:16:33.000000000 -0500
> +++ Linux/arch/ia64/ia32/binfmt_elf32.c	2007-03-06 15:19:02.000000000 -0500
> @@ -240,7 +240,11 @@ ia32_setup_arg_pages (struct linux_binpr
>  		struct page *page = bprm->page[i];
>  		if (page) {
>  			bprm->page[i] = NULL;
> -			install_arg_page(mpnt, page, stack_base);
> +			if (!ret)
> +				ret = install_new_anon_page(mpnt, page,
> +								stack_base);
> +			if (ret)
> +				put_page(page);
>  		}
>  		stack_base += PAGE_SIZE;
>  	}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
