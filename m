Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 454ED6B00AB
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 06:46:12 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/2] Revert "hugetlb: avoid taking i_mmap_mutex in unmap_single_vma() for hugetlb"
Date: Fri, 27 Jul 2012 11:46:04 +0100
Message-Id: <1343385965-7738-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1343385965-7738-1-git-send-email-mgorman@suse.de>
References: <1343385965-7738-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This reverts the patch "hugetlb: avoid taking i_mmap_mutex in
unmap_single_vma() for hugetlb" from mmotm.

This patch is possibly a mistake and blocks the merging of a hugetlb fix
where page tables can get corrupted (https://lkml.org/lkml/2012/7/24/93).
The motivation of the patch appears to be two-fold.

First, it believes that the i_mmap_mutex is to protect against list
corruption of the page->lru lock but that is not quite accurate. The
i_mmap_mutex for shared page tables is meant to protect against races
when sharing and unsharing the page tables. For example, an important
use of i_mmap_mutex is to stabilise the page_count of the PMD page
during huge_pmd_unshare.

Second, it is protecting against a potential deadlock when
unmap_unsingle_page is called from unmap_mapping_range(). However, hugetlbfs
should never be in this path. It has its own setattr and truncate handlers
where are the paths that use unmap_mapping_range().

Unless Aneesh has another reason for the patch, it should be reverted
to preserve hugetlb page sharing locking.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/memory.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 8a989f1..22bc695 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1344,8 +1344,11 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 			 * Since no pte has actually been setup, it is
 			 * safe to do nothing in this case.
 			 */
-			if (vma->vm_file)
+			if (vma->vm_file) {
+				mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
 				__unmap_hugepage_range(tlb, vma, start, end, NULL);
+				mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
+			}
 		} else
 			unmap_page_range(tlb, vma, start, end, details);
 	}
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
