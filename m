Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8QK18J9032609
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 16:01:08 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8QK18dF090788
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 16:01:08 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j8QK18Ej022359
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 16:01:08 -0400
Message-ID: <4338537E.8070603@austin.ibm.com>
Date: Mon, 26 Sep 2005 15:01:02 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 0/9] fragmentation avoidance
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: lhms <lhms-devel@lists.sourceforge.net>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Mike Kravetz <kravetz@us.ibm.com>, jschopp@austin.ibm.com
List-ID: <linux-mm.kvack.org>

The buddy system provides an efficient algorithm for managing a set of pages
within each zone. Despite the proven effectiveness of the algorithm in its
current form as used in the kernel, it is not possible to aggregate a subset
of pages within a zone according to specific allocation types. As a result,
two physically contiguous page frames (or sets of page frames) may satisfy
allocation requests that are drastically different. For example, one page
frame may contain data that is only temporarily used by an application while
the other is in use for a kernel device driver.  This can result in heavy
system fragmentation.

This series of patches is designed to reduce fragmentation in the standard
buddy allocator without impairing the performance of the allocator. High
fragmentation in the standard binary buddy allocator means that high-order
allocations can rarely be serviced. These patches work by dividing allocations
into three different types of allocations;

UserReclaimable - These are userspace pages that are easily reclaimable. Right
	now, all allocations of GFP_USER, GFP_HIGHUSER and disk buffers are
	in this category. These pages are trivially reclaimed by writing
	the page out to swap or syncing with backing storage

KernelReclaimable - These are pages allocated by the kernel that are easily
	reclaimed. This is stuff like inode caches, dcache, buffer_heads etc.
	These type of pages potentially could be reclaimed by dumping the
	caches and reaping the slabs

KernelNonReclaimable - These are pages that are allocated by the kernel that
	are not trivially reclaimed. For example, the memory allocated for a
	loaded module would be in this category. By default, allocations are
	considered to be of this type

Instead of having one global MAX_ORDER-sized array of free lists, there
are four, one for each type of allocation and another 12.5% reserve for
fallbacks. Finally, there is a list of pages of size 2^MAX_ORDER which is
a global pool of the largest pages the kernel deals with.

Once a 2^MAX_ORDER block of pages it split for a type of allocation, it is
added to the free-lists for that type, in effect reserving it. Hence, over
time, pages of the different types can be clustered together. This means that
if we wanted 2^MAX_ORDER number of pages, we could linearly scan a block of
pages allocated for UserReclaimable and page each of them out.

Fallback is used when there are no 2^MAX_ORDER pages available and there
are no free pages of the desired type. The fallback lists were chosen in a
way that keeps the most easily reclaimable pages together.

These patches originally were discussed as "Avoiding external fragmentation
with a placement policy" as authored by Mel Gorman and went through about 13
revisions on lkml and linux-mm.  Then with Mel's permission I have been
reworking these patches for easier mergability, readability, maintainability,
etc.  Several revisions have been posted on lhms-devel, as the Linux memory
hotplug community will be a major beneficiary of these patches.  All of the
various revisions have been tested on various platforms and shown to perform
well.  I believe the patches are now ready for inclusion in -mm, and after
wider testing inclusion in the mainline kernel.

The patch set consists of 9 patches that can be merged in 4 separate blocks,
with the only dependency being that the lower numbered patches are merged
first.  All are against 2.6.13.
Patch 1 defines the allocation flags and adds them to the allocator calls.
Patch 2 defines some new structures and the macros used to access them.
Patch 3-8 implement the fully functional fragmentation avoidance.
Patch 9 is trivial but useful for memory hotplug remove.
---
Patch 10 -- not ready for merging -- extends fragmentation avoidance to the
percpu allocator.  This patch works on 2.6.13-rc1 but only with NUMA off on
2.6.13; I am having a great deal of trouble tracking down why, help would be
appreciated.  I include the patch for review and test purposes as I plan to
submit it for merging after resolving the NUMA issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
