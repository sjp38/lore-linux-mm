Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 91C646B02A4
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 02:52:59 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q77so11790844qke.4
        for <linux-mm@kvack.org>; Sun, 10 Sep 2017 23:52:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t184si8275254qkc.66.2017.09.10.23.52.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Sep 2017 23:52:58 -0700 (PDT)
Date: Mon, 11 Sep 2017 02:52:53 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] mm: respect the __GFP_NOWARN flag when warning about
 stalls
Message-ID: <alpine.LRH.2.02.1709110231010.3666@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I am occasionally getting these warnings in khugepaged. It is an old 
machine with 550MHz CPU and 512 MB RAM.

Note that khugepaged has nice value 19, so when the machine is loaded with 
some work, khugepaged is stalled and this stall produces warning in the 
allocator.

khugepaged does allocations with __GFP_NOWARN, but the flag __GFP_NOWARN
is masked off when calling warn_alloc. This patch removes the masking of
__GFP_NOWARN, so that the warning is suppressed.

khugepaged: page allocation stalls for 10273ms, order:10, mode:0x4340ca(__GFP_HIGHMEM|__GFP_IO|__GFP_FS|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_DIRECT_RECLAIM), nodemask=(null)
CPU: 0 PID: 3936 Comm: khugepaged Not tainted 4.12.3 #1
Hardware name: System Manufacturer Product Name/VA-503A, BIOS 4.51 PG 08/02/00
Call Trace:
 ? warn_alloc+0xb9/0x140
 ? __alloc_pages_nodemask+0x724/0x880
 ? arch_irq_stat_cpu+0x1/0x40
 ? detach_if_pending+0x80/0x80
 ? khugepaged+0x10a/0x1d40
 ? pick_next_task_fair+0xd2/0x180
 ? wait_woken+0x60/0x60
 ? kthread+0xcf/0x100
 ? release_pte_page+0x40/0x40
 ? kthread_create_on_node+0x40/0x40
 ? ret_from_fork+0x19/0x30

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Cc: stable@vger.kernel.org
Fixes: 63f53dea0c98 ("mm: warn about allocations which stall for too long")

---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -3923,7 +3923,7 @@ retry:
 
 	/* Make sure we know about allocations which stall for too long */
 	if (time_after(jiffies, alloc_start + stall_timeout)) {
-		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
+		warn_alloc(gfp_mask, ac->nodemask,
 			"page allocation stalls for %ums, order:%u",
 			jiffies_to_msecs(jiffies-alloc_start), order);
 		stall_timeout += 10 * HZ;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
