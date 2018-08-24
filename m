Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBB4C6B2EED
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 05:32:28 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id p22-v6so3692354pfj.7
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 02:32:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 192-v6sor1602228pgf.194.2018.08.24.02.32.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 02:32:27 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] tools/vm/slabinfo.c: fix sign-compare warning
Date: Fri, 24 Aug 2018 18:32:14 +0900
Message-Id: <1535103134-20239-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>

Currently we get the following compiler warning:

    slabinfo.c:854:22: warning: comparison between signed and unsigned integer expressions [-Wsign-compare]
       if (s->object_size < min_objsize)
                          ^

due to the mismatch of signed/unsigned comparison. ->object_size and
->slab_size are never expected to be negative, so let's define them
as unsigned int.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 tools/vm/slabinfo.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git v4.18-mmotm-2018-08-17-15-48/tools/vm/slabinfo.c v4.18-mmotm-2018-08-17-15-48_patched/tools/vm/slabinfo.c
index f82c2ea..eebeeb1 100644
--- v4.18-mmotm-2018-08-17-15-48/tools/vm/slabinfo.c
+++ v4.18-mmotm-2018-08-17-15-48_patched/tools/vm/slabinfo.c
@@ -30,9 +30,10 @@ struct slabinfo {
 	int alias;
 	int refs;
 	int aliases, align, cache_dma, cpu_slabs, destroy_by_rcu;
-	int hwcache_align, object_size, objs_per_slab;
-	int sanity_checks, slab_size, store_user, trace;
+	int hwcache_align, objs_per_slab;
+	int sanity_checks, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
+	unsigned int object_size, slab_size;
 	unsigned long partial, objects, slabs, objects_partial, objects_total;
 	unsigned long alloc_fastpath, alloc_slowpath;
 	unsigned long free_fastpath, free_slowpath;
-- 
2.7.0
