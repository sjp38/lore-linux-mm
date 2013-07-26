Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 9CDC36B0031
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 01:22:28 -0400 (EDT)
From: Libin <huawei.libin@huawei.com>
Subject: [PATCH] mm: Fix potential NULL pointer dereference
Date: Fri, 26 Jul 2013 13:21:31 +0800
Message-ID: <1374816091-30328-1-git-send-email-huawei.libin@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, liwanp@linux.vnet.ibm.com, mgorman@suse.de, gregkh@linuxfoundation.org, xiaoguangrong@linux.vnet.ibm.com, guohanjun@huawei.com, wujianguo@huawei.com

v1->v2: Add description about the bug potential trigger condition.
	Thanks for the review/suggestion of Michal Hocko &
	Wanpeng Li.

In collapse_huge_page, there is a race window between release
the mmap_sem read lock and hold the mmap_sem write lock, so
find_vma() may return NULL, thus check the return value to
avoid NULL pointer dereference.

collapse_huge_page
	khugepaged_alloc_page
		up_read(&mm->mmap_sem)
	down_write(&mm->mmap_sem)
	vma = find_vma(mm, address)

Signed-off-by: Libin <huawei.libin@huawei.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Cc: <stable@vger.kernel.org> # v3.0+
---
 mm/huge_memory.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 243e710..d4423f4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2294,6 +2294,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out;
 
 	vma = find_vma(mm, address);
+	if (!vma)
+		goto out;
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
-- 
1.8.2.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
