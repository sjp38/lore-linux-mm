Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id DEFB36B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 02:46:43 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id um1so12044692pbc.20
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 23:46:43 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id dk5si36045629pbc.286.2013.11.27.23.46.41
        for <linux-mm@kvack.org>;
        Wed, 27 Nov 2013 23:46:42 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 0/9] mm/rmap: unify rmap traversing functions through rmap_walk
Date: Thu, 28 Nov 2013 16:48:37 +0900
Message-Id: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Rmap traversing is used in five different cases, try_to_unmap(),
try_to_munlock(), page_referenced(), page_mkclean() and
remove_migration_ptes(). Each one implements its own traversing functions
for the cases, anon, file, ksm, respectively. These cause lots of duplications
and cause maintenance overhead. They also make codes being hard to understand
and error-prone. One example is hugepage handling. There is a code to compute
hugepage offset correctly in try_to_unmap_file(), but, there isn't a code
to compute hugepage offset in rmap_walk_file(). These are used pairwise
in migration context, but we missed to modify pairwise.

To overcome these drawbacks, we should unify these through one unified
function. I decide rmap_walk() as main function since it has no
unnecessity. And to control behavior of rmap_walk(), I introduce
struct rmap_walk_control having some function pointers. These makes
rmap_walk() working for their specific needs.

This patchset remove a lot of duplicated code as you can see in below
short-stat and kernel text size also decrease slightly.

   text    data     bss     dec     hex filename
  10640       1      16   10657    29a1 mm/rmap.o
  10047       1      16   10064    2750 mm/rmap.o

  13823     705    8288   22816    5920 mm/ksm.o
  13199     705    8288   22192    56b0 mm/ksm.o

Thanks.

Joonsoo Kim (9):
  mm/rmap: recompute pgoff for huge page
  mm/rmap: factor nonlinear handling out of try_to_unmap_file()
  mm/rmap: factor lock function out of rmap_walk_anon()
  mm/rmap: make rmap_walk to get the rmap_walk_control argument
  mm/rmap: extend rmap_walk_xxx() to cope with different cases
  mm/rmap: use rmap_walk() in try_to_unmap()
  mm/rmap: use rmap_walk() in try_to_munlock()
  mm/rmap: use rmap_walk() in page_referenced()
  mm/rmap: use rmap_walk() in page_mkclean()

 include/linux/ksm.h  |   15 +-
 include/linux/rmap.h |   19 +-
 mm/ksm.c             |  116 +---------
 mm/migrate.c         |    7 +-
 mm/rmap.c            |  570 ++++++++++++++++++++++----------------------------
 5 files changed, 286 insertions(+), 441 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
