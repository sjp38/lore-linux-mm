Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3FE6B0169
	for <linux-mm@kvack.org>; Thu, 21 May 2015 11:48:47 -0400 (EDT)
Received: by pabts4 with SMTP id ts4so109345398pab.3
        for <linux-mm@kvack.org>; Thu, 21 May 2015 08:48:46 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id fe6si32306629pdb.84.2015.05.21.08.48.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 08:48:43 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v3 PATCH 00/10] hugetlbfs: add fallocate support
Date: Thu, 21 May 2015 08:47:34 -0700
Message-Id: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

There have been numerous changes to this patch set since the previous
RFC.  Most notably in the area of synchronization and race condition
handling.  The patch set now stands up to a series of functionality
and stress testing.

hugetlbfs is used today by applications that want a high degree of
control over huge page usage.  Often, large hugetlbfs files are used
to map a large number huge pages into the application processes.
The applications know when page ranges within these large files will
no longer be used, and ideally would like to release them back to
the subpool or global pools for other uses.  The fallocate() system
call provides an interface for preallocation and hole punching within
files.  This patch set adds fallocate functionality to hugetlbfs.

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


Mike Kravetz (10):
  mm/hugetlb: compute/return the number of regions added by region_add()
  mm/hugetlb: handle races in alloc_huge_page and hugetlb_reserve_pages
  mm/hugetlb: add region_del() to delete a specific range of entries
  mm/hugetlb: expose hugetlb fault mutex for use by fallocate
  hugetlbfs: hugetlb_vmtruncate_list() needs to take a range to delete
  hugetlbfs: truncate_hugepages() takes a range of pages
  hugetlbfs: New huge_add_to_page_cache helper routine
  mm/hugetlb: vma_has_reserves() needs to handle fallocate hole punch
  hugetlbfs: add hugetlbfs_fallocate()
  mm: madvise allow remove operation for hugetlbfs

 fs/hugetlbfs/inode.c    | 282 ++++++++++++++++++++++++++++++++++++++++++++----
 include/linux/hugetlb.h |  12 ++-
 mm/hugetlb.c            | 238 ++++++++++++++++++++++++++++++++--------
 mm/madvise.c            |   2 +-
 4 files changed, 469 insertions(+), 65 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
