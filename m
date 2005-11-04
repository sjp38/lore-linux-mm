Date: Fri, 4 Nov 2005 17:05:05 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051104160505.GA7689@elte.hu>
References: <20051104151842.GA5745@elte.hu> <20051104153903.E5D561845FF@thermo.lanl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051104153903.E5D561845FF@thermo.lanl.gov>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Nelson <andy@thermo.lanl.gov>
Cc: akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, nickpiggin@yahoo.com.au, pj@sgi.com, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

* Andy Nelson <andy@thermo.lanl.gov> wrote:

> Ingo wrote:
> >ok, this posting of you seems to be it:
> 
> > <elided>
> 
> >to me it seems that this slowdown is due to some inefficiency in the
> >R12000's TLB-miss handling - possibly very (very!) long TLB-miss
> >latencies? On modern CPUs (x86/x64) the TLB-miss latency is rarely
> >visible. Would it be possible to run some benchmarks of hugetlbs vs. 4K
> >pages on x86/x64?
> >
> >if my assumption is correct, then hugeTLBs are more of a workaround for
> >bad TLB-miss properties of the CPUs you are using, not something that
> >will inevitably happen in the future. Hence i think the 'factor 3x'
> >slowdown should not be realistic anymore - or are you still running
> >R12000 CPUs?
> 
> >        Ingo
> 
> 
> AFAIK, mips chips have a software TLB refill that takes 1000 cycles 
> more or less. I could be wrong. [...]

x86 in comparison has a typical cost of 7 cycles per TLB miss. And a 
modern x64 chip has 1024 TLBs ... If that's not enough then i believe 
you'll be limited by cachemiss costs and RAM latency/throughput anyway, 
and the only thing the TLB misses have to do is to be somewhat better 
than those bottlenecks. TLBs are really fast in the x86/x64 world. Then 
there come other features like TLB prefetch, so if you are touching 
pages in any predictable fashion you ought to see better latencies than 
the worst-case.

> The effect is not a consequence of any excessively long tlb handling 
> times for one single arch.
> 
> The effect is a property of the code. Which has one part that is 
> extremely branchy: traversing a tree, and another part that isn't 
> branchy but grabs stuff from all over everywhere.

i dont think anyone argues against the fact that a larger 'TLB reach' 
will most likely improve performance. The question is always 'by how 
much', and that number very much depends on the cost of a single TLB 
miss. (and on alot of other factors)

(note that it's also possible for large TLBs to cause a slowdown: there 
are CPUs [e.g. P3] where there are fewer large TLBs than 4K TLBs, so 
there are workloads where you lose due to fewer TLBs. It is also 
possible for large TLBs to be zero speedup: if the working set is so 
large that you will always get a TLB miss with a new node accessed.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
