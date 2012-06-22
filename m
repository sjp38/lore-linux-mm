Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id E51826B0202
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 11:01:48 -0400 (EDT)
Date: Fri, 22 Jun 2012 17:01:37 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm v2 00/11] mm: scalable and unified
 arch_get_unmapped_area
Message-ID: <20120622150137.GI27816@cmpxchg.org>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340315835-28571-1-git-send-email-riel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org

On Thu, Jun 21, 2012 at 05:57:04PM -0400, Rik van Riel wrote:
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
> In this version I have only gotten rid of the x86, ARM, SH
> and MIPS arch-specific code, and am already showing a
> fairly promising diffstat:
> 
>  arch/arm/include/asm/pgtable.h    |    6 
>  arch/arm/mm/init.c                |    4 
>  arch/arm/mm/mmap.c                |  217 ------------------
>  arch/mips/include/asm/page.h      |    2 
>  arch/mips/include/asm/pgtable.h   |    7 
>  arch/mips/mm/mmap.c               |  177 --------------
>  arch/sh/include/asm/pgtable.h     |    4 
>  arch/sh/mm/mmap.c                 |  219 ------------------
>  arch/x86/include/asm/elf.h        |    3 
>  arch/x86/include/asm/pgtable_64.h |    4 
>  arch/x86/kernel/sys_x86_64.c      |  200 ++--------------
>  arch/x86/vdso/vma.c               |    2 
>  include/linux/mm_types.h          |   19 +
>  include/linux/rbtree.h            |   12 +
>  include/linux/sched.h             |   13 +
>  lib/rbtree.c                      |   46 +++
>  mm/internal.h                     |    5 
>  mm/mmap.c                         |  449 +++++++++++++++++++++++++++++---------
>  18 files changed, 478 insertions(+), 911 deletions(-)
> 
> v2: address reviewers' comments
>     optimize propagating info up the VMA tree (30% faster at frag test)

Here is a comparison of running the anti-bench on all three kernels
(an updated version of the test, I botched the initial one.  But it
still yielded useful results, albeit from testing another aspect).

First, repeated unmaps and remaps of one VMA in the midst of a few
thousand other VMAs.  v2 did not improve over v1, unfortunately:

                        innerremap-next innerremap-agua-v1      innerremap-agua-v2
Elapsed time            4.99 (  +0.00%)   12.66 (+128.05%)        12.55 (+126.21%)
Elapsed time (stddev)   0.06 (  +0.00%)    0.73 ( +63.43%)         0.54 ( +45.51%)
User time               0.41 (  +0.00%)    0.57 ( +10.66%)         0.47 (  +3.63%)
User time (stddev)      0.02 (  +0.00%)    0.06 (  +3.34%)         0.07 (  +4.26%)
System time             4.57 (  +0.00%)   12.09 (+134.86%)        12.08 (+134.68%)
System time (stddev)    0.06 (  +0.00%)    0.69 ( +59.38%)         0.50 ( +41.05%)

The vma_adjust() optimizations for the case where vmas were split or
merged without changing adjacent holes seemed to improve for repeated
mprotect-splitting instead of remapping of the VMA in v2:

                        innermprot-next innermprot-agua-v1      innermprot-agua-v2
Elapsed time            8.02 (  +0.00%)   18.84 (+119.93%)        13.10 ( +56.32%)
Elapsed time (stddev)   0.77 (  +0.00%)    1.15 ( +21.25%)         0.79 (  +0.62%)
User time               3.92 (  +0.00%)    3.95 (  +0.59%)         4.09 (  +3.50%)
User time (stddev)      0.80 (  +0.00%)    0.69 (  -6.14%)         0.81 (  +0.34%)
System time             4.10 (  +0.00%)   14.89 (+211.44%)         9.01 ( +96.18%)
System time (stddev)    0.11 (  +0.00%)    0.90 ( +71.61%)         0.32 ( +19.00%)

The kernbench result did not measurably change from v1 to v2:

                        1x4kernbench-3.5.0-rc3-next-20120619    1x4kernbench-3.5.0-rc3-next-20120619-00007-g594e750     1x4kernbench-3.5.0-rc3-next-20120619-00011-g09982c8
Elapsed time                               273.95 (  +0.00%)                                      274.11 (  +0.06%)                                       274.69 (  +0.27%)
Elapsed time (stddev)                        0.23 (  +0.00%)                                        0.20 (  -2.81%)                                         0.30 (  +5.87%)
User time                                  463.38 (  +0.00%)                                      463.13 (  -0.05%)                                       463.78 (  +0.09%)
User time (stddev)                           0.16 (  +0.00%)                                        0.23 (  +6.66%)                                         0.32 ( +14.15%)
System time                                 49.36 (  +0.00%)                                       50.16 (  +1.60%)                                        50.07 (  +1.42%)
System time (stddev)                         0.24 (  +0.00%)                                        0.26 (  +1.43%)                                         0.27 (  +2.89%)

---

#include <sys/mman.h>

int main(int ac, char **av)
{
	int orig_write;
	unsigned int i;
	int write = 0;
	char *map;

	for (i = 0; i < 4096; i++)
		mmap(NULL, 2 << 12, (write ^= 1) ? PROT_WRITE : PROT_READ, MAP_PRIVATE | MAP_ANON, -1, 0);
	map = mmap(NULL, 2 << 12, (orig_write = write ^= 1) ? PROT_WRITE : PROT_READ, MAP_PRIVATE | MAP_ANON, -1, 0);
	sbrk(0);
	for (i = 0; i < 8192; i++)
		mmap(NULL, 2 << 12, (write ^= 1) ? PROT_WRITE : PROT_READ, MAP_PRIVATE | MAP_ANON, -1, 0);
	sbrk(0);
	for (i = 0; i < (1UL << 23); i++) {
#if 1
		mprotect(map, 1 << 12, PROT_NONE);
		mprotect(map, 1 << 12, orig_write ? PROT_WRITE : PROT_READ);
#else
		munmap(map, 2 << 12);
		map = mmap(NULL, 2 << 12, orig_write ? PROT_WRITE : PROT_READ, MAP_PRIVATE | MAP_ANON, -1, 0);
#endif
	}
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
