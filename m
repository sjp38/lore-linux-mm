Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D68A36B0027
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 06:44:11 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id m184so4740389ith.4
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 03:44:11 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f67si1201968iod.76.2018.02.08.03.44.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Feb 2018 03:44:10 -0800 (PST)
Subject: [PATCH v2] lockdep: Fix fs_reclaim warning.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <8f1c776d-b791-e0b9-1e5c-62b03dcd1d74@I-love.SAKURA.ne.jp>
	<20180129102746.GQ2269@hirez.programming.kicks-ass.net>
	<201801292047.EHC05241.OHSQOJOVtFMFLF@I-love.SAKURA.ne.jp>
	<20180129135547.GR2269@hirez.programming.kicks-ass.net>
	<201802012036.FEE78102.HOMFFOtJVFOSQL@I-love.SAKURA.ne.jp>
In-Reply-To: <201802012036.FEE78102.HOMFFOtJVFOSQL@I-love.SAKURA.ne.jp>
Message-Id: <201802082043.FFJ39503.SVQFFFOJMHLOtO@I-love.SAKURA.ne.jp>
Date: Thu, 8 Feb 2018 20:43:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org
Cc: torvalds@linux-foundation.org, davej@codemonkey.org.uk, npiggin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, mhocko@kernel.org, linux-btrfs@vger.kernel.org

>From 361d37a7d36978020dfb4c11ec1f4800937ccb68 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 8 Feb 2018 10:35:35 +0900
Subject: [PATCH v2] lockdep: Fix fs_reclaim warning.

Dave Jones reported fs_reclaim lockdep warnings.

  ============================================
  WARNING: possible recursive locking detected
  4.15.0-rc9-backup-debug+ #1 Not tainted
  --------------------------------------------
  sshd/24800 is trying to acquire lock:
   (fs_reclaim){+.+.}, at: [<0000000084f438c2>] fs_reclaim_acquire.part.102+0x5/0x30

  but task is already holding lock:
   (fs_reclaim){+.+.}, at: [<0000000084f438c2>] fs_reclaim_acquire.part.102+0x5/0x30

  other info that might help us debug this:
   Possible unsafe locking scenario:

         CPU0
         ----
    lock(fs_reclaim);
    lock(fs_reclaim);

   *** DEADLOCK ***

   May be due to missing lock nesting notation

  2 locks held by sshd/24800:
   #0:  (sk_lock-AF_INET6){+.+.}, at: [<000000001a069652>] tcp_sendmsg+0x19/0x40
   #1:  (fs_reclaim){+.+.}, at: [<0000000084f438c2>] fs_reclaim_acquire.part.102+0x5/0x30

  stack backtrace:
  CPU: 3 PID: 24800 Comm: sshd Not tainted 4.15.0-rc9-backup-debug+ #1
  Call Trace:
   dump_stack+0xbc/0x13f
   __lock_acquire+0xa09/0x2040
   lock_acquire+0x12e/0x350
   fs_reclaim_acquire.part.102+0x29/0x30
   kmem_cache_alloc+0x3d/0x2c0
   alloc_extent_state+0xa7/0x410
   __clear_extent_bit+0x3ea/0x570
   try_release_extent_mapping+0x21a/0x260
   __btrfs_releasepage+0xb0/0x1c0
   btrfs_releasepage+0x161/0x170
   try_to_release_page+0x162/0x1c0
   shrink_page_list+0x1d5a/0x2fb0
   shrink_inactive_list+0x451/0x940
   shrink_node_memcg.constprop.88+0x4c9/0x5e0
   shrink_node+0x12d/0x260
   try_to_free_pages+0x418/0xaf0
   __alloc_pages_slowpath+0x976/0x1790
   __alloc_pages_nodemask+0x52c/0x5c0
   new_slab+0x374/0x3f0
   ___slab_alloc.constprop.81+0x47e/0x5a0
   __slab_alloc.constprop.80+0x32/0x60
   __kmalloc_track_caller+0x267/0x310
   __kmalloc_reserve.isra.40+0x29/0x80
   __alloc_skb+0xee/0x390
   sk_stream_alloc_skb+0xb8/0x340
   tcp_sendmsg_locked+0x8e6/0x1d30
   tcp_sendmsg+0x27/0x40
   inet_sendmsg+0xd0/0x310
   sock_write_iter+0x17a/0x240
   __vfs_write+0x2ab/0x380
   vfs_write+0xfb/0x260
   SyS_write+0xb6/0x140
   do_syscall_64+0x1e5/0xc05
   entry_SYSCALL64_slow_path+0x25/0x25

This warning is caused by commit d92a8cfcb37ecd13 ("locking/lockdep: Rework
FS_RECLAIM annotation") which replaced lockdep_set_current_reclaim_state()/
lockdep_clear_current_reclaim_state() in __perform_reclaim() and
lockdep_trace_alloc() in slab_pre_alloc_hook() with fs_reclaim_acquire()/
fs_reclaim_release(). Since __kmalloc_reserve() from __alloc_skb() adds
__GFP_NOMEMALLOC | __GFP_NOWARN to gfp_mask, and all reclaim path simply
propagates __GFP_NOMEMALLOC, fs_reclaim_acquire() in slab_pre_alloc_hook()
is trying to grab the 'fake' lock again when __perform_reclaim() already
grabbed the 'fake' lock.

The

  /* this guy won't enter reclaim */
  if ((current->flags & PF_MEMALLOC) && !(gfp_mask & __GFP_NOMEMALLOC))
          return false;

test which causes slab_pre_alloc_hook() to try to grab the 'fake' lock
was added by commit cf40bd16fdad42c0 ("lockdep: annotate reclaim context
(__GFP_NOFS)"). But that test is outdated because PF_MEMALLOC thread won't
enter reclaim regardless of __GFP_NOMEMALLOC after commit 341ce06f69abfafa
("page allocator: calculate the alloc_flags for allocation only once")
added the PF_MEMALLOC safeguard (

  /* Avoid recursion of direct reclaim */
  if (p->flags & PF_MEMALLOC)
          goto nopage;

in __alloc_pages_slowpath()).

Thus, let's fix outdated test by removing __GFP_NOMEMALLOC test and allow
__need_fs_reclaim() to return false.

Reported-and-tested-by: Dave Jones <davej@codemonkey.org.uk>
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Nick Piggin <npiggin@gmail.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 81e18ce..19fb76b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3590,7 +3590,7 @@ static bool __need_fs_reclaim(gfp_t gfp_mask)
 		return false;
 
 	/* this guy won't enter reclaim */
-	if ((current->flags & PF_MEMALLOC) && !(gfp_mask & __GFP_NOMEMALLOC))
+	if (current->flags & PF_MEMALLOC)
 		return false;
 
 	/* We're only interested __GFP_FS allocations for now */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
