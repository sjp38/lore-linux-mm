Date: Sun, 4 Aug 2002 15:02:18 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: how not to write a search algorithm
Message-ID: <20020804220218.GF4010@holomorphy.com>
References: <3D4CE74A.A827C9BC@zip.com.au> <Pine.LNX.4.44L.0208041015350.23404-100000@imladris.surriel.com> <3D4D87CE.25198C28@zip.com.au> <20020804203804.GD4010@holomorphy.com> <3D4D9802.D1F208F0@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D4D9802.D1F208F0@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> (1) alter pte-highmem semantics to sleep holding pagetable kmaps
>>         (A) reserve some virtual address space for mm-local mappings
>>         (B) shove pagetable mappings for "self" and "other" into it

On Sun, Aug 04, 2002 at 02:09:22PM -0700, Andrew Morton wrote:
> Why?

kmapped pte's are passed into the rmap interface, so they're forbidden
from sleeping for allocations if they do them. The additional twist is
that separating locking from holding a reference as in the later
portions opens up the opportunity to sleep while ensuring the pagetable
page will still exist after waking.

i.e.
(1) grab ->page_table_lock long enough to find 3rd-level pagetable
(2) inc refcount
(3) call things with the lock held
(4) if they do some sleeping allocations, they can drop the lock
(5) grab lock
(6) do the real stuff
(7) drop refcount & move on to a different page

Mostly needed for interactions with various kinds of pagetable pruning
and ZONE_NORMAL conservation as the locking requirements get stiffer
when things are prunable at times other than exit() and kmapped and/or
swappable above the 3rd-level of the pagetable. And this scheme, already
used by FreeBSD, has far lower TLB overhead than per-page TLB
invalidation even in the normal case. And the weird mapping stuff in the
generic code vaporizes too.

Note 32K tasks * 16K pmdspace/task = 512MB, i.e. impossible to allocate
from ZONE_NORMAL on i386 with sufficiently large mem_map[] and/or
hashtable bloat. Also, rmap never touches pmd's or pgd's to get at pages
in vmscan.c, so it needs no more than a single pte to scan pte_chains.

 
William Lee Irwin III wrote:
>> (2) separate pte_chain allocation from insertion operations
>>         (A) provide a hook to preallocate batches outside the locks
>>         (B) convert the allocation to sleeping allocations
>>         (C) rearrange pagetable modifications for error recovery and
>>                 to call preallocation hooks and pass in reserved state

On Sun, Aug 04, 2002 at 02:09:22PM -0700, Andrew Morton wrote:
> Seems that simply changing the page_add_ramp() interface to require the
> caller to pass in one (err, two) pte_chains would suffice.  The tricky
> one is copy_page_range(), which is probably where -ac panics.
> I suppose we could hang the pool of pte_chains off task_struct
> and have a little "precharge the pte_chains" function.  Gack.

This is (A) and (B), where the notion for (A) I had was more of simply
grabbing the most pte_chains needed for a single 3rd-level pagetable
copy and keeping the reference to it on the stack to keep the arrival
rates down. (C) is just

	if ((A) failed)
		goto nomem;

with proper drops of locks and refcounts and freeing of memory for the
failed operation.


William Lee Irwin III wrote:
>> (6) Assign a global hard limit on the amount of space permissible to
>>         allocate for pagetables & pte_chains and enforce it with (1)-(5).

On Sun, Aug 04, 2002 at 02:09:22PM -0700, Andrew Morton wrote:
> Different problem ;)

I had fixing "this box should be able to run a lot of tasks but drops
dead instead" in mind. What subset of this were you looking for?


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
