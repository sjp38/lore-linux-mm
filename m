Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0C66B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 16:10:18 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id a17-v6so4031741ybm.2
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 13:10:18 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v71-v6si3577161ybv.84.2018.03.08.13.10.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 13:10:17 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2] hugetlbfs: check for pgoff value overflow
Date: Thu,  8 Mar 2018 13:05:02 -0800
Message-Id: <20180308210502.15952-1-mike.kravetz@oracle.com>
In-Reply-To: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
References: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Nic Losby <blurbdust@gmail.com>, Yisheng Xie <xieyisheng1@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, stable@vger.kernel.org

A vma with vm_pgoff large enough to overflow a loff_t type when
converted to a byte offset can be passed via the remap_file_pages
system call.  The hugetlbfs mmap routine uses the byte offset to
calculate reservations and file size.

A sequence such as:
  mmap(0x20a00000, 0x600000, 0, 0x66033, -1, 0);
  remap_file_pages(0x20a00000, 0x600000, 0, 0x20000000000000, 0);
will result in the following when task exits/file closed,
  kernel BUG at mm/hugetlb.c:749!
Call Trace:
  hugetlbfs_evict_inode+0x2f/0x40
  evict+0xcb/0x190
  __dentry_kill+0xcb/0x150
  __fput+0x164/0x1e0
  task_work_run+0x84/0xa0
  exit_to_usermode_loop+0x7d/0x80
  do_syscall_64+0x18b/0x190
  entry_SYSCALL_64_after_hwframe+0x3d/0xa2

The overflowed pgoff value causes hugetlbfs to try to set up a
mapping with a negative range (end < start) that leaves invalid
state which causes the BUG.

The previous overflow fix to this code was incomplete and did not
take the remap_file_pages system call into account.

Fixes: 045c7a3f53d9 ("hugetlbfs: fix offset overflow in hugetlbfs mmap")
Cc: <stable@vger.kernel.org>
Reported-by: Nic Losby <blurbdust@gmail.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
Changes in v2
  * Use bitmask for overflow check as suggested by Yisheng Xie
  * Add explicit (from > to) check when setting up reservations
  * Cc stable

 fs/hugetlbfs/inode.c | 11 ++++++++---
 mm/hugetlb.c         |  6 ++++++
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 8fe1b0aa2896..dafffa6affae 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -111,6 +111,7 @@ static void huge_pagevec_release(struct pagevec *pvec)
 static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct inode *inode = file_inode(file);
+	unsigned long ovfl_mask;
 	loff_t len, vma_len;
 	int ret;
 	struct hstate *h = hstate_file(file);
@@ -127,12 +128,16 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 	vma->vm_ops = &hugetlb_vm_ops;
 
 	/*
-	 * Offset passed to mmap (before page shift) could have been
-	 * negative when represented as a (l)off_t.
+	 * page based offset in vm_pgoff could be sufficiently large to
+	 * overflow a (l)off_t when converted to byte offset.
 	 */
-	if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
+	ovfl_mask = (1UL << (PAGE_SHIFT + 1)) - 1;
+	ovfl_mask <<= ((sizeof(unsigned long) * BITS_PER_BYTE) -
+		       (PAGE_SHIFT + 1));
+	if (vma->vm_pgoff & ovfl_mask)
 		return -EINVAL;
 
+	/* must be huge page aligned */
 	if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
 		return -EINVAL;
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7c204e3d132b..8eeade0a0b7a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4374,6 +4374,12 @@ int hugetlb_reserve_pages(struct inode *inode,
 	struct resv_map *resv_map;
 	long gbl_reserve;
 
+	/* This should never happen */
+	if (from > to) {
+		VM_WARN(1, "%s called with a negative range\n", __func__);
+		return -EINVAL;
+	}
+
 	/*
 	 * Only apply hugepage reservation if asked. At fault time, an
 	 * attempt will be made for VM_NORESERVE to allocate a page
-- 
2.13.6
