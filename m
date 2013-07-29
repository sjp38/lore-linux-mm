Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 4913F6B0033
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 01:32:21 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 00/18] mm, hugetlb: remove a hugetlb_instantiation_mutex
Date: Mon, 29 Jul 2013 14:31:51 +0900
Message-Id: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Without a hugetlb_instantiation_mutex, if parallel fault occur, we can
fail to allocate a hugepage, because many threads dequeue a hugepage
to handle a fault of same address. This makes reserved pool shortage
just for a little while and this cause faulting thread who is ensured
to have enough reserved hugepages to get a SIGBUS signal.

To solve this problem, we already have a nice solution, that is,
a hugetlb_instantiation_mutex. This blocks other threads to dive into
a fault handler. This solve the problem clearly, but it introduce
performance degradation, because it serialize all fault handling.
    
Now, I try to remove a hugetlb_instantiation_mutex to get rid of
performance problem reported by Davidlohr Bueso [1].

It is implemented by following 3-steps.

Step 1.	Protect region tracking via per region spin_lock.

	Currently, region tracking is protected by a
	hugetlb_instantiation_mutex, so before removing it, we should
	replace it with another solution.

Step 2.	Decide whether we use reserved page pool or not by an uniform way.

	We need a graceful failure handling if there is no lock like as
	hugetlb_instantiation_mutex. To decide whether we need to handle
	a failure or not, we need to know current status properly.

Step 3.	Graceful failure handling if we failed with reserved page or
	failed to allocate with use_reserve.

	Failure handling consist of two cases. One is if we failed with
	having reserved page, we return back to reserved pool properly.
	Current code doesn't recover a reserve count properly, so we need
	to fix it. The other is if we failed to allocate a new huge page
	with use_reserve indicator, we return 0 to fault handler,
	instead of SIGBUS. This makes this thread retrying fault handling.
	With above handlings, we can succeed to handle a fault
	on any situation without a hugetlb_instantiation_mutex.

Patch 1: Fix a minor problem
Patch 2-5: Implement Step 1.
Patch 6-11: Implement Step 2.
Patch 12-18: Implement Step 3.

These patches are based on my previous patchset [2].
[2] is based on v3.10.

With applying these, I passed a libhugetlbfs test suite clearly which
have allocation-instantiation race test cases.

If there is a something I should consider, please let me know!
Thanks.

[1] http://lwn.net/Articles/558863/ 
	"[PATCH] mm/hugetlb: per-vma instantiation mutexes"
[2] https://lkml.org/lkml/2013/7/22/96
	"[PATCH v2 00/10] mm, hugetlb: clean-up and possible bug fix"


Joonsoo Kim (18):
  mm, hugetlb: protect reserved pages when softofflining requests the
    pages
  mm, hugetlb: change variable name reservations to resv
  mm, hugetlb: unify region structure handling
  mm, hugetlb: region manipulation functions take resv_map rather
    list_head
  mm, hugetlb: protect region tracking via newly introduced resv_map
    lock
  mm, hugetlb: remove vma_need_reservation()
  mm, hugetlb: pass has_reserve to dequeue_huge_page_vma()
  mm, hugetlb: do hugepage_subpool_get_pages() when avoid_reserve
  mm, hugetlb: unify has_reserve and avoid_reserve to use_reserve
  mm, hugetlb: call vma_has_reserve() before entering alloc_huge_page()
  mm, hugetlb: move down outside_reserve check
  mm, hugetlb: remove a check for return value of alloc_huge_page()
  mm, hugetlb: grab a page_table_lock after page_cache_release
  mm, hugetlb: clean-up error handling in hugetlb_cow()
  mm, hugetlb: move up anon_vma_prepare()
  mm, hugetlb: return a reserved page to a reserved pool if failed
  mm, hugetlb: retry if we fail to allocate a hugepage with use_reserve
  mm, hugetlb: remove a hugetlb_instantiation_mutex

 fs/hugetlbfs/inode.c    |   12 +-
 include/linux/hugetlb.h |   10 ++
 mm/hugetlb.c            |  361 +++++++++++++++++++++++++----------------------
 3 files changed, 217 insertions(+), 166 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
