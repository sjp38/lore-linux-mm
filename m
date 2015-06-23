Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8066B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 20:39:38 -0400 (EDT)
Received: by paceq1 with SMTP id eq1so119946941pac.3
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 17:39:37 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id an13si31941237pac.14.2015.06.22.17.39.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jun 2015 17:39:36 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v5 PATCH 0/9] hugetlbfs: add fallocate support
Date: Mon, 22 Jun 2015 17:38:30 -0700
Message-Id: <1435019919-29225-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

No major changes since last RFC.  Externalized existing hugetlb
fault mutex code.  Added more comments to alloc_huge_page reservation
handling as I could not come up with a good way to encapsulate.
libhugetlbfs test cases and man page updates will be included with
a later request for patch inclusion.

hugetlbfs is used today by applications that want a high degree of
control over huge page usage.  Often, large hugetlbfs files are used
to map a large number huge pages into the application processes.
The applications know when page ranges within these large files will
no longer be used, and ideally would like to release them back to
the subpool or global pools for other uses.  The fallocate() system
call provides an interface for preallocation and hole punching within
files.  This patch set adds fallocate functionality to hugetlbfs.

RFC v5:
  Simply made existing hugetlb fault mutex hash routine available for
    use by fallocate.
  Unable to come up with good reservation encapsulation routines for
    alloc_huge_page, so attempted to comment better.
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
   Error handling for the case when region_del() fails
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

 fs/hugetlbfs/inode.c    | 281 ++++++++++++++++++++++++++++++++++++++++++++----
 include/linux/hugetlb.h |  14 ++-
 mm/hugetlb.c            | 245 +++++++++++++++++++++++++++++------------
 mm/madvise.c            |   2 +-
 4 files changed, 456 insertions(+), 86 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
