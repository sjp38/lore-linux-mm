Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7136B0260
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 19:00:46 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 10so9194959qty.10
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 16:00:46 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 41si1382040qtu.211.2017.10.19.16.00.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 16:00:45 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/1] mm:hugetlbfs: Fix hwpoison reserve accounting
Date: Thu, 19 Oct 2017 16:00:07 -0700
Message-Id: <20171019230007.17043-2-mike.kravetz@oracle.com>
In-Reply-To: <20171019230007.17043-1-mike.kravetz@oracle.com>
References: <20171019230007.17043-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@kernel.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, stable@vger.kernel.org

Calling madvise(MADV_HWPOISON) on a hugetlbfs page will result in
bad (negative) reserved huge page counts.  This may not happen
immediately, but may happen later when the underlying file is
removed or filesystem unmounted.  For example:
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
HugePages_Total:       1
HugePages_Free:        0
HugePages_Rsvd:    18446744073709551615
HugePages_Surp:        0
Hugepagesize:       2048 kB

In routine hugetlbfs_error_remove_page(), hugetlb_fix_reserve_counts
is called after remove_huge_page.  hugetlb_fix_reserve_counts is
designed to only be called/used only if a failure is returned from
hugetlb_unreserve_pages.  Therefore, call hugetlb_unreserve_pages
as required and only call hugetlb_fix_reserve_counts in the unlikely
event that hugetlb_unreserve_pages returns an error.

Fixes: 78bb920344b8 ("mm: hwpoison: dissolve in-use hugepage in unrecoverable memory error")
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: <stable@vger.kernel.org>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 59073e9f01a4..ed113ea17aff 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -842,9 +842,12 @@ static int hugetlbfs_error_remove_page(struct address_space *mapping,
 				struct page *page)
 {
 	struct inode *inode = mapping->host;
+	pgoff_t index = page->index;
 
 	remove_huge_page(page);
-	hugetlb_fix_reserve_counts(inode);
+	if (unlikely(hugetlb_unreserve_pages(inode, index, index + 1, 1)))
+		hugetlb_fix_reserve_counts(inode);
+
 	return 0;
 }
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
