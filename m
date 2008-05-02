Date: Fri, 2 May 2008 10:58:20 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] MM: Make page tables relocatable -- conditional flush (rc9)
Message-ID: <20080502095819.GA24124@csn.ul.ie>
References: <20080414163933.A9628DCA48@localhost> <20080414155702.ca7eb622.akpm@linux-foundation.org> <Pine.LNX.4.64.0804161221060.14718@schroedinger.engr.sgi.com> <d43160c70804290627g77a74e48k5a383dd441177293@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <d43160c70804290627g77a74e48k5a383dd441177293@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, apm@shadoween.org
List-ID: <linux-mm.kvack.org>

On (29/04/08 09:27), Ross Biro didst pronounce:
> On Wed, Apr 16, 2008 at 3:22 PM, Christoph Lameter <clameter@sgi.com> wrote:
> >  The patch is interesting because it would allow the moving of page table
> >  pages into MOVABLE sections and reduce the size of the UNMOVABLE
> >  allocations signficantly (Ross: We need some numbers here). This in turn
> 
> Is there a standard test used to evaluate kernel memory fragmentation?

Not exactly, but the test I run most frequently for testing
fragmentation-related problems is

1. Kernbench building 2.6.14 - 5 iterations
2. aim9
3. bench-hugepagecapability.sh
4. bench-stresshighalloc.sh

the last two are from vmregress
www.csn.ul.ie/~mel/projects/vmregress/vmregress-0.88-rc7.tar.gz which is a
mess of undocumented tools. bench-stresshighalloc.sh needs to be built
against the current running kernel

./configure --with-linux=PATH_TO_KERNEL_SOURCE

The parameters passed to the last two tests depend on the machine but
generally -k $((PHYS_MEMORY_IN_MB/250)) for the number of kernels and
--mb-per-sec 16 are the most important ones.

These tests are not suitable on machines with very large amounts of memory
because too many kernels would be built at the same time and the machine
just grinds. Originally, the tests reflected the most hostile load in terms
of fragmentation, but it's showing it's age now as a suitable test.

Particularly from your perspective, the test is not very pagetable-page
intentensive. You could run the tests above and then start a long-lived
test like sysbench tuned to consume most of memory and then trigger a
relocation to see how effective it would be? Tuned to consume most of
memory should mean there are a lot of pagetable-allocations as well.

If you wanted to see what large page allocation was like at any time,
you could use bench-plainhighalloc.sh from vmregress just to artifically
allocate huge pages or attempt growing of the hugepage pool via proc as
that would also give an indication of the fragmentation state of the
system.

>  I'm sure I can rig up a test to create huge amounts of fragmentation
> with about 1/2 the pages being page tables.  However, I doubt that it
> would reflect any real loads.  Similarly, if I check the memory
> fragmentation on my test system right after it's been booted, I won't
> see much fragmentation and page tables won't be causing any trouble.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
