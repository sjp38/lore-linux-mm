Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 633496B0031
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 12:36:59 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id wp4so5321480obc.2
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 09:36:59 -0800 (PST)
Received: from g1t0026.austin.hp.com (g1t0026.austin.hp.com. [15.216.28.33])
        by mx.google.com with ESMTPS id rj3si5210784oeb.3.2014.01.31.09.36.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jan 2014 09:36:58 -0800 (PST)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH v2 0/6] mm, hugetlb: fixes and fault scalability
Date: Fri, 31 Jan 2014 09:36:40 -0800
Message-Id: <1391189806-13319-1-git-send-email-davidlohr@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com
Cc: riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, dhillf@gmail.com, rientjes@google.com, davidlohr@hp.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Changes from v1 (http://lkml.org/lkml/2014/1/26/219), based on feedback 
from Naoya Horiguchi:
- Dropped cleanup patches 6 & 7.

- Re did patch 3, fixing some potential use after free for new
  regions.

- Cleaned up patch 5.

- Added review tags.

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
A A A A A A A A data structure, instead of the hugetlb_instantiation_mutex. There
A A A A A A A A is race condition when we map the hugetlbfs file to two different
A A A A A A A A processes. To prevent it, we need to new protection method like
A A A A A A A A as this patchset.

Part 2. (4-5) clean-up.

A A A A A A A A These make code really simple, so these are worth to go into
A A A A A A A A mainline separately.

Part 3 (6) Use a table of mutexes instead of a unique one, and allow
A A A A A A A  faults to be handled in parallel. Benefits and caveats to this
A A A A A A A  approach are in the patch.

All changes have passed the libhugetblfs test cases.
This patchset applies on top of Linus' current tree (3.13-e7651b81).

  mm, hugetlb: unify region structure handling
  mm, hugetlb: improve, cleanup resv_map parameters
  mm, hugetlb: fix race in region tracking
  mm, hugetlb: remove resv_map_put
  mm, hugetlb: use vma_resv_map() map types
  mm, hugetlb: improve page-fault scalability

 fs/hugetlbfs/inode.c    |  17 ++-
 include/linux/hugetlb.h |  10 ++
 mm/hugetlb.c            | 286 ++++++++++++++++++++++++++++++------------------
 3 files changed, 204 insertions(+), 109 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
