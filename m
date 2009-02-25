Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E6B796B00E7
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 11:20:40 -0500 (EST)
Date: Wed, 25 Feb 2009 08:19:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
Message-Id: <20090225081954.8776ba9b.akpm@linux-foundation.org>
In-Reply-To: <20090225160124.GA31915@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
	<1235344649-18265-21-git-send-email-mel@csn.ul.ie>
	<20090223013723.1d8f11c1.akpm@linux-foundation.org>
	<20090223233030.GA26562@csn.ul.ie>
	<20090223155313.abd41881.akpm@linux-foundation.org>
	<20090224115126.GB25151@csn.ul.ie>
	<20090224160103.df238662.akpm@linux-foundation.org>
	<20090225160124.GA31915@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, hannes@cmpxchg.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Wed, 25 Feb 2009 16:01:25 +0000 Mel Gorman <mel@csn.ul.ie> wrote:

> ...
>
> > That would rub out the benefit which that microbenchmark
> > demonstrated?
> > 
> 
> It'd impact it for sure. Due to the non-temporal stores, I'm surprised
> there is any measurable impact from the patch.  This has likely been the
> case since commit 0812a579c92fefa57506821fa08e90f47cb6dbdd. My reading of
> this (someone correct/enlighten) is that even if the data was cache hot,
> it is pushed out as a result of the non-temporal access.

yup, that's my understanding.

> The changelog doesn't give the reasoning for using uncached accesses but maybe
> it's because for filesystem writes, it is not expected that the data will be
> accessed by the CPU any more and the storage device driver has less work to
> do to ensure the data in memory is not dirty in cache (this is speculation,
> I don't know for sure what the expected benefit is meant to be but it might
> be in the manual, I'll check later).
> 
> Thinking of alternative microbenchmarks that might show this up....

Well, 0812a579c92fefa57506821fa08e90f47cb6dbdd is beeing actively
discussed over in the "Performance regression in write() syscall"
thread.  There are patches there which disable the movnt for
less-than-PAGE_SIZE copies.  Perhaps adapt those to disable movnt
altogether to then see whether the use of movnt broke the advantages
which hot-cold-pages gave us?

argh.

Sorry to be pushing all this kernel archeology at you.  Sometimes I
think we're insufficiently careful about removing old stuff - it can
turn out that it wasn't that bad after all!  (cf slab.c...)

> Repeated setup, populate and teardown of pagetables might show up something
> as it should benefit if the pages were cache hot but the cost of faulting
> and zeroing might hide it.

Well, pagetables have been churning for years, with special-cased
magazining, quicklists, magazining of known-to-be-zeroed pages, etc.

I've always felt that we're doing that wrong, or at least awkwardly. 
If the magazining which the core page allocator does is up-to-snuff
then it _should_ be usable for pagetables.

The magazining of known-to-be-zeroed pages is a new requirement.  But
it absolutely should not be done private to the pagetable page
allocator (if it still is - I forget), because there are other
callsites in the kernel which want cache-hot zeroed pages, and there
are probably other places which free up known-to-be-zeroed pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
