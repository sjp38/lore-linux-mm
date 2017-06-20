Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BDB166B02B4
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 19:07:49 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o41so87407795qtf.8
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 16:07:49 -0700 (PDT)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id k49si3007222qtb.318.2017.06.20.16.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 16:07:48 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v7 00/10] mm: page migration enhancement for thp
Date: Tue, 20 Jun 2017 19:07:05 -0400
Message-Id: <20170620230715.81590-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

From: Zi Yan <zi.yan@cs.rutgers.edu>

Hi all,

The patches are rebased on mmotm-2017-06-16-13-59 with the feedbacks
(the kbuild bot warning and error) from v6 patches.

Hi Kirill, I have cleaned up Patch 5 and Patch 6, so PTE-mapped THP migration is
handled fully by existing code. Can you review these two patches?

Patch 1 factors out common code. It could be picked up easily.
Patch 2 moves _PAGE_SWP_SOFT_DIRTY bit to prepare for THP migration.
Patch 3 adds a new TTU flag to avoid the conflict between TTU_MIGRATION and THP migration.
Patch 4-6 are the core part of THP migration.
Patch 7 adds soft dirty bit to THP migraiton.
Patch 8-10 enables THP migration in the various locations in the kernel.

Please review and give comments. Thanks.


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

Changes since v6:
  * Fix the kbuild bot warning in swp_entry_to_pmd().
  * Add macro to disable the code when thp migration is not enabled. This fixes
    the kbuild bot errors while building kernels without THP migration enabled.
  * In memory hotremove, move THP allocation code from new_node_page() to
    new_page_nodemask(). This follows the patch ("mm: unify new_node_page and
    alloc_migrate_target") in latest mmotm.

Changes since v5:
  * THP migration support for soft-offline patch is dropped, because it needs
    more discussion. I will send it separately.
  * Better commit message in Patch 2 (on moving _PAGE_SWP_SOFT_DIRTY bit),
    thanks for Dave Hansen's help.

Changes since v4:
  * In Patch 5, I dropped PTE-mapped THP migration handling code, since it is
    already well handled by existing code.

  * In Patch 6, I did a thorough check on PMD handling places and corrected all
    errors I discovered.

  * In Patch 6, I use is_swap_pmd() to check PMD migration entries and add
    VM_BUG_ON to make sure only migration entries present. It should be useful
    later when someone wants to add PMD swap entries, since VM_BUG_ON will
    catch the missing code path.

  * In Patch 6, I keep pmd_none() in pmd_none_or_trans_huge_or_clear_bad() to
    avoid confusion on the function name. I also add a comment to explain it.

  * In Patch 7-11, I added some missing soft dirty bit preserving code and
    corrected page stats countings.

Changes since v3:

  * I dropped my fix on zap_pmd_range() since THP migration will not trigger
    it and Kirill has posted patches to fix the bug triggered by MADV_DONTNEED.

  * In Patch 6, I used !pmd_present() instead of is_pmd_migration_entry()
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

The main benefit is that we can avoid unnecessary thp splits, which helps us
avoid performance decrease when your applications handles NUMA optimization on
their own.

The implementation is similar to that of normal page migration, the key point
is that we modify a pmd to a pmd migration entry in swap-entry like format.

Naoya Horiguchi (8):
  mm: mempolicy: add queue_pages_required()
  mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to bit 1
  mm: thp: introduce separate TTU flag for thp freezing
  mm: thp: introduce CONFIG_ARCH_ENABLE_THP_MIGRATION
  mm: soft-dirty: keep soft-dirty bits over thp migration
  mm: mempolicy: mbind and migrate_pages support thp migration
  mm: migrate: move_pages() supports thp migration
  mm: memory_hotplug: memory hotremove supports thp migration

Zi Yan (2):
  mm: thp: enable thp migration in generic path
  mm: thp: check pmd migration entry in common path

 arch/x86/Kconfig                     |   4 +
 arch/x86/include/asm/pgtable.h       |  17 ++++
 arch/x86/include/asm/pgtable_64.h    |  14 ++-
 arch/x86/include/asm/pgtable_types.h |  10 +-
 arch/x86/mm/gup.c                    |   7 +-
 fs/proc/task_mmu.c                   |  60 +++++++-----
 include/asm-generic/pgtable.h        |  51 +++++++++-
 include/linux/huge_mm.h              |  24 ++++-
 include/linux/migrate.h              |  15 ++-
 include/linux/rmap.h                 |   3 +-
 include/linux/swapops.h              |  71 +++++++++++++-
 mm/Kconfig                           |   3 +
 mm/gup.c                             |  22 ++++-
 mm/huge_memory.c                     | 180 ++++++++++++++++++++++++++++++++---
 mm/memcontrol.c                      |   5 +
 mm/memory.c                          |  12 ++-
 mm/memory_hotplug.c                  |   4 +-
 mm/mempolicy.c                       | 130 ++++++++++++++++++-------
 mm/migrate.c                         |  77 ++++++++++++---
 mm/mprotect.c                        |   4 +-
 mm/mremap.c                          |   2 +-
 mm/page_vma_mapped.c                 |  17 +++-
 mm/pgtable-generic.c                 |   3 +-
 mm/rmap.c                            |  20 +++-
 24 files changed, 639 insertions(+), 116 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
