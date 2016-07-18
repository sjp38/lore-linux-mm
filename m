Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41DB46B025F
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 04:41:34 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f126so53284398wma.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 01:41:34 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id b15si13605520wmg.111.2016.07.18.01.41.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 01:41:33 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id x83so11522869wma.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 01:41:32 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 2/2] mm, mempool: do not throttle PF_LESS_THROTTLE tasks
Date: Mon, 18 Jul 2016 10:41:25 +0200
Message-Id: <1468831285-27242-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1468831285-27242-1-git-send-email-mhocko@kernel.org>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Mikulas has reported that a swap backed by dm-crypt doesn't work
properly because the swapout cannot make a sufficient forward progress
as the writeout path depends on dm_crypt worker which has to allocate
memory to perform the encryption. In order to guarantee a forward
progress it relies on the mempool allocator. mempool_alloc(), however,
prefers to use the underlying (usually page) allocator before it grabs
objects from the pool. Such an allocation can dive into the memory
reclaim and consequently to throttle_vm_writeout. If there are too many
dirty or pages under writeback it will get throttled even though it is
in fact a flusher to clear pending pages.

[  345.352536] kworker/u4:0    D ffff88003df7f438 10488     6      2 0x00000000
[  345.352536] Workqueue: kcryptd kcryptd_crypt [dm_crypt]
[  345.352536]  ffff88003df7f438 ffff88003e5d0380 ffff88003e5d0380 ffff88003e5d8e80
[  345.352536]  ffff88003dfb3240 ffff88003df73240 ffff88003df80000 ffff88003df7f470
[  345.352536]  ffff88003e5d0380 ffff88003e5d0380 ffff88003df7f828 ffff88003df7f450
[  345.352536] Call Trace:
[  345.352536]  [<ffffffff818d466c>] schedule+0x3c/0x90
[  345.352536]  [<ffffffff818d96a8>] schedule_timeout+0x1d8/0x360
[  345.352536]  [<ffffffff81135e40>] ? detach_if_pending+0x1c0/0x1c0
[  345.352536]  [<ffffffff811407c3>] ? ktime_get+0xb3/0x150
[  345.352536]  [<ffffffff811958cf>] ? __delayacct_blkio_start+0x1f/0x30
[  345.352536]  [<ffffffff818d39e4>] io_schedule_timeout+0xa4/0x110
[  345.352536]  [<ffffffff8121d886>] congestion_wait+0x86/0x1f0
[  345.352536]  [<ffffffff810fdf40>] ? prepare_to_wait_event+0xf0/0xf0
[  345.352536]  [<ffffffff812061d4>] throttle_vm_writeout+0x44/0xd0
[  345.352536]  [<ffffffff81211533>] shrink_zone_memcg+0x613/0x720
[  345.352536]  [<ffffffff81211720>] shrink_zone+0xe0/0x300
[  345.352536]  [<ffffffff81211aed>] do_try_to_free_pages+0x1ad/0x450
[  345.352536]  [<ffffffff81211e7f>] try_to_free_pages+0xef/0x300
[  345.352536]  [<ffffffff811fef19>] __alloc_pages_nodemask+0x879/0x1210
[  345.352536]  [<ffffffff810e8080>] ? sched_clock_cpu+0x90/0xc0
[  345.352536]  [<ffffffff8125a8d1>] alloc_pages_current+0xa1/0x1f0
[  345.352536]  [<ffffffff81265ef5>] ? new_slab+0x3f5/0x6a0
[  345.352536]  [<ffffffff81265dd7>] new_slab+0x2d7/0x6a0
[  345.352536]  [<ffffffff810e7f87>] ? sched_clock_local+0x17/0x80
[  345.352536]  [<ffffffff812678cb>] ___slab_alloc+0x3fb/0x5c0
[  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
[  345.352536]  [<ffffffff810e7f87>] ? sched_clock_local+0x17/0x80
[  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
[  345.352536]  [<ffffffff81267ae1>] __slab_alloc+0x51/0x90
[  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
[  345.352536]  [<ffffffff81267d9b>] kmem_cache_alloc+0x27b/0x310
[  345.352536]  [<ffffffff811f71bd>] mempool_alloc_slab+0x1d/0x30
[  345.352536]  [<ffffffff811f6f11>] mempool_alloc+0x91/0x230
[  345.352536]  [<ffffffff8141a02d>] bio_alloc_bioset+0xbd/0x260
[  345.352536]  [<ffffffffc02f1a54>] kcryptd_crypt+0x114/0x3b0 [dm_crypt]

Memory pools are usually used for the writeback paths and it doesn't
really make much sense to throttle them just because there are too many
dirty/writeback pages. The main purpose of throttle_vm_writeout is to
make sure that the pageout path doesn't generate too much dirty data.
Considering that we are in mempool path which performs __GFP_NORETRY
requests the risk shouldn't be really high.

Fix this by ensuring that mempool users will get PF_LESS_THROTTLE and
that such processes are not throttled in throttle_vm_writeout. They can
still get throttled due to current_may_throttle() sleeps but that should
happen when the backing device itself is congested which sounds like a
proper reaction.

Please note that the bonus given by domain_dirty_limits() alone is not
sufficient because at least dm-crypt has to double buffer each page
under writeback so this won't be sufficient to prevent from being
throttled.

There are other users of the flag but they are in the writeout path so
this looks like a proper thing for them as well.

Reported-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/mempool.c        | 19 +++++++++++++++----
 mm/page-writeback.c |  3 +++
 2 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/mm/mempool.c b/mm/mempool.c
index ea26d75c8adf..916e95c4192c 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -310,7 +310,8 @@ EXPORT_SYMBOL(mempool_resize);
  */
 void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 {
-	void *element;
+	unsigned int pflags = current->flags;
+	void *element = NULL;
 	unsigned long flags;
 	wait_queue_t wait;
 	gfp_t gfp_temp;
@@ -328,6 +329,12 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 
 	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
 
+	/*
+	 * Make sure that the allocation doesn't get throttled during the
+	 * reclaim
+	 */
+	if (gfpflags_allow_blocking(gfp_mask))
+		current->flags |= PF_LESS_THROTTLE;
 repeat_alloc:
 	/*
 	 * Make sure that the OOM victim will get access to memory reserves
@@ -339,7 +346,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 
 	element = pool->alloc(gfp_temp, pool->pool_data);
 	if (likely(element != NULL))
-		return element;
+		goto out;
 
 	spin_lock_irqsave(&pool->lock, flags);
 	if (likely(pool->curr_nr)) {
@@ -352,7 +359,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 		 * for debugging.
 		 */
 		kmemleak_update_trace(element);
-		return element;
+		goto out;
 	}
 
 	/*
@@ -369,7 +376,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 	/* We must not sleep if !__GFP_DIRECT_RECLAIM */
 	if (!(gfp_mask & __GFP_DIRECT_RECLAIM)) {
 		spin_unlock_irqrestore(&pool->lock, flags);
-		return NULL;
+		goto out;
 	}
 
 	/* Let's wait for someone else to return an element to @pool */
@@ -386,6 +393,10 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 
 	finish_wait(&pool->wait, &wait);
 	goto repeat_alloc;
+out:
+	if (gfpflags_allow_blocking(gfp_mask))
+		tsk_restore_flags(current, pflags, PF_LESS_THROTTLE);
+	return element;
 }
 EXPORT_SYMBOL(mempool_alloc);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 7fbb2d008078..a37661f1a11b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1971,6 +1971,9 @@ void throttle_vm_writeout(gfp_t gfp_mask)
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 
+	if (current->flags & PF_LESS_THROTTLE)
+		return;
+
         for ( ; ; ) {
 		global_dirty_limits(&background_thresh, &dirty_thresh);
 		dirty_thresh = hard_dirty_limit(&global_wb_domain, dirty_thresh);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
