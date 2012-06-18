Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 3C9726B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 18:05:42 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 0/7] mm: scalable and unified arch_get_unmapped_area
Date: Mon, 18 Jun 2012 18:05:19 -0400
Message-Id: <1340057126-31143-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org

[actually include all 7 patches]

A long time ago, we decided to limit the number of VMAs per
process to 64k. As it turns out, there actually are programs
using tens of thousands of VMAs.

The linear search in arch_get_unmapped_area and
arch_get_unmapped_area_topdown can be a real issue for
those programs. 

This patch series aims to fix the scalability issue by
tracking the size of each free hole in the VMA rbtree,
propagating the free hole info up the tree. 

Another major goal is to put the bulk of the necessary
arch_get_unmapped_area(_topdown) functionality into one
set of functions, so we can eliminate the custom large
functions per architecture, sticking to a few much smaller
architecture specific functions instead.

In this version I have only gotten rid of the x86, ARM
and MIPS arch-specific code, and am already showing a
fairly promising diffstat:

 arch/arm/include/asm/pgtable.h    |    6 
 arch/arm/mm/init.c                |    3 
 arch/arm/mm/mmap.c                |  217 ------------------
 arch/mips/include/asm/page.h      |    2 
 arch/mips/include/asm/pgtable.h   |    7 
 arch/mips/mm/mmap.c               |  177 --------------
 arch/x86/include/asm/elf.h        |    3 
 arch/x86/include/asm/pgtable_64.h |    4 
 arch/x86/kernel/sys_x86_64.c      |  200 ++--------------
 arch/x86/vdso/vma.c               |    2 
 include/linux/mm_types.h          |    8 
 include/linux/sched.h             |   13 +
 mm/internal.h                     |    5 
 mm/mmap.c                         |  455 ++++++++++++++++++++++++++++++--------
 14 files changed, 420 insertions(+), 682 deletions(-)

TODO:
- eliminate arch-specific functions for more architectures
- integrate hugetlbfs alignment (with Andi Kleen's patch?)

Performance

Testing performance with a benchmark that allocates tens
of thousands of VMAs, unmaps them and mmaps them some more
in a loop, shows promising results.

Vanilla 3.4 kernel:
$ ./agua_frag_test_64
..........

Min Time (ms): 6
Avg. Time (ms): 294.0000
Max Time (ms): 609
Std Dev (ms): 113.1664
Standard deviation exceeds 10

With patches:
$ ./agua_frag_test_64
..........

Min Time (ms): 14
Avg. Time (ms): 38.0000
Max Time (ms): 60
Std Dev (ms): 3.9312
All checks pass

The total run time of the test goes down by about a
factor 4.  More importantly, the worst case performance
of the loop (which is what really hurt some applications)
has gone down by about a factor 10.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
