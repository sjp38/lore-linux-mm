Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CFF646B0055
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 23:42:46 -0500 (EST)
Date: Tue, 3 Mar 2009 05:42:40 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
Message-ID: <20090303044239.GC3973@wotan.suse.de>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie> <1235639427.11390.11.camel@minggr> <20090226110336.GC32756@csn.ul.ie> <1235647139.16552.34.camel@penberg-laptop> <20090226112232.GE32756@csn.ul.ie> <1235724283.11610.212.camel@minggr> <20090302112122.GC21145@csn.ul.ie> <20090302113936.GJ1257@wotan.suse.de> <20090302121632.GA14217@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090302121632.GA14217@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lin Ming <ming.m.lin@intel.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 02, 2009 at 12:16:33PM +0000, Mel Gorman wrote:
> On Mon, Mar 02, 2009 at 12:39:36PM +0100, Nick Piggin wrote:
> > > Perfect, thanks a lot for profiling this. It is a big help in figuring out
> > > how the allocator is actually being used for your workloads.
> > > 
> > > The OLTP results had the following things to say about the page allocator.
> > 
> > Is this OLTP, or UDP-U-4K?
> > 
> 
> OLTP. I didn't do a comparison for UDP due to uncertainity of what I was
> looking at other than to note that high-order allocations may be a
> bigger deal there.

OK.


> > > Question 1: Would it be possible to increase the sample rate and track cache
> > > misses as well please?
> > 
> > If the events are constantly biased, I don't think sample rate will
> > help. I don't know how the internals of profiling counters work exactly,
> > but you would expect yes cache misses, and stalls from any number of
> > different resources could put results in funny places.
> > 
> 
> Ok, if it's stalls that are the real factor then yes, increasing the
> sample rate might not help. However, the same rates for instructions
> were so low, I thought it might be a combination of both low sample
> count and stalls happening at particular places. A profile of cache
> misses will still be useful as it'll say in general if there is a marked
> increase overall or not.

OK.


> > Intel's OLTP workload is very sensitive to cacheline footprint of the
> > kernel, and if you touch some extra cachelines at point A, it can just
> > result in profile hits getting distributed all over the place. Profiling
> > cache misses might help, but probably see a similar phenomenon.
> > 
> 
> Interesting, this might put a hole in replacing the gfp_zone() with a
> version that uses an additional (or maybe two depending on alignment)
> cacheline.

Well... I still think it is probably a good idea. Firstly is that
it probably saves a line of icache too. Secondly, I guess adding a
*single* extra readonly cacheline is probably not such a problem
even for this workload. I was more thinking of if you changed the
pattern in which pages are allocated (ie. like the hot/cold thing),
or if some change resulted in more cross-cpu operations then it
could result in worse cache efficiency.

But you never know, it might be one patch to look at.


> > I can't remember, does your latest patchset include any patches that change
> > the possible order in which pages move around? Or is it just made up of
> > straight-line performance improvement of existing implementation?
> > 
> 
> It shouldn't affect order. I did a test a while ago to make sure pages
> were still coming back in contiguous order as some IO cards depend on this
> behaviour for performance. The intention for the first pass is a straight-line
> performance improvement.

OK, but the dynamic behaviour too. Free page A, free page B, allocate page
A allocate page B etc.

The hot/cold removal would be an obvious example of what I mean, although
that wasn't included in this recent patchset anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
