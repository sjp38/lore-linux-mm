Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id A1C626B0089
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 18:58:59 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id ho1so1750782wib.5
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 15:58:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id eg1si23530396wib.76.2014.06.06.15.58.57
        for <linux-mm@kvack.org>;
        Fri, 06 Jun 2014 15:58:58 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm 0/7] mm/pagewalk: standardize current users, move pmd locking, apply to mincore
Date: Fri,  6 Jun 2014 18:58:33 -0400
Message-Id: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

Here is the patchset on top of previous series (now in linux-mm.)
According to the previous discussion with Dave Hansen, all users of page
table walker are interested in running some code on the leaf entries
(i.e. pmd for thp, pte for normal pages. hugetlb needs special handling
due to arch dependnecy,) not on the "internal node" entries.
I think it's correct for now, but not sure for future users because
for example free_pgtable() seems to do freeing work on every level.

But obviously current code is not standardized (I mean that some users use
only pmd_entry() and do pte loop inside it, not using pte_entry(),) so
we can't move forward without cleaning up these, so this patchset does it.

Patch 1: just a cleanup
Patch 2: preparing walk control parameter
Patch 3-5: cleaning up current users
Patch 6: move pmd locking from each pmd_entry() to common code (affects all
         users implementing pmd_entry().)
Patch 7: apply page table walk to mincore()

This patchset is based on mmotm-2014-05-21-16-57.

Thanks,
Naoya Horiguchi
---
Summary:

Naoya Horiguchi (7):
      mm/pagewalk: remove pgd_entry() and pud_entry()
      mm/pagewalk: replace mm_walk->skip with more general mm_walk->control
      madvise: cleanup swapin_walk_pmd_entry()
      memcg: separate mem_cgroup_move_charge_pte_range()
      arch/powerpc/mm/subpage-prot.c: cleanup subpage_walk_pmd_entry()
      mm/pagewalk: move pmd_trans_huge_lock() from callbacks to common code
      mincore: apply page table walker on do_mincore()

 arch/powerpc/mm/subpage-prot.c |  12 ++-
 fs/proc/task_mmu.c             |  71 ++++++---------
 include/linux/mm.h             |  23 +++--
 mm/huge_memory.c               |  20 -----
 mm/madvise.c                   |  54 +++++-------
 mm/memcontrol.c                | 162 ++++++++++++++++------------------
 mm/mempolicy.c                 |   3 +-
 mm/mincore.c                   | 192 ++++++++++++++---------------------------
 mm/pagewalk.c                  | 127 +++++++++++++++------------
 9 files changed, 281 insertions(+), 383 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
