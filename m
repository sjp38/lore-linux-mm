Date: Fri, 4 Nov 2005 21:12:48 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051104201248.GA14201@elte.hu>
References: <20051104170359.80947184684@thermo.lanl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051104170359.80947184684@thermo.lanl.gov>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Nelson <andy@thermo.lanl.gov>
Cc: torvalds@osdl.org, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

* Andy Nelson <andy@thermo.lanl.gov> wrote:

> The problem is a different configuration of particles, and about 2 
> times bigger (7Million) than the one in comp.arch (3million I think). 
> I would estimate that the data set in this test spans something like 
> 2-2.5GB or so.
> 
> Here are the results:
> 
> cpus    4k pages   16m pages
> 1       4888.74s   2399.36s
> 2       2447.68s   1202.71s
> 4       1225.98s    617.23s
> 6        790.05s    418.46s
> 8        592.26s    310.03s
> 12       398.46s    210.62s
> 16       296.19s    161.96s

interesting, and thanks for the numbers. Even if hugetlbs were only 
showing a 'mere' 5% improvement, a 5% _user-space improvement_ is still 
a considerable improvement that we should try to achieve, if possible 
cheaply.

the 'separate hugetlb zone' solution is cheap and simple, and i believe 
it should cover your needs of mixed hugetlb and smallpages workloads.

it would work like this: unlike the current hugepages=<nr> boot 
parameter, this zone would be useful for other (4K sized) allocations 
too. If an app requests a hugepage then we have the chance to allocate 
it from the hugetlb zone, in a guaranteed way [up to the point where the 
whole zone consists of hugepages only].

the architectural appeal in this solution is that no additional 
"fragmentation prevention" has to be done on this zone, because we only 
allow content into it that is "easy" to flush - this means that there is 
no complexity drag on the generic kernel VM.

can you think of any reason why the boot-time-configured hugetlb zone 
would be inadequate for your needs?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
