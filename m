Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id C7E986B00B1
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 06:18:09 -0400 (EDT)
Date: Thu, 21 Jun 2012 12:18:00 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm 0/7] mm: scalable and unified arch_get_unmapped_area
Message-ID: <20120621101800.GH27816@cmpxchg.org>
References: <1340057126-31143-1-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340057126-31143-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org

On Mon, Jun 18, 2012 at 06:05:19PM -0400, Rik van Riel wrote:
> [actually include all 7 patches]
> 
> A long time ago, we decided to limit the number of VMAs per
> process to 64k. As it turns out, there actually are programs
> using tens of thousands of VMAs.
> 
> The linear search in arch_get_unmapped_area and
> arch_get_unmapped_area_topdown can be a real issue for
> those programs. 
> 
> This patch series aims to fix the scalability issue by
> tracking the size of each free hole in the VMA rbtree,
> propagating the free hole info up the tree. 
> 
> Another major goal is to put the bulk of the necessary
> arch_get_unmapped_area(_topdown) functionality into one
> set of functions, so we can eliminate the custom large
> functions per architecture, sticking to a few much smaller
> architecture specific functions instead.
> 
> In this version I have only gotten rid of the x86, ARM
> and MIPS arch-specific code, and am already showing a
> fairly promising diffstat:
> 
>  arch/arm/include/asm/pgtable.h    |    6 
>  arch/arm/mm/init.c                |    3 
>  arch/arm/mm/mmap.c                |  217 ------------------
>  arch/mips/include/asm/page.h      |    2 
>  arch/mips/include/asm/pgtable.h   |    7 
>  arch/mips/mm/mmap.c               |  177 --------------
>  arch/x86/include/asm/elf.h        |    3 
>  arch/x86/include/asm/pgtable_64.h |    4 
>  arch/x86/kernel/sys_x86_64.c      |  200 ++--------------
>  arch/x86/vdso/vma.c               |    2 
>  include/linux/mm_types.h          |    8 
>  include/linux/sched.h             |   13 +
>  mm/internal.h                     |    5 
>  mm/mmap.c                         |  455 ++++++++++++++++++++++++++++++--------
>  14 files changed, 420 insertions(+), 682 deletions(-)
> 
> TODO:
> - eliminate arch-specific functions for more architectures
> - integrate hugetlbfs alignment (with Andi Kleen's patch?)
> 
> Performance
> 
> Testing performance with a benchmark that allocates tens
> of thousands of VMAs, unmaps them and mmaps them some more
> in a loop, shows promising results.
> 
> Vanilla 3.4 kernel:
> $ ./agua_frag_test_64
> ..........
> 
> Min Time (ms): 6
> Avg. Time (ms): 294.0000
> Max Time (ms): 609
> Std Dev (ms): 113.1664
> Standard deviation exceeds 10
> 
> With patches:
> $ ./agua_frag_test_64
> ..........
> 
> Min Time (ms): 14
> Avg. Time (ms): 38.0000
> Max Time (ms): 60
> Std Dev (ms): 3.9312
> All checks pass
> 
> The total run time of the test goes down by about a
> factor 4.  More importantly, the worst case performance
> of the loop (which is what really hurt some applications)
> has gone down by about a factor 10.

I ran 8 4-job kernel builds on before and after kernels, here are the
results:

                        1x4kernbench-3.5.0-rc3-next-20120619    1x4kernbench-3.5.0-rc3-next-20120619-00007-g594e750
Elapsed time                               273.95 (  +0.00%)                                      274.11 (  +0.06%)
Elapsed time (stddev)                        0.23 (  +0.00%)                                        0.20 (  -2.81%)
User time                                  463.38 (  +0.00%)                                      463.13 (  -0.05%)
User time (stddev)                           0.16 (  +0.00%)                                        0.23 (  +6.66%)
System time                                 49.36 (  +0.00%)                                       50.16 (  +1.60%)
System time (stddev)                         0.24 (  +0.00%)                                        0.26 (  +1.43%)

Walltime is unchanged, but system time went up a tiny notch.

I suspect this comes from the freegap propagation, which can be quite
a bit of work if vmas are created, split/merged, or unmapped deep down
in the rb tree.  Here is a worst-case scenario that creates a bunch of
vmas next to each other and then unmaps and remaps one in the middle
repeatedly in a tight loop (code below):

vanilla: 0.802003266 seconds time elapsed                                          ( +-  0.66% )
patched: 1.710614276 seconds time elapsed                                          ( +-  0.28% )

vanilla:
     7.50%  freegap  [kernel.kallsyms]  [k] perf_event_mmap
     6.73%  freegap  [kernel.kallsyms]  [k] __split_vma
     6.06%  freegap  [kernel.kallsyms]  [k] unmap_single_vma
     5.96%  freegap  [kernel.kallsyms]  [k] vma_adjust
     5.55%  freegap  [kernel.kallsyms]  [k] do_munmap
     5.24%  freegap  [kernel.kallsyms]  [k] find_vma_prepare
     4.21%  freegap  [kernel.kallsyms]  [k] rb_insert_color
     4.13%  freegap  [kernel.kallsyms]  [k] vma_merge
     3.39%  freegap  [kernel.kallsyms]  [k] find_vma
     2.88%  freegap  [kernel.kallsyms]  [k] do_mmap_pgoff
patched:
    28.36%  freegap  [kernel.kallsyms]  [k] vma_rb_augment_cb
    12.20%  freegap  [kernel.kallsyms]  [k] rb_augment_path
     3.85%  freegap  [kernel.kallsyms]  [k] unmap_single_vma
     3.68%  freegap  [kernel.kallsyms]  [k] perf_event_mmap
     3.56%  freegap  [kernel.kallsyms]  [k] vma_adjust
     3.30%  freegap  [kernel.kallsyms]  [k] __split_vma
     3.03%  freegap  [kernel.kallsyms]  [k] rb_erase
     2.56%  freegap  [kernel.kallsyms]  [k] arch_get_unmapped_area_topdown
     1.97%  freegap  [kernel.kallsyms]  [k] rb_insert_color
     1.92%  freegap  [kernel.kallsyms]  [k] vma_merge

One idea would be to be a bit more generous with free space and lazily
update the holes.  Chain up vmas that need to propagate gaps and do it
in batch.  If the same vma is unmapped and remapped, it would first
move to the left-most gap but then the vma that'd need propagation
would always be the same neighboring one, and it can be easily checked
if it's already linked to the lazy-update chain, so no extra work in
this case.  When the chain is full (or finding a hole failed), the
batched propagation can at the same time unlink any visited vma that
are also linked to the lazy-update chain, in an effort to avoid repeat
tree path traversals.

And vma_adjust() could probably be more discriminate about splits and
merges where the holes don't change, no?

---

#include <sys/mman.h>
#include <stdio.h>

int main(void)
{
	unsigned int i;
	char *map;

	for (i = 0; i < 512; i++)
		mmap(NULL, 1 << 12, PROT_READ, MAP_PRIVATE | MAP_ANON, -1, 0);
	map = mmap(NULL, 1 << 12, PROT_READ, MAP_PRIVATE | MAP_ANON, -1, 0);
	sbrk(0);
	for (i = 0; i < 512; i++)
		mmap(NULL, 1 << 12, PROT_READ, MAP_PRIVATE | MAP_ANON, -1, 0);
	sbrk(0);
	for (i = 0; i < (1 << 20); i++) {
#if 1
		mprotect(map, 1 << 6, PROT_NONE);
		mprotect(map, 1 << 6, PROT_READ);
#else
		munmap(map, 1 << 12);
		map = mmap(NULL, 1 << 12, PROT_READ, MAP_PRIVATE | MAP_ANON, -1, 0);
#endif
	}
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
