Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f51.google.com (mail-oa0-f51.google.com [209.85.219.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3A56B0037
	for <linux-mm@kvack.org>; Sun, 26 Jan 2014 22:52:53 -0500 (EST)
Received: by mail-oa0-f51.google.com with SMTP id h16so6128598oag.38
        for <linux-mm@kvack.org>; Sun, 26 Jan 2014 19:52:53 -0800 (PST)
Received: from g4t0016.houston.hp.com (g4t0016.houston.hp.com. [15.201.24.19])
        by mx.google.com with ESMTPS id f4si4480665oel.79.2014.01.26.19.52.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 26 Jan 2014 19:52:51 -0800 (PST)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 0/8] mm, hugetlb: fixes and fault scalability
Date: Sun, 26 Jan 2014 19:52:18 -0800
Message-Id: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com
Cc: riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, dhillf@gmail.com, rientjes@google.com, davidlohr@hp.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patchset resumes the work to improve the whole hugepage fault
scalability path. Previous efforts can be found here:

https://lkml.org/lkml/2013/7/26/299
https://lkml.org/lkml/2013/12/18/50

The latest attempt to address the big-fat hugetlb instantiation mutex by
removing the need for it altogether ended up having too much of an overhead
to consider and allow scalability. The discussion can be found at:
https://lkml.org/lkml/2014/1/3/244

This patchset is divided in three parts, where the first seven patches,
from Joonsoo, have been included and reviewed in previous patchsets. The 
last patch is the actual performance one.

Part 1. (1-3) Introduce new protection method for region tracking 
	data structure, instead of the hugetlb_instantiation_mutex. There
	is race condition when we map the hugetlbfs file to two different
	processes. To prevent it, we need to new protection method like
	as this patchset.

Part 2. (4-7) clean-up.

	These make code really simple, so these are worth to go into
	mainline separately.

Part 4 (8) Use a table of mutexes instead of a unique one, and allow
        faults to be handled in parallel. Benefits and caveats to this
        approach are in the patch.

All changes have passed the libhugetblfs test cases.
This patchset applies on top of Linus' current tree (3.13-77d143de)

Thanks!

  mm, hugetlb: unify region structure handling
  mm, hugetlb: region manipulation functions take resv_map rather
    list_head
  mm, hugetlb: fix race in region tracking
  mm, hugetlb: remove resv_map_put
  mm, hugetlb: use vma_resv_map() map types
  mm, hugetlb: remove vma_has_reserves
  mm, hugetlb: mm, hugetlb: unify chg and avoid_reserve to use_reserve
  mm, hugetlb: improve page-fault scalability

 fs/hugetlbfs/inode.c    |  17 ++-
 include/linux/hugetlb.h |  10 ++
 mm/hugetlb.c            | 323 +++++++++++++++++++++++++++---------------------
 3 files changed, 206 insertions(+), 144 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
