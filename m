Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 470666B002C
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:45 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id h89so3889060qtd.18
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:23:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p73si5996190qka.270.2018.03.21.12.23.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:23:43 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJN0kO118969
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:42 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gut67scqs-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:41 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:23:38 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 08/32] docs/vm: hugetlbfs_reserv.txt: convert to ReST format
Date: Wed, 21 Mar 2018 21:22:24 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-9-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/hugetlbfs_reserv.txt | 212 ++++++++++++++++++++++------------
 1 file changed, 135 insertions(+), 77 deletions(-)

diff --git a/Documentation/vm/hugetlbfs_reserv.txt b/Documentation/vm/hugetlbfs_reserv.txt
index 9aca09a..36a87a2 100644
--- a/Documentation/vm/hugetlbfs_reserv.txt
+++ b/Documentation/vm/hugetlbfs_reserv.txt
@@ -1,6 +1,13 @@
-Hugetlbfs Reservation Overview
-------------------------------
-Huge pages as described at 'Documentation/vm/hugetlbpage.txt' are typically
+.. _hugetlbfs_reserve:
+
+=====================
+Hugetlbfs Reservation
+=====================
+
+Overview
+========
+
+Huge pages as described at :ref:`hugetlbpage` are typically
 preallocated for application use.  These huge pages are instantiated in a
 task's address space at page fault time if the VMA indicates huge pages are
 to be used.  If no huge page exists at page fault time, the task is sent
@@ -17,47 +24,55 @@ describe how huge page reserve processing is done in the v4.10 kernel.
 
 
 Audience
---------
+========
 This description is primarily targeted at kernel developers who are modifying
 hugetlbfs code.
 
 
 The Data Structures
--------------------
+===================
+
 resv_huge_pages
 	This is a global (per-hstate) count of reserved huge pages.  Reserved
 	huge pages are only available to the task which reserved them.
 	Therefore, the number of huge pages generally available is computed
-	as (free_huge_pages - resv_huge_pages).
+	as (``free_huge_pages - resv_huge_pages``).
 Reserve Map
-	A reserve map is described by the structure:
-	struct resv_map {
-		struct kref refs;
-		spinlock_t lock;
-		struct list_head regions;
-		long adds_in_progress;
-		struct list_head region_cache;
-		long region_cache_count;
-	};
+	A reserve map is described by the structure::
+
+		struct resv_map {
+			struct kref refs;
+			spinlock_t lock;
+			struct list_head regions;
+			long adds_in_progress;
+			struct list_head region_cache;
+			long region_cache_count;
+		};
+
 	There is one reserve map for each huge page mapping in the system.
 	The regions list within the resv_map describes the regions within
-	the mapping.  A region is described as:
-	struct file_region {
-		struct list_head link;
-		long from;
-		long to;
-	};
+	the mapping.  A region is described as::
+
+		struct file_region {
+			struct list_head link;
+			long from;
+			long to;
+		};
+
 	The 'from' and 'to' fields of the file region structure are huge page
 	indices into the mapping.  Depending on the type of mapping, a
 	region in the reserv_map may indicate reservations exist for the
 	range, or reservations do not exist.
 Flags for MAP_PRIVATE Reservations
 	These are stored in the bottom bits of the reservation map pointer.
-	#define HPAGE_RESV_OWNER    (1UL << 0) Indicates this task is the
-		owner of the reservations associated with the mapping.
-	#define HPAGE_RESV_UNMAPPED (1UL << 1) Indicates task originally
-		mapping this range (and creating reserves) has unmapped a
-		page from this task (the child) due to a failed COW.
+
+	``#define HPAGE_RESV_OWNER    (1UL << 0)``
+		Indicates this task is the owner of the reservations
+		associated with the mapping.
+	``#define HPAGE_RESV_UNMAPPED (1UL << 1)``
+		Indicates task originally mapping this range (and creating
+		reserves) has unmapped a page from this task (the child)
+		due to a failed COW.
 Page Flags
 	The PagePrivate page flag is used to indicate that a huge page
 	reservation must be restored when the huge page is freed.  More
