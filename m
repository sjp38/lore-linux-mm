Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 73C326B00E5
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 11:01:33 -0500 (EST)
Date: Wed, 25 Feb 2009 16:01:25 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
Message-ID: <20090225160124.GA31915@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-21-git-send-email-mel@csn.ul.ie> <20090223013723.1d8f11c1.akpm@linux-foundation.org> <20090223233030.GA26562@csn.ul.ie> <20090223155313.abd41881.akpm@linux-foundation.org> <20090224115126.GB25151@csn.ul.ie> <20090224160103.df238662.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090224160103.df238662.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, hannes@cmpxchg.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Tue, Feb 24, 2009 at 04:01:03PM -0800, Andrew Morton wrote:
> On Tue, 24 Feb 2009 11:51:26 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > > > Almost the opposite with steady improvements almost all the way through.
> > > > 
> > > > With the patch applied, we are still using hot/cold information on the
> > > > allocation side so I'm somewhat surprised the patch even makes much of a
> > > > difference. I'd have expected the pages being freed to be mostly hot.
> > > 
> > > Oh yeah.  Back in the ancient days, hot-cold-pages was using separate
> > > magazines for hot and cold pages.  Then Christoph went and mucked with
> > > it, using a single queue.  That might have affected things.
> > > 
> > 
> > It might have. The impact is that requests for cold pages can get hot pages
> > if there are not enough cold pages in the queue so readahead could prevent
> > an active process getting cache hot pages. I don't think that would have
> > showed up in the microbenchmark though.
> 
> We switched to doing non-temporal stores in copy_from_user(), didn't
> we? 

We do? I would have missed something like that but luckily I took a profile
of the microbenchmark and what do you know, we spent 17053 profiles samples in
__copy_user_nocache(). It's not quite copy_from_user() but it's close. Thanks
for pointing that out!

For anyone watching, copy_from_user() itself and the functions it calls do
not use non-temporal stores. At least, I am not seeing the nt variants of
mov in the assembly I looked at. __copy_user_nocache() on the other hand
uses movnt and it's called in the generic_file_buffered_write() path which
this micro-benchmark is optimising.

> That would rub out the benefit which that microbenchmark
> demonstrated?
> 

It'd impact it for sure. Due to the non-temporal stores, I'm surprised
there is any measurable impact from the patch.  This has likely been the
case since commit 0812a579c92fefa57506821fa08e90f47cb6dbdd. My reading of
this (someone correct/enlighten) is that even if the data was cache hot,
it is pushed out as a result of the non-temporal access.

The changelog doesn't give the reasoning for using uncached accesses but maybe
it's because for filesystem writes, it is not expected that the data will be
accessed by the CPU any more and the storage device driver has less work to
do to ensure the data in memory is not dirty in cache (this is speculation,
I don't know for sure what the expected benefit is meant to be but it might
be in the manual, I'll check later).

Thinking of alternative microbenchmarks that might show this up....

Repeated setup, populate and teardown of pagetables might show up something
as it should benefit if the pages were cache hot but the cost of faulting
and zeroing might hide it.

Maybe a microbenchmark that creates/deletes many small (or empty) files
or reads large directories might benefit from cache hotness as the slab
pages would have to be allocated, populated and then freed back to the
allocator. I'll give it a shot but alternative suggestions are welcome.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
