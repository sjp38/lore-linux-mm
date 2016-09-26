Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B20456B02A1
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:24:00 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id m184so192243848qkb.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:24:00 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id d42si14820118qtb.37.2016.09.26.08.23.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:24:00 -0700 (PDT)
From: zi.yan@sent.com
Subject: [PATCH v1 00/12] mm: THP migration support
Date: Mon, 26 Sep 2016 11:22:22 -0400
Message-Id: <20160926152234.14809-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, Zi Yan <zi.yan@cs.rutgers.edu>

From: Zi Yan <zi.yan@cs.rutgers.edu>

Hi all,

This patchset is based on Naoya Horiguchi's page migration enchancement 
for thp patchset with additional IBM ppc64 support. And I rebase it
on the latest upstream commit.

The motivation is that 4KB page migration is underutilizing the memory
bandwidth compared to 2MB THP migration.

As part of my internship work in NVIDIA, I compared the bandwidth
utilizations between 512 4KB pages and 1 2MB page in both x86_64 and ppc64.
And the results show that migrating 512 4KB pages takes only 3x and 1.15x of
the time, compared to migrating single 2MB THP, in x86_64 and ppc64 
respectively.

Here are the actual BW numbers (total_data_size/migration_time):
        | 512 4KB pages | 1 2MB THP  |  1 4KB page
x86_64  |  0.98GB/s     |  2.97GB/s  |   0.06GB/s
ppc64   |  6.14GB/s     |  7.10GB/s  |   1.24GB/s

Any comments or advices are welcome.

Here is the original message from Naoya:

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
pmd_present() is not simple and it's not enough by itself to determine whether
a given pmd is a pmd migration entry. See patch 3/11 and 5/11 for details.

Here're topics which might be helpful to start discussion:

- at this point, this functionality is limited to x86_64.

- there's alrealy an implementation of thp migration in autonuma code of which
  this patchset doesn't touch anything because it works fine as it is.

- fallback to thp split: current implementation just fails a migration trial if
  thp migration fails. It's possible to retry migration after splitting the thp,
  but that's not included in this version.



Thanks,
Zi Yan
---

Naoya Horiguchi (11):
  mm: mempolicy: add queue_pages_node_check()
  mm: thp: introduce CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
  mm: thp: add helpers related to thp/pmd migration
  mm: thp: enable thp migration in generic path
  mm: thp: check pmd migration entry in common path
  mm: soft-dirty: keep soft-dirty bits over thp migration
  mm: hwpoison: fix race between unpoisoning and freeing migrate source
    page
  mm: hwpoison: soft offline supports thp migration
  mm: mempolicy: mbind and migrate_pages support thp migration
  mm: migrate: move_pages() supports thp migration
  mm: memory_hotplug: memory hotremove supports thp migration

Zi Yan (1):
  mm: ppc64: Add THP migration support for ppc64.

 arch/powerpc/Kconfig                         |   4 +
 arch/powerpc/include/asm/book3s/64/pgtable.h |  23 ++++
 arch/x86/Kconfig                             |   4 +
 arch/x86/include/asm/pgtable.h               |  28 ++++
 arch/x86/include/asm/pgtable_64.h            |   2 +
 arch/x86/include/asm/pgtable_types.h         |   8 +-
 arch/x86/mm/gup.c                            |   3 +
 fs/proc/task_mmu.c                           |  20 +--
 include/asm-generic/pgtable.h                |  34 ++++-
 include/linux/huge_mm.h                      |  13 ++
 include/linux/swapops.h                      |  64 ++++++++++
 mm/Kconfig                                   |   3 +
 mm/gup.c                                     |   8 ++
 mm/huge_memory.c                             | 184 +++++++++++++++++++++++++--
 mm/memcontrol.c                              |   2 +
 mm/memory-failure.c                          |  41 +++---
 mm/memory.c                                  |   5 +
 mm/memory_hotplug.c                          |   8 ++
 mm/mempolicy.c                               | 108 ++++++++++++----
 mm/migrate.c                                 |  49 ++++++-
 mm/page_isolation.c                          |   9 ++
 mm/rmap.c                                    |   5 +
 22 files changed, 549 insertions(+), 76 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
