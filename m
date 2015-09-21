Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 88FD26B0254
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 21:24:08 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so101157169pac.0
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 18:24:08 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w7si33854019pbs.85.2015.09.20.18.24.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 20 Sep 2015 18:24:07 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v2] xfs: Print comm name and pid when open-coded __GFP_NOFAIL allocation stucks
Date: Mon, 21 Sep 2015 10:23:57 +0900
Message-Id: <1442798637-5941-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <20150920231858.GY3902@dastard>
References: <20150920231858.GY3902@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: xfs@oss.sgi.com, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>

This patch adds comm name and pid to warning messages printed by
kmem_alloc(), kmem_zone_alloc() and xfs_buf_allocate_memory().
This will help telling which memory allocations (e.g. kernel worker
threads, OOM victim tasks, neither) are stalling because these functions
are passing __GFP_NOWARN which suppresses not only backtrace but comm name
and pid.

  [  135.568662] Out of memory: Kill process 9593 (a.out) score 998 or sacrifice child
  [  135.570195] Killed process 9593 (a.out) total-vm:4700kB, anon-rss:488kB, file-rss:0kB
  [  137.473691] XFS: kworker/u16:29(383) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
  [  137.497662] XFS: a.out(8944) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
  [  137.598219] XFS: a.out(9658) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
  [  139.494529] XFS: kworker/u16:29(383) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
  [  139.517196] XFS: a.out(8944) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
  [  139.616396] XFS: a.out(9658) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
  [  141.512753] XFS: kworker/u16:29(383) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
  [  141.531421] XFS: a.out(8944) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
  [  141.633574] XFS: a.out(9658) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)

(Strictly speaking, we want task_lock()/task_unlock() when reading comm name.)

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
---
 fs/xfs/kmem.c    | 10 ++++++----
 fs/xfs/xfs_buf.c |  3 ++-
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index a7a3a63..735095a 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -55,8 +55,9 @@ kmem_alloc(size_t size, xfs_km_flags_t flags)
 			return ptr;
 		if (!(++retries % 100))
 			xfs_err(NULL,
-		"possible memory allocation deadlock in %s (mode:0x%x)",
-					__func__, lflags);
+				"%s(%u) possible memory allocation deadlock in %s (mode:0x%x)",
+				current->comm, current->pid,
+				__func__, lflags);
 		congestion_wait(BLK_RW_ASYNC, HZ/50);
 	} while (1);
 }
@@ -120,8 +121,9 @@ kmem_zone_alloc(kmem_zone_t *zone, xfs_km_flags_t flags)
 			return ptr;
 		if (!(++retries % 100))
 			xfs_err(NULL,
-		"possible memory allocation deadlock in %s (mode:0x%x)",
-					__func__, lflags);
+				"%s(%u) possible memory allocation deadlock in %s (mode:0x%x)",
+				current->comm, current->pid,
+				__func__, lflags);
 		congestion_wait(BLK_RW_ASYNC, HZ/50);
 	} while (1);
 }
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 8ecffb3..86785b5 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -354,7 +354,8 @@ retry:
 			 */
 			if (!(++retries % 100))
 				xfs_err(NULL,
-		"possible memory allocation deadlock in %s (mode:0x%x)",
+					"%s(%u) possible memory allocation deadlock in %s (mode:0x%x)",
+					current->comm, current->pid,
 					__func__, gfp_mask);
 
 			XFS_STATS_INC(xb_page_retries);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
