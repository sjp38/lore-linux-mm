Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 35D176B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 17:35:07 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 0/8] extend hugepage migration
Date: Thu, 18 Jul 2013 17:34:24 -0400
Message-Id: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Here is the 3rd version of hugepage migration patchset.
I rebased it onto v3.11-rc1 and applied most of your feedbacks.

Some works referred to in previous discussion (shown below) are not included
in this patchset, but likely to be done after this work.
 - using page walker in check_range
 - split page table lock for pmd/pud based hugepage (maybe applicable to thp)

Thanks,
Naoya Horiguchi

--- General Description (exactly same with previous post) ---

Hugepage migration is now available only for soft offlining (moving
data on the half corrupted page to another page to save the data).
But it's also useful some other users of page migration, so this
patchset tries to extend some of such users to support hugepage.

The targets of this patchset are NUMA related system calls (i.e.
migrate_pages(2), move_pages(2), and mbind(2)), and memory hotplug.
This patchset does not extend page migration in memory compaction,
because I think that users of memory compaction mainly expect to
construct thp by arranging raw pages but hugepage migration doesn't
help it.
CMA, another user of page migration, can have benefit from hugepage
migration, but is not enabled to support it now. This is because
I've never used CMA and need to learn more to extend and/or test
hugepage migration in CMA. I'll add this in later version if it
becomes ready, or will post as a separate patchset.

Hugepage migration of 1GB hugepage is not enabled for now, because
I'm not sure whether users of 1GB hugepage really want it.
We need to spare free hugepage in order to do migration, but I don't
think that users want to 1GB memory to idle for that purpose
(currently we can't expand/shrink 1GB hugepage pool after boot).

---
GitHub:
  git://github.com/Naoya-Horiguchi/linux.git extend_hugepage_migration.v3

Test code:
  git://github.com/Naoya-Horiguchi/test_hugepage_migration_extension.git

Naoya Horiguchi (8):
      migrate: make core migration code aware of hugepage
      soft-offline: use migrate_pages() instead of migrate_huge_page()
      migrate: add hugepage migration code to migrate_pages()
      migrate: add hugepage migration code to move_pages()
      mbind: add hugepage migration code to mbind()
      migrate: remove VM_HUGETLB from vma flag check in vma_migratable()
      memory-hotplug: enable memory hotplug to handle hugepage
      prepare to remove /proc/sys/vm/hugepages_treat_as_movable

 Documentation/sysctl/vm.txt |  13 +----
 include/linux/hugetlb.h     |  15 +++++
 include/linux/mempolicy.h   |   2 +-
 include/linux/migrate.h     |   5 --
 mm/hugetlb.c                | 130 +++++++++++++++++++++++++++++++++++++++-----
 mm/memory-failure.c         |  15 ++++-
 mm/memory.c                 |  12 +++-
 mm/memory_hotplug.c         |  42 +++++++++++---
 mm/mempolicy.c              |  43 +++++++++++++--
 mm/migrate.c                |  51 ++++++++---------
 mm/page_alloc.c             |  12 ++++
 mm/page_isolation.c         |   5 ++
 12 files changed, 267 insertions(+), 78 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
