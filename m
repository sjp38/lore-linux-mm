Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 526846B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 01:54:08 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kl14so5489129pab.5
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 22:54:07 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id wh6si13516242pac.306.2013.12.17.22.54.05
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 22:54:06 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 00/14] mm, hugetlb: remove a hugetlb_instantiation_mutex
Date: Wed, 18 Dec 2013 15:53:46 +0900
Message-Id: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

* NOTE for v3
- Updating patchset is so late because of other works, not issue from
this patchset.

- While reviewing v2, David Gibson who had tried to remove this mutex long
time ago suggested that the race between concurrent call to
alloc_buddy_huge_page() in alloc_huge_page() is also prevented[2] since
this *new* hugepage from it is also contended page for the last allocation.
But I think that it is useless, since if some application's success depends
on the *new* hugepage from alloc_buddy_huge_page() rather than *reserved*
page, it's successful running cannot be guaranteed all the times. So I
don't implement it. Except this issue, there is no issue to this patchset.

* Changes in v3 (No big difference)
- Slightly modify cover-letter since Part 1. is already mereged.
- On patch 1-12, add Reviewed-by from "Aneesh Kumar K.V".
- Patches 1-12 and 14 are just rebased onto v3.13-rc4.
- Patch 13 is changed as following.
	add comment on alloc_huge_page()
	add in-flight user handling in alloc_huge_page_noerr()
	minor code position changes (Suggested by David)

* Changes in v2
- Re-order patches to clear it's relationship
- sleepable object allocation(kmalloc) without holding a spinlock
	(Pointed by Hillf)
- Remove vma_has_reserves, instead of vma_needs_reservation.
	(Suggest by Aneesh and Naoya)
- Change a way of returning a hugepage back to reserved pool
	(Suggedt by Naoya)

Without a hugetlb_instantiation_mutex, if parallel fault occur, we can
fail to allocate a hugepage, because many threads dequeue a hugepage
to handle a fault of same address. This makes reserved pool shortage
just for a little while and this causes faulting thread to get a SIGBUS
signal, although there are enough hugepages.

To solve this problem, we already have a nice solution, that is,
a hugetlb_instantiation_mutex. This blocks other threads to dive into
a fault handler. This solve the problem clearly, but it introduce
performance degradation, because it serialize all fault handling.
    
Now, I try to remove a hugetlb_instantiation_mutex to get rid of
performance problem reported by Davidlohr Bueso [1].

This patchset consist of 4 parts roughly.

Part 1. (Merged) Random fix and clean-up to enhance error handling.
	These are already merged to mainline.

Part 2. (1-3) introduce new protection method for region tracking 
	data structure, instead of the hugetlb_instantiation_mutex. There
	is race condition when we map the hugetlbfs file to two different
	processes. To prevent it, we need to new protection method like
	as this patchset.
	
	This can be merged into mainline separately.

Part 3. (4-7) clean-up.
	
	IMO, these make code really simple, so these are worth to go into
	mainline separately.

Part 4. (8-14) remove a hugetlb_instantiation_mutex.
	
	Almost patches are just for clean-up to error handling path.
	In patch 13, retry approach is implemented that if faulted thread
	failed to allocate a hugepage, it continue to run a fault handler
	until there is no concurrent thread having a hugepage. This causes
	threads who want to get a last hugepage to be serialized, so
	threads don't get a SIGBUS if enough hugepage exist.
	In patch 14, remove a hugetlb_instantiation_mutex.

These patches are based on v3.13-rc4.

With applying these, I passed a libhugetlbfs test suite clearly which
have allocation-instantiation race test cases.

If there is something I should consider, please let me know!
Thanks.

[1] http://lwn.net/Articles/558863/ 
	"[PATCH] mm/hugetlb: per-vma instantiation mutexes"
[2] https://lkml.org/lkml/2013/9/4/630

Joonsoo Kim (14):
  mm, hugetlb: unify region structure handling
  mm, hugetlb: region manipulation functions take resv_map rather
    list_head
  mm, hugetlb: protect region tracking via newly introduced resv_map
    lock
  mm, hugetlb: remove resv_map_put()
  mm, hugetlb: make vma_resv_map() works for all mapping type
  mm, hugetlb: remove vma_has_reserves()
  mm, hugetlb: mm, hugetlb: unify chg and avoid_reserve to use_reserve
  mm, hugetlb: call vma_needs_reservation before entering
    alloc_huge_page()
  mm, hugetlb: remove a check for return value of alloc_huge_page()
  mm, hugetlb: move down outside_reserve check
  mm, hugetlb: move up anon_vma_prepare()
  mm, hugetlb: clean-up error handling in hugetlb_cow()
  mm, hugetlb: retry if failed to allocate and there is concurrent user
  mm, hugetlb: remove a hugetlb_instantiation_mutex

 fs/hugetlbfs/inode.c    |   17 +-
 include/linux/hugetlb.h |   11 ++
 mm/hugetlb.c            |  401 +++++++++++++++++++++++++----------------------
 3 files changed, 241 insertions(+), 188 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
