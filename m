Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 51B9A6B0074
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:06:47 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so126609665wgy.2
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:06:46 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u3si14194927wiy.42.2015.04.27.12.06.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 12:06:38 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 8/9] mm: page_alloc: wait for OOM killer progress before retrying
Date: Mon, 27 Apr 2015 15:05:54 -0400
Message-Id: <1430161555-6058-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

There is not much point in rushing back to the freelists and burning
CPU cycles in direct reclaim when somebody else is in the process of
OOM killing, or right after issuing a kill ourselves, because it could
take some time for the OOM victim to release memory.

This is a very cold error path, so there is not much hurry.  Use the
OOM victim waitqueue to wait for victims to actually exit, which is a
solid signal that the memory pinned by those tasks has been released.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/oom_kill.c   | 11 +++++++----
 mm/page_alloc.c | 43 ++++++++++++++++++++++++++-----------------
 2 files changed, 33 insertions(+), 21 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5cfda39..823f87e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -711,12 +711,15 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		killed = 1;
 	}
 out:
+	if (test_thread_flag(TIF_MEMDIE))
+		return true;
 	/*
-	 * Give the killed threads a good chance of exiting before trying to
-	 * allocate memory again.
+	 * Wait for any outstanding OOM victims to die.  In rare cases
+	 * victims can get stuck behind the allocating tasks, so the
+	 * wait needs to be bounded.  It's crude alright, but cheaper
+	 * than keeping a global dependency tree between all tasks.
 	 */
-	if (killed)
-		schedule_timeout_killable(1);
+	wait_event_timeout(oom_victims_wait, !atomic_read(&oom_victims), 5*HZ);
 
 	return true;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3b4e4f81..94530db 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2323,30 +2323,30 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 }
 
 static inline struct page *
-__alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
+__alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	const struct alloc_context *ac, unsigned long *did_some_progress)
 {
-	struct page *page;
+	struct page *page = NULL;
 
 	*did_some_progress = 0;
 
 	/*
-	 * Acquire the oom lock.  If that fails, somebody else is
-	 * making progress for us.
+	 * This allocating task can become the OOM victim itself at
+	 * any point before acquiring the lock.  In that case, exit
+	 * quickly and don't block on the lock held by another task
+	 * waiting for us to exit.
 	 */
-	if (!mutex_trylock(&oom_lock)) {
-		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
-		return NULL;
+	if (test_thread_flag(TIF_MEMDIE) || mutex_lock_killable(&oom_lock)) {
+		if (test_thread_flag(TIF_MEMDIE))
+			alloc_flags |= ALLOC_NO_WATERMARKS;
+		goto alloc;
 	}
 
 	/*
-	 * Go through the zonelist yet one more time, keep very high watermark
-	 * here, this is only to catch a parallel oom killing, we must fail if
-	 * we're still under heavy pressure.
+	 * While we have been waiting for the lock, the previous OOM
+	 * kill might have released enough memory for the both of us.
 	 */
-	page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL, order,
-					ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
+	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
 	if (page)
 		goto out;
 
@@ -2376,12 +2376,20 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		if (gfp_mask & __GFP_THISNODE)
 			goto out;
 	}
-	/* Exhausted what can be done so it's blamo time */
-	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false)
-			|| WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
+
+	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false)) {
 		*did_some_progress = 1;
+	} else {
+		/* Oops, these shouldn't happen with the OOM killer disabled */
+		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
+			*did_some_progress = 1;
+	}
 out:
 	mutex_unlock(&oom_lock);
+alloc:
+	if (!page)
+		page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+
 	return page;
 }
 
@@ -2768,7 +2776,8 @@ retry:
 	}
 
 	/* Reclaim has failed us, start killing things */
-	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
+	page = __alloc_pages_may_oom(gfp_mask, order, alloc_flags, ac,
+				     &did_some_progress);
 	if (page)
 		goto got_pg;
 
-- 
2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
