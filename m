Date: Thu, 27 Sep 2007 18:13:25 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] kswapd should only wait on IO if there is IO
Message-ID: <20070927181325.21aae460@bree.surriel.com>
In-Reply-To: <20070927144702.a9124c7a.akpm@linux-foundation.org>
References: <20070927170816.055548fd@bree.surriel.com>
	<20070927144702.a9124c7a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Sep 2007 14:47:02 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 27 Sep 2007 17:08:16 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
> > The current kswapd (and try_to_free_pages) code has an oddity where the
> > code will wait on IO, even if there is no IO in flight.  This problem is
> > notable especially when the system scans through many unfreeable pages,
> > causing unnecessary stalls in the VM.
> > 
> 
> What effect did this change have?

Kswapd was no longer sitting in "D" state as often and pages got
freed more promptly.  The test was done on a RHEL kernel with
this change though - I guess I should redo it with a current upstream
kernel.

> > diff -up linux-2.6.22.x86_64/mm/vmscan.c.wait linux-2.6.22.x86_64/mm/vmscan.c
> > --- linux-2.6.22.x86_64/mm/vmscan.c.wait	2007-09-25 11:33:30.000000000 -0400
> > +++ linux-2.6.22.x86_64/mm/vmscan.c	2007-09-25 21:27:08.000000000 -0400
> > @@ -68,6 +68,8 @@ struct scan_control {
> >  	int all_unreclaimable;
> >  
> >  	int order;
> > +
> > +	int nr_io_pages;
> >  };
> >  
> >  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> > @@ -489,8 +491,10 @@ static unsigned long shrink_page_list(st
> >  			 */
> >  			if (sync_writeback == PAGEOUT_IO_SYNC && may_enter_fs)
> >  				wait_on_page_writeback(page);
> > -			else
> > +			else {
> > +				sc->nr_io_pages++;
> >  				goto keep_locked;
> > +			}
> >  		}
> >  
> >  		referenced = page_referenced(page, 1);
> > @@ -541,8 +545,10 @@ static unsigned long shrink_page_list(st
> >  			case PAGE_ACTIVATE:
> >  				goto activate_locked;
> >  			case PAGE_SUCCESS:
> > -				if (PageWriteback(page) || PageDirty(page))
> > +				if (PageWriteback(page) || PageDirty(page)) {
> > +					sc->nr_io_pages++;
> >  					goto keep;
> > +				}
> >  				/*
> >  				 * A synchronous write - probably a ramdisk.  Go
> >  				 * ahead and try to reclaim the page.
> > @@ -1201,6 +1207,7 @@ unsigned long try_to_free_pages(struct z
> >  
> >  	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> >  		sc.nr_scanned = 0;
> > +		sc.nr_io_pages = 0;
> >  		if (!priority)
> >  			disable_swap_token();
> >  		nr_reclaimed += shrink_zones(priority, zones, &sc);
> > @@ -1229,7 +1236,8 @@ unsigned long try_to_free_pages(struct z
> >  		}
> >  
> >  		/* Take a nap, wait for some writeback to complete */
> > -		if (sc.nr_scanned && priority < DEF_PRIORITY - 2)
> > +		if (sc.nr_scanned && priority < DEF_PRIORITY - 2 &&
> > +				sc.nr_io_pages > sc.swap_cluster_max)
> 
> The comparison with swap_cluster_max is unobvious, and merits a
> comment.  What is the thinking here?  

If the number of pages undergoing IO is really small, waiting
for them may be a waste of time.

Maybe my thinking is wrong, not sure...

> Also, we now have this:
> 
> 		if (total_scanned > sc.swap_cluster_max +
> 					sc.swap_cluster_max / 2) {
> 			wakeup_pdflush(laptop_mode ? 0 : total_scanned);
> 			sc.may_writepage = 1;
> 		}
> 
> 		/* Take a nap, wait for some writeback to complete */
> 		if (sc.nr_scanned && priority < DEF_PRIORITY - 2 && 
>					sc.nr_io_pages > sc.swap_cluster_max)
> 			congestion_wait(WRITE, HZ/10);
> 
> 
> So in the case where total_scanned has not yet reached
> swap_cluster_max, this process isn't initiating writeout and it isn't
> sleeping, either.  Nor is it incrementing nr_io_pages.

Actually, nr_io_pages is also incremented when we run into pages that
are already PageWriteback - even if we did not start the IO ourselves.

> In the range (swap_cluster_max < nr_io_pages < 1.5*swap_cluster_max) this
> process still isn't incrementing nr_io_pages, but it _is_ running
> congestion_wait().

It is incrementing sc.nr_io_pages and will wait on IO to complete if
the amount of pages in flight to disk that it scanned over is larger
than the number of pages that it is trying to free.

> Once nr_io_pages exceeds 1.5*swap_cluster_max, this process is both
> initiating IO and is throttling on writeback completion events.
> 
> This all seems a bit weird and arbitrary - what is the reason for
> throttling-but-not-writing in that 1.0->1.5 window?

Good question.  Note that the throttling-but-not-writing window in
the current code is 0.0->1.5, so this patch does reduce the throttling
window compared to the current code.

What is the reason that the current code does IO throttling even if
there is no IO at all in flight?

> If there _is_ a reason and it's all been carefully thought out and
> designed, then can we please capture a description of that design in the
> changelog or in the code?

I'll add a description for the sc.nr_io_pages > sc.swap_cluster_max
test.

> Also, I wonder about what this change will do to the dynamic behaviour of
> GFP_NOFS direct-reclaimers.  Previously they would throttle if they
> encounter dirty pages which they can't write out.  Hopefully someone else
> (kswapd or a __GFP_FS direct-reclaimer) will write some of those pages
> and this caller will be woken when that writeout completes and will go off
> and scoop them off the tail of the LRU.
> 
> But after this change, such a GFP_NOFS caller will, afacit, burn its way
> through potentially the entire inactive list and will then declare oom. 

Nope, sc.nr_io_pages will also be incremented when the code runs into
pages that are already PageWriteback.

 
-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
