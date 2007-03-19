Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l2JK4HKS004444
	for <linux-mm@kvack.org>; Mon, 19 Mar 2007 16:04:17 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2JK5vxx063262
	for <linux-mm@kvack.org>; Mon, 19 Mar 2007 14:05:57 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2JK5vgG005806
	for <linux-mm@kvack.org>; Mon, 19 Mar 2007 14:05:57 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 5/7] change_protection for hugetlb
Date: Mon, 19 Mar 2007 13:05:55 -0700
Message-Id: <20070319200555.17168.14817.stgit@localhost.localdomain>
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
 mm/mprotect.c        |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 198efa7..3de5d93 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -569,6 +569,7 @@ static const struct pagetable_operations_struct hugetlbfs_pagetable_ops = {
 	.copy_vma		= copy_hugetlb_page_range,
 	.pin_pages		= follow_hugetlb_page,
 	.unmap_page_range	= unmap_hugepage_range,
+	.change_protection	= hugetlb_change_protection,
 };
 
 static const struct inode_operations hugetlbfs_dir_inode_operations = {
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
