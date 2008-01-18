Date: Fri, 18 Jan 2008 05:09:56 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] #ifdef very expensive debug check in page fault path
Message-ID: <20080118040956.GA14043@wotan.suse.de>
References: <1200506488.32116.11.camel@cotte.boeblingen.de.ibm.com> <20080116234540.GB29823@wotan.suse.de> <1200563614.22385.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1200563614.22385.9.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Carsten Otte <cotte@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, holger.wolf@de.ibm.com, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 17, 2008 at 10:53:34AM +0100, Martin Schwidefsky wrote:
> On Thu, 2008-01-17 at 00:45 +0100, Nick Piggin wrote:
> > On Wed, Jan 16, 2008 at 07:01:28PM +0100, Carsten Otte wrote:
> > > This patch puts #ifdef CONFIG_DEBUG_VM around a check in vm_normal_page
> > > that verifies that a pfn is valid. This patch increases performance of
> > > the page fault microbenchmark in lmbench by 13% and overall dbench
> > > performance by 7% on s390x.  pfn_valid() is an expensive operation on
> > > s390 that needs a high double digit amount of CPU cycles.
> > > Nick Piggin suggested that pfn_valid() involves an array lookup on
> > > systems with sparsemem, and therefore is an expensive operation there
> > > too.
> > > The check looks like a clear debug thing to me, it should never trigger
> > > on regular kernels. And if a pte is created for an invalid pfn, we'll
> > > find out once the memory gets accessed later on anyway. Please consider
> > > inclusion of this patch into mm.
> > > 
> > > Signed-off-by: Carsten Otte <cotte@de.ibm.com>
> > 
> > Wow, that's a big performance hit for a few instructions ;)
> > I haven't seen it to be quite so expensive on x86, but it definitely is
> > not zero cost, especially with NUMA kernels. Thanks for getting those
> > numbers.
> 
> These number have been a surprise. We knew that the LRA instruction we
> use in pfn_valid has a cost, but from the cycle count we did not expect
> that the difference in the minor fault benchmark would be 13%. Most
> probably a cache effect.
> 
> I shortly discussed with Carsten what we should do with pfn_valid. One
> idea was to make it a nop - always return 1. The current implementation
> of pfn_valid uses the kernel address space mapping to decide if a page
> frame is valid. All available memory areas that fit into the 4TB kernel
> address space get mapped. If a page is mapped pfn_valid returns true.
> But what is the background of pfn_valid, what does it protect against?
> What is the exact semantics if pfn_valid returns true? From the name
> page-frame-number-valid you could argue that it should always return
> true if the number is smaller than 2**52. The number is valid, if there
> is accessible memory is another question.

It is supposed to return true if there is a valid struct page for the
pfn AFAIK.  s390 can probably get around without implementing it like
that because it is mostly only used in memory mapping setup code
(once we have removed it from vm_normal_page).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
