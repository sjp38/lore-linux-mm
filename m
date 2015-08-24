Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4A29003CA
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 18:16:12 -0400 (EDT)
Received: by pdob1 with SMTP id b1so58138050pdo.2
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 15:16:11 -0700 (PDT)
Received: from mail1.windriver.com (mail1.windriver.com. [147.11.146.13])
        by mx.google.com with ESMTPS id bc7si29641537pdb.228.2015.08.24.15.16.10
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 15:16:11 -0700 (PDT)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 00/10] mm: fix instances of non-modular code using modular fcns
Date: Mon, 24 Aug 2015 18:14:32 -0400
Message-ID: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrey Konovalov <adech.fo@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Christoph Lameter <cl@linux.com>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Pekka Enberg <penberg@kernel.org>, Rob Jones <rob.jones@codethink.co.uk>, Roman Pen <r.peniaev@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Toshi Kani <toshi.kani@hp.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, WANG Chao <chaowang@redhat.com>

In the previous merge window, we made changes to allow better
delineation between modular and non-modular code in commit
0fd972a7d91d6e15393c449492a04d94c0b89351 ("module: relocate module_init
from init.h to module.h").  This allows us to now ensure module code
looks modular and non-modular code does not accidentally look modular
without suffering build breakage from header entanglement.
  
Here we target mm code that is, by nature of their Kconfig/Makefile, only
available to be built-in, but implicitly presenting itself as being
possibly modular by way of using modular headers and macros.
  
The goal here is to remove that illusion of modularity from these
files, but in a way that leaves the actual runtime unchanged.
We also get the side benefit of a reduced CPP overhead, since the
removal of module.h from a file can reduce the number of lines emitted
by 20k.

In all but the hugetlb change, the change is the trivial remapping
of module_init onto device_initcall -- which is what module_init 
becomes in the non-modular case.  In the hugetlb case, there was also
an unused/orphaned module_exit chunk of code that got removed.

I considered using an alternate level (i.e. earlier) initcall but
since we don't have an mm initcall category, there wasn't a clear
choice.  And staying with device initcall reduces this patch series
to zero risk by keeping the status quo on init order processing, which
is I think preferable as we approach the merge window in a week.

Paul.
---

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <adech.fo@gmail.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: David Rientjes <rientjes@google.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Rob Jones <rob.jones@codethink.co.uk>
Cc: Roman Pen <r.peniaev@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: WANG Chao <chaowang@redhat.com>
Cc: linux-mm@kvack.org


Paul Gortmaker (10):
  mm: make cleancache.c explicitly non-modular
  mm: make slab_common.c explicitly non-modular
  mm: make hugetlb.c explicitly non-modular
  mm: make vmscan.c explicitly non-modular
  mm: make page_alloc.c explicitly non-modular
  mm: make vmstat.c explicitly non-modular
  mm: make workingset.c explicitly non-modular
  mm: make vmalloc.c explicitly non-modular
  mm: make frontswap.c explicitly non-modular
  mm: make kasan.c explicitly non-modular

 mm/cleancache.c  |  4 ++--
 mm/frontswap.c   |  5 ++---
 mm/hugetlb.c     | 39 +--------------------------------------
 mm/kasan/kasan.c |  4 +---
 mm/page_alloc.c  |  2 +-
 mm/slab_common.c |  4 ++--
 mm/vmalloc.c     |  4 ++--
 mm/vmscan.c      |  4 +---
 mm/vmstat.c      |  7 +++----
 mm/workingset.c  |  4 ++--
 10 files changed, 17 insertions(+), 60 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
