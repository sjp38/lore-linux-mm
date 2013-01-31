Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id A4F546B000A
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 19:26:24 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id hz11so1385817pad.31
        for <linux-mm@kvack.org>; Wed, 30 Jan 2013 16:26:23 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 0/3] fixes for large mm_populate() and munlock() operations
Date: Wed, 30 Jan 2013 16:26:17 -0800
Message-Id: <1359591980-29542-1-git-send-email-walken@google.com>
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

Michel Lespinasse (3):
  mm: use long type for page counts in mm_populate() and get_user_pages()
  mm: accelerate mm_populate() treatment of THP pages
  mm: accelerate munlock() treatment of THP pages

 arch/ia64/xen/xencomm.c    |  3 ++-
 arch/powerpc/kernel/vdso.c |  9 +++++----
 arch/s390/mm/pgtable.c     |  3 ++-
 include/linux/hugetlb.h    |  6 +++---
 include/linux/mm.h         | 16 ++++++++--------
 mm/hugetlb.c               | 10 +++++-----
 mm/internal.h              |  2 +-
 mm/ksm.c                   | 10 +++++++---
 mm/memory.c                | 39 ++++++++++++++++++++++++++-------------
 mm/migrate.c               |  7 +++++--
 mm/mlock.c                 | 37 ++++++++++++++++++++++++-------------
 11 files changed, 88 insertions(+), 54 deletions(-)

-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
