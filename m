From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [patch] shared page table for hugetlb page - v2
Date: Wed, 20 Sep 2006 18:35:52 -0700
Message-ID: <000001c6dd1e$4671ac50$1ee8030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20060920180825.1c1ad6ae.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Andrew Morton' <akpm@osdl.org>
Cc: 'Hugh Dickins' <hugh@veritas.com>, 'Dave McCracken' <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote on Wednesday, September 20, 2006 6:08 PM
> On Wed, 20 Sep 2006 17:57:33 -0700
> "Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
> 
> > Following up with the work on shared page table, here is a re-post of
> > shared page table for hugetlb memory.
> 
> Is that actually useful?  With one single pagetable page controlling,
> say, 4GB of hugepage memory, I'm surprised that there's much point in
> trying to optimise it.

Yes, there is when large number of processes using one large shared memory
segment.  The optimization is not really targeted to save memory in this
case, instead, the goal of using shared PT on hugetlb is to allow faster
TLB refill and less cache pollution upon TLB miss.

Since pte entries are shared among hundreds of processes, the cache
consumption used by all the page table is a lot smaller and in return, we
got much higher cache hit rate for user space application. I have performance
counter data to back that claim if people want to see the detail. The other
effect is also that cache hit rate with hardware page walker will be higher
too and this helps to reduce tlb miss latency.

In Dave's implementation for sharing PT on normal page, the performance
gain is predominantly come from reducing memory overhead in managing PTE.
I think cache miss rate and tlb miss latency is of secondary consideration
in that scenario, though it should help there as well.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
