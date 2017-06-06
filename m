Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 65C606B02FA
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 13:58:32 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b13so95709016pgn.4
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 10:58:32 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 16si14549884pgd.139.2017.06.06.10.58.30
        for <linux-mm@kvack.org>;
        Tue, 06 Jun 2017 10:58:31 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH 0/3] mm: huge pages: Misc fixes for issues found during fuzzing
Date: Tue,  6 Jun 2017 18:58:33 +0100
Message-Id: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mark.rutland@arm.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com, Will Deacon <will.deacon@arm.com>

Hi there,

We ran into very occasional VM_BUG_ONs whilst running the "syzkaller" fuzzing
tool on an arm64 box:

BUG: Bad page state in process syz-fuzzer  pfn:50200
page:ffff7e0000408000 count:0 mapcount:0 mapping:          (null) index:0x1
flags: 0xfffc00000000080(waiters)
raw: 0fffc00000000080 0000000000000000 0000000000000001 00000000ffffffff
raw: dead000000000100 dead000000000200 0000000000000000 0000000000000000
page dumped because: PAGE_FLAGS_CHECK_AT_PREP flag set
bad because of flags: 0x80(waiters)
Modules linked in:
CPU: 1 PID: 1274 Comm: syz-fuzzer Not tainted 4.11.0-rc3 #13
Hardware name: linux,dummy-virt (DT)
Call trace:
[<ffff200008094778>] dump_backtrace+0x0/0x538 arch/arm64/kernel/traps.c:73
[<ffff200008094cd0>] show_stack+0x20/0x30 arch/arm64/kernel/traps.c:228
[<ffff200008be82a8>] __dump_stack lib/dump_stack.c:16 [inline]
[<ffff200008be82a8>] dump_stack+0x120/0x188 lib/dump_stack.c:52
[<ffff20000842c858>] bad_page+0x1d8/0x2e8 mm/page_alloc.c:555
[<ffff20000842cc68>] check_new_page_bad+0xf8/0x200 mm/page_alloc.c:1682
[<ffff20000843a2a0>] check_new_pages mm/page_alloc.c:1694 [inline]
[<ffff20000843a2a0>] rmqueue mm/page_alloc.c:2729 [inline]
[<ffff20000843a2a0>] get_page_from_freelist+0xc58/0x2580 mm/page_alloc.c:3046
[<ffff20000843cb80>] __alloc_pages_nodemask+0x1d0/0x1af0 mm/page_alloc.c:3965
[<ffff200008548238>] __alloc_pages include/linux/gfp.h:426 [inline]
[<ffff200008548238>] __alloc_pages_node include/linux/gfp.h:439 [inline]
[<ffff200008548238>] alloc_pages_vma+0x438/0x7a8 mm/mempolicy.c:2015
[<ffff20000858299c>] do_huge_pmd_wp_page+0x4bc/0x1630 mm/huge_memory.c:1230
[<ffff2000084d7b80>] wp_huge_pmd mm/memory.c:3624 [inline]
[<ffff2000084d7b80>] __handle_mm_fault+0x10a0/0x2760 mm/memory.c:3831
[<ffff2000084d9530>] handle_mm_fault+0x2f0/0x998 mm/memory.c:3878
[<ffff2000080bb9e4>] __do_page_fault arch/arm64/mm/fault.c:264 [inline]
[<ffff2000080bb9e4>] do_page_fault+0x48c/0x730 arch/arm64/mm/fault.c:359
[<ffff2000080816b8>] do_mem_abort+0xd8/0x2c8 arch/arm64/mm/fault.c:578

Debugging the issue led to Mark's patch, which resolves the problem, but
I found a couple of fastgup issues by inspection along the way.

Comments welcome.

Will

--->8

Mark Rutland (1):
  mm: numa: avoid waiting on freed migrated pages

Will Deacon (2):
  mm/page_ref: Ensure page_ref_unfreeze is ordered against prior
    accesses
  mm: migrate: Stabilise page count when migrating transparent hugepages

 include/linux/page_ref.h |  1 +
 mm/huge_memory.c         |  8 +++++++-
 mm/migrate.c             | 15 ++-------------
 3 files changed, 10 insertions(+), 14 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
