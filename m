Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id B0F7F828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 10:14:41 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id w123so15418595pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 07:14:41 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id p11si9848291par.72.2016.02.03.07.14.40
        for <linux-mm@kvack.org>;
        Wed, 03 Feb 2016 07:14:40 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/4] thp: simplify freeze_page() and unfreeze_page()
Date: Wed,  3 Feb 2016 18:14:15 +0300
Message-Id: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patchset rewrites freeze_page() and unfreeze_page() using try_to_unmap()
and remove_migration_ptes(). Result is much simplier, but somewhat slower.
See the last patch for details.

I did quick sanity check. More testing is required.

Any comments?

Kirill A. Shutemov (4):
  rmap: introduce rmap_walk_locked()
  rmap: extend try_to_unmap() to be usable by split_huge_page()
  mm: make remove_migration_ptes() beyond mm/migration.c
  thp: rewrite freeze_page()/unfreeze_page() with generic rmap walkers

 include/linux/huge_mm.h |   7 ++
 include/linux/rmap.h    |   6 ++
 mm/huge_memory.c        | 219 ++++++------------------------------------------
 mm/migrate.c            |  13 +--
 mm/rmap.c               |  49 ++++++++---
 5 files changed, 83 insertions(+), 211 deletions(-)

-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
