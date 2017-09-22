Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BEA716B0253
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 14:46:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r83so3155603pfj.5
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 11:46:35 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 73si232683pfu.496.2017.09.22.11.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Sep 2017 11:46:34 -0700 (PDT)
From: Shaohua Li <shli@kernel.org>
Subject: [PATCH V2 0/2] mm: fix race condition in MADV_FREE
Date: Fri, 22 Sep 2017 11:46:29 -0700
Message-Id: <cover.1506105110.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Artem Savkov <asavkov@redhat.com>, Kernel-team@fb.com, Shaohua Li <shli@fb.com>

From: Shaohua Li <shli@fb.com>

Artem Savkov reported a race condition[1] in MADV_FREE. MADV_FREE clear pte
dirty bit and then mark the page lazyfree. There is no lock to prevent the
page is added to swap cache between these two steps by page reclaim. There are
two problems:
- page in swapcache is marked lazyfree (clear SwapBacked). This confuses some
  code pathes, like page fault handling.
- The page is added into swapcache, and freed but the page isn't swapout
  because pte isn't dity. This will cause data corruption.

The patches will fix the issues.

Thanks,
Shaohua

V1->V2:
- dirty page in add_to_swap instead of in shrink_page_list as suggested by Minchan

Shaohua Li (2):
  mm: avoid marking swap cached page as lazyfree
  mm: fix data corruption caused by lazyfree page

 mm/swap.c       | 4 ++--
 mm/swap_state.c | 3 ++-
 2 files changed, 4 insertions(+), 3 deletions(-)

-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
