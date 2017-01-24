Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F2BD26B029B
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 11:29:44 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c73so244599402pfb.7
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:29:44 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id u25si19776739pge.31.2017.01.24.08.29.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 08:29:43 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 00/12] Fix few rmap-related THP bugs
Date: Tue, 24 Jan 2017 19:28:12 +0300
Message-Id: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch fixes handing PTE-mapped THPs in page_referenced() and
page_idle_clear_pte_refs().

To achieve that I've intrdocued new helper -- page_check_walk() -- which
replaces all page_check_address{,_transhuge}() and covers all THP cases.

Patchset overview:
  - First patch fixes one uprobe bug (unrelated to the rest of the
    patchset, just spotted it at the same time);

  - Patches 2-5 fix handling PTE-mapped THPs in page_referenced(),
    page_idle_clear_pte_refs() and rmap core;

  - Patches 6-12 convert all page_check_address{,_transhuge}() users (plus
    remove_migration_pte()) to page_check_walk() and drop unused helpers.

I think the fixes are not critical enough for stable@ as they don't lead
to crashes or hangs, only suboptimal behaviour.

Please review and consider applying.

Kirill A. Shutemov (12):
  uprobes: split THPs before trying replace them
  mm: introduce page_check_walk()
  mm: fix handling PTE-mapped THPs in page_referenced()
  mm: fix handling PTE-mapped THPs in page_idle_clear_pte_refs()
  mm, rmap: check all VMAs that PTE-mapped THP can be part of
  mm: convert page_mkclean_one() to page_check_walk()
  mm: convert try_to_unmap_one() to page_check_walk()
  mm, ksm: convert write_protect_page() to page_check_walk()
  mm, uprobes: convert __replace_page() to page_check_walk()
  mm: convert page_mapped_in_vma() to page_check_walk()
  mm: drop page_check_address{,_transhuge}
  mm: convert remove_migration_pte() to page_check_walk()

 include/linux/rmap.h    |  85 ++++---
 kernel/events/uprobes.c |  26 ++-
 mm/Makefile             |   6 +-
 mm/huge_memory.c        |  25 +--
 mm/internal.h           |   9 +-
 mm/ksm.c                |  34 +--
 mm/migrate.c            | 103 ++++-----
 mm/page_check.c         | 178 +++++++++++++++
 mm/page_idle.c          |  34 +--
 mm/rmap.c               | 572 +++++++++++++++++++-----------------------------
 10 files changed, 567 insertions(+), 505 deletions(-)
 create mode 100644 mm/page_check.c

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
