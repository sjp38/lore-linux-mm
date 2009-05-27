Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C9D3E6B0062
	for <linux-mm@kvack.org>; Wed, 27 May 2009 07:12:24 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/2] mm: Account for MAP_SHARED mappings using VM_MAYSHARE and not VM_SHARED in hugetlbfs
Date: Wed, 27 May 2009 12:12:29 +0100
Message-Id: <1243422749-6256-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1243422749-6256-1-git-send-email-mel@csn.ul.ie>
References: <1243422749-6256-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, starlight@binnacle.cx, Eric B Munson <ebmunson@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, wli@movementarian.org
List-ID: <linux-mm.kvack.org>

hugetlbfs reserves huge pages but does not fault them at mmap() time to ensure
that future faults succeed. The reservation behaviour differs depending on
whether the mapping was mapped MAP_SHARED or MAP_PRIVATE. For MAP_SHARED
mappings, hugepages are reserved when mmap() is first called and are tracked
based on information associated with the inode. Other processes mapping
MAP_SHARED use the same reservation. MAP_PRIVATE track the reservations
based on the VMA created as part of the mmap() operation. Each process
mapping MAP_PRIVATE must make its own reservation.

hugetlbfs currently checks if a VMA is MAP_SHARED with the VM_SHARED flag and
not VM_MAYSHARE.  For file-backed mappings, such as hugetlbfs, VM_SHARED is
set only if the mapping is MAP_SHARED and the file was opened read-write. If a
shared memory mapping was mapped shared-read-write for populating of data and
mapped shared-read-only by other processes, then hugetlbfs would account for
the mapping as if it was MAP_PRIVATE.  This causes processes to fail to map
the file MAP_SHARED even though it should succeed as the reservation is there.

This patch alters mm/hugetlb.c and replaces VM_SHARED with VM_MAYSHARE when
the intent of the code was to check whether the VMA was mapped MAP_SHARED
or MAP_PRIVATE.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/hugetlb.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 28c655b..e83ad2c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -316,7 +316,7 @@ static void resv_map_release(struct kref *ref)
 static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
 {
 	VM_BUG_ON(!is_vm_hugetlb_page(vma));
-	if (!(vma->vm_flags & VM_SHARED))
+	if (!(vma->vm_flags & VM_MAYSHARE))
 		return (struct resv_map *)(get_vma_private_data(vma) &
 							~HPAGE_RESV_MASK);
 	return NULL;
@@ -325,7 +325,7 @@ static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
 static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map *map)
 {
 	VM_BUG_ON(!is_vm_hugetlb_page(vma));
-	VM_BUG_ON(vma->vm_flags & VM_SHARED);
+	VM_BUG_ON(vma->vm_flags & VM_MAYSHARE);
 
 	set_vma_private_data(vma, (get_vma_private_data(vma) &
 				HPAGE_RESV_MASK) | (unsigned long)map);
@@ -334,7 +334,7 @@ static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map *map)
 static void set_vma_resv_flags(struct vm_area_struct *vma, unsigned long flags)
 {
 	VM_BUG_ON(!is_vm_hugetlb_page(vma));
-	VM_BUG_ON(vma->vm_flags & VM_SHARED);
+	VM_BUG_ON(vma->vm_flags & VM_MAYSHARE);
 
 	set_vma_private_data(vma, get_vma_private_data(vma) | flags);
 }
@@ -353,7 +353,7 @@ static void decrement_hugepage_resv_vma(struct hstate *h,
 	if (vma->vm_flags & VM_NORESERVE)
 		return;
 
-	if (vma->vm_flags & VM_SHARED) {
+	if (vma->vm_flags & VM_MAYSHARE) {
 		/* Shared mappings always use reserves */
 		h->resv_huge_pages--;
 	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
@@ -369,14 +369,14 @@ static void decrement_hugepage_resv_vma(struct hstate *h,
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 {
 	VM_BUG_ON(!is_vm_hugetlb_page(vma));
-	if (!(vma->vm_flags & VM_SHARED))
+	if (!(vma->vm_flags & VM_MAYSHARE))
 		vma->vm_private_data = (void *)0;
 }
 
 /* Returns true if the VMA has associated reserve pages */
 static int vma_has_reserves(struct vm_area_struct *vma)
 {
-	if (vma->vm_flags & VM_SHARED)
+	if (vma->vm_flags & VM_MAYSHARE)
 		return 1;
 	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER))
 		return 1;
@@ -924,7 +924,7 @@ static long vma_needs_reservation(struct hstate *h,
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	struct inode *inode = mapping->host;
 
-	if (vma->vm_flags & VM_SHARED) {
+	if (vma->vm_flags & VM_MAYSHARE) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		return region_chg(&inode->i_mapping->private_list,
 							idx, idx + 1);
@@ -949,7 +949,7 @@ static void vma_commit_reservation(struct hstate *h,
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	struct inode *inode = mapping->host;
 
-	if (vma->vm_flags & VM_SHARED) {
+	if (vma->vm_flags & VM_MAYSHARE) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		region_add(&inode->i_mapping->private_list, idx, idx + 1);
 
@@ -1893,7 +1893,7 @@ retry_avoidcopy:
 	 * at the time of fork() could consume its reserves on COW instead
 	 * of the full address range.
 	 */
-	if (!(vma->vm_flags & VM_SHARED) &&
+	if (!(vma->vm_flags & VM_MAYSHARE) &&
 			is_vma_resv_set(vma, HPAGE_RESV_OWNER) &&
 			old_page != pagecache_page)
 		outside_reserve = 1;
@@ -2000,7 +2000,7 @@ retry:
 		clear_huge_page(page, address, huge_page_size(h));
 		__SetPageUptodate(page);
 
-		if (vma->vm_flags & VM_SHARED) {
+		if (vma->vm_flags & VM_MAYSHARE) {
 			int err;
 			struct inode *inode = mapping->host;
 
@@ -2104,7 +2104,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			goto out_mutex;
 		}
 
-		if (!(vma->vm_flags & VM_SHARED))
+		if (!(vma->vm_flags & VM_MAYSHARE))
 			pagecache_page = hugetlbfs_pagecache_page(h,
 								vma, address);
 	}
@@ -2289,7 +2289,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * to reserve the full area even if read-only as mprotect() may be
 	 * called to make the mapping read-write. Assume !vma is a shm mapping
 	 */
-	if (!vma || vma->vm_flags & VM_SHARED)
+	if (!vma || vma->vm_flags & VM_MAYSHARE)
 		chg = region_chg(&inode->i_mapping->private_list, from, to);
 	else {
 		struct resv_map *resv_map = resv_map_alloc();
@@ -2330,7 +2330,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * consumed reservations are stored in the map. Hence, nothing
 	 * else has to be done for private mappings here
 	 */
-	if (!vma || vma->vm_flags & VM_SHARED)
+	if (!vma || vma->vm_flags & VM_MAYSHARE)
 		region_add(&inode->i_mapping->private_list, from, to);
 	return 0;
 }
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
