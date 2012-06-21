Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 09BE36B0107
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:57:30 -0400 (EDT)
From: Rik van Riel <riel@surriel.com>
Subject: [PATCH -mm v2 00/11] mm: scalable and unified arch_get_unmapped_area
Date: Thu, 21 Jun 2012 17:57:04 -0400
Message-Id: <1340315835-28571-1-git-send-email-riel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org

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

In this version I have only gotten rid of the x86, ARM, SH
and MIPS arch-specific code, and am already showing a
fairly promising diffstat:

 arch/arm/include/asm/pgtable.h    |    6 
 arch/arm/mm/init.c                |    4 
 arch/arm/mm/mmap.c                |  217 ------------------
 arch/mips/include/asm/page.h      |    2 
 arch/mips/include/asm/pgtable.h   |    7 
 arch/mips/mm/mmap.c               |  177 --------------
 arch/sh/include/asm/pgtable.h     |    4 
 arch/sh/mm/mmap.c                 |  219 ------------------
 arch/x86/include/asm/elf.h        |    3 
 arch/x86/include/asm/pgtable_64.h |    4 
 arch/x86/kernel/sys_x86_64.c      |  200 ++--------------
 arch/x86/vdso/vma.c               |    2 
 include/linux/mm_types.h          |   19 +
 include/linux/rbtree.h            |   12 +
 include/linux/sched.h             |   13 +
 lib/rbtree.c                      |   46 +++
 mm/internal.h                     |    5 
 mm/mmap.c                         |  449 +++++++++++++++++++++++++++++---------
 18 files changed, 478 insertions(+), 911 deletions(-)

v2: address reviewers' comments
    optimize propagating info up the VMA tree (30% faster at frag test)
    add SH architecture

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

With -v2 patches:
$ ./agua_frag_test_64
..........

Min Time (ms): 12
Avg. Time (ms): 31.0000
Max Time (ms): 42
Std Dev (ms): 3.3648
All checks pass

The total run time of the test goes down by about a
factor 5.  More importantly, the worst case performance
of the loop (which is what really hurt some applications)
has gone down by about a factor 14.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
