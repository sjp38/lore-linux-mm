Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 119BD6007DB
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 09:19:37 -0500 (EST)
Date: Wed, 2 Dec 2009 14:19:30 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] hugetlb: Acquire the i_mmap_lock before walking the
	prio_tree to unmap a page
Message-ID: <20091202141930.GF1457@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

When the owner of a mapping fails COW because a child process is holding a
reference and no pages are available, the children VMAs are walked and the
page is unmapped. The i_mmap_lock is taken for the unmapping of the page but
not the walking of the prio_tree. In theory, that tree could be changing
while the lock is released although in practice it is protected by the
hugetlb_instantiation_mutex. This patch takes the i_mmap_lock properly for
the duration of the prio_tree walk in case the hugetlb_instantiation_mutex
ever goes away.

[hugh.dickins@tiscali.co.uk: Spotted the problem in the first place]
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/hugetlb.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a952cb8..5adc284 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1906,6 +1906,12 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 		+ (vma->vm_pgoff >> PAGE_SHIFT);
 	mapping = (struct address_space *)page_private(page);
 
+	/*
+	 * Take the mapping lock for the duration of the table walk. As
+	 * this mapping should be shared between all the VMAs,
+	 * __unmap_hugepage_range() is called as the lock is already held
+	 */
+	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(iter_vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		/* Do not unmap the current VMA */
 		if (iter_vma == vma)
@@ -1919,10 +1925,11 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * from the time of fork. This would look like data corruption
 		 */
 		if (!is_vma_resv_set(iter_vma, HPAGE_RESV_OWNER))
-			unmap_hugepage_range(iter_vma,
+			__unmap_hugepage_range(iter_vma,
 				address, address + huge_page_size(h),
 				page);
 	}
+	spin_unlock(&mapping->i_mmap_lock);
 
 	return 1;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