@@ -65,12 +80,14 @@ Page Flags
 
 
 Reservation Map Location (Private or Shared)
---------------------------------------------
+============================================
+
 A huge page mapping or segment is either private or shared.  If private,
 it is typically only available to a single address space (task).  If shared,
 it can be mapped into multiple address spaces (tasks).  The location and
 semantics of the reservation map is significantly different for two types
 of mappings.  Location differences are:
+
 - For private mappings, the reservation map hangs off the the VMA structure.
   Specifically, vma->vm_private_data.  This reserve map is created at the
   time the mapping (mmap(MAP_PRIVATE)) is created.
@@ -82,15 +99,15 @@ of mappings.  Location differences are:
 
 
 Creating Reservations
----------------------
+=====================
 Reservations are created when a huge page backed shared memory segment is
 created (shmget(SHM_HUGETLB)) or a mapping is created via mmap(MAP_HUGETLB).
-These operations result in a call to the routine hugetlb_reserve_pages()
+These operations result in a call to the routine hugetlb_reserve_pages()::
 
-int hugetlb_reserve_pages(struct inode *inode,
-					long from, long to,
-					struct vm_area_struct *vma,
-					vm_flags_t vm_flags)
+	int hugetlb_reserve_pages(struct inode *inode,
+				  long from, long to,
+				  struct vm_area_struct *vma,
+				  vm_flags_t vm_flags)
 
 The first thing hugetlb_reserve_pages() does is check for the NORESERVE
 flag was specified in either the shmget() or mmap() call.  If NORESERVE
@@ -105,6 +122,7 @@ the 'from' and 'to' arguments have been adjusted by this offset.
 
 One of the big differences between PRIVATE and SHARED mappings is the way
 in which reservations are represented in the reservation map.
+
 - For shared mappings, an entry in the reservation map indicates a reservation
   exists or did exist for the corresponding page.  As reservations are
   consumed, the reservation map is not modified.
@@ -121,12 +139,13 @@ to indicate this VMA owns the reservations.
 The reservation map is consulted to determine how many huge page reservations
 are needed for the current mapping/segment.  For private mappings, this is
 always the value (to - from).  However, for shared mappings it is possible that some reservations may already exist within the range (to - from).  See the
-section "Reservation Map Modifications" for details on how this is accomplished.
+section :ref:`Reservation Map Modifications <resv_map_modifications>`
+for details on how this is accomplished.
 
 The mapping may be associated with a subpool.  If so, the subpool is consulted
 to ensure there is sufficient space for the mapping.  It is possible that the
 subpool has set aside reservations that can be used for the mapping.  See the
-section "Subpool Reservations" for more details.
+section :ref:`Subpool Reservations <sub_pool_resv>` for more details.
 
 After consulting the reservation map and subpool, the number of needed new
 reservations is known.  The routine hugetlb_acct_memory() is called to check
@@ -135,9 +154,11 @@ calls into routines that potentially allocate and adjust surplus page counts.
 However, within those routines the code is simply checking to ensure there
 are enough free huge pages to accommodate the reservation.  If there are,
 the global reservation count resv_huge_pages is adjusted something like the
-following.
+following::
+
 	if (resv_needed <= (resv_huge_pages - free_huge_pages))
 		resv_huge_pages += resv_needed;
+
 Note that the global lock hugetlb_lock is held when checking and adjusting
 these counters.
 
@@ -152,14 +173,18 @@ If hugetlb_reserve_pages() was successful, the global reservation count and
 reservation map associated with the mapping will be modified as required to
 ensure reservations exist for the range 'from' - 'to'.
 
+.. _consume_resv:
 
 Consuming Reservations/Allocating a Huge Page
----------------------------------------------
+=============================================
+
 Reservations are consumed when huge pages associated with the reservations
 are allocated and instantiated in the corresponding mapping.  The allocation
