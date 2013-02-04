Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id CB3F16B0005
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 02:17:16 -0500 (EST)
Received: by mail-da0-f54.google.com with SMTP id n2so2533248dad.27
        for <linux-mm@kvack.org>; Sun, 03 Feb 2013 23:17:16 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 0/3] fixes for large mm_populate() and munlock() operations
Date: Sun,  3 Feb 2013 23:17:09 -0800
Message-Id: <1359962232-20811-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

These 3 changes are to improve the handling of large mm_populate and
munlock operations. They apply on top of mmotm (in particular, they
depend on both my prior mm_populate work and Kirill's "thp: avoid
dumping huge zero page" change).

- Patch 1 fixes an integer overflow issue when populating 2^32 pages.
  The nr_pages argument to get_user_pages would overflow, resulting in 0
  pages being processed per iteration. I am proposing to simply convert
  the nr_pages argument to a long.

- Patch 2 accelerates populating regions with THP pages. get_user_pages()
  can increment the address by a huge page size in this case instead of
  a small page size, and avoid repeated mm->page_table_lock acquisitions.
  This fixes an issue reported by Roman Dubtsov where populating regions
  via mmap MAP_POPULATE was significantly slower than doing so by
  touching pages from userspace.

- Patch 3 is a similar acceleration for the munlock case. I would actually
  like to get Andrea's attention on this one, as I can't explain how
  munlock_vma_page() is safe against racing with split_huge_page().

Note that patches 1-2 are logically independent of patch 3, so if the
discussion of patch 3 takes too long I would ask Andrew to consider
merging patches 1-2 first.

Changes since v1:

- Andrew accepted patch 1 into his -mm tree but suggested the nr_pages
  argument type should actually be unsigned long; I am sending this as
  a "fix" for the previous patch 1 to be collapsed over the previous one.

- In patch 2, I am adding a separate follow_page_mask() function so that
  the callers to the original follow_page() don't have to be modified to
  ignore the returned page_mask (following another suggestion from Andrew).
  Also the page_mask argument type was changed to unsigned int.

- In patch 3, I similarly changed the page_mask values to unsigned int.

Michel Lespinasse (3):
  fix mm: use long type for page counts in mm_populate() and get_user_pages()
  mm: accelerate mm_populate() treatment of THP pages
  mm: accelerate munlock() treatment of THP pages

 include/linux/hugetlb.h |  2 +-
 include/linux/mm.h      | 24 +++++++++++++++++-------
 mm/hugetlb.c            |  8 ++++----
 mm/internal.h           |  2 +-
 mm/memory.c             | 43 +++++++++++++++++++++++++++++--------------
 mm/mlock.c              | 34 ++++++++++++++++++++++------------
 mm/nommu.c              |  6 ++++--
 7 files changed, 78 insertions(+), 41 deletions(-)

-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
