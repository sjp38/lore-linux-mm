Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0PLjL15003327
	for <linux-mm@kvack.org>; Thu, 25 Jan 2007 16:45:21 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0PLgv05245094
	for <linux-mm@kvack.org>; Thu, 25 Jan 2007 16:42:58 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0PLgvIg012822
	for <linux-mm@kvack.org>; Thu, 25 Jan 2007 16:42:57 -0500
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH] Don't allow the stack to grow into hugetlb reserved regions
Date: Thu, 25 Jan 2007 13:40:52 -0800
Message-Id: <20070125214052.22841.33449.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: david@gibson.dropbear.id.au, linux-kernel@vger.kernel.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

When expanding the stack, we don't currently check if the VMA will cross into
an area of the address space that is reserved for hugetlb pages.  Subsequent
faults on the expanded portion of such a VMA will confuse the low-level MMU
code, resulting in an OOPS.  Check for this.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 mm/mmap.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 9717337..2c6b163 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1477,6 +1477,7 @@ static int acct_stack_growth(struct vm_area_struct * vma, unsigned long size, un
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct rlimit *rlim = current->signal->rlim;
+	unsigned long new_start;
 
 	/* address space limit tests */
 	if (!may_expand_vm(mm, grow))
@@ -1496,6 +1497,12 @@ static int acct_stack_growth(struct vm_area_struct * vma, unsigned long size, un
 			return -ENOMEM;
 	}
 
+	/* Check to make the stack will not grow into a hugetlb-only region. */
+	new_start = (vma->vm_flags & VM_GROWSUP) ? vma->vm_start :
+			vma->vm_end - size;
+	if (is_hugepage_only_range(vma->vm_mm, new_start, size))
+		return -EFAULT;
+
 	/*
 	 * Overcommit..  This must be the final test, as it will
 	 * update security statistics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
