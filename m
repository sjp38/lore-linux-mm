Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 429DC6B0037
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 16:12:01 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so1562394wib.5
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 13:12:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bs19si3951214wib.12.2014.06.20.13.11.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jun 2014 13:12:00 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 00/13] pagewalk: improve vma handling, apply to new users
Date: Fri, 20 Jun 2014 16:11:26 -0400
Message-Id: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

This series is ver.3 of page table walker patchset.
In previous discussion I got an objection of moving pte handling code to
->pte_entry() callback, so in this version I've dropped all of such code.

The patchset mainly does fixing vma handling and applying page walker to
2 new users. Here is a brief overview:
  patch 1: clean up
  patch 2: fix bug-prone vma handling code
  patch 3: add another interface of page walker
  patch 4-10: clean up each of existing user
  patch 11: apply page walker to new user queue_pages_range()
  patch 12: allow clear_refs_pte_range() to handle thp (from Kirill)
  patch 13: apply page walker to new user do_mincore()

Thanks,
Naoya Horiguchi

Tree: git@github.com:Naoya-Horiguchi/linux.git
Branch: v3.16-rc1/page_table_walker.ver3
---
Summary:

Kirill A. Shutemov (1):
      mm: /proc/pid/clear_refs: avoid split_huge_page()

Naoya Horiguchi (12):
      mm/pagewalk: remove pgd_entry() and pud_entry()
      pagewalk: improve vma handling
      pagewalk: add walk_page_vma()
      smaps: remove mem_size_stats->vma and use walk_page_vma()
      clear_refs: remove clear_refs_private->vma and introduce clear_refs_test_walk()
      pagemap: use walk->vma instead of calling find_vma()
      numa_maps: remove numa_maps->vma
      numa_maps: fix typo in gather_hugetbl_stats
      memcg: apply walk_page_vma()
      arch/powerpc/mm/subpage-prot.c: use walk->vma and walk_page_vma()
      mempolicy: apply page table walker on queue_pages_range()
      mincore: apply page table walker on do_mincore()

 arch/powerpc/mm/subpage-prot.c |   6 +-
 fs/proc/task_mmu.c             | 143 ++++++++++++++++----------
 include/linux/mm.h             |  22 ++--
 mm/huge_memory.c               |  20 ----
 mm/memcontrol.c                |  36 +++----
 mm/mempolicy.c                 | 228 +++++++++++++++++------------------------
 mm/mincore.c                   | 174 ++++++++++++-------------------
 mm/pagewalk.c                  | 223 ++++++++++++++++++++++++----------------
 8 files changed, 406 insertions(+), 446 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
