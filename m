Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED816B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 00:03:07 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t143so7027647pgb.1
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 21:03:07 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r62si1010524pgr.157.2017.03.23.21.03.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 21:03:06 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] mm/hugetlb: Don't call region_abort if region_chg fails
Date: Thu, 23 Mar 2017 21:02:42 -0700
Message-Id: <1490328162-21245-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux^Coundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Changes to hugetlbfs reservation maps is a two step process.  The first
step is a call to region_chg to determine what needs to be changed, and
prepare that change.  This should be followed by a call to call to
region_add to commit the change, or region_abort to abort the change.

The error path in hugetlb_reserve_pages called region_abort after a
failed call to region_chg.  As a result, the adds_in_progress counter
in the reservation map is off by 1.  This is caught by a VM_BUG_ON
in resv_map_release when the reservation map is freed.

syzkaller fuzzer found this bug, that resulted in the following:

 kernel BUG at mm/hugetlb.c:742!
 Call Trace:
  hugetlbfs_evict_inode+0x7b/0xa0 fs/hugetlbfs/inode.c:493
  evict+0x481/0x920 fs/inode.c:553
  iput_final fs/inode.c:1515 [inline]
  iput+0x62b/0xa20 fs/inode.c:1542
  hugetlb_file_setup+0x593/0x9f0 fs/hugetlbfs/inode.c:1306
  newseg+0x422/0xd30 ipc/shm.c:575
  ipcget_new ipc/util.c:285 [inline]
  ipcget+0x21e/0x580 ipc/util.c:639
  SYSC_shmget ipc/shm.c:673 [inline]
  SyS_shmget+0x158/0x230 ipc/shm.c:657
  entry_SYSCALL_64_fastpath+0x1f/0xc2
 RIP: resv_map_release+0x265/0x330 mm/hugetlb.c:742

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c7025c1..c65d45c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4233,7 +4233,9 @@ int hugetlb_reserve_pages(struct inode *inode,
 	return 0;
 out_err:
 	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		region_abort(resv_map, from, to);
+		/* Don't call region_abort if region_chg failed */
+		if (chg >= 0)
+			region_abort(resv_map, from, to);
 	if (vma && is_vma_resv_set(vma, HPAGE_RESV_OWNER))
 		kref_put(&resv_map->refs, resv_map_release);
 	return ret;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
