Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A0CDE6B025E
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 13:26:30 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p5so22550478pgn.7
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 10:26:30 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t12si5553177pgs.36.2017.09.26.10.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 10:26:29 -0700 (PDT)
From: Shaohua Li <shli@kernel.org>
Subject: [PATCH V3 0/2] mm: fix race condition in MADV_FREE
Date: Tue, 26 Sep 2017 10:26:24 -0700
Message-Id: <cover.1506446061.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: asavkov@redhat.com, Kernel-team@fb.com, Shaohua Li <shli@fb.com>

From: Shaohua Li <shli@fb.com>

Artem Savkov reported a race condition[1] in MADV_FREE. MADV_FREE clear pte
dirty bit and then mark the page lazyfree. There is no lock to prevent the
page is added to swap cache between these two steps by page reclaim. There are
two problems:
- page in swapcache is marked lazyfree (clear SwapBacked). This confuses some
  code pathes, like page fault handling.
- The page is added into swapcache, and freed but the page isn't swapout
  because pte isn't dirty. This will cause data corruption.

The patches will fix the issues.

I knew Minchan suggested these should be combined to one patch, but I really
think the separation makes things clearer because these are two issues even
they are stemmed from the same race.

Thanks,
Shaohua

V2->V3:
- reword patch log and code comments, no code change

V1->V2:
- dirty page in add_to_swap instead of in shrink_page_list as suggested by Minchan

Shaohua Li (2):
  mm: avoid marking swap cached page as lazyfree
  mm: fix data corruption caused by lazyfree page

 mm/swap.c       |  4 ++--
 mm/swap_state.c | 11 +++++++++++
 2 files changed, 13 insertions(+), 2 deletions(-)

-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
