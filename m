Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0195B6B0027
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 10:54:26 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id w9so5850768uae.8
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 07:54:25 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k29si2710055uai.27.2018.03.30.07.54.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Mar 2018 07:54:24 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2] hugetlbfs: fix bug in pgoff overflow checking
Date: Fri, 30 Mar 2018 07:54:02 -0700
Message-Id: <20180330145402.5053-1-mike.kravetz@oracle.com>
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
hugetlbfs files at offsets greater than 4GB on 32 bit kernels.

On 32 bit kernels conversion from a page based unsigned long can
not overflow a loff_t byte offset.  Therefore, skip this check
if sizeof(unsigned long) != sizeof(loff_t).

Fixes: 63489f8e8211 ("hugetlbfs: check for pgoff value overflow")
Cc: <stable@vger.kernel.org>
Reported-by: Dan Rue <dan.rue@linaro.org>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index b9a254dcc0e7..d508c7844681 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -138,10 +138,14 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 
 	/*
 	 * page based offset in vm_pgoff could be sufficiently large to
-	 * overflow a (l)off_t when converted to byte offset.
+	 * overflow a loff_t when converted to byte offset.  This can
+	 * only happen on architectures where sizeof(loff_t) ==
+	 * sizeof(unsigned long).  So, only check in those instances.
 	 */
-	if (vma->vm_pgoff & PGOFF_LOFFT_MAX)
-		return -EINVAL;
+	if (sizeof(unsigned long) == sizeof(loff_t)) {
+		if (vma->vm_pgoff & PGOFF_LOFFT_MAX)
+			return -EINVAL;
+	}
 
 	/* must be huge page aligned */
 	if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
-- 
2.13.6
