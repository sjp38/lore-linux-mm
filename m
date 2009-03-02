Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 945106B00DC
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 06:39:42 -0500 (EST)
Date: Mon, 2 Mar 2009 12:39:36 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
Message-ID: <20090302113936.GJ1257@wotan.suse.de>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie> <1235639427.11390.11.camel@minggr> <20090226110336.GC32756@csn.ul.ie> <1235647139.16552.34.camel@penberg-laptop> <20090226112232.GE32756@csn.ul.ie> <1235724283.11610.212.camel@minggr> <20090302112122.GC21145@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090302112122.GC21145@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lin Ming <ming.m.lin@intel.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 02, 2009 at 11:21:22AM +0000, Mel Gorman wrote:
> (Added Ingo as a second scheduler guy as there are queries on tg_shares_up)
> 
> On Fri, Feb 27, 2009 at 04:44:43PM +0800, Lin Ming wrote:
> > On Thu, 2009-02-26 at 19:22 +0800, Mel Gorman wrote: 
> > > In that case, Lin, could I also get the profiles for UDP-U-4K please so I
> > > can see how time is being spent and why it might have gotten worse?
> > 
> > I have done the profiling (oltp and UDP-U-4K) with and without your v2
> > patches applied to 2.6.29-rc6.
> > I also enabled CONFIG_DEBUG_INFO so you can translate address to source
> > line with addr2line.
> > 
> > You can download the oprofile data and vmlinux from below link,
> > http://www.filefactory.com/file/af2330b/
> > 
> 
> Perfect, thanks a lot for profiling this. It is a big help in figuring out
> how the allocator is actually being used for your workloads.
> 
> The OLTP results had the following things to say about the page allocator.

Is this OLTP, or UDP-U-4K?

 
> Samples in the free path
> 	vanilla:	6207
> 	mg-v2:		4911
> Samples in the allocation path
> 	vanilla		19948
> 	mg-v2:		14238
> 
> This is based on glancing at the following graphs and not counting the VM
> counters as it can't be determined which samples are due to the allocator
> and which are due to the rest of the VM accounting.
> 
> http://www.csn.ul.ie/~mel/postings/lin-20090228/free_pages-vanilla-oltp.png
> http://www.csn.ul.ie/~mel/postings/lin-20090228/free_pages-mgv2-oltp.png
> 
> So the path costs are reduced in both cases. Whatever caused the regression
> there doesn't appear to be in time spent in the allocator but due to
> something else I haven't imagined yet. Other oddness
> 
> o According to the profile, something like 45% of time is spent entering
>   the __alloc_pages_nodemask() function. Function entry costs but not
>   that much. Another significant part appears to be in checking a simple
>   mask. That doesn't make much sense to me so I don't know what to do with
>   that information yet.
> 
> o In get_page_from_freelist(), 9% of the time is spent deleting a page
>   from the freelist.
> 
> Neither of these make sense, we're not spending time where I would expect
> to at all. One of two things are happening. Something like cache misses or
> bounces are dominating for some reason that is specific to this machine. Cache
> misses are one possibility that I'll check out. The other is that the sample
> rate is too low and the profile counts are hence misleading.
> 
> Question 1: Would it be possible to increase the sample rate and track cache
> misses as well please?

If the events are constantly biased, I don't think sample rate will
help. I don't know how the internals of profiling counters work exactly,
but you would expect yes cache misses, and stalls from any number of
different resources could put results in funny places.

Intel's OLTP workload is very sensitive to cacheline footprint of the
kernel, and if you touch some extra cachelines at point A, it can just
result in profile hits getting distributed all over the place. Profiling
cache misses might help, but probably see a similar phenomenon.

I can't remember, does your latest patchset include any patches that change
the possible order in which pages move around? Or is it just made up of
straight-line performance improvement of existing implementation?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
