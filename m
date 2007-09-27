Date: Thu, 27 Sep 2007 15:21:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kswapd should only wait on IO if there is IO
Message-Id: <20070927152121.3f5b6830.akpm@linux-foundation.org>
In-Reply-To: <20070927181325.21aae460@bree.surriel.com>
References: <20070927170816.055548fd@bree.surriel.com>
	<20070927144702.a9124c7a.akpm@linux-foundation.org>
	<20070927181325.21aae460@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Sep 2007 18:13:25 -0400
Rik van Riel <riel@redhat.com> wrote:

> On Thu, 27 Sep 2007 14:47:02 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Thu, 27 Sep 2007 17:08:16 -0400
> > Rik van Riel <riel@redhat.com> wrote:
> > 
> > > The current kswapd (and try_to_free_pages) code has an oddity where the
> > > code will wait on IO, even if there is no IO in flight.  This problem is
> > > notable especially when the system scans through many unfreeable pages,
> > > causing unnecessary stalls in the VM.
> > > 
> > 
> > What effect did this change have?
> 
> Kswapd was no longer sitting in "D" state as often and pages got
> freed more promptly.  The test was done on a RHEL kernel with
> this change though - I guess I should redo it with a current upstream
> kernel.

OK.  Yes, it should help quite a bit in the common cases.

> > >  
> > >  		/* Take a nap, wait for some writeback to complete */
> > > -		if (sc.nr_scanned && priority < DEF_PRIORITY - 2)
> > > +		if (sc.nr_scanned && priority < DEF_PRIORITY - 2 &&
> > > +				sc.nr_io_pages > sc.swap_cluster_max)
> > 
> > The comparison with swap_cluster_max is unobvious, and merits a
> > comment.  What is the thinking here?  
> 
> If the number of pages undergoing IO is really small, waiting
> for them may be a waste of time.
> 
> Maybe my thinking is wrong, not sure...

The thinking sounds good to me, but I'm looking for weirdo side-effects in
corner cases.  And I'm trying to work out what actual design we want to
have behind these various magic numbers and thresholds.

> > Also, we now have this:
> > 
> > 		if (total_scanned > sc.swap_cluster_max +
> > 					sc.swap_cluster_max / 2) {
> > 			wakeup_pdflush(laptop_mode ? 0 : total_scanned);
> > 			sc.may_writepage = 1;
> > 		}
> > 
> > 		/* Take a nap, wait for some writeback to complete */
> > 		if (sc.nr_scanned && priority < DEF_PRIORITY - 2 && 
> >					sc.nr_io_pages > sc.swap_cluster_max)
> > 			congestion_wait(WRITE, HZ/10);
> > 
> > 
> > So in the case where total_scanned has not yet reached
> > swap_cluster_max, this process isn't initiating writeout and it isn't
> > sleeping, either.  Nor is it incrementing nr_io_pages.
> 
> Actually, nr_io_pages is also incremented when we run into pages that
> are already PageWriteback - even if we did not start the IO ourselves.

OK, that'll help a lot in this scenario.

> > In the range (swap_cluster_max < nr_io_pages < 1.5*swap_cluster_max) this
> > process still isn't incrementing nr_io_pages, but it _is_ running
> > congestion_wait().
> 
> It is incrementing sc.nr_io_pages and will wait on IO to complete if
> the amount of pages in flight to disk that it scanned over is larger
> than the number of pages that it is trying to free.
> 
> > Once nr_io_pages exceeds 1.5*swap_cluster_max, this process is both
> > initiating IO and is throttling on writeback completion events.
> > 
> > This all seems a bit weird and arbitrary - what is the reason for
> > throttling-but-not-writing in that 1.0->1.5 window?
> 
> Good question.  Note that the throttling-but-not-writing window in
> the current code is 0.0->1.5, so this patch does reduce the throttling
> window compared to the current code.
> 
> What is the reason that the current code does IO throttling even if
> there is no IO at all in flight?

Buggered if I know ;)

It may have the accidental effect that it opens a window in which some
may_enter_fs-capable process can get scheduled and do some writeout,
perhaps.

> > If there _is_ a reason and it's all been carefully thought out and
> > designed, then can we please capture a description of that design in the
> > changelog or in the code?
> 
> I'll add a description for the sc.nr_io_pages > sc.swap_cluster_max
> test.

OK, thanks.  Perhaps a few words tacked onto the nr_io_pages definition
site would be the place to capture this.

> > Also, I wonder about what this change will do to the dynamic behaviour of
> > GFP_NOFS direct-reclaimers.  Previously they would throttle if they
> > encounter dirty pages which they can't write out.  Hopefully someone else
> > (kswapd or a __GFP_FS direct-reclaimer) will write some of those pages
> > and this caller will be woken when that writeout completes and will go off
> > and scoop them off the tail of the LRU.
> > 
> > But after this change, such a GFP_NOFS caller will, afacit, burn its way
> > through potentially the entire inactive list and will then declare oom. 
> 
> Nope, sc.nr_io_pages will also be incremented when the code runs into
> pages that are already PageWriteback.

yup, I didn't think of that.  Hopefully someone else will be in there
working on that zone too.  If this caller yields and defers to kswapd
then that's very likely.  Except we just took away the ability to do that..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
