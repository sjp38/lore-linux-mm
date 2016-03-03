Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D16016B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 02:42:03 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id 63so10156150pfe.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:03 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id b19si63860412pfd.242.2016.03.02.23.42.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 23:42:03 -0800 (PST)
Received: by mail-pa0-x230.google.com with SMTP id fi3so8276416pac.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:02 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 00/11] mm: page migration enhancement for thp
Date: Thu,  3 Mar 2016 16:41:47 +0900
Message-Id: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Hi everyone,

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

Any comments or advices are welcomed.

Thanks,
Naoya Horiguchi
---
Summary:

Naoya Horiguchi (11):
      mm: mempolicy: add queue_pages_node_check()
      mm: thp: introduce CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
      mm: thp: add helpers related to thp/pmd migration
      mm: thp: enable thp migration in generic path
      mm: thp: check pmd migration entry in common path
      mm: soft-dirty: keep soft-dirty bits over thp migration
      mm: hwpoison: fix race between unpoisoning and freeing migrate source page
      mm: hwpoison: soft offline supports thp migration
      mm: mempolicy: mbind and migrate_pages support thp migration
      mm: migrate: move_pages() supports thp migration
      mm: memory_hotplug: memory hotremove supports thp migration

 arch/x86/Kconfig                     |   4 +
 arch/x86/include/asm/pgtable.h       |  28 ++++++
 arch/x86/include/asm/pgtable_64.h    |   2 +
 arch/x86/include/asm/pgtable_types.h |   8 +-
 arch/x86/mm/gup.c                    |   3 +
 fs/proc/task_mmu.c                   |  25 +++--
 include/asm-generic/pgtable.h        |  34 ++++++-
 include/linux/huge_mm.h              |  17 ++++
 include/linux/swapops.h              |  64 +++++++++++++
 mm/Kconfig                           |   3 +
 mm/gup.c                             |   8 ++
 mm/huge_memory.c                     | 175 +++++++++++++++++++++++++++++++++--
 mm/memcontrol.c                      |   2 +
 mm/memory-failure.c                  |  41 ++++----
 mm/memory.c                          |   5 +
 mm/memory_hotplug.c                  |   8 ++
 mm/mempolicy.c                       | 110 ++++++++++++++++------
 mm/migrate.c                         |  57 +++++++++---
 mm/page_isolation.c                  |   8 ++
 mm/rmap.c                            |   7 +-
 20 files changed, 527 insertions(+), 82 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
