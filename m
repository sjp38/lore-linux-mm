Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B9DCB6B16E9
	for <linux-mm@kvack.org>; Sun, 19 Aug 2018 23:22:09 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id t81-v6so13661737qkt.7
        for <linux-mm@kvack.org>; Sun, 19 Aug 2018 20:22:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a3-v6si4283830qkb.265.2018.08.19.20.22.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Aug 2018 20:22:08 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/2] fix for "pathological THP behavior"
Date: Sun, 19 Aug 2018 23:22:02 -0400
Message-Id: <20180820032204.9591-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

Hello,

we detected a regression compared to older kernels, only happening
with defrag=always or by using MADV_HUGEPAGE (and QEMU uses it).

I haven't bisected but I suppose this started since commit
5265047ac30191ea24b16503165000c225f54feb combined with previous
commits that introduced the logic to not try to invoke reclaim for THP
allocations in the remote nodes.

Once I looked into it the problem was pretty obvious and there are two
possible simple fixes, one is not to invoke reclaim and stick to
compaction in the local node only (still __GFP_THISNODE model).

This approach keeps the logic the same and prioritizes for NUMA
locality over THP generation.

Then I'll send the an alternative that drops the __GFP_THISNODE logic
if_DIRECT_RECLAIM is set. That however changes the behavior for
MADV_HUGEPAGE and prioritizes THP generation over NUMA locality.

A possible incremental improvement for this __GFP_COMPACT_ONLY
solution would be to remove __GFP_THISNODE (and in turn
__GFP_COMPACT_ONLY) after checking the watermarks if there's no free
PAGE_SIZEd memory in the local node. However checking the watermarks
in mempolicy.c is not ideal so it would be a more messy change and
it'd still need to use __GFP_COMPACT_ONLY as implemented here for when
there's no PAGE_SIZEd free memory in the local node. That further
improvement wouldn't be necessary if there's agreement to prioritize
THP generation over NUMA locality (the alternative solution I'll send
in a separate post).

Andrea Arcangeli (2):
  mm: thp: consolidate policy_nodemask call
  mm: thp: fix transparent_hugepage/defrag = madvise || always

 include/linux/gfp.h | 18 ++++++++++++++++++
 mm/mempolicy.c      | 16 +++++++++++++---
 mm/page_alloc.c     |  4 ++++
 3 files changed, 35 insertions(+), 3 deletions(-)
