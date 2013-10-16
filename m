Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 75D856B0031
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 02:55:35 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so443196pdj.8
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 23:55:35 -0700 (PDT)
Received: by mail-ee0-f41.google.com with SMTP id b15so103278eek.28
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 23:55:31 -0700 (PDT)
Date: Wed, 16 Oct 2013 08:55:26 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v8 0/9] rwsem performance optimizations
Message-ID: <20131016065526.GB22509@gmail.com>
References: <cover.1380748401.git.tim.c.chen@linux.intel.com>
 <1380753493.11046.82.camel@schen9-DESK>
 <20131003073212.GC5775@gmail.com>
 <1381186674.11046.105.camel@schen9-DESK>
 <20131009061551.GD7664@gmail.com>
 <1381336441.11046.128.camel@schen9-DESK>
 <20131010075444.GD17990@gmail.com>
 <1381882156.11046.178.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381882156.11046.178.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Jason Low <jason.low2@hp.com>, Waiman Long <Waiman.Long@hp.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> On Thu, 2013-10-10 at 09:54 +0200, Ingo Molnar wrote:
> > * Tim Chen <tim.c.chen@linux.intel.com> wrote:
> > 
> > > The throughput of pure mmap with mutex is below vs pure mmap is below:
> > > 
> > > % change in performance of the mmap with pthread-mutex vs pure mmap
> > > #threads        vanilla 	all rwsem    	without optspin
> > > 				patches
> > > 1               3.0%    	-1.0%   	-1.7%
> > > 5               7.2%    	-26.8%  	5.5%
> > > 10              5.2%    	-10.6%  	22.1%
> > > 20              6.8%    	16.4%   	12.5%
> > > 40              -0.2%   	32.7%   	0.0%
> > > 
> > > So with mutex, the vanilla kernel and the one without optspin both run 
> > > faster.  This is consistent with what Peter reported.  With optspin, the 
> > > picture is more mixed, with lower throughput at low to moderate number 
> > > of threads and higher throughput with high number of threads.
> > 
> > So, going back to your orignal table:
> > 
> > > % change in performance of the mmap with pthread-mutex vs pure mmap
> > > #threads        vanilla all     without optspin
> > > 1               3.0%    -1.0%   -1.7%
> > > 5               7.2%    -26.8%  5.5%
> > > 10              5.2%    -10.6%  22.1%
> > > 20              6.8%    16.4%   12.5%
> > > 40              -0.2%   32.7%   0.0%
> > >
> > > In general, vanilla and no-optspin case perform better with 
> > > pthread-mutex.  For the case with optspin, mmap with pthread-mutex is 
> > > worse at low to moderate contention and better at high contention.
> > 
> > it appears that 'without optspin' appears to be a pretty good choice - if 
> > it wasn't for that '1 thread' number, which, if I correctly assume is the 
> > uncontended case, is one of the most common usecases ...
> > 
> > How can the single-threaded case get slower? None of the patches should 
> > really cause noticeable overhead in the non-contended case. That looks 
> > weird.
> > 
> > It would also be nice to see the 2, 3, 4 thread numbers - those are the 
> > most common contention scenarios in practice - where do we see the first 
> > improvement in performance?
> > 
> > Also, it would be nice to include a noise/sttdev figure, it's really hard 
> > to tell whether -1.7% is statistically significant.
> 
> Ingo,
> 
> I think that the optimistic spin changes to rwsem should enhance 
> performance to real workloads after all.
> 
> In my previous tests, I was doing mmap followed immediately by 
> munmap without doing anything to the memory.  No real workload
> will behave that way and it is not the scenario that we 
> should optimize for.  A much better approximation of
> real usages will be doing mmap, then touching 
> the memories being mmaped, followed by munmap.  

That's why I asked for a working testcase to be posted ;-) Not just 
pseudocode - send the real .c thing please.

> This changes the dynamics of the rwsem as we are now dominated by read 
> acquisitions of mmap sem due to the page faults, instead of having only 
> write acquisitions from mmap. [...]

Absolutely, the page fault read case is the #1 optimization target of 
rwsems.

> [...] In this case, any delay in write acquisitions will be costly as we 
> will be blocking a lot of readers.  This is where optimistic spinning on 
> write acquisitions of mmap sem can provide a very significant boost to 
> the throughput.
> 
> I change the test case to the following with writes to
> the mmaped memory:
> 
> #define MEMSIZE (1 * 1024 * 1024)
> 
> char *testcase_description = "Anonymous memory mmap/munmap of 1MB";
> 
> void testcase(unsigned long long *iterations)
> {
>         int i;
> 
>         while (1) {
>                 char *c = mmap(NULL, MEMSIZE, PROT_READ|PROT_WRITE,
>                                MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
>                 assert(c != MAP_FAILED);
>                 for (i=0; i<MEMSIZE; i+=8) {
>                         c[i] = 0xa;
>                 }
>                 munmap(c, MEMSIZE);
> 
>                 (*iterations)++;
>         }
> }

It would be _really_ nice to stick this into tools/perf/bench/ as:

	perf bench mem pagefaults

or so, with a number of parallelism and workload patterns. See 
tools/perf/bench/numa.c for a couple of workload generators - although 
those are not page fault intense.

So that future generations can run all these tests too and such.

> I compare the throughput where I have the complete rwsem patchset 
> against vanilla and the case where I take out the optimistic spin patch.  
> I have increased the run time by 10x from my pervious experiments and do 
> 10 runs for each case.  The standard deviation is ~1.5% so any changes 
> under 1.5% is statistically significant.
> 
> % change in throughput vs the vanilla kernel.
> Threads	all	No-optspin
> 1		+0.4%	-0.1%
> 2		+2.0%	+0.2%
> 3		+1.1%	+1.5%
> 4		-0.5%	-1.4%
> 5		-0.1%	-0.1%
> 10		+2.2%	-1.2%
> 20		+237.3%	-2.3%
> 40		+548.1%	+0.3%

The tail is impressive. The early parts are important as well, but it's 
really hard to tell the significance of the early portion without having 
an sttdev column.

( "perf stat --repeat N" will give you sttdev output, in handy percentage 
  form. )

> Now when I test the case where we acquire mutex in the
> user space before mmap, I got the following data versus
> vanilla kernel.  There's little contention on mmap sem 
> acquisition in this case.
> 
> n	all	No-optspin
> 1	+0.8%	-1.2%
> 2	+1.0%	-0.5%
> 3	+1.8%	+0.2%
> 4	+1.5%	-0.4%
> 5	+1.1%	+0.4%
> 10	+1.5%	-0.3%
> 20	+1.4%	-0.2%
> 40	+1.3%	+0.4%
> 
> Thanks.

A bit hard to see as there's no comparison _between_ the pthread_mutex and 
plain-parallel versions. No contention isn't a great result if performance 
suffers because it's all serialized.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
