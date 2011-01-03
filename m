Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D322D6B00B2
	for <linux-mm@kvack.org>; Mon,  3 Jan 2011 11:31:39 -0500 (EST)
Received: by pxi12 with SMTP id 12so3768980pxi.14
        for <linux-mm@kvack.org>; Mon, 03 Jan 2011 08:31:07 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] writeback: avoid unnecessary determine_dirtyable_memory call
Date: Tue,  4 Jan 2011 01:30:49 +0900
Message-Id: <1294072249-2916-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

I think determine_dirtyable_memory is rather costly function since
it need many atomic reads for gathering zone/global page state.
But when we use vm_dirty_bytes && dirty_background_bytes, we don't
need that costly calculation.

This patch eliminates such unnecessary overhead.

NOTE : newly added if condition might add overhead in normal path.
       But it should be _really_ small because anyway we need the
       access both vm_dirty_bytes and dirty_background_bytes so it is
       likely to hit the cache.

Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/page-writeback.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index fc93802..c340536 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -390,9 +390,12 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
 {
 	unsigned long background;
 	unsigned long dirty;
-	unsigned long available_memory = determine_dirtyable_memory();
+	unsigned long available_memory;
 	struct task_struct *tsk;
 
+	if (!vm_dirty_bytes || !dirty_background_bytes)
+		available_memory = determine_dirtyable_memory();
+
 	if (vm_dirty_bytes)
 		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
 	else
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
