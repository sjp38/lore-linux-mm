Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 267CF6B0036
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 13:37:34 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so7824218pab.3
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 10:37:33 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/11] update page table walker
Date: Mon, 14 Oct 2013 13:36:59 -0400
Message-Id: <1381772230-26878-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org

Page table walker is widely used when you want to traverse page table
tree and do some work for the entries (and pages pointed to by them.)
This is a common operation, and keep the code clean and maintainable
is important. Moreover this patchset introduces caller-specific walk
control function which is helpful for us to newly introduce page table
walker to some other users. Core change comes from patch 1, so please
see it for how it's supposed to work.

This patchset changes core code in mm/pagewalk.c at first in patch 1 and 2,
and then updates all of current users to make the code cleaner in patch
3-9. Patch 10 changes the interface of hugetlb_entry(), I put it here to
keep bisectability of the whole patchset. Patch 11 applies page table walker
to a new user queue_pages_range().

There're some other candidates of new users of page table walker:
 - do_mincore()
 - copy_page_range()
 - remap_pfn_range()
 - zap_page_range()
 - free_pgtables()
 - vmap_page_range_noflush()
 - change_protection_range()
, but at the first step I start with adding only one new user,
queue_pages_range().

Any comments?

Thanks,
Naoya Horiguchi
---
GitHub:
  git://github.com/Naoya-Horiguchi/linux.git v3.12-rc4/rewrite_pagewalker.v1

Test code:
  git://github.com/Naoya-Horiguchi/test_rewrite_page_table_walker.git
---
Summary:

Naoya Horiguchi (11):
      pagewalk: update page table walker core
      pagewalk: add walk_page_vma()
      smaps: redefine callback functions for page table walker
      clear_refs: redefine callback functions for page table walker
      pagemap: redefine callback functions for page table walker
      numa_maps: redefine callback functions for page table walker
      memcg: redefine callback functions for page table walker
      madvise: redefine callback functions for page table walker
      arch/powerpc/mm/subpage-prot.c: use walk_page_vma() instead of walk_page_range()
      pagewalk: remove argument hmask from hugetlb_entry()
      mempolicy: apply page table walker on queue_pages_range()

 arch/powerpc/mm/subpage-prot.c |   6 +-
 fs/proc/task_mmu.c             | 262 +++++++++++++-----------------
 include/linux/mm.h             |  24 ++-
 mm/madvise.c                   |  43 ++---
 mm/memcontrol.c                |  72 ++++-----
 mm/mempolicy.c                 | 251 +++++++++++------------------
 mm/pagewalk.c                  | 352 +++++++++++++++++++++++++----------------
 7 files changed, 482 insertions(+), 528 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
