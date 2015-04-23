Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2A4536B0038
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 18:14:00 -0400 (EDT)
Received: by oiko83 with SMTP id o83so26637196oik.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 15:14:00 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u83si6863524oia.138.2015.04.23.15.13.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 15:13:59 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v2 PATCH 0/5] hugetlbfs: add fallocate support
Date: Thu, 23 Apr 2015 15:13:12 -0700
Message-Id: <1429827197-677-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

hugetlbfs is used today by applications that want a high degree of
control over huge page usage.  Often, large hugetlbfs files are used
to map a large number huge pages into the application processes.
The applications know when page ranges within these large files will
no longer be used, and ideally would like to release them back to
the subpool or global pools for other uses.  The fallocate() system
call provides an interface for preallocation and hole punching within
files.  This patch set adds fallocate functionality to hugetlbfs.

RFC v2:
  Addressed alignment and error handling issues noticed by Hillf Danton
  New region_del() routine for region tracking/resv_map of ranges
  Fixed several issues found during more extensive testing
  Error handling in region_del() when kmalloc() fails stills needs
        to be addressed
  madvise remove support remains

Mike Kravetz (5):
  hugetlbfs: truncate_hugepages() takes a range of pages
  hugetlbfs: remove region_truncte() as region_del() can be used
  hugetlbfs: New huge_add_to_page_cache helper routine
  hugetlbfs: add hugetlbfs_fallocate()
  mm: madvise allow remove operation for hugetlbfs

 fs/hugetlbfs/inode.c    | 169 ++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/hugetlb.h |   8 ++-
 mm/hugetlb.c            | 110 ++++++++++++++++++++++---------
 mm/madvise.c            |   2 +-
 4 files changed, 248 insertions(+), 41 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
