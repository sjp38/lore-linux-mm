Date: Thu, 28 Jun 2007 17:19:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
Message-Id: <20070628171922.2c1bd91f.akpm@linux-foundation.org>
In-Reply-To: <46844B83.20901@redhat.com>
References: <8e38f7656968417dfee0.1181332979@v2.random>
	<466C36AE.3000101@redhat.com>
	<20070610181700.GC7443@v2.random>
	<46814829.8090808@redhat.com>
	<20070626105541.cd82c940.akpm@linux-foundation.org>
	<468439E8.4040606@redhat.com>
	<20070628155715.49d051c9.akpm@linux-foundation.org>
	<46843E65.3020008@redhat.com>
	<20070628161350.5ce20202.akpm@linux-foundation.org>
	<4684415D.1060700@redhat.com>
	<20070628162936.9e78168d.akpm@linux-foundation.org>
	<46844B83.20901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jun 2007 20:00:03 -0400
Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> 
> >> Scanning fewer pages in the pageout path is probably
> >> the way to go.
> > 
> > I don't see why that would help.  The bottom-line steady-state case is that
> > we need to reclaim N pages per second, and we need to scan N*M vmas per
> > second to do so.  How we chunk that up won't affect the aggregate amount of
> > work which needs to be done.
> > 
> > Or maybe you're referring to the ongoing LRU balancing thing.  Or to something
> > else.
> 
> Yes, I am indeed talking about LRU balancing.
> 
> We pretty much *know* that an anonymous page on the
> active list is accessed, so why bother scanning them
> all?

Because there might well be pages in there which haven't been accessed in
days.  Confused.

> We could just deactivate the oldest ones and clear
> their referenced bits.
> 
> Once they reach the end of the inactive list, we
> check for the referenced bit again.  If the page
> was accessed, we move it back to the active list.

ok.

> The only problem with this is that anonymous
> pages could be easily pushed out of memory by
> the page cache, because the page cache has
> totally different locality of reference.

I don't immediately see why we need to change the fundamental aging design
at all.   The problems afacit are

a) that huge burst of activity when we hit pages_high and

b) the fact that this huge burst happens on lots of CPUs at the same time.

And balancing the LRUs _prior_ to hitting pages_high can address both
problems?

It will I guess impact the page aging a bit though.

> The page cache also benefits from the use-once
> scheme we have in place today.
> 
> Because of these three reasons, I want to split
> the page cache LRU lists from the anonymous
> memory LRU lists.
> 
> Does this make sense to you?

Could do, don't know.    What new problems will it introduce? :(

> >> No matter how efficient we make the scanning of one
> >> individual page, we simply cannot scan through 1TB
> >> worth of anonymous pages (which are all referenced
> >> because they've been there for a week) in order to
> >> deactivate something.
> > 
> > Sure.  And we could avoid that sudden transition by balancing the LRU prior
> > to hitting the great pages_high wall.
> 
> Yes, we will need to do some preactive balancing.

OK..

And that huge anon-vma walk might need attention.  At the least we could do
something to prevent lots of CPUs from piling up in there.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
