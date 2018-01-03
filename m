Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9C46B02FE
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 03:26:06 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 31so515931plk.20
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 00:26:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h126sor97777pgc.126.2018.01.03.00.26.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 00:26:04 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/3] unclutter thp migration
Date: Wed,  3 Jan 2018 09:25:52 +0100
Message-Id: <20180103082555.14592-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
I have posted this work as an RFC [1] and there were no fundamental
objections to the approach so I am resending for inclusion. It is
quite late in the release cycle and I definitely do not want to
rush this into the next release cycle but having it in linux-next
for longer should be only better to show potential fallouts.

Motivation:
THP migration is hacked into the generic migration with rather
surprising semantic. The migration allocation callback is supposed to
check whether the THP can be migrated at once and if that is not the
case then it allocates a simple page to migrate. unmap_and_move then
fixes that up by splitting the THP into small pages while moving the head
page to the newly allocated order-0 page. Remaining pages are moved to
the LRU list by split_huge_page. The same happens if the THP allocation
fails. This is really ugly and error prone [2].

I also believe that split_huge_page to the LRU lists is inherently
wrong because all tail pages are not migrated. Some callers will just
work around that by retrying (e.g. memory hotplug). There are other
pfn walkers which are simply broken though. e.g. madvise_inject_error
will migrate head and then advances next pfn by the huge page size.
do_move_page_to_node_array, queue_pages_range (migrate_pages, mbind),
will simply split the THP before migration if the THP migration is not
supported then falls back to single page migration but it doesn't handle
tail pages if the THP migration path is not able to allocate a fresh
THP so we end up with ENOMEM and fail the whole migration which is a
questionable behavior. Page compaction doesn't try to migrate large
pages so it should be immune.

The first patch reworks do_pages_move which relies on a very ugly
calling semantic when the return status is pushed to the migration
path via private pointer. It uses pre allocated fixed size batching to
achieve that.  We simply cannot do the same if a THP is to be split
during the migration path which is done in the patch 3. Patch 2 is
follow up cleanup which removes the mentioned return status calling
convention ugliness.

On a side note:
There are some semantic issues I have encountered on the way when
working on patch 1 but I am not addressing them here. E.g. trying
to move THP tail pages will result in either success or EBUSY (the
later one more likely once we isolate head from the LRU list). Hugetlb
reports EACCESS on tail pages.  Some errors are reported via status
parameter but migration failures are not even though the original
`reason' argument suggests there was an intention to do so. From a
quick look into git history this never worked. I have tried to keep the
semantic unchanged.

Then there is a relatively minor thing that the page isolation might
fail because of pages not being on the LRU - e.g. because they are
sitting on the per-cpu LRU caches. Easily fixable.

Shortlog
Michal Hocko (3):
      mm, numa: rework do_pages_move
      mm, migrate: remove reason argument from new_page_t
      mm: unclutter THP migration

Diffstat
 include/linux/migrate.h        |   7 +-
 include/linux/page-isolation.h |   3 +-
 mm/compaction.c                |   3 +-
 mm/huge_memory.c               |   6 +
 mm/internal.h                  |   1 +
 mm/memory_hotplug.c            |   5 +-
 mm/mempolicy.c                 |  40 +----
 mm/migrate.c                   | 354 ++++++++++++++++++-----------------------
 mm/page_isolation.c            |   3 +-
 9 files changed, 181 insertions(+), 241 deletions(-)

[1] http://lkml.kernel.org/r/20171208161559.27313-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20171121021855.50525-1-zi.yan@sent.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
