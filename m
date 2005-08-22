Date: Mon, 22 Aug 2005 22:27:47 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [RFT][PATCH 0/2] pagefault scalability alternative
Message-ID: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's my alternative to Christoph's pagefault scalability patches:
no pte xchging, just narrowing the scope of the page_table_lock and
(if CONFIG_SPLIT_PTLOCK=y when SMP) splitting it up per page table.

Currently only supports i386 (PAE or not), x86_64 and ia64 (latter
unbuilt and untested so far).  The rest ought not to build (removed
an arg from pte_alloc_kernel).  I'll take a look through the other
arches: most should be easy, a few (e.g. the sparcs) need more care.

(What I've done for oprofile backtrace is probably not quite right,
but I think in the right direction: can no longer lock out swapout
with page_table_lock, should just try to copy atomically - I'm
hoping someone can help me out there to get it right.)

Certainly not to be considered for merging into -mm yet: contains
various tangential mods (e.g. mremap move speedup) which should be
split off into separate patches for description, review and merge.

I do expect we shall want to merge the narrowing of page_table_lock
in due course - unless you find it's broken.  Whether we shall want
the ptlock splitting, whether with or without anonymous pte xchging,
depends on how they all perform.

Presented as a Request For Testing - any chance, Christoph, that you
could get someone to run it up on SGI's ia64 512-ways, to compare
against the vanilla 2.6.13-rc6-mm1 including your patches?  Thanks!

(The rss counting in this patch matches how it was in -rc6-mm1.
Later I'll want to look at the rss delta mechanism and integrate that
in - the narrowing won't want it, but the splitting would.  If you
think we'd get fairer test numbers by temporarily suppressing rss
counting in each version, please do so.)

Diffstat below is against 2.6.13-rc6-mm1 minus Christoph's version.
No disrespect intended - but it's a bit easier to see what this one
is up to if diffed against the simpler base.  I'll send the removal
of page-fault-patches from -rc6-mm1 as 1/2 then mine as 2/2.

Hugh

 arch/i386/kernel/vm86.c        |   17 -
 arch/i386/mm/ioremap.c         |    4 
 arch/i386/mm/pgtable.c         |   51 +++
 arch/i386/oprofile/backtrace.c |   42 +-
 arch/ia64/mm/init.c            |   11 
 arch/x86_64/mm/ioremap.c       |    4 
 fs/exec.c                      |   14 
 fs/hugetlbfs/inode.c           |    4 
 fs/proc/task_mmu.c             |   19 -
 include/asm-generic/tlb.h      |    4 
 include/asm-i386/pgalloc.h     |   11 
 include/asm-i386/pgtable.h     |   14 
 include/asm-ia64/pgalloc.h     |   13 
 include/asm-x86_64/pgalloc.h   |   24 -
 include/linux/hugetlb.h        |    2 
 include/linux/mm.h             |   73 ++++-
 include/linux/rmap.h           |    3 
 include/linux/sched.h          |   30 ++
 kernel/fork.c                  |   19 -
 kernel/futex.c                 |    6 
 mm/Kconfig                     |   16 +
 mm/filemap_xip.c               |   14 
 mm/fremap.c                    |   53 +--
 mm/hugetlb.c                   |   33 +-
 mm/memory.c                    |  578 ++++++++++++++++++-----------------------
 mm/mempolicy.c                 |    7 
 mm/mmap.c                      |   85 ++----
 mm/mprotect.c                  |    7 
 mm/mremap.c                    |  169 +++++------
 mm/msync.c                     |   49 +--
 mm/rmap.c                      |  115 ++++----
 mm/swap_state.c                |    3 
 mm/swapfile.c                  |   20 -
 mm/vmalloc.c                   |    4 
 34 files changed, 740 insertions(+), 778 deletions(-)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
