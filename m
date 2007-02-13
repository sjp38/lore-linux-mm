Date: Tue, 13 Feb 2007 22:40:39 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] build error: allnoconfig fails on mincore/swapper_space
In-Reply-To: <20070213121217.0f4e9f3a.randy.dunlap@oracle.com>
Message-ID: <Pine.LNX.4.64.0702132224280.3729@blonde.wat.veritas.com>
References: <20070212145040.c3aea56e.randy.dunlap@oracle.com>
 <20070212150802.f240e94f.akpm@linux-foundation.org> <45D12715.4070408@yahoo.com.au>
 <20070213121217.0f4e9f3a.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, tony.luck@gmail.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Feb 2007, Randy Dunlap wrote:
> On Tue, 13 Feb 2007 13:48:53 +1100 Nick Piggin wrote:
> > Andrew Morton wrote:
> > >>On Mon, 12 Feb 2007 14:50:40 -0800 Randy Dunlap <randy.dunlap@oracle.com> wrote:
> > >>2.6.20-git8 on x86_64:
> > >>
> > >>
> > >>  LD      init/built-in.o
> > >>  LD      .tmp_vmlinux1
> > >>mm/built-in.o: In function `sys_mincore':
> > >>(.text+0xe584): undefined reference to `swapper_space'
> > >>make: *** [.tmp_vmlinux1] Error 1
> > > 
> > > 
> > > oops.  CONFIG_SWAP=n,  I assume?
> > > 
> > 
> > Hmm, OK. Hugh can strip me of my bonus point now...

No, Nick, you get to keep your bonus point, it was for remembering
migration pages.  I was the devil who tempted you into using
find_get_page(&swapper_space,).

> > 
> > Hugh, you can strip me of my bonus point now... How about your other
> > suggestion to just remove the stats from lookup_swap_cache? (and should
> > we also rename it to find_get_swap_page?)

Not at this point.  I won't mind you putting up a patch doing that for
discussion and inclusion in -mm (if you do, then read_swap_cache_async
should use it too), but it's not now an appropriate fix to the
CONFIG_SWAP=n build issue.

> 
> I need a fix for this.  It's killing my daily/automated builds.
> So here is an ifdeffery-fix.

Sorry for being so slow to respond on this.  Yes, I'm inclined to
your ifdeffery fix - one can go cleverer, but I'd say it's the
appropriate fix now.

But, please change your "present = 0;" to "present = 1;" -
if CONFIG_SWAP isn't on, it has to be a migration entry,
which always counts as present.

> 
> BUT:  what is <present> used for in that loop?  or is it used?

Well spotted!  Something has gone missing: there needs to be a
			vec[i] = present;
at the bottom of that loop.

Hugh

> 
> ---
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Don't check for pte swap entries when CONFIG_SWAP=n.
> 
> mm/built-in.o: In function `sys_mincore':
> (.text+0xe584): undefined reference to `swapper_space'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  mm/mincore.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> --- linux-2.6.20-git8.orig/mm/mincore.c
> +++ linux-2.6.20-git8/mm/mincore.c
> @@ -111,6 +111,7 @@ static long do_mincore(unsigned long add
>  			present = mincore_page(vma->vm_file->f_mapping, pgoff);
>  
>  		} else { /* pte is a swap entry */
> +#ifdef CONFIG_SWAP
>  			swp_entry_t entry = pte_to_swp_entry(pte);
>  			if (is_migration_entry(entry)) {
>  				/* migration entries are always uptodate */
> @@ -119,6 +120,9 @@ static long do_mincore(unsigned long add
>  				pgoff = entry.val;
>  				present = mincore_page(&swapper_space, pgoff);
>  			}
> +#else
> +			present = 0;
> +#endif
>  		}
>  	}
>  	pte_unmap_unlock(ptep-1, ptl);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
