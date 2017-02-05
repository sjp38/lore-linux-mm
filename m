Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD1D06B0069
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 11:14:33 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id d15so31470990qke.1
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 08:14:33 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id n4si2248106qtd.112.2017.02.05.08.14.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Feb 2017 08:14:32 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v3 00/14] mm: page migration enhancement for thp
Date: Sun,  5 Feb 2017 11:12:38 -0500
Message-Id: <20170205161252.85004-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, Zi Yan <ziy@nvidia.com>

From: Zi Yan <ziy@nvidia.com>

Hi all,

The patches are rebased on mmotm-2017-02-01-15-35 with feedbacks from 
Naoya Horiguchi's v2 patches.

I fix a bug in zap_pmd_range() and include the fixes in Patches 1-3.
The racy check in zap_pmd_range() can miss pmd_protnone and pmd_migration_entry,
which leads to PTE page table not freed.

In Patch 4, I move _PAGE_SWP_SOFT_DIRTY to bit 1. Because bit 6 (used in v2)
can be set by some CPUs by mistake and the new swap entry format does not use
bit 1-4.

I also adjust two core migration functions, set_pmd_migration_entry() and
remove_migration_pmd(), to use Kirill A. Shutemov's page_vma_mapped_walk()
function. Patch 8 needs Kirill's comments, since I also add changes
to his page_vma_mapped_walk() function with pmd_migration_entry handling.

In Patch 8, I replace pmdp_huge_get_and_clear() with pmdp_huge_clear_flush()
in set_pmd_migration_entry() to avoid data corruption after page migration.

In Patch 9, I include is_pmd_migration_entry() in pmd_none_or_trans_huge_or_clear_bad().
Otherwise, a pmd_migration_entry is treated as pmd_bad and cleared, which
leads to deposited PTE page table not freed.

I personally use this patchset with my customized kernel to test frequent
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

Zi Yan (3):
  mm: thp: make __split_huge_pmd_locked visible.
  mm: thp: create new __zap_huge_pmd_locked function.
  mm: use pmd lock instead of racy checks in zap_pmd_range()

 arch/x86/Kconfig                     |   4 +
 arch/x86/include/asm/pgtable.h       |  17 ++
 arch/x86/include/asm/pgtable_64.h    |   2 +
 arch/x86/include/asm/pgtable_types.h |  10 +-
 arch/x86/mm/gup.c                    |   4 +-
 fs/proc/task_mmu.c                   |  37 +++--
 include/asm-generic/pgtable.h        | 105 ++++--------
 include/linux/huge_mm.h              |  36 ++++-
 include/linux/rmap.h                 |   1 +
 include/linux/swapops.h              | 146 ++++++++++++++++-
 mm/Kconfig                           |   3 +
 mm/gup.c                             |  20 ++-
 mm/huge_memory.c                     | 302 +++++++++++++++++++++++++++++------
 mm/madvise.c                         |   2 +
 mm/memcontrol.c                      |   2 +
 mm/memory-failure.c                  |  31 ++--
 mm/memory.c                          |  33 ++--
 mm/memory_hotplug.c                  |  17 +-
 mm/mempolicy.c                       | 124 ++++++++++----
 mm/migrate.c                         |  66 ++++++--
 mm/mprotect.c                        |   6 +-
 mm/mremap.c                          |   2 +-
 mm/page_vma_mapped.c                 |  13 +-
 mm/pagewalk.c                        |   2 +
 mm/pgtable-generic.c                 |   3 +-
 mm/rmap.c                            |  21 ++-
 26 files changed, 770 insertions(+), 239 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
