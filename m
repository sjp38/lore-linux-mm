Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 585B66B00B6
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 10:04:04 -0500 (EST)
Date: Tue, 24 Feb 2009 15:03:28 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 11/20] Inline get_page_from_freelist() in the fast-path
Message-ID: <20090224150327.GB5364@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <200902240232.39140.nickpiggin@yahoo.com.au> <20090224133253.GB26239@csn.ul.ie> <200902250108.11664.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200902250108.11664.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 25, 2009 at 01:08:10AM +1100, Nick Piggin wrote:
> On Wednesday 25 February 2009 00:32:53 Mel Gorman wrote:
> > On Tue, Feb 24, 2009 at 02:32:37AM +1100, Nick Piggin wrote:
> > > On Monday 23 February 2009 10:17:20 Mel Gorman wrote:
> > > > In the best-case scenario, use an inlined version of
> > > > get_page_from_freelist(). This increases the size of the text but
> > > > avoids time spent pushing arguments onto the stack.
> > >
> > > I'm quite fond of inlining ;) But it can increase register pressure as
> > > well as icache footprint as well. x86-64 isn't spilling a lot more
> > > registers to stack after these changes, is it?
> >
> > I didn't actually check that closely so I don't know for sure. Is there a
> > handier way of figuring it out than eyeballing the assembly? In the end
> 
> I guess the 5 second check is to look at how much stack the function
> uses. OTOH I think gcc does do a reasonable job at register allocation.
> 

FWIW, 6 registers get pushed onto the stack from the calling function from
a glance of the assembly. According to the profile, about 7% of the cost of
the get_page_from_freelist() function is incurred by setting up and making
the function call. This is 2755 samples out of 35266. To compare, the cost
of zeroing was 192574 samples.

So, it's a good chunk of time, but in the grand scheme of things, time is
better spent optimising elsewhere for now.

> 
> > I dropped the inline of this function anyway. It means the patches
> > reduce rather than increase text size which is a bit more clear-cut.
> 
> Cool, clear cut patches for round 1 should help to get things moving.
> 

Indeed

> 
> > > In which case you will get extra icache footprint. What speedup does
> > > it give in the cache-hot microbenchmark case?
> >
> > I wasn't measuring with a microbenchmark at the time of writing so I don't
> > know. I was going entirely by profile counts running kernbench and the
> > time spent running the benchmark.
> 
> OK. Well seeing as you have dropped this for the moment, let's not
> dwell on it ;)
> 

Agreed.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
