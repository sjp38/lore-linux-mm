Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 232BC6B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 11:46:17 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j30so41347088qta.2
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:46:17 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id d10si687485qkj.240.2017.03.13.08.46.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 08:46:15 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v4 00/11] mm: page migration enhancement for thp
Date: Mon, 13 Mar 2017 11:44:56 -0400
Message-Id: <20170313154507.3647-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

From: Zi Yan <zi.yan@cs.rutgers.edu>

Hi all,

The patches are rebased on mmotm-2017-03-09-16-19 with the feedbacks from
v3 patches. Please give comments and consider merging it.

Hi Kirill, could you take a look at [05/11], which uses and modifies your
page_vma_mapped_walk()?


Motivations
===========================================
1. THP migration becomes important in the upcoming heterogeneous memory systems.

As David Nellans from NVIDIA pointed out from other threads
(http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1349227.html),
future GPUs or other accelerators will have their memory managed by operating
systems. Moving data into and out of these memory nodes efficiently is critical
to applications that use GPUs or other accelerators. Existing page migration
only supports base pages, which has a very low memory bandwidth utilization.
My experiments (see below) show THP migration can migrate pages more efficiently.

2. Base page migration vs THP migration throughput.

Here are cross-socket page migration results from calling
move_pages() syscall:

In x86_64, a Intel two-socket E5-2640v3 box,
single 4KB base page migration takes 62.47 us, using 0.06 GB/s BW,
single 2MB THP migration takes 658.54 us, using 2.97 GB/s BW,
512 4KB base page migration takes 1987.38 us, using 0.98 GB/s BW.

In ppc64, a two-socket Power8 box,
single 64KB base page migration takes 49.3 us, using 1.24 GB/s BW,
single 16MB THP migration takes 2202.17 us, using 7.10 GB/s BW,
256 64KB base page migration takes 2543.65 us, using 6.14 GB/s BW.

THP migration can give us 3x and 1.15x throughput over base page migration
in x86_64 and ppc64 respectivley.

You can test it out by using the code here:
https://github.com/x-y-z/thp-migration-bench

3. Existing page migration splits THP before migration and cannot guarantee
the migrated pages are still contiguous. Contiguity is always what GPUs and
accelerators look for. Without THP migration, khugepaged needs to do extra work
to reassemble the migrated pages back to THPs.

ChangeLog
===========================================

Changes since v3:

  * I dropped my fix on zap_pmd_range() since THP migration will not trigger
    it and Kirill has posted patches to fix the bug triggered by MADV_DONTNEED.

  * In Patch 9, I used !pmd_present() instead of is_pmd_migration_entry()
    in pmd_none_or_trans_huge_or_clear_bad() to avoid moving the function to
    linux/swapops.h. Currently, !pmd_present() is equivalent to 
    is_pmd_migration_entry(). Any suggestion is welcome to this change.

Changes since v2:

  * I fix a bug in zap_pmd_range() and include the fixes in Patches 1-3.
    The racy check in zap_pmd_range() can miss pmd_protnone and pmd_migration_entry,
    which leads to PTE page table not freed.

  * In Patch 4, I move _PAGE_SWP_SOFT_DIRTY to bit 1. Because bit 6 (used in v2)
    can be set by some CPUs by mistake and the new swap entry format does not use
    bit 1-4.

  * I also adjust two core migration functions, set_pmd_migration_entry() and
    remove_migration_pmd(), to use Kirill A. Shutemov's page_vma_mapped_walk()
    function. Patch 8 needs Kirill's comments, since I also add changes
    to his page_vma_mapped_walk() function with pmd_migration_entry handling.

  * In Patch 8, I replace pmdp_huge_get_and_clear() with pmdp_huge_clear_flush()
    in set_pmd_migration_entry() to avoid data corruption after page migration.

  * In Patch 9, I include is_pmd_migration_entry() in pmd_none_or_trans_huge_or_clear_bad().
    Otherwise, a pmd_migration_entry is treated as pmd_bad and cleared, which
    leads to deposited PTE page table not freed.

  * I personally use this patchset with my customized kernel to test frequent
    page migrations by replacing page reclaim with page migration.
    The bugs fixed in Patches 1-3 and 8 was discovered while I am testing my kernel.
    I did a 16-hour stress test that has ~7 billion total page migrations.
    No error or data corruption was found. 

General description
===========================================

This patchset enhances page migration functionality to handle thp migration
for various page migration's callers:
 - mbind(2)
 - move_pages(2)
 - migrate_pages(2)
 - cgroup/cpuset migration
 - memory hotremove
 - soft offline

The main benefit is that we can avoid unnecessary thp splits, which helps us
avoid performance decrease when your applications handles NUMA optimization on
their own.

The implementation is similar to that of normal page migration, the key point
is that we modify a pmd to a pmd migration entry in swap-entry like format.

Any comments or advices are welcomed.

Best Regards,
Yan Zi

Naoya Horiguchi (11):
  mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to bit 1
  mm: mempolicy: add queue_pages_node_check()
  mm: thp: introduce separate TTU flag for thp freezing
  mm: thp: introduce CONFIG_ARCH_ENABLE_THP_MIGRATION
  mm: thp: enable thp migration in generic path
  mm: thp: check pmd migration entry in common path
  mm: soft-dirty: keep soft-dirty bits over thp migration
  mm: hwpoison: soft offline supports thp migration
  mm: mempolicy: mbind and migrate_pages support thp migration
  mm: migrate: move_pages() supports thp migration
  mm: memory_hotplug: memory hotremove supports thp migration

 arch/x86/Kconfig                     |   4 +
 arch/x86/include/asm/pgtable.h       |  17 +++
 arch/x86/include/asm/pgtable_64.h    |  14 ++-
 arch/x86/include/asm/pgtable_types.h |  10 +-
 arch/x86/mm/gup.c                    |   4 +-
 fs/proc/task_mmu.c                   |  49 +++++---
 include/asm-generic/pgtable.h        |  37 +++++-
 include/linux/huge_mm.h              |  32 ++++-
 include/linux/rmap.h                 |   3 +-
 include/linux/swapops.h              |  72 ++++++++++-
 mm/Kconfig                           |   3 +
 mm/gup.c                             |  22 +++-
 mm/huge_memory.c                     | 237 +++++++++++++++++++++++++++++++----
 mm/madvise.c                         |   2 +
 mm/memcontrol.c                      |   2 +
 mm/memory-failure.c                  |  31 ++---
 mm/memory.c                          |   9 +-
 mm/memory_hotplug.c                  |  17 ++-
 mm/mempolicy.c                       | 124 +++++++++++++-----
 mm/migrate.c                         |  66 ++++++++--
 mm/mprotect.c                        |   6 +-
 mm/mremap.c                          |   2 +-
 mm/page_vma_mapped.c                 |  13 +-
 mm/pgtable-generic.c                 |   3 +-
 mm/rmap.c                            |  16 ++-
 25 files changed, 655 insertions(+), 140 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
