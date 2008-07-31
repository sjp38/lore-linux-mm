Date: Thu, 31 Jul 2008 14:50:16 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Message-ID: <20080731135016.GG1704@csn.ul.ie>
References: <cover.1216928613.git.ebmunson@us.ibm.com> <200807311626.15709.nickpiggin@yahoo.com.au> <20080731112734.GE1704@csn.ul.ie> <200807312151.56847.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200807312151.56847.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Munson <ebmunson@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On (31/07/08 21:51), Nick Piggin didst pronounce:
> On Thursday 31 July 2008 21:27, Mel Gorman wrote:
> > On (31/07/08 16:26), Nick Piggin didst pronounce:
> 
> > > I imagine it should be, unless you're using a CPU with seperate TLBs for
> > > small and huge pages, and your large data set is mapped with huge pages,
> > > in which case you might now introduce *new* TLB contention between the
> > > stack and the dataset :)
> >
> > Yes, this can happen particularly on older CPUs. For example, on my
> > crash-test laptop the Pentium III there reports
> >
> > TLB and cache info:
> > 01: Instruction TLB: 4KB pages, 4-way set assoc, 32 entries
> > 02: Instruction TLB: 4MB pages, 4-way set assoc, 2 entries
> 
> Oh? Newer CPUs tend to have unified TLBs?
> 

I've seen more unified DTLBs (ITLB tends to be split) than not but it could
just be where I'm looking. For example, on the machine I'm writing this
(Core Duo), it's

TLB and cache info:
51: Instruction TLB: 4KB and 2MB or 4MB pages, 128 entries
5b: Data TLB: 4KB and 4MB pages, 64 entries

DTLB is unified there but on my T60p laptop where I guess they want the CPU
to be using less power and be cheaper, it's

TLB info
 Instruction TLB: 4K pages, 4-way associative, 128 entries.
 Instruction TLB: 4MB pages, fully associative, 2 entries
 Data TLB: 4K pages, 4-way associative, 128 entries.
 Data TLB: 4MB pages, 4-way associative, 8 entries

So I would expect huge pages to be slower there than in other cases.
On one Xeon, I see 32 entries for huge pages and 256 for small pages so
it's not straight-forward to predict. On another Xeon, I see the DLB is 64
entries unified.

To make all this more complex, huge pages can be a win because less L2 cache
is consumed on page table information. The gains are due to fewer access to
main memory and less to do with TLB misses. So lets say we do have a TLB
that is set-associative with very few large page entries, it could still
end up winning because the increased usage of L2 offset the increased TLB
misses. Predicting when huge pages are a win and when they are a loss is
just not particularly straight-forward.

> 
> > > Also, interestingly I have actually seen some CPUs whos memory operations
> > > get significantly slower when operating on large pages than small (in the
> > > case when there is full TLB coverage for both sizes). This would make
> > > sense if the CPU only implements a fast L1 TLB for small pages.
> >
> > It's also possible there is a micro-TLB involved that only support small
> > pages.
> 
> That is the case on a couple of contemporary CPUs I've tested with
> (although granted they are engineering samples, but I don't expect
> that to be the cause)
> 

I found it hard to determine if the CPU I was using at a uTLB or not. The
manuals didn't cover the subject but it was a theory as to why large pages
might be slower on a particular CPU. Whatever the reason, I'm ok
admitting that large pages can be slower on smaller data sets and in
other situations for whatever reason. It's not a major surprise.

> 
> > > So for the vast majority of workloads, where stacks are relatively small
> > > (or slowly changing), and relatively hot, I suspect this could easily
> > > have no benefit at best and slowdowns at worst.
> >
> > I wouldn't expect an application with small stacks to request its stack
> > to be backed by hugepages either. Ideally, it would be enabled because a
> > large enough number of DTLB misses were found to be in the stack
> > although catching this sort of data is tricky.
> 
> Sure, as I said, I have nothing against this functionality just because
> it has the possibility to cause a regression. I was just pointing out
> there are a few possibilities there, so it will take a particular type
> of app to take advantage of it. Ie. it is not something you would ever
> just enable "just in case the stack starts thrashing the TLB".
> 

No, it's something you'd enable because you know your app is using a lot
of stack. If you are lazy, you might do a test run of the app with it
enabled for the sake of curiousity and take the option that's faster :)

> 
> > > But I'm not saying that as a reason not to merge it -- this is no
> > > different from any other hugepage allocations and as usual they have to
> > > be used selectively where they help.... I just wonder exactly where huge
> > > stacks will help.
> >
> > Benchmark wise, SPECcpu and SPEComp have stack-dependent benchmarks.
> > Computations that partition problems with recursion I would expect to
> > benefit as well as some JVMs that heavily use the stack (see how many docs
> > suggest setting ulimit -s unlimited). Bit out there, but stack-based
> > languages would stand to gain by this. The potential gap is for threaded
> > apps as there will be stacks that are not the "main" stack.  Backing those
> > with hugepages depends on how they are allocated (malloc, it's easy,
> > MAP_ANONYMOUS not so much).
> 
> Oh good, then there should be lots of possibilities to demonstrate it.
> 

There should :)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
