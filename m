Date: Tue, 22 Apr 2003 10:31:49 -0400 (EDT)
From: Ingo Molnar <mingo@redhat.com>
Subject: Re: objrmap and vmtruncate
In-Reply-To: <20030422115421.GC8931@holomorphy.com>
Message-ID: <Pine.LNX.4.44.0304221017200.10400-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@digeo.com>, Andrea Arcangeli <andrea@suse.de>, mbligh@aracnet.com, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Apr 2003, William Lee Irwin III wrote:

> Are the reserved bits in PAE kernel-usable at all or do they raise
> exceptions when set? This may be cpu revision -dependent, but if things
> are usable in some majority of models it could be ihteresting.

if the present bit is clear then the remaining 63 bits are documented by
Intel as being software-available, so this all works just fine.

> Getting the things out of lowmem sounds very interesting, although I
> vaguely continue to wonder about the total RAM overhead. ISTR an old 2.4
> benchmark run on PAE x86 where 90+% of physical RAM was consumed by
> pagetables _after_ pte_highmem (where before the kernel dropped dead).

just create a sparse enough memory layout (one page mapped every 2MB) and
pagetable overhead will dominate. Is it a problem in practice? I doubt it,
and you get what you asked for, and you can always offset it with RAM.

> But anyway, companion pages are doable. The real metric is what the code
> looks like and how it performs and what workloads it supports.

> I would not say 0.4% of RAM. I would say 0.4% of aggregate virtualspace.
> So someone needs to factor virtual:physical ratio for the important
> workloads into that analysis.

yes.

> Well, the already-existing pagetable overhead is not insignificant. It's
> somewhere around 3MB on lightly-loaded 768MB x86-32 UP, which is very
> close to beginning to swap.

3MB might sound alot. Companion pagetables will make that 9MB on non-PAE.
(current pte chains should make that roughly 6MB on average) 9MB is 1.1%
of all RAM. 4K granular mem_map[] is 1.5% cost, and even there it's not
mainly the RAM overhead that hurts us, but the lowmem overhead.

(btw., the size of companion pagetables is likely reduced via pgcl as well
- they need to track the VM units of pages, not the MMU units of pages.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
