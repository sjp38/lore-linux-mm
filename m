Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 82B216B03D7
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 19:01:39 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id q192so11697671ioe.22
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 16:01:39 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id u1si7470895iou.12.2017.04.11.16.01.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 16:01:38 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] hugetlbfs: fix offset overflow in huegtlbfs mmap
Date: Tue, 11 Apr 2017 15:51:58 -0700
Message-Id: <1491951118-30678-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Vegard Nossum <vegard.nossum@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

If mmap() maps a file, it can be passed an offset into the file at
which the mapping is to start.  Offset could be a negative value when
represented as a loff_t.  The offset plus length will be used to
update the file size (i_size) which is also a loff_t.  Validate the
value of offset and offset + length to make sure they do not overflow
and appear as negative.

Found by syzcaller with commit ff8c0c53c475 ("mm/hugetlb.c: don't call
region_abort if region_chg fails") applied.  Prior to this commit, the
overflow would still occur but we would luckily return ENOMEM.
To reproduce:
mmap(0, 0x2000, 0, 0x40021, 0xffffffffffffffffULL, 0x8000000000000000ULL);

Resulted in,
kernel BUG at mm/hugetlb.c:742!
Call Trace:
 hugetlbfs_evict_inode+0x80/0xa0
 ? hugetlbfs_setattr+0x3c0/0x3c0
 evict+0x24a/0x620
 iput+0x48f/0x8c0
 dentry_unlink_inode+0x31f/0x4d0
 __dentry_kill+0x292/0x5e0
 dput+0x730/0x830
 __fput+0x438/0x720
 ____fput+0x1a/0x20
 task_work_run+0xfe/0x180
 exit_to_usermode_loop+0x133/0x150
 syscall_return_slowpath+0x184/0x1c0
 entry_SYSCALL_64_fastpath+0xab/0xad

Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 7163fe0..dde8613 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -136,17 +136,26 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 	vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND;
 	vma->vm_ops = &hugetlb_vm_ops;
 
+	/*
+	 * Offset passed to mmap (before page shift) could have been
+	 * negative when represented as a (l)off_t.
+	 */
+	if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
+		return -EINVAL;
+
 	if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
 		return -EINVAL;
 
 	vma_len = (loff_t)(vma->vm_end - vma->vm_start);
+	len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
+	/* check for overflow */
+	if (len < vma_len)
+		return -EINVAL;
 
 	inode_lock(inode);
 	file_accessed(file);
 
 	ret = -ENOMEM;
-	len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
-
 	if (hugetlb_reserve_pages(inode,
 				vma->vm_pgoff >> huge_page_order(h),
 				len >> huge_page_shift(h), vma,
@@ -155,7 +164,7 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 
 	ret = 0;
 	if (vma->vm_flags & VM_WRITE && inode->i_size < len)
-		inode->i_size = len;
+		i_size_write(inode, len);
 out:
 	inode_unlock(inode);
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
