Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1JIWSe6008598
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 13:32:28 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JIWSwO499316
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 11:32:28 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JIWSQN017284
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 11:32:28 -0700
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 6/7] free_pgtable_range for hugetlb
Date: Mon, 19 Feb 2007 10:32:27 -0800
Message-Id: <20070219183227.27318.12572.stgit@localhost.localdomain>
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
index 1016694..3461f9b 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -567,6 +567,7 @@ static struct pagetable_operations_struct hugetlbfs_pagetable_ops = {
 	.pin_pages		= follow_hugetlb_page,
 	.unmap_page_range	= unmap_hugepage_range,
 	.change_protection	= hugetlb_change_protection,
+	.free_pgtable_range	= hugetlb_free_pgd_range,
 };
 
 static struct inode_operations hugetlbfs_dir_inode_operations = {
diff --git a/mm/memory.c b/mm/memory.c
index aa6b06e..442e6b2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -279,15 +279,15 @@ void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
 		anon_vma_unlink(vma);
 		unlink_file_vma(vma);
 
-		if (is_vm_hugetlb_page(vma)) {
-			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
+		if (has_pt_op(vma, free_pgtable_range)) {
+			pt_op(vma, free_pgtable_range)(tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
 		} else {
 			/*
 			 * Optimization: gather nearby vmas into one call down
 			 */
 			while (next && next->vm_start <= vma->vm_end + PMD_SIZE
-			       && !is_vm_hugetlb_page(next)) {
+			       && !has_pt_op(next, free_pgtable_range)) {
 				vma = next;
 				next = vma->vm_next;
 				anon_vma_unlink(vma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
