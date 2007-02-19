Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1JIWIoB024670
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 13:32:18 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JIWHAb303482
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 13:32:17 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JIWHxi002965
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 13:32:17 -0500
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 5/7] change_protection for hugetlb
Date: Mon, 19 Feb 2007 10:32:16 -0800
Message-Id: <20070219183216.27318.81665.stgit@localhost.localdomain>
In-Reply-To: <20070219183123.27318.27319.stgit@localhost.localdomain>
References: <20070219183123.27318.27319.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 fs/hugetlbfs/inode.c |    1 +
 mm/mprotect.c        |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 146a4b7..1016694 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -566,6 +566,7 @@ static struct pagetable_operations_struct hugetlbfs_pagetable_ops = {
 	.copy_vma		= copy_hugetlb_page_range,
 	.pin_pages		= follow_hugetlb_page,
 	.unmap_page_range	= unmap_hugepage_range,
+	.change_protection	= hugetlb_change_protection,
 };
 
 static struct inode_operations hugetlbfs_dir_inode_operations = {
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 3b8f3c0..172e204 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -201,8 +201,9 @@ success:
 		dirty_accountable = 1;
 	}
 
-	if (is_vm_hugetlb_page(vma))
-		hugetlb_change_protection(vma, start, end, vma->vm_page_prot);
+	if (has_pt_op(vma, change_protection))
+		pt_op(vma, change_protection)(vma, start, end,
+			vma->vm_page_prot);
 	else
 		change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
 	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
