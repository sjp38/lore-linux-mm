Date: Thu, 5 Jul 2007 12:13:09 -0600
From: Mike Stroyan <mike@stroyan.net>
Subject: Re: [BUGFIX][PATCH] DO flush icache before set_pte() on ia64.
Message-ID: <20070705181308.GB8320@stroyan.net>
References: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, GOTO <y-goto@jp.fujitsu.com>, dmosberger@gmail.com, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, Jul 04, 2007 at 03:05:04PM +0900, KAMEZAWA Hiroyuki wrote:
> This is a experimental patch for fixing icache flush race of ia64(Montecito).
> 
> Problem Description:
> Montecito, new ia64 processor, has separated L2 i-cache and d-cache,
> and i-cache and d-cache is not consistent in automatic way.
> 
> L1 cache is also separated but L1 D-cache is write-through. Then, before
> Montecito, any changes in L1-dcache is visible in L2-mixed-cache consistently.
> 
> Montecito has separated L2 cache and Mixed L3 cache. But...L2 D-cache is
> *write back*. (See http://download.intel.com/design/Itanium2/manuals/
> 30806501.pdf section 2.3.3)
> 
> Assume : valid data is in L2 d-cache and old data in L3 mixed cache.
> If write-back L2->L3 is delayed, at L2 i-cache miss cpu will fetch old data
> in L3 mixed cache. 
> By this, L2-icache-miss will read wrong instruction from L3-mixed cache.
> (Just I think so, is this correct ?)

  The L3 cache is involved in the HP-UX defect description because the
earlier HP-UX patch PHKL_33781 added flushing of the instruction cache
when an executable mapping was removed.  Linux never added that
unsuccessfull attempt at montecito cache coherency.  In the current
linux situation it can execute old cache lines straight from L2 icache.

> Now, I think icache should be flushed before set_pte().
> This is a patch to try that.
> 
> 1. remove all lazy_mmu_prot_update()...which is used by only ia64.
> 2. implements flush_cache_page()/flush_icache_page() for ia64.
> 
> Something unsure....
> 3. mprotect() flushes cache before removing pte. Is this sane ?
>    I added flush_icache_range() before set_pte() here.
> 
> Any comments and advices ?

  I am concerned about performance consequences.  With the change
from lazy_mmu_prot_update to __flush_icache_page_ia64 you dropped
the code that avoids icache flushes for non-executable pages.
Section 4.6.2 of David Mosberger and Stephane Eranian's
"ia-64 linux kernel design and implementation" goes into some
detail about the performance penalties avoided by limiting icache
flushes to executable pages and defering flushes until the first
fault for execution.

  Have you done any benchmarking to measure the performance
effect of these additional cache flushes?  It would be particularly
interesting to measure on large systems with many CPUs.  The fc.i
instruction needs to be broadcast to all CPUs in the system.

  The only defect that I see in the current implementation of
lazy_mmu_prot_update() is that it is called too late in some
functions that are already calling it.  Are your large changes
attempting to correct other defects?  Or are you simplifying
away potentially valuable code because you don't understand it?

>  
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  arch/ia64/mm/init.c           |    7 +------
>  include/asm-generic/pgtable.h |    4 ----
>  include/asm-ia64/cacheflush.h |   24 ++++++++++++++++++++++--
>  include/asm-ia64/pgtable.h    |    9 ---------
>  mm/fremap.c                   |    1 -
>  mm/memory.c                   |   13 ++++++-------
>  mm/migrate.c                  |    6 +++++-
>  mm/mprotect.c                 |   10 +++++++++-
>  mm/rmap.c                     |    1 -
>  9 files changed, 43 insertions(+), 32 deletions(-)

You don't seem to have removed the lazy_mmu_prot_update() calls from
mm/hugetlb.c.  Will that build with HUGETLBFS configured?

-- 
Mike Stroyan <mike@stroyan.net>

P.S.  I am retired from hp.  So the mike_stroyan@hp.com address that
      this was previously cc'd to no longer reaches me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
