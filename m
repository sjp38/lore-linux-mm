Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id A79D16B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:09:34 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v5 1/3] hugetlbfs: stop setting VM_DONTDUMP in initializing vma(VM_HUGETLB)
Date: Wed, 10 Apr 2013 12:09:15 -0400
Message-Id: <1365610157-15290-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1365610157-15290-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1365610157-15290-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Currently we fail to include any data on hugepages into coredump,
because VM_DONTDUMP is set on hugetlbfs's vma. This behavior was recently
introduced by commit 314e51b98 "mm: kill vma flag VM_RESERVED and
mm->reserved_vm counter". This looks to me a serious regression,
so let's fix it.

ChangeLog v3:
 - move 'return 0' into a separate patch

ChangeLog v2:
 - add 'return 0' in hugepage memory check

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
Cc: stable@vger.kernel.org
---
 fs/hugetlbfs/inode.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git v3.9-rc3.orig/fs/hugetlbfs/inode.c v3.9-rc3/fs/hugetlbfs/inode.c
index 84e3d85..523464e 100644
--- v3.9-rc3.orig/fs/hugetlbfs/inode.c
+++ v3.9-rc3/fs/hugetlbfs/inode.c
@@ -110,7 +110,7 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 	 * way when do_mmap_pgoff unwinds (may be important on powerpc
 	 * and ia64).
 	 */
-	vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND | VM_DONTDUMP;
+	vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND;
 	vma->vm_ops = &hugetlb_vm_ops;
 
 	if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
