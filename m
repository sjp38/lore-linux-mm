Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 743726B0007
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 12:58:40 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l9-v6so6495409qtp.23
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 09:58:40 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h49-v6si7959718qtc.197.2018.04.20.09.58.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 09:58:39 -0700 (PDT)
From: Chunyu Hu <chuhu@redhat.com>
Subject: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in gfp_kmemleak_mask
Date: Sat, 21 Apr 2018 00:58:33 +0800
Message-Id: <1524243513-29118-1-git-send-email-chuhu@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com
Cc: mhocko@suse.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

__GFP_NORETRY and  __GFP_NOFAIL are combined in gfp_kmemleak_mask now.
But it's a wrong combination. As __GFP_NOFAIL is blockable, but
__GFP_NORETY is not blockable, make it self-contradiction.

__GFP_NOFAIL means 'The VM implementation _must_ retry infinitely'. But
it's not the real intention, as kmemleak allow alloc failure happen in
memory pressure, in that case kmemleak just disables itself.

commit 9a67f6488eca ("mm: consolidate GFP_NOFAIL checks in the allocator
slowpath") documented that what user wants here should use GFP_NOWAIT, and
the WARN in __alloc_pages_slowpath caught this weird usage.

 <snip>
 WARNING: CPU: 3 PID: 64 at mm/page_alloc.c:4261 __alloc_pages_slowpath+0x1cc3/0x2780
 CPU: 3 PID: 64 Comm: kswapd1 Not tainted 4.17.0-rc1.syzcaller+ #12
 Hardware name: Red Hat KVM, BIOS 0.0.0 02/06/2015
 RIP: 0010:__alloc_pages_slowpath+0x1cc3/0x2780
 RSP: 0000:ffff88002fa5e6c8 EFLAGS: 00010046
 RAX: 0000000000000000 RBX: 0000000000010000 RCX: 1ffff10005f4bcb6
 RDX: 1ffff10007da3f46 RSI: 0000000000000000 RDI: ffff88003ed1fa38
 RBP: 0000000001000000 R08: 0000000000000040 R09: 0000000000000030
 R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
 kmemleak: Kernel memory leak detector disabled
 R13: ffff88002fa5ea68 R14: dffffc0000000000 R15: ffff88002fa5ea68
 FS:  0000000000000000(0000) GS:ffff88003e900000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 CR2: 00007f5db91c6640 CR3: 0000000004014000 CR4: 00000000001406e0
 Call Trace:
  __alloc_pages_nodemask+0x5ce/0x7c0
  alloc_pages_current+0xb6/0x230
  new_slab+0x29d/0x9f0
  ___slab_alloc+0x4e5/0xa90
  __slab_alloc.isra.37+0x92/0x120
  kmem_cache_alloc+0x35f/0x580
  create_object+0xa6/0xaf0
  kmem_cache_alloc+0x20a/0x580
  mempool_alloc+0x13a/0x350
  bio_alloc_bioset+0x3ef/0x6e0
  get_swap_bio+0x125/0x490
  __swap_writepage+0x7be/0x11f0
  swap_writepage+0x46/0xb0
  pageout.isra.33+0x435/0xe70
  ? trace_event_raw_event_mm_shrink_slab_start+0x4d0/0x4d0
  ? page_mapped+0x165/0x3f0
  shrink_page_list+0x1ded/0x3960
  shrink_inactive_list+0x737/0x14b0
  shrink_node_memcg+0xa9f/0x1ef0
  shrink_node+0x376/0x15f0
  balance_pgdat+0x2c9/0x970
  kswapd+0x537/0xfe0
  kthread+0x387/0x510
  <snip>

Replace the __GFP_NOFAIL with GFP_NOWAIT in gfp_kmemleak_mask, __GFP_NORETRY
and GFP_NOWAIT are in the gfp_kmemleak_mask. So kmemleak object allocaion
is no blockable and no reclaim, making kmemleak less disruptive to user
processes in pressure.

Signed-off-by: Chunyu Hu <chuhu@redhat.com>
CC: Michal Hocko <mhocko@suse.com>
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 9a085d5..4ea07e4 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -126,7 +126,7 @@
 /* GFP bitmask for kmemleak internal allocations */
 #define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
 				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
-				 __GFP_NOWARN | __GFP_NOFAIL)
+				 __GFP_NOWARN | GFP_NOWAIT)
 
 /* scanning area inside a memory block */
 struct kmemleak_scan_area {
-- 
1.8.3.1
