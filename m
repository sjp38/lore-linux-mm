Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5741C600337
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 18:26:21 -0400 (EDT)
Date: Wed, 7 Apr 2010 00:26:13 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Downsides to madvise/fadvise(willneed) for application startup
Message-ID: <20100406222613.GB28964@cmpxchg.org>
References: <4BBA6776.5060804@mozilla.com> <20100406095135.GB5183@cmpxchg.org> <4BBBAE4A.7070000@mozilla.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BBBAE4A.7070000@mozilla.com>
Sender: owner-linux-mm@kvack.org
To: Taras Glek <tglek@mozilla.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 02:57:30PM -0700, Taras Glek wrote:
> On 04/06/2010 02:51 AM, Johannes Weiner wrote:
> >On Mon, Apr 05, 2010 at 03:43:02PM -0700, Taras Glek wrote:
> >   
> >>Hello,
> >>I am working on improving Mozilla startup times. It turns out that page
> >>faults(caused by lack of cooperation between user/kernelspace) are the
> >>main cause of slow startup. I need some insights from someone who
> >>understands linux vm behavior.
> >>
> >>Current Situation:
> >>The dynamic linker mmap()s  executable and data sections of our
> >>executable but it doesn't call madvise().
> >>By default page faults trigger 131072byte reads. To make matters worse,
> >>the compile-time linker + gcc lay out code in a manner that does not
> >>correspond to how the resulting executable will be executed(ie the
> >>layout is basically random). This means that during startup 15-40mb
> >>binaries are read in basically random fashion. Even if one orders the
> >>binary optimally, throughput is still suboptimal due to the puny 
> >>readahead.
> >>
> >>IO Hints:
> >>Fortunately when one specifies madvise(WILLNEED) pagefaults trigger 2mb
> >>reads and a binary that tends to take 110 page faults(ie program stops
> >>execution and waits for disk) can be reduced down to 6. This has the
> >>potential to double application startup of large apps without any clear
> >>downsides. Suse ships their glibc with a dynamic linker patch to
> >>fadvise() dynamic libraries(not sure why they switched from doing
> >>madvise before).
> >>
> >>I filed a glibc bug about this at
> >>http://sourceware.org/bugzilla/show_bug.cgi?id=11431 . Uli commented
> >>with his concern about wasting memory resources. What is the impact of
> >>madvise(WILLNEED) or the fadvise equivalent on systems under memory
> >>pressure? Does the kernel simply start ignoring these hints?
> >>     
> >It will throttle based on memory pressure.  In idle situations it will
> >eat your file cache, however, to satisfy the request.
> >   
> Define idle situations. Do you mean that madv(willneed) will aggresively 
> readahead, but only while cpu(or disk?) is idle?
> I am trying to optimize application startup which means that the cpu is 
> busy while not blocked on io.

Sorry.  I meant without memory pressure.  It will trigger readahead for the
whole page range immediately, unless the sum of free pages and file cache
pages is less than that.

So yes, it will be aggressive against the cache but should not touch things
frequently in use or start swapping for example.

> >>Also, once an application is started is it reasonable to keep it
> >>madvise(WILLNEED)ed or should the madvise flags be reset?
> >>     
> >It's a one-time operation that starts immediate readahead, no permanent
> >changes are done.
> >   
> I may be measuring this wrong, but in my experience the only change 
> madvise(willneed) does in increase the length parameter to 
> __do_page_cache_readahead(). My script is at 
> http://hg.mozilla.org/users/tglek_mozilla.com/startup/file/6453ad2a7906/kernelio.stp
> .

Whether the page is read on a major fault or by means of WILLNEED,
they both end up calling this function.  It's just that faulting
does all the heuristics and WILLNEED will just force reading the
pages in the specified range.

But your question whether it would be reasonable to keep the region
WILLNEED madvised makes no sense.  It's just a request to prepopulate
the page cache from disk data immediately instead of waiting for
faults to trigger the reads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
