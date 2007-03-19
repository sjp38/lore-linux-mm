Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l2JK3vj6004150
	for <linux-mm@kvack.org>; Mon, 19 Mar 2007 16:03:57 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2JK5b53051282
	for <linux-mm@kvack.org>; Mon, 19 Mar 2007 14:05:37 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2JK5ZEL027907
	for <linux-mm@kvack.org>; Mon, 19 Mar 2007 14:05:37 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 3/7] pin_pages for hugetlb
Date: Mon, 19 Mar 2007 13:05:34 -0700
Message-Id: <20070319200534.17168.74446.stgit@localhost.localdomain>
In-Reply-To: <20070319200502.17168.17175.stgit@localhost.localdomain>
References: <20070319200502.17168.17175.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Adam Litke <agl@us.ibm.com>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 fs/hugetlbfs/inode.c |    1 +
 mm/memory.c          |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 2452dde..d0b4b46 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -567,6 +567,7 @@ const struct file_operations hugetlbfs_file_operations = {
 
 static const struct pagetable_operations_struct hugetlbfs_pagetable_ops = {
 	.copy_vma		= copy_hugetlb_page_range,
+	.pin_pages		= follow_hugetlb_page,
 };
 
 static const struct inode_operations hugetlbfs_dir_inode_operations = {
diff --git a/mm/memory.c b/mm/memory.c
index 69bb0b3..01256cf 100644
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
