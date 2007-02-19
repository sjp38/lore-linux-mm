Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1JIW2rU027639
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 13:32:02 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JIVuuD282436
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 13:31:56 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JIVu2V006147
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 13:31:56 -0500
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 3/7] pin_pages for hugetlb
Date: Mon, 19 Feb 2007 10:31:55 -0800
Message-Id: <20070219183155.27318.17766.stgit@localhost.localdomain>
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
 mm/memory.c          |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index c0a7984..2d1dd84 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -564,6 +564,7 @@ const struct file_operations hugetlbfs_file_operations = {
 
 static struct pagetable_operations_struct hugetlbfs_pagetable_ops = {
 	.copy_vma		= copy_hugetlb_page_range,
+	.pin_pages		= follow_hugetlb_page,
 };
 
 static struct inode_operations hugetlbfs_dir_inode_operations = {
diff --git a/mm/memory.c b/mm/memory.c
index 80eafd5..9467c65 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1039,9 +1039,9 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 				|| !(vm_flags & vma->vm_flags))
 			return i ? : -EFAULT;
 
-		if (is_vm_hugetlb_page(vma)) {
-			i = follow_hugetlb_page(mm, vma, pages, vmas,
-						&start, &len, i);
+		if (has_pt_op(vma, pin_pages)) {
+			i = pt_op(vma, pin_pages)(mm, vma, pages,
+						vmas, &start, &len, i);
 			continue;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
