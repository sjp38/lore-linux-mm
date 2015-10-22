Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4EA6B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 21:45:47 -0400 (EDT)
Received: by pasz6 with SMTP id z6so71095221pas.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 18:45:47 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id yw2si406274pbb.44.2015.10.21.18.45.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 18:45:47 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] mm/hugetlb: i_mmap_lock_write before unmapping in remove_inode_hugepages
Date: Wed, 21 Oct 2015 18:42:27 -0700
Message-Id: <1445478147-29782-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Code was added to remove_inode_hugepages that will unmap a page if
it is mapped.  i_mmap_lock_write() must be taken during the call
to hugetlb_vmdelete_list().  This is to prevent mappings(vmas) from
being added or deleted while the list of vmas is being examined.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index f25b72f..0f3999d 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -428,9 +428,11 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			 * until we finish removing the page.
 			 */
 			if (page_mapped(page)) {
+				i_mmap_lock_write(mapping);
 				hugetlb_vmdelete_list(&mapping->i_mmap,
 					next * pages_per_huge_page(h),
 					(next + 1) * pages_per_huge_page(h));
+				i_mmap_unlock_write(mapping);
 			}
 
 			lock_page(page);
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
