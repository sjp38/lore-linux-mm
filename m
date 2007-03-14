Date: Tue, 13 Mar 2007 18:12:44 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [QUICKLIST 0/4] Arch independent quicklists V2
Message-ID: <20070314011244.GM2986@holomorphy.com>
References: <20070313071325.4920.82870.sendpatchset@schroedinger.engr.sgi.com> <20070313005334.853559ca.akpm@linux-foundation.org> <45F65ADA.9010501@yahoo.com.au> <20070313035250.f908a50e.akpm@linux-foundation.org> <45F685C6.8070806@yahoo.com.au> <20070313041551.565891b5.akpm@linux-foundation.org> <45F68B4B.9020200@yahoo.com.au> <20070313044756.b45649ac.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070313044756.b45649ac.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 13, 2007 at 04:47:56AM -0800, Andrew Morton wrote:
> I'm trying to remember why we ever would have needed to zero out the
> pagetable pages if we're taking down the whole mm?  Maybe it's
> because "oh, the arch wants to put this page into a quicklist to
> recycle it", which is all rather circular.
> It would be interesting to look at a) leave the page full of random
> garbage if we're releasing the whole mm and b) return it straight to
> the page allocator.

We never did need to modify ptes on exit() or other pagetable prunings
(not that they were ever done outside exit() before 2.6.x). The only
subtlety is that pruning on munmap() needs a TLB flush for the TLB
itself to drop the references to the pages referred to by the PTE's on
pruning in the presence of hardware pagetable walkers (in the exit()
case there are no user execution contexts left to potentially utilize
the dead translations so it's less important). That's handled by
tlb_remove_page() and shouldn't need any updates across such a change.

I believe the zeroing on teardown was largely a result of idiom vs.
any particular need. Essentially using ptep_get_and_clear() to handle
the non-pruning munmap() case in a manner unified with other pagetable
teardowns. Also likely is 2.4.x legacy from when that and possibly
earlier kernels maintained arch-private quicklists for pagetables.

There are furthermore distinctions to make between fork() and execve().
fork() stomps over the entire process address space copying pagetables
en masse. After execve() a process incrementally faults in PTE's one at
a time. It should be clear that if case analyses are of interest at
all, fork() will want cache-hot pages (cache-preloaded pages?) where
such are largely wasted on incremental faults after execve(). The copy
operations in fork() should probably also be examined in the context of
shared pagetables at some point.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
