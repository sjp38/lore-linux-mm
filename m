Date: Thu, 11 Jul 2002 20:18:25 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Optimize out pte_chain take three
In-Reply-To: <3D2E08DE.3C0D619@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207112011150.14432-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jul 2002, Andrew Morton wrote:

> > generic_file_write() calls deactivate_page() if it crosses
> > the page boundary (ie. if it is done writing this page)
>
> Ah, OK.  I tried lots of those sorts of things.  But fact is
> that moving the unwanted pages to the far of the inactive list
> just isn't effective: pagecache which will be used at some time
> in the future always ends up getting evicted.

There's no way around that, unless you know your application
workload well enough to be able to predict the future.


> But yes, at some point you do need to stop carving away at the
> clean pagecache and wait on writeback completion.  Not sure
> how to balance that.

Keeping all the pages on the same LRU would be a start.
There's no reason you couldn't start (or even finish)
writeout of the dirty pages before they reach the end
of the LRU.  If a page is still dirty when it reaches
the end of the LRU it can be moved aside onto a laundry
list, from where it gets freed after IO completes.

As soon as you start putting dirty pages on a different
LRU list we'll almost certainly lose the ability to
balance things.


> Suppose you're running a massive `dd of=foo'.  Some innocent
> task tries to allocate a page and hits a dirty one.  It
> sleeps in get_request_wait().  dd is sleeping there too.
> Now 32 requests complete and both tasks get woken.  The innocent
> page allocator starts running again.  And `dd' immediately jams
> another 32 requests into the queue.  It's very unfair.

Fixing this unfairness when the queue is "almost full"
is probably a useful thing to do.


> > Keeping them on the LRU _does_ make sense since we know
> > when we want to evict these pages.  Putting them aside
> > on a laundry list might make sense though, provided that
> > they are immediately made a candidate for replacement
> > after IO completion.
>
> Yes, well that's basically what we do now, if you're referring
> to PageWriteback (used to be PageLocked) pages.  We just shove
> them onto the far end of the LRU and hope they don't come back
> until IO completes.

Which is wrong, not only because these pages have reached the
end of the LRU and want to get replaced, but also because we
just don't want to go through the trouble of scanning them
again.

This would be a good place to catch these pages and put them
on a separate list from which they go to the free list once
IO completes.


> > > > ...
> > > > If the throttling is wrong, I propose we fix the trottling.
> > >
> > > How?  (Without adding more list scanning)
> >
> > For one, we shouldn't let every process go into
> > try_to_free_pages() and check for itself if the
> > pages really aren't freeable.
>
> mm.  Well we do want processes to go in and reclaim their own
> pages normally, to avoid a context switch (I guess.  No numbers
> to back this up).

Falling from __alloc_pages into the pageout path shouldn't be
part of the fast path.  If it is we have bigger problems...


> But I think killing batch_requests may make all this rather better.

Probably.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
