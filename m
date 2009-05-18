Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C37A66B005C
	for <linux-mm@kvack.org>; Mon, 18 May 2009 12:36:23 -0400 (EDT)
Date: Mon, 18 May 2009 17:36:51 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of process
	with hugepage shared memory segments attached
Message-ID: <20090518163651.GA13093@csn.ul.ie>
References: <6.2.5.6.2.20090515144058.03a55298@binnacle.cx>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <6.2.5.6.2.20090515144058.03a55298@binnacle.cx>
Sender: owner-linux-mm@kvack.org
To: starlight@binnacle.cx
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 15, 2009 at 02:44:29PM -0400, starlight@binnacle.cx wrote:
> This was really bugging me, so I hacked out
> the test case for the attach failure.
> 
> Hoses 2.6.29.1 100% every time.  Run it like this:
> 
> tcbm_att
> tcbm_att -
> tcbm_att -
> tcbm_att -
> 
> It will break on the last iteration with ENOMEM
> and ENOMEM is all any shmget() or shmat() call
> gets forever more.
> 
> After removing the segments this appears:
> 
> HugePages_Total:    2048
> HugePages_Free:     2048
> HugePages_Rsvd:     1280
> HugePages_Surp:        0
> 

Ok, the critical fact was that one process mapped read-write and
populated the segment. Each subsequent process mapped it read-only. The
core VM sets VM_SHARED for file-shared-read-write mappings but not
file-shared-read-only mapping. Hugetlbfs confused how it should be using
VM_SHARED as it was being used to check if the mapping was MAP_SHARED.
Straight-forward mistake with the consequence that reservations "leaked"
and future mappings failed as a result.

Can you try this patch out please? It is against 2.6.29.1 and mostly
applies to 2.6.27.7. The reject is trivially resolved by editting
mm/hugetlb.c and changing the VM_SHARED at the end of
hugetlb_reserve_pages() to VM_MAYSHARE.

Thing is, this patch fixes a reservation issue. The bad pmd messages do
show up for the original test on 2.6.27.7 for x86-64 (not x86) but it's a
separate issue and I have not determined what it is yet. Can you test this
patch to begin with please?

==== CUT HERE ====
Account for MAP_SHARED mappings using VM_MAYSHARE and not VM_SHARED in hugetlbfs

hugetlbfs reserves huge pages and accounts for them differently depending on
whether the mapping was mapped MAP_SHARED or MAP_PRIVATE. However, the check
it makes against the VMA in some places is VM_SHARED and not VM_MAYSHARE.
For file-backed mappings, such as hugetlbfs, VM_SHARED is set only if the
mapping is MAP_SHARED *and* it is read-write. If a shared memory mapping
was created read-write for populating of data and mapped read-only by other
processes, then hugetlbfs gets the accounting wrong and reservations leak.

This patch alters mm/hugetlb.c and replaces VM_SHARED with VM_MAYSHARE when
the intent of the code was to check whether the VMA was mapped MAP_SHARED
or MAP_PRIVATE.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 mm/hugetlb.c |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
