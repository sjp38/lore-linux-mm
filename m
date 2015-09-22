Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0F49B6B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 12:34:48 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so13817041pac.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 09:34:47 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ep1si3721920pbd.256.2015.09.22.09.34.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Sep 2015 09:34:46 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm/page_alloc: Favor kthread and dying threads over normal threads
Date: Wed, 23 Sep 2015 01:34:28 +0900
Message-Id: <1442939668-4421-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: xfs@oss.sgi.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

shrink_inactive_list() and throttle_direct_reclaim() are expecting that
dying threads should not be throttled so that they can leave memory
allocator functions and exit and release their memory shortly.
Also, throttle_direct_reclaim() is expecting that kernel threads should
not be throttled as they may be indirectly responsible for cleaning pages
necessary for reclaim to make forward progress.

Currently __GFP_WAIT && order <= PAGE_ALLOC_COSTLY_ORDER && !__GFP_NORETRY
&& !__GFP_NOFAIL allocation requests implicitly retry forever unless
TIF_MEMDIE is set by the OOM killer. Also, currently the OOM killer sets
TIF_MEMDIE to only one thread even if there are 1000 threads sharing the
mm struct. All threads get SIGKILL and are treated as dying thread, but
only OOM victim threads with TIF_MEMDIE are favored at several locations
in memory allocator functions. While OOM victim threads without TIF_MEMDIE
can acquire TIF_MEMDIE by calling out_of_memory(), they cannot acquire
TIF_MEMDIE unless they are doing __GFP_FS allocations.

Therefore, __GFP_WAIT && order <= PAGE_ALLOC_COSTLY_ORDER && !__GFP_NORETRY
&& !__GFP_NOFAIL && !__GFP_FS allocation requests by dying threads and
kernel threads are throttled by above-mentioned implicit retry loop because
they are using watermark for normal threads' normal allocation requests.

The effect of this throttling becomes visible on XFS (like kernel messages
shown below) if we revert commit cc87317726f8 ("mm: page_alloc: revert
inadvertent !__GFP_FS retry behavior change").

  [   66.089978] Kill process 8505 (a.out) sharing same memory
  [   69.748060] XFS: a.out(8082) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [   69.798580] XFS: kworker/u16:28(381) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [   69.876952] XFS: xfs-data/sda1(399) possible memory allocation deadlock in kmem_alloc (mode:0x8250)
  [   70.359518] XFS: a.out(8412) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [   73.299509] XFS: kworker/u16:28(381) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [   73.470350] XFS: xfs-data/sda1(399) possible memory allocation deadlock in kmem_alloc (mode:0x8250)
  [   73.664420] XFS: a.out(8082) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [   73.967434] XFS: a.out(8412) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [   76.950038] XFS: kworker/u16:28(381) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [   76.957938] XFS: xfs-data/sda1(399) possible memory allocation deadlock in kmem_alloc (mode:0x8250)

Favoring only TIF_MEMDIE threads is prone to cause OOM livelock. Also,
favoring only dying threads still causes OOM livelock because sometimes
dying threads depend on memory allocations issued by kernel threads
(like kernel messages shown above).

Kernel threads and dying threads (especially OOM victim threads) want
higher priority than normal threads. This patch favors them (as with
throttle_direct_reclaim()) by implicitly applying ALLOC_HIGH priority.
This patch should help handling OOM events where a multi-threaded
program (e.g. java) is chosen as an OOM victim when the victim is
contended on unkillable locks (e.g. inode's mutex).

Presumably we don't need to apply ALLOC_NO_WATERMARKS priority for
TIF_MEMDIE threads if we evenly favor all OOM victim threads. But it is
outside of this patch's scope because we after all need to handle cases
where killing other threads is necessary for OOM victim threads to make
forward progress.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9bcfd70..f0c9098 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3010,6 +3010,13 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 				((current->flags & PF_MEMALLOC) ||
 				 unlikely(test_thread_flag(TIF_MEMDIE))))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
+		/*
+		 * Favor kernel threads and dying threads like
+		 * shrink_inactive_list() and throttle_direct_reclaim().
+		 */
+		else if (!atomic && ((current->flags & PF_KTHREAD) ||
+				     fatal_signal_pending(current)))
+			alloc_flags |= ALLOC_HIGH;
 	}
 #ifdef CONFIG_CMA
 	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
