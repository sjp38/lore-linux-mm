Message-ID: <3D2E08DE.3C0D619@zip.com.au>
Date: Thu, 11 Jul 2002 15:38:22 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Optimize out pte_chain take three
References: <3D2DF5CB.471024F9@zip.com.au> <Pine.LNX.4.44L.0207111837060.14432-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Thu, 11 Jul 2002, Andrew Morton wrote:
> > Rik van Riel wrote:
> 
> > > > I looked at 2.4-ac as well.  Seems that the dropbehind there only
> > > > addresses reads?
> > >
> > > It should also work on linear writes.
> >
> > The only call site for drop_behind() in -ac is generic_file_readahead().
> 
> generic_file_write() calls deactivate_page() if it crosses
> the page boundary (ie. if it is done writing this page)

Ah, OK.  I tried lots of those sorts of things.  But fact is
that moving the unwanted pages to the far of the inactive list
just isn't effective: pagecache which will be used at some time
in the future always ends up getting evicted.

> > > > I suspect the best fix here is to not have dirty or writeback
> > > > pagecache pages on the LRU at all.  Throttle on memory coming
> > > > reclaimable, put the pages back on the LRU when they're clean,
> > > > etc.  As we have often discussed.  Big change.
> > >
> > > That just doesn't make sense, if you don't put the dirty pages
> > > on the LRU then what incentive _do_ you have to write them out ?
> >
> > We have dirty page accounting.  If the page reclaim code decides
> > there's too much dirty memory then kick pdflush, and sleep on
> > IO completion's movement of reclaimable pages back onto the LRU.
> 
> At what point in the LRU ?

Interesting question.  If those pages haven't been moved to the
active list and if they're not referenced then one could just
reclaim them as soon as IO completes.   After all, that's basically
what we do now.
 
> Are you proposing to reclaim free pages before considering
> dirty pages ?

Well that would be a lower-latency implementation.  And given
that the machine is known to be sloshing pagecache pages at
a great rate, accuracy of replacement of those pages probably
isn't very important.

But yes, at some point you do need to stop carving away at the
clean pagecache and wait on writeback completion.  Not sure
how to balance that.
 
> > Making page reclaimers perform writeback in shrink_cache()
> > just has awful latency problems.  If we don't do that then
> > there's just no point in keeping those pages on the LRU
> > because all we do is scan past them and blow cycles.
> 
> Why does it have latency problems ?

Because the request queue may be full.   Page allocators
spend tons of time in get_request_wait.  Always have.

However it just occurs to me that we're doing bad things
in there.  Note how blkdev_release_request only wakes
a waiter when 32 requests are available.  That basically
guarantees a 0.3 second sleep.   If we kill the batch_requests
concept then the sleep time becomes just

	nr_flushing_processes * request interval

ie: 0.01 to 0.02 seconds.  hmm.  Yes.  Ouch.  Ugh.

Suppose you're running a massive `dd of=foo'.  Some innocent
task tries to allocate a page and hits a dirty one.  It
sleeps in get_request_wait().  dd is sleeping there too.
Now 32 requests complete and both tasks get woken.  The innocent
page allocator starts running again.  And `dd' immediately jams
another 32 requests into the queue.  It's very unfair.

> Keeping them on the LRU _does_ make sense since we know
> when we want to evict these pages.  Putting them aside
> on a laundry list might make sense though, provided that
> they are immediately made a candidate for replacement
> after IO completion.

Yes, well that's basically what we do now, if you're referring
to PageWriteback (used to be PageLocked) pages.  We just shove
them onto the far end of the LRU and hope they don't come back
until IO completes. 

> > > ...
> > > If the throttling is wrong, I propose we fix the trottling.
> >
> > How?  (Without adding more list scanning)
> 
> For one, we shouldn't let every process go into
> try_to_free_pages() and check for itself if the
> pages really aren't freeable.

mm.  Well we do want processes to go in and reclaim their own
pages normally, to avoid a context switch (I guess.  No numbers
to back this up).   But if that reclaimer then hits a PageDirty
or PageWriteback page then yup, he needs to ask pdflush to do
some IO and then he needs to sleep on *any* page becoming freeable,
not *that* page.

But I think killing batch_requests may make all this rather better.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
