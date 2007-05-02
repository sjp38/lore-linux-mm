Date: Wed, 2 May 2007 10:01:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.22 -mm merge plans: slub
In-Reply-To: <Pine.LNX.4.64.0705021330001.16517@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0705020955550.32271@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
 <20070501125559.9ab42896.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705011403470.26819@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705021330001.16517@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007, Hugh Dickins wrote:

> > Why would we need to go back to SLAB if we have not switched to SLUB? SLUB 
> > is marked experimental and not the default.
> 
> I said above that I thought SLUB ought to be defaulted to on throughout
> the -rcs: if we don't do that, we're not going to learn much from having
> it in Linus' tree.

I'd rather be careful with that..... mm is enough for now. Why go to the 
extremes immediately. If it is an option then people can gradually start 
testing with it.
 
> > The only problems that I am aware of is(or was) the issue with arches 
> > modifying page struct fields of slab pages that SLUB needs for its own 
> > operations. And I thought it was all fixed since the powerpc guys were 
> > quiet and the patch was in for i386.
> 
> You're forgetting your unions in struct page: in the SPLIT_PTLOCK
> case (NR_CPUS >= 4) the pagetable code is using spinlock_t ptl,
> which overlays SLUB's first_page and slab pointers.

Uhhh.... Right. So SLUB wont work if the lowest page table block is 
managed via slabs.
 
> I just tried rebuilding powerpc with the SPLIT_PTLOCK cutover
> edited to 8 cpus instead, and then no crash.
> 
> I presume the answer is just to extend your quicklist work to
> powerpc's lowest level of pagetables.  The only other architecture

I am not sure how PowerPCs lower pagetable pages work. If they are of 
PAGE_SIZE then this is no problem.

> which is using kmem_cache for them is arm26, which has
> "#error SMP is not supported", so won't be giving this problem.

Ahh. Good.

But these are arch specific problems. We could use 
ARCH_USES_SLAB_PAGE_STRUCT to disable SLUB on these platforms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