-is performed within the routine alloc_huge_page().
-struct page *alloc_huge_page(struct vm_area_struct *vma,
-                                    unsigned long addr, int avoid_reserve)
+is performed within the routine alloc_huge_page()::
+
+	struct page *alloc_huge_page(struct vm_area_struct *vma,
+				     unsigned long addr, int avoid_reserve)
+
 alloc_huge_page is passed a VMA pointer and a virtual address, so it can
 consult the reservation map to determine if a reservation exists.  In addition,
 alloc_huge_page takes the argument avoid_reserve which indicates reserves
@@ -170,8 +195,9 @@ page are being allocated.
 
 The helper routine vma_needs_reservation() is called to determine if a
 reservation exists for the address within the mapping(vma).  See the section
-"Reservation Map Helper Routines" for detailed information on what this
-routine does.  The value returned from vma_needs_reservation() is generally
+:ref:`Reservation Map Helper Routines <resv_map_helpers>` for detailed
+information on what this routine does.
+The value returned from vma_needs_reservation() is generally
 0 or 1.  0 if a reservation exists for the address, 1 if no reservation exists.
 If a reservation does not exist, and there is a subpool associated with the
 mapping the subpool is consulted to determine if it contains reservations.
@@ -180,21 +206,25 @@ However, in every case the avoid_reserve argument overrides the use of
 a reservation for the allocation.  After determining whether a reservation
 exists and can be used for the allocation, the routine dequeue_huge_page_vma()
 is called.  This routine takes two arguments related to reservations:
+
 - avoid_reserve, this is the same value/argument passed to alloc_huge_page()
 - chg, even though this argument is of type long only the values 0 or 1 are
   passed to dequeue_huge_page_vma.  If the value is 0, it indicates a
   reservation exists (see the section "Memory Policy and Reservations" for
   possible issues).  If the value is 1, it indicates a reservation does not
   exist and the page must be taken from the global free pool if possible.
+
 The free lists associated with the memory policy of the VMA are searched for
 a free page.  If a page is found, the value free_huge_pages is decremented
 when the page is removed from the free list.  If there was a reservation
-associated with the page, the following adjustments are made:
+associated with the page, the following adjustments are made::
+
 	SetPagePrivate(page);	/* Indicates allocating this page consumed
 				 * a reservation, and if an error is
 				 * encountered such that the page must be
 				 * freed, the reservation will be restored. */
 	resv_huge_pages--;	/* Decrement the global reservation count */
+
 Note, if no huge page can be found that satisfies the VMA's memory policy
 an attempt will be made to allocate one using the buddy allocator.  This
 brings up the issue of surplus huge pages and overcommit which is beyond
@@ -222,12 +252,14 @@ mapping.  In such cases, the reservation count and subpool free page count
 will be off by one.  This rare condition can be identified by comparing the
 return value from vma_needs_reservation and vma_commit_reservation.  If such
 a race is detected, the subpool and global reserve counts are adjusted to
-compensate.  See the section "Reservation Map Helper Routines" for more
+compensate.  See the section
+:ref:`Reservation Map Helper Routines <resv_map_helpers>` for more
 information on these routines.
 
 
 Instantiate Huge Pages
-----------------------
+======================
+
 After huge page allocation, the page is typically added to the page tables
 of the allocating task.  Before this, pages in a shared mapping are added
 to the page cache and pages in private mappings are added to an anonymous
@@ -237,7 +269,8 @@ to the global reservation count (resv_huge_pages).
 
 
 Freeing Huge Pages
-------------------
+==================
+
 Huge page freeing is performed by the routine free_huge_page().  This routine
 is the destructor for hugetlbfs compound pages.  As a result, it is only
 passed a pointer to the page struct.  When a huge page is freed, reservation
@@ -247,7 +280,8 @@ on an error path where a global reserve count must be restored.
 
 The page->private field points to any subpool associated with the page.
 If the PagePrivate flag is set, it indicates the global reserve count should
