Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1JIWdN4029903
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 13:32:39 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JIWdqW519050
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 11:32:39 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JIWdf7007946
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 11:32:39 -0700
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 7/7] hugetlbfs fault handler
Date: Mon, 19 Feb 2007 10:32:38 -0800
Message-Id: <20070219183237.27318.97223.stgit@localhost.localdomain>
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
 mm/hugetlb.c         |    4 +++-
 mm/memory.c          |    4 ++--
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 3461f9b..1de73c1 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -568,6 +568,7 @@ static struct pagetable_operations_struct hugetlbfs_pagetable_ops = {
 	.unmap_page_range	= unmap_hugepage_range,
 	.change_protection	= hugetlb_change_protection,
 	.free_pgtable_range	= hugetlb_free_pgd_range,
+	.fault			= hugetlb_fault,
 };
 
 static struct inode_operations hugetlbfs_dir_inode_operations = {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3bcc0db..63de369 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -588,6 +588,8 @@ int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long vaddr = *position;
 	int remainder = *length;
 
+	BUG_ON(!has_pt_op(vma, fault));
+
 	spin_lock(&mm->page_table_lock);
 	while (vaddr < vma->vm_end && remainder) {
 		pte_t *pte;
@@ -604,7 +606,7 @@ int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			int ret;
 
 			spin_unlock(&mm->page_table_lock);
-			ret = hugetlb_fault(mm, vma, vaddr, 0);
+			ret = pt_op(vma, fault)(mm, vma, vaddr, 0);
 			spin_lock(&mm->page_table_lock);
 			if (ret == VM_FAULT_MINOR)
 				continue;
diff --git a/mm/memory.c b/mm/memory.c
index 442e6b2..c8e17b4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2455,8 +2455,8 @@ int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	count_vm_event(PGFAULT);
 
-	if (unlikely(is_vm_hugetlb_page(vma)))
-		return hugetlb_fault(mm, vma, address, write_access);
+	if (unlikely(has_pt_op(vma, fault)))
+		return pt_op(vma, fault)(mm, vma, address, write_access);
 
 	pgd = pgd_offset(mm, address);
 	pud = pud_alloc(mm, pgd, address);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
