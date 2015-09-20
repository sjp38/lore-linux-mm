Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id BB00B6B0254
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 03:03:31 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so87574837pad.1
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 00:03:31 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id mk6si26695658pab.21.2015.09.20.00.03.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 20 Sep 2015 00:03:30 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 2/2] xfs: Print comm name and pid when open-coded __GFP_NOFAIL allocation stucks
Date: Sun, 20 Sep 2015 16:03:14 +0900
Message-Id: <1442732594-4205-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1442732594-4205-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1442732594-4205-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: xfs@oss.sgi.com, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>

This patch adds comm name and pid to warning messages printed by
kmem_alloc(), kmem_zone_alloc() and xfs_buf_allocate_memory().
This will help telling which memory allocations (e.g. kernel worker
threads, OOM victim tasks, neither) are stalling.

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
 fs/xfs/kmem.c    | 6 ++++--
 fs/xfs/xfs_buf.c | 3 ++-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index 1fcf90d..95a5b76 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -54,8 +54,9 @@ kmem_alloc(size_t size, xfs_km_flags_t flags)
 		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
 			return ptr;
 		if (!(++retries % 100))
-			xfs_err(NULL,
+			xfs_err(NULL, "%s(%u) "
 		"possible memory allocation deadlock in %s (mode:0x%x)",
+					current->comm, current->pid,
 					__func__, lflags);
 		congestion_wait(BLK_RW_ASYNC, HZ/50);
 	} while (1);
@@ -119,8 +120,9 @@ kmem_zone_alloc(kmem_zone_t *zone, xfs_km_flags_t flags)
 		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
 			return ptr;
 		if (!(++retries % 100))
-			xfs_err(NULL,
+			xfs_err(NULL, "%s(%u) "
 		"possible memory allocation deadlock in %s (mode:0x%x)",
+					current->comm, current->pid,
 					__func__, lflags);
 		congestion_wait(BLK_RW_ASYNC, HZ/50);
 	} while (1);
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index cbd4f91..5deb629 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -353,8 +353,9 @@ retry:
 			 * handle buffer allocation failures we can't do much.
 			 */
 			if (!(++retries % 100))
-				xfs_err(NULL,
+				xfs_err(NULL, "%s(%u) "
 		"possible memory allocation deadlock in %s (mode:0x%x)",
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
