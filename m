Date: Tue, 22 Apr 2003 09:20:55 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030422162055.GJ8978@holomorphy.com>
References: <20030422145644.GG8978@holomorphy.com> <Pine.LNX.4.44.0304221110560.10400-100000@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0304221110560.10400-100000@devserv.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: Andrew Morton <akpm@digeo.com>, Andrea Arcangeli <andrea@suse.de>, mbligh@aracnet.com, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Apr 2003, William Lee Irwin III wrote:
>> Actually it wasn't from sparse memory, it was from massive sharing.
>> Basically 10000 processes whose virtualspace was dominated by shmem
>> shared across all of them.
>> On some reflection I suspect a variety of techniques are needed here.

On Tue, Apr 22, 2003 at 11:26:21AM -0400, Ingo Molnar wrote:
> there are two main techniques to reduce per-context pagetable-alike
> overhead: 1) the use of pagetable sharing via CLONE_VM 2) the use of
> bigger MMU units with a much smaller pagetable hw cost [hugetlbs].

Sharing pagetables across process contexts seems to be relatively
effective. Reclaiming them also curtails various worst-case scenarious
and simultaneously renders all others techniques optimizations as
opposed to workload feasibility patches.

I'm having a tough time getting too interested in these today. I'll
just add to the list for now (if you will).


On Tue, Apr 22, 2003 at 11:26:21AM -0400, Ingo Molnar wrote:
> all of this is true, and still remains valid. None of this changes the
> fact that objrmap, as proposed, introduces a quadratic component to a
> central piece of code. If then we should simply abort any mmap() attempt
> that increases the sharing factor above a certain level, or something like
> that.

It does do poorly there according to benchmarks. I don't have anything
specific to say for or against it. It's sensible as a general idea and
has its benefits but has theoretical and practical drawbacks too. I'm
going to have to let those involved with it address things.


On Tue, Apr 22, 2003 at 11:26:21AM -0400, Ingo Molnar wrote:
> using nonlinear mappings adds the overhead of pte chains, which roughly
> doubles the pagetable overhead. (or companion pagetables, which triple the
> pagetable overhead) Purely RAM-wise the break-even point is at around 8
> pages, 8 pte chain entries make up for 64 bytes of vma overhead.
> the biggest problem i can see is that we (well, the kernel) has to make a
> judgement of RAM footprint vs. algorithmic overhead, which is apples to
> oranges. Nonlinear vmas [or just linear vmas with pte chains installed],
> while being only O(N), double/triple the pagetable overhead. objrmap
> linear vmas, while having only the pagetable overhead, are O(N^2). [well,
> it's O(N*M)]
> RAM-footprint wise the boundary is clear: above 8 pages of granularity,
> vmas with objrmap cost less RAM than nonlinear mappings.
> CPU-time-wise the nonlinear mappings with pte chains always beat objrmap.

There's definitely an argument brewing here. Large 32-bit is very space
conscious; the rest of the world is largely oblivious to these specific
forms of space consumption aside from those tight on space in general.
I don't know that there can be a general answer for all systems.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
