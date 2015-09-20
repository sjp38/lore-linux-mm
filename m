Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5116A6B0253
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 03:03:30 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so89242978pac.2
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 00:03:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id ix8si14434813pbc.172.2015.09.20.00.03.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 20 Sep 2015 00:03:29 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 1/2] xfs: Add __GFP_NORETRY and __GFP_NOWARN to open-coded __GFP_NOFAIL allocations
Date: Sun, 20 Sep 2015 16:03:13 +0900
Message-Id: <1442732594-4205-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: xfs@oss.sgi.com, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>

kmem_alloc(), kmem_zone_alloc() and xfs_buf_allocate_memory() are doing
open-coded __GFP_NOFAIL allocations with warning messages as a canary.
But since small !__GFP_NOFAIL allocations retry forever inside memory
allocator unless TIF_MEMDIE is set, the canary does not help even if
allocations are stalling. Thus, this patch adds __GFP_NORETRY so that
we can know possibility of allocation deadlock.

If a patchset which makes small !__GFP_NOFAIL !__GFP_FS allocations not
retry inside memory allocator is merged, warning messages by
warn_alloc_failed() will dominate warning messages by the canary
because each thread calls warn_alloc_failed() for approximately
every 2 milliseconds. Thus, this patch also adds __GFP_NOWARN so that
we won't flood kernel logs by these open-coded __GFP_NOFAIL allocations.
Next patch compensates for lack of comm name and pid by addding them to
the canary.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
---
 fs/xfs/kmem.c    | 4 ++--
 fs/xfs/xfs_buf.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index a7a3a63..1fcf90d 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -46,7 +46,7 @@ void *
 kmem_alloc(size_t size, xfs_km_flags_t flags)
 {
 	int	retries = 0;
-	gfp_t	lflags = kmem_flags_convert(flags);
+	gfp_t	lflags = kmem_flags_convert(flags) | __GFP_NORETRY | __GFP_NOWARN;
 	void	*ptr;
 
 	do {
@@ -111,7 +111,7 @@ void *
 kmem_zone_alloc(kmem_zone_t *zone, xfs_km_flags_t flags)
 {
 	int	retries = 0;
-	gfp_t	lflags = kmem_flags_convert(flags);
+	gfp_t	lflags = kmem_flags_convert(flags) | __GFP_NORETRY | __GFP_NOWARN;
 	void	*ptr;
 
 	do {
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 8ecffb3..cbd4f91 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -289,7 +289,7 @@ xfs_buf_allocate_memory(
 {
 	size_t			size;
 	size_t			nbytes, offset;
-	gfp_t			gfp_mask = xb_to_gfp(flags);
+	gfp_t			gfp_mask = xb_to_gfp(flags) | __GFP_NORETRY | __GFP_NOWARN;
 	unsigned short		page_count, i;
 	xfs_off_t		start, end;
 	int			error;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
