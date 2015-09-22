Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 40EF56B0038
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 04:04:01 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so2639057pad.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 01:04:01 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id rj3si627601pbc.104.2015.09.22.01.03.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Sep 2015 01:04:00 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v3] xfs: Print comm name and pid when open-coded __GFP_NOFAIL allocation stucks
Date: Tue, 22 Sep 2015 17:03:43 +0900
Message-Id: <1442909023-4088-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <20150922051253.GB3902@dastard>
References: <20150922051253.GB3902@dastard>
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

(Strictly speaking, we want task_lock()/task_unlock() when reading comm name.)

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
---
 fs/xfs/kmem.c    | 10 ++++++----
 fs/xfs/xfs_buf.c |  3 ++-
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index a7a3a63..535c136 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -55,8 +55,9 @@ kmem_alloc(size_t size, xfs_km_flags_t flags)
 			return ptr;
 		if (!(++retries % 100))
 			xfs_err(NULL,
-		"possible memory allocation deadlock in %s (mode:0x%x)",
-					__func__, lflags);
+		"%s(%u) possible memory allocation deadlock in %s (mode:0x%x)",
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
+		"%s(%u) possible memory allocation deadlock in %s (mode:0x%x)",
+				current->comm, current->pid,
+				__func__, lflags);
 		congestion_wait(BLK_RW_ASYNC, HZ/50);
 	} while (1);
 }
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 8ecffb3..cac62e1 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -354,7 +354,8 @@ retry:
 			 */
 			if (!(++retries % 100))
 				xfs_err(NULL,
-		"possible memory allocation deadlock in %s (mode:0x%x)",
+		"%s(%u) possible memory allocation deadlock in %s (mode:0x%x)",
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
