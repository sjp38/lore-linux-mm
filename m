Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 094056B006C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 10:39:41 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 30 May 2012 20:09:39 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4UEdb226947314
	for <linux-mm@kvack.org>; Wed, 30 May 2012 20:09:37 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4UK8qsn026427
	for <linux-mm@kvack.org>; Thu, 31 May 2012 06:08:53 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 05/14] hugetlb: avoid taking i_mmap_mutex in unmap_single_vma() for hugetlb
Date: Wed, 30 May 2012 20:08:50 +0530
Message-Id: <1338388739-22919-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

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
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hillf Danton <dhillf@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
