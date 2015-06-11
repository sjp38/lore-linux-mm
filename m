Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 30A1B6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 17:02:20 -0400 (EDT)
Received: by oiha141 with SMTP id a141so10462920oih.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 14:02:20 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id jr3si1191444oeb.86.2015.06.11.14.02.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 14:02:19 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v4 PATCH 0/9] hugetlbfs: add fallocate support
Date: Thu, 11 Jun 2015 14:01:31 -0700
Message-Id: <1434056500-2434-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

Most changes since the last RFC have been code cleanup and restructuring
as suggested by review comments.  One bug was fixed in alloc_huge_page
accounting for hole punched areas.  man pages have not yet been updated
and test cases have not yet been added to libhugetlbfs as suggested.
Looking for any additional review comments before proposing code be
included.

hugetlbfs is used today by applications that want a high degree of
control over huge page usage.  Often, large hugetlbfs files are used
to map a large number huge pages into the application processes.
The applications know when page ranges within these large files will
no longer be used, and ideally would like to release them back to
the subpool or global pools for other uses.  The fallocate() system
call provides an interface for preallocation and hole punching within
files.  This patch set adds fallocate functionality to hugetlbfs.

RFC v4:
  Removed alloc_huge_page/hugetlb_reserve_pages race patches as already
    in mmotm
  Moved hugetlb_fix_reserve_counts in series as suggested by Naoya Horiguchi
  Inline'ed hugetlb_fault_mutex routines as suggested by Davidlohr Bueso and
    existing code changed to use new interfaces as suggested by Naoya
  fallocate preallocation code cleaned up and made simpler
  Modified alloc_huge_page to handle special case where allocation is
    for a hole punched area with spool reserves
RFC v3:
  Folded in patch for alloc_huge_page/hugetlb_reserve_pages race
    in current code
  fallocate allocation and hole punch is synchronized with page
    faults via existing mutex table
   hole punch uses existing hugetlb_vmtruncate_list instead of more
    generic unmap_mapping_range for unmapping
   Error handling for the case when region_del() fauils
RFC v2:
  Addressed alignment and error handling issues noticed by Hillf Danton
  New region_del() routine for region tracking/resv_map of ranges
  Fixed several issues found during more extensive testing
  Error handling in region_del() when kmalloc() fails stills needs
    to be addressed
  madvise remove support remains

Mike Kravetz (9):
  mm/hugetlb: add region_del() to delete a specific range of entries
  mm/hugetlb: expose hugetlb fault mutex for use by fallocate
  hugetlbfs: hugetlb_vmtruncate_list() needs to take a range to delete
  hugetlbfs: truncate_hugepages() takes a range of pages
  mm/hugetlb: vma_has_reserves() needs to handle fallocate hole punch
  mm/hugetlb: alloc_huge_page handle areas hole punched by fallocate
  hugetlbfs: New huge_add_to_page_cache helper routine
  hugetlbfs: add hugetlbfs_fallocate()
  mm: madvise allow remove operation for hugetlbfs

 fs/hugetlbfs/inode.c    | 274 ++++++++++++++++++++++++++++++++++++++++++++----
 include/linux/hugetlb.h |  19 +++-
 mm/hugetlb.c            | 207 +++++++++++++++++++++++++++---------
 mm/madvise.c            |   2 +-
 4 files changed, 432 insertions(+), 70 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
