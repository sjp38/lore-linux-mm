Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 719A66B000A
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 00:17:15 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id h89so3192615qtd.18
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 21:17:15 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a85si1779036qkj.366.2018.03.28.21.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 21:17:14 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/1] hugetlbfs: fix bug in pgoff overflow checking
Date: Wed, 28 Mar 2018 21:16:56 -0700
Message-Id: <20180329041656.19691-2-mike.kravetz@oracle.com>
In-Reply-To: <20180329041656.19691-1-mike.kravetz@oracle.com>
References: <20180329041656.19691-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Nic Losby <blurbdust@gmail.com>, Dan Rue <dan.rue@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, stable@vger.kernel.org

This is a fix for a regression in 32 bit kernels caused by an
invalid check for pgoff overflow in hugetlbfs mmap setup.  The
check incorrectly specified that the size of a loff_t was the
same as the size of a long.  The regression prevents mapping
hugetlbfs files at offset greater than 4GB on 32 bit kernels.

Fix the check by using sizeof(loff_t) to get size.  In addition,
make sure pgoff + length can be represented by a signed long
huge page offset.  This check is only necessary on 32 bit kernels.

Fixes: 63489f8e8211 ("hugetlbfs: check for pgoff value overflow")
Cc: <stable@vger.kernel.org>
Reported-by: Dan Rue <dan.rue@linaro.org>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index b9a254dcc0e7..8450a1d75dfa 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -116,7 +116,8 @@ static void huge_pagevec_release(struct pagevec *pvec)
  * bit into account.
  */
 #define PGOFF_LOFFT_MAX \
-	(((1UL << (PAGE_SHIFT + 1)) - 1) <<  (BITS_PER_LONG - (PAGE_SHIFT + 1)))
+	(((1UL << (PAGE_SHIFT + 1)) - 1) << \
+	 ((sizeof(loff_t) * BITS_PER_BYTE) - (PAGE_SHIFT + 1)))
 
 static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
@@ -138,21 +139,32 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 
 	/*
 	 * page based offset in vm_pgoff could be sufficiently large to
-	 * overflow a (l)off_t when converted to byte offset.
+	 * overflow a loff_t when converted to byte offset.
 	 */
-	if (vma->vm_pgoff & PGOFF_LOFFT_MAX)
+	if ((loff_t)vma->vm_pgoff & (loff_t)PGOFF_LOFFT_MAX)
 		return -EINVAL;
 
-	/* must be huge page aligned */
+	/* vm_pgoff must be huge page aligned */
 	if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
 		return -EINVAL;
 
+	/*
+	 * Compute file offset of the end of this mapping
+	 */
 	vma_len = (loff_t)(vma->vm_end - vma->vm_start);
 	len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
-	/* check for overflow */
+
+	/* Check to ensure this did not overflow loff_t */
 	if (len < vma_len)
 		return -EINVAL;
 
+	/*
+	 * On 32 bit systems, this check is necessary to ensure the last page
+	 * of mapping can be represented as a signed long huge page index.
+	 */
+	if ((len >> huge_page_shift(h)) > LONG_MAX)
+		return -EINVAL;
+
 	inode_lock(inode);
 	file_accessed(file);
 
-- 
2.13.6
