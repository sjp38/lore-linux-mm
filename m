Date: Wed, 25 Oct 2006 16:29:04 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 3/3] hugetlb: fix absurd HugePages_Rsvd
Message-ID: <20061025062904.GC2330@localhost.localdomain>
References: <Pine.LNX.4.64.0610250323570.30678@blonde.wat.veritas.com> <Pine.LNX.4.64.0610250335530.30678@blonde.wat.veritas.com> <20061025062610.GB2330@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061025062610.GB2330@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, Ken Chen <kenneth.w.chen@intel.com>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 25, 2006 at 04:26:10PM +1000, David Gibson wrote:
> On Wed, Oct 25, 2006 at 03:38:24AM +0100, Hugh Dickins wrote:
> > If you truncated an mmap'ed hugetlbfs file, then faulted on the truncated
> > area, /proc/meminfo's HugePages_Rsvd wrapped hugely "negative".  Reinstate
> > my preliminary i_size check before attempting to allocate the page (though
> > this only fixes the most obvious case: more work will be needed here).
> > 
> > Signed-off-by: Hugh Dickins <hugh@veritas.com>
> > ___
> > 
> > This is not a complete solution (what if hugetlb_no_page is actually
> > racing with truncate_hugepages?), and there are several other accounting
> > anomalies in here (private versus shared pages, hugetlbfs quota handling);
> > but those all need more thought.  It'll probably make sense to use i_mutex
> > instead of hugetlb_instantiation_mutex, so locking out truncation
> > and mmap.
> 
> Ah, yes.  I also encountered this one a few days ago - I found it in
> the context of deserializing the hugepage fault path, which makes the
> problem worse, and forgot to consider if there was also a problem in
> the original case.
> 
> In fact, there's a second problem with the current location of the
> i_size check.  As well as wrapping the reserved count, if there's a
> fault on a truncated area and the hugepage pool is also empty, we can
> get an OOM SIGKILL instead of the correct SIGBUS.
> 
> I don't things are quite as bad as you fear, though:  I believe the
> page lock protects us against racing concurrent truncations (this is
> one reason we have find_lock_page() here, rather than the
> find_get_page() which appears in the analagous normal page path).
> 
> I suggest the slightly revised patch below, which doesn't duplicate
> the i_size test, and cleans up the backout path (removing a
> no-longer-useful goto label) in the process.

Bother.  Forgot to add in the above, that I've also implemented a
couple of extra cases for the libhugetlbfs testsuite which will catch
this bug.  Adam, if you could merge the patch with these test cases
from:
	http://ozlabs.org/~dgibson/home/tmp/reserve-wraparound
to the libhugetlbfs tree, that would be great.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
