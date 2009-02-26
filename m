Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0644C6B0055
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 11:37:59 -0500 (EST)
Date: Thu, 26 Feb 2009 16:37:51 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
Message-ID: <20090226163751.GG32756@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-21-git-send-email-mel@csn.ul.ie> <20090223013723.1d8f11c1.akpm@linux-foundation.org> <20090223233030.GA26562@csn.ul.ie> <20090223155313.abd41881.akpm@linux-foundation.org> <20090224115126.GB25151@csn.ul.ie> <20090224160103.df238662.akpm@linux-foundation.org> <20090225160124.GA31915@csn.ul.ie> <20090225081954.8776ba9b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090225081954.8776ba9b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, hannes@cmpxchg.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Feb 25, 2009 at 08:19:54AM -0800, Andrew Morton wrote:
> On Wed, 25 Feb 2009 16:01:25 +0000 Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > ...
> >
> > > That would rub out the benefit which that microbenchmark
> > > demonstrated?
> > > 
> > 
> > It'd impact it for sure. Due to the non-temporal stores, I'm surprised
> > there is any measurable impact from the patch.  This has likely been the
> > case since commit 0812a579c92fefa57506821fa08e90f47cb6dbdd. My reading of
> > this (someone correct/enlighten) is that even if the data was cache hot,
> > it is pushed out as a result of the non-temporal access.
> 
> yup, that's my understanding.
> 
> > The changelog doesn't give the reasoning for using uncached accesses but maybe
> > it's because for filesystem writes, it is not expected that the data will be
> > accessed by the CPU any more and the storage device driver has less work to
> > do to ensure the data in memory is not dirty in cache (this is speculation,
> > I don't know for sure what the expected benefit is meant to be but it might
> > be in the manual, I'll check later).
> > 
> > Thinking of alternative microbenchmarks that might show this up....
> 
> Well, 0812a579c92fefa57506821fa08e90f47cb6dbdd is beeing actively
> discussed over in the "Performance regression in write() syscall"
> thread.  There are patches there which disable the movnt for
> less-than-PAGE_SIZE copies.  Perhaps adapt those to disable movnt
> altogether to then see whether the use of movnt broke the advantages
> which hot-cold-pages gave us?
> 

I checked just what that patch was doing with write-truncate and the results
show that using temporal access for small files appeared to have a huge
positive difference for the microbenchmark. It also showed that hot/cold
freeing (i.e. the current code) was a gain when temporal accesses were used
but then I saw a big problem with the benchmark.

The deviations between runs are huge - really huge and I had missed that
before. I redid the test to run a larger number of iterations and then 20
times in a row on a kernel with hot/cold freeing and I got;

size          avg   stddev
      64 3.337564 0.619085
     128 2.753963 0.461398
     256 2.556934 0.461848
     512 2.736831 0.475484
    1024 2.561668 0.470887
    2048 2.719766 0.478039
    4096 2.963039 0.407311
    8192 4.043475 0.236713
   16384 6.098094 0.249132
   32768 9.439190 0.143978

where size is the size of the write/truncate, avg is the average time and the
stddev is the standard deviation. For small sizes, it's too massive to draw
any reasonable conclusion from the microbenchmark. Factors like scheduling,
whether sync happened and a host of other issues muck up the results.

More importantly, I then checked how many times we freed cold pages during
the test and the answer is ..... *never*. They were all hot page releases
which is what my patch originally forced and the profiles agreed because they
showed no samples in the "if (cold)" branch. Cold pages were only freed if I
made kswapd kick off which was my original expectation as a system reclaiming
is currently polluting cache with scanning so it's not important.

Based on that nugget, the patch makes common sense because we never take the
cold branch at a time we care. Common sense also tells me the patch should
be an improvement because pagevec is smaller. Proving it's a good change is
not working out very well at all.

> argh.
> 
> Sorry to be pushing all this kernel archeology at you.

Don't be. This was time well spent in my opinion.

> Sometimes I
> think we're insufficiently careful about removing old stuff - it can
> turn out that it wasn't that bad after all!  (cf slab.c...)
> 

Agreed. Better safe than sorry.

> > Repeated setup, populate and teardown of pagetables might show up something
> > as it should benefit if the pages were cache hot but the cost of faulting
> > and zeroing might hide it.
> 
> Well, pagetables have been churning for years, with special-cased
> magazining, quicklists, magazining of known-to-be-zeroed pages, etc.
> 

The known-to-be-zeroed pages is interesting and something I tried but didn't
get far enough with. One patch I did but didn't release would zero pages on
the free path if the was process exiting or if it was kswapd.  It tracked if
the page was zero using page->index to record the order of the zerod page. On
allocation, it would check index and if a matching order, would not zero a
second time. I got this working for order-0 pages reliably but it didn't gain
anything because we were zeroing even more than we had to in the free path.

I should have gone at the pagetable pages as a source of zerod pages that
required no additional work and said "screw it, I'll release what I have
and see what happens".

> I've always felt that we're doing that wrong, or at least awkwardly. 
> If the magazining which the core page allocator does is up-to-snuff
> then it _should_ be usable for pagetables.
> 

If pagetable pages were known to be zero and handed back to the allocator
that remember zerod pages, I bet we'd get a win.

> The magazining of known-to-be-zeroed pages is a new requirement. 

They don't even need a separate magazine. Put them back on the lists and
record if they are zero with page->index. Granted, it means a caller will
sometimes get pages that are zerod when they don't need to be but I think
it'd be better than larger structures or searches.

> But
> it absolutely should not be done private to the pagetable page
> allocator (if it still is - I forget), because there are other
> callsites in the kernel which want cache-hot zeroed pages, and there
> are probably other places which free up known-to-be-zeroed pages.
> 

Agreed. I believe we can do it in the allocator too using page->index if I
am understanding you properly.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