-be adjusted (see the section "Consuming Reservations/Allocating a Huge Page"
+be adjusted (see the section
+:ref:`Consuming Reservations/Allocating a Huge Page <consume_resv>`
 for information on how these are set).
 
 The routine first calls hugepage_subpool_put_pages() for the page.  If this
@@ -259,9 +293,11 @@ Therefore, the global resv_huge_pages counter is incremented in this case.
 If the PagePrivate flag was set in the page, the global resv_huge_pages counter
 will always be incremented.
 
+.. _sub_pool_resv:
 
 Subpool Reservations
---------------------
+====================
+
 There is a struct hstate associated with each huge page size.  The hstate
 tracks all huge pages of the specified size.  A subpool represents a subset
 of pages within a hstate that is associated with a mounted hugetlbfs
@@ -295,7 +331,8 @@ the global pools.
 
 
 COW and Reservations
---------------------
+====================
+
 Since shared mappings all point to and use the same underlying pages, the
 biggest reservation concern for COW is private mappings.  In this case,
 two tasks can be pointing at the same previously allocated page.  One task
@@ -326,30 +363,36 @@ faults on a non-present page.  But, the original owner of the
 mapping/reservation will behave as expected.
 
 
+.. _resv_map_modifications:
+
 Reservation Map Modifications
------------------------------
+=============================
+
 The following low level routines are used to make modifications to a
 reservation map.  Typically, these routines are not called directly.  Rather,
 a reservation map helper routine is called which calls one of these low level
 routines.  These low level routines are fairly well documented in the source
-code (mm/hugetlb.c).  These routines are:
-long region_chg(struct resv_map *resv, long f, long t);
-long region_add(struct resv_map *resv, long f, long t);
-void region_abort(struct resv_map *resv, long f, long t);
-long region_count(struct resv_map *resv, long f, long t);
+code (mm/hugetlb.c).  These routines are::
+
+	long region_chg(struct resv_map *resv, long f, long t);
+	long region_add(struct resv_map *resv, long f, long t);
+	void region_abort(struct resv_map *resv, long f, long t);
+	long region_count(struct resv_map *resv, long f, long t);
 
 Operations on the reservation map typically involve two operations:
+
 1) region_chg() is called to examine the reserve map and determine how
    many pages in the specified range [f, t) are NOT currently represented.
 
    The calling code performs global checks and allocations to determine if
    there are enough huge pages for the operation to succeed.
 
-2a) If the operation can succeed, region_add() is called to actually modify
-    the reservation map for the same range [f, t) previously passed to
-    region_chg().
-2b) If the operation can not succeed, region_abort is called for the same range
-    [f, t) to abort the operation.
+2)
+  a) If the operation can succeed, region_add() is called to actually modify
+     the reservation map for the same range [f, t) previously passed to
+     region_chg().
+  b) If the operation can not succeed, region_abort is called for the same
+     range [f, t) to abort the operation.
 
 Note that this is a two step process where region_add() and region_abort()
 are guaranteed to succeed after a prior call to region_chg() for the same
@@ -371,6 +414,7 @@ and make the appropriate adjustments.
 
 The routine region_del() is called to remove regions from a reservation map.
 It is typically called in the following situations:
+
 - When a file in the hugetlbfs filesystem is being removed, the inode will
   be released and the reservation map freed.  Before freeing the reservation
   map, all the individual file_region structures must be freed.  In this case
@@ -384,6 +428,7 @@ It is typically called in the following situations:
   removed, region_del() is called to remove the corresponding entry from the
   reservation map.  In this case, region_del is passed the range
   [page_idx, page_idx + 1).
+
 In every case, region_del() will return the number of pages removed from the
 reservation map.  In VERY rare cases, region_del() can fail.  This can only
 happen in the hole punch case where it has to split an existing file_region
@@ -403,9 +448,11 @@ outstanding (outstanding = (end - start) - region_count(resv, start, end)).
 Since the mapping is going away, the subpool and global reservation counts
 are decremented by the number of outstanding reservations.
 
