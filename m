Date: Tue, 27 Mar 2007 09:52:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch resend v4] update ctime and mtime for mmaped write
Message-Id: <20070327095220.4bc76cdc.akpm@linux-foundation.org>
In-Reply-To: <E1HW7tS-0003em-00@dorka.pomaz.szeredi.hu>
References: <E1HVZyn-0008T8-00@dorka.pomaz.szeredi.hu>
	<20070326140036.f3352f81.akpm@linux-foundation.org>
	<E1HVwy4-0002UD-00@dorka.pomaz.szeredi.hu>
	<20070326153153.817b6a82.akpm@linux-foundation.org>
	<E1HW5am-0003Mc-00@dorka.pomaz.szeredi.hu>
	<20070326232214.ee92d8c4.akpm@linux-foundation.org>
	<E1HW6Ec-0003Tv-00@dorka.pomaz.szeredi.hu>
	<20070326234957.6b287dda.akpm@linux-foundation.org>
	<E1HW6eb-0003WX-00@dorka.pomaz.szeredi.hu>
	<20070327001834.04dc375e.akpm@linux-foundation.org>
	<E1HW72O-0003ZB-00@dorka.pomaz.szeredi.hu>
	<20070327005150.9177ae02.akpm@linux-foundation.org>
	<E1HW7tS-0003em-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 27 Mar 2007 11:23:06 +0200 Miklos Szeredi <miklos@szeredi.hu> wrote:

> > > > > But Peter Staubach says a RH custumer has files written thorugh mmap,
> > > > > which are not being backed up.
> > > > 
> > > > Yes, I expect the backup problem is the major real-world hurt arising from
> > > > this bug.
> > > > 
> > > > But I expect we could adequately plug that problem at munmap()-time.  Or,
> > > > better, do_wp_page().  As I said - half-assed.
> > > > 
> > > > It's a question if whether the backup problem is the only thing which is hurting
> > > > in the real-world, or if people have other problems.
> > > > 
> > > > (In fact, what's wrong with doing it in do_wp_page()?
> > > 
> > > It's rather more expensive, than just toggling a bit.
> > 
> > It shouldn't be, especially for filesystems which have one-second timestamp
> > granularity.
> > 
> > Filesystems which have s_time_gran=1 might hurt a bit, but no more than
> > they will with write().
> > 
> > Actually, no - we'd only update the mctime once per page per writeback
> > period (30 seconds by default) so the load will be small.
> 
> Why?  For each faulted page the times will be updated, no?

Yes, but only at pagefault-time.  And

- the faults are already "slow": we need to pull the page contents in
  from disk, or memset or cow the page

- we need to take the trap

compared to which, the cost of the timestamp update will (we hope) be
relatively low.

> Maybe it's acceptable, I don't really know the cost of
> file_update_time().
> 
> Tried this patch, and it seems to work.  It will even randomly update
> the time for tmpfs files (on initial fault, and on swapins).
> 
> Miklos
> 
> Index: linux/mm/memory.c
> ===================================================================
> --- linux.orig/mm/memory.c	2007-03-27 11:04:40.000000000 +0200
> +++ linux/mm/memory.c	2007-03-27 11:08:19.000000000 +0200
> @@ -1664,6 +1664,8 @@ gotten:
>  unlock:
>  	pte_unmap_unlock(page_table, ptl);
>  	if (dirty_page) {
> +		if (vma->vm_file)
> +			file_update_time(vma->vm_file);
>  		set_page_dirty_balance(dirty_page);
>  		put_page(dirty_page);
>  	}
> @@ -2316,6 +2318,8 @@ retry:
>  unlock:
>  	pte_unmap_unlock(page_table, ptl);
>  	if (dirty_page) {
> +		if (vma->vm_file)
> +			file_update_time(vma->vm_file);
>  		set_page_dirty_balance(dirty_page);
>  		put_page(dirty_page);
>  	}

that's simpler ;) Is it correct enough though?  The place where it will
become inaccurate is for repeated modification via an established map.  ie:

	p = mmap(..., MAP_SHARED);
	for ( ; ; )
		*p = 1;

in which case I think the timestamp will only get updated once per
writeback interval (ie: 30 seconds).


tmpfs files have an s_time_gran of 1, so benchmarking some workload on
tmpfs with this patch will tell us the worst-case overhead of the change. 

I guess we should arrange for multiple CPUs to perform write faults against
multiple pages of the same file in parallel.  Of course, that'd be a pretty
darn short benchmark because it'll run out of RAM.  Which reveals why we
probably won't have a performance problem in there.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
