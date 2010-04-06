Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 353CD6B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 07:38:35 -0400 (EDT)
Date: Tue, 6 Apr 2010 07:35:42 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100406113542.GC5218@think>
References: <patchbomb.1270168887@v2.random>
 <20100405120906.0abe8e58.akpm@linux-foundation.org>
 <20100405193616.GA5125@elte.hu>
 <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com>
 <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
 <20100405210133.GE21620@think>
 <4BBA53A0.8050608@redhat.com>
 <20100406083028.GA17882@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100406083028.GA17882@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 09:30:28AM +0100, Mel Gorman wrote:
> On Tue, Apr 06, 2010 at 12:18:24AM +0300, Avi Kivity wrote:
> > On 04/06/2010 12:01 AM, Chris Mason wrote:
> >> On Mon, Apr 05, 2010 at 01:32:21PM -0700, Linus Torvalds wrote:
> >>    
> >>>
> >>> On Mon, 5 Apr 2010, Pekka Enberg wrote:
> >>>      
> >>>> AFAIK, most modern GCs split memory in young and old generation
> >>>> "zones" and _copy_ surviving objects from the former to the latter if
> >>>> their lifetime exceeds some threshold. The JVM keeps scanning the
> >>>> smaller young generation very aggressively which causes TLB pressure
> >>>> and scans the larger old generation less often.
> >>>>        
> >>> .. my only input to this is: numbers talk, bullsh*t walks.
> >>>
> >>> I'm not interested in micro-benchmarks, either. I can show infinite TLB
> >>> walk improvement in a microbenchmark.
> >>>      
> >> Ok, I'll bite.  I should be able to get some database workloads with
> >> hugepages, transparent hugepages, and without any hugepages at all.
> >>    
> >
> > Please run them in conjunction with Mel Gorman's memory compaction,  
> > otherwise fragmentation may prevent huge pages from being instantiated.
> >
> 
> Strictly speaking, compaction is not necessary to allocate huge pages.
> What compaction gets you is
> 
>   o Lower latency and cost of huge page allocation
>   o Works on swapless systems
> 
> What is important is that you run
> hugeadm --set-recommended-min_free_kbytes
> from the libhugetlbfs 2.8 package early in boot so that
> anti-fragmentation is doing as good as job as possible.

Great, I'll make sure to do this.

> If one is very
> curious, use the mm_page_alloc_extfrag to trace how often severe
> fragmentation-related events occur under default settings and with
> min_free_kbytes set properly.
> 
> Without the compaction patches, allocating huge pages will be occasionally
> *very* expensive as a large number of pages will need to be reclaimed.
> Most likely sympton is trashing while the database starts up. Allocation
> success rates will also be lower when under heavy load.
> 
> Running make -j16 at the same time is unlikely to make much of a
> difference from a hugepage allocation point of view. The performance
> figures will vary significantly of course as make competes with the
> database for CPU time and other resources.

Heh, Linus did actually say to run them concurrently with make -j16, but
I read it as make -j16 before the database run.  My goal will be to
fragment the ram, then get a db in ram and see how fast it all goes.

Fragmenting memory during the run is only interesting to test compaction, I'd
throw out the resulting db benchmark numbers and only count the
number of transparent hugepages we were able to allocate.

> 
> Finally, benchmarking with databases is not new as such -
> http://lwn.net/Articles/378641/ . This was on fairly simple hardware
> though as I didn't have access to hardware more suitable for database
> workloads. If you are running with transparent huge pages though, be
> sure to double check that huge pages are actually being used
> transparently.

Will do.  It'll take me a few days to get the machines setup and a
baseline measurement.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
