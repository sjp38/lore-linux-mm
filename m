Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id DB1326B00EC
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 06:45:13 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 16 Apr 2012 16:15:06 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3GAj6Hu3920018
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 16:15:06 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3GGFf1W001089
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 02:15:43 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V6 05/14] hugetlb: Avoid taking i_mmap_mutex in unmap_single_vma for hugetlb
Date: Mon, 16 Apr 2012 16:14:42 +0530
Message-Id: <1334573091-18602-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

i_mmap_mutex lock was added in unmap_single_vma by 502717f4e112b18d9c37753a32f675bec9f2838b
But we don't use page->lru in unmap_hugepage_range any more. Also the lock was
taken higher up in the stack in some code path. That would result in deadlock.

unmap_mapping_range (i_mmap_mutex)
 -> unmap_mapping_range_tree
    -> unmap_mapping_range_vma
       -> zap_page_range_single
         -> unmap_single_vma
	      -> unmap_hugepage_range (i_mmap_mutex)

For shared pagetable support for huge pages, since pagetable pages are
ref counted we don't need any lock during huge_pmd_unshare. We do take
i_mmap_mutex in huge_pmd_share while walking the vma_prio_tree in mapping.
( 39dde65c9940c97fcd178a3d2b1c57ed8b7b68aa )

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/memory.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 4b11961..d642b3e 100644
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