+.. _resv_map_helpers:
 
 Reservation Map Helper Routines
--------------------------------
+===============================
+
 Several helper routines exist to query and modify the reservation maps.
 These routines are only interested with reservations for a specific huge
 page, so they just pass in an address instead of a range.  In addition,
@@ -414,32 +461,40 @@ or shared) and the location of the reservation map (inode or VMA) can be
 determined.  These routines simply call the underlying routines described
 in the section "Reservation Map Modifications".  However, they do take into
 account the 'opposite' meaning of reservation map entries for private and
-shared mappings and hide this detail from the caller.
+shared mappings and hide this detail from the caller::
+
+	long vma_needs_reservation(struct hstate *h,
+				   struct vm_area_struct *vma,
+				   unsigned long addr)
 
-long vma_needs_reservation(struct hstate *h,
-				struct vm_area_struct *vma, unsigned long addr)
 This routine calls region_chg() for the specified page.  If no reservation
-exists, 1 is returned.  If a reservation exists, 0 is returned.
+exists, 1 is returned.  If a reservation exists, 0 is returned::
+
+	long vma_commit_reservation(struct hstate *h,
+				    struct vm_area_struct *vma,
+				    unsigned long addr)
 
-long vma_commit_reservation(struct hstate *h,
-				struct vm_area_struct *vma, unsigned long addr)
 This calls region_add() for the specified page.  As in the case of region_chg
 and region_add, this routine is to be called after a previous call to
 vma_needs_reservation.  It will add a reservation entry for the page.  It
 returns 1 if the reservation was added and 0 if not.  The return value should
 be compared with the return value of the previous call to
 vma_needs_reservation.  An unexpected difference indicates the reservation
-map was modified between calls.
+map was modified between calls::
+
+	void vma_end_reservation(struct hstate *h,
+				 struct vm_area_struct *vma,
+				 unsigned long addr)
 
-void vma_end_reservation(struct hstate *h,
-				struct vm_area_struct *vma, unsigned long addr)
 This calls region_abort() for the specified page.  As in the case of region_chg
 and region_abort, this routine is to be called after a previous call to
 vma_needs_reservation.  It will abort/end the in progress reservation add
-operation.
+operation::
+
+	long vma_add_reservation(struct hstate *h,
+				 struct vm_area_struct *vma,
+				 unsigned long addr)
 
-long vma_add_reservation(struct hstate *h,
-				struct vm_area_struct *vma, unsigned long addr)
 This is a special wrapper routine to help facilitate reservation cleanup
 on error paths.  It is only called from the routine restore_reserve_on_error().
 This routine is used in conjunction with vma_needs_reservation in an attempt
@@ -453,8 +508,10 @@ be done on error paths.
 
 
 Reservation Cleanup in Error Paths
-----------------------------------
-As mentioned in the section "Reservation Map Helper Routines", reservation
+==================================
+
+As mentioned in the section
+:ref:`Reservation Map Helper Routines <resv_map_helpers>`, reservation
 map modifications are performed in two steps.  First vma_needs_reservation
 is called before a page is allocated.  If the allocation is successful,
 then vma_commit_reservation is called.  If not, vma_end_reservation is called.
@@ -494,13 +551,14 @@ so that a reservation will not be leaked when the huge page is freed.
 
 
 Reservations and Memory Policy
-------------------------------
+==============================
 Per-node huge page lists existed in struct hstate when git was first used
 to manage Linux code.  The concept of reservations was added some time later.
 When reservations were added, no attempt was made to take memory policy
 into account.  While cpusets are not exactly the same as memory policy, this
 comment in hugetlb_acct_memory sums up the interaction between reservations
-and cpusets/memory policy.
+and cpusets/memory policy::
+
 	/*
 	 * When cpuset is configured, it breaks the strict hugetlb page
 	 * reservation as the accounting is done on a global variable. Such
-- 
2.7.4
