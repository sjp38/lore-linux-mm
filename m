Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 868B96B0069
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 06:28:13 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 13 Jun 2012 15:58:10 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5DAS7sx40108264
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 15:58:08 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5DFvdoN000710
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 21:27:42 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V9 05/15] hugetlb: avoid taking i_mmap_mutex in unmap_single_vma() for hugetlb
Date: Wed, 13 Jun 2012 15:57:24 +0530
Message-Id: <1339583254-895-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

i_mmap_mutex lock was added in unmap_single_vma by 502717f4e ("hugetlb:
fix linked list corruption in unmap_hugepage_range()") but we don't use
page->lru in unmap_hugepage_range any more.  Also the lock was taken
higher up in the stack in some code path.  That would result in deadlock.

unmap_mapping_range (i_mmap_mutex)
 -> unmap_mapping_range_tree
    -> unmap_mapping_range_vma
       -> zap_page_range_single
         -> unmap_single_vma
	      -> unmap_hugepage_range (i_mmap_mutex)

For shared pagetable support for huge pages, since pagetable pages are ref
counted we don't need any lock during huge_pmd_unshare.  We do take
i_mmap_mutex in huge_pmd_share while walking the vma_prio_tree in mapping.
(39dde65c9940c97f ("shared page table for hugetlb page")).

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/memory.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 545e18a..f6bc04f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1326,11 +1326,8 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 			 * Since no pte has actually been setup, it is
 			 * safe to do nothing in this case.
 			 */
-			if (vma->vm_file) {
-				mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
+			if (vma->vm_file)
 				__unmap_hugepage_range(tlb, vma, start, end, NULL);
-				mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
-			}
 		} else
 			unmap_page_range(tlb, vma, start, end, details);
 	}
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
