Date: Sun, 4 Aug 2002 13:38:04 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: how not to write a search algorithm
Message-ID: <20020804203804.GD4010@holomorphy.com>
References: <3D4CE74A.A827C9BC@zip.com.au> <Pine.LNX.4.44L.0208041015350.23404-100000@imladris.surriel.com> <3D4D87CE.25198C28@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D4D87CE.25198C28@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
>> Good to hear that you found this one ;)

On Sun, Aug 04, 2002 at 01:00:14PM -0700, Andrew Morton wrote:
> The same test panics Alan's kernel with pte_chain oom, so I can't
> check whether/how well it fixes it :(
> 2.5 is no better off wrt pte_chain oom, and I expect it'll oops
> with this test when per-zone-LRUs are implemented.
> Is there a proposed way of recovering from pte_chain oom?

Yes. I'll outline my strategy here.

(1) alter pte-highmem semantics to sleep holding pagetable kmaps
	(A) reserve some virtual address space for mm-local mappings
	(B) shove pagetable mappings for "self" and "other" into it

(2) separate pte_chain allocation from insertion operations
	(A) provide a hook to preallocate batches outside the locks
	(B) convert the allocation to sleeping allocations
	(C) rearrange pagetable modifications for error recovery and
		to call preallocation hooks and pass in reserved state

(3) recovery from pte_chain proliferation by unmapping things on demand
	(A) per-mm and per-vma accounting of pte_chain space consumption
	(B) pte_chain memory recovery routine run on-demand
	(C) budget-based allocation and mm-local pte_chain recycling

(4) recovery from pagetable proliferation by unmapping files on demand
	(A) per-mm and per-vma accounting of pagetable space consumption
	(B) per 3rd-level pagetable accounting of occupancy
	(C) budget-based pagetable allocation and mm-local recycling
	(D) pagetable memory recovery routine run on-demand

(5) recovery from pagetable proliferation by swapping anonymous pagetables
	(A) per-mm and per-vma accounting of anonymous pagetable space
	(B) per 3rd-level pagetable accounting of occupancy
	(C) fault handling for non-present pmd's
	(D) swap I/O for pagetable pages
	(E) recovery of anonymous pagetable memory run on-demand

(6) Assign a global hard limit on the amount of space permissible to
	allocate for pagetables & pte_chains and enforce it with (1)-(5).


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
