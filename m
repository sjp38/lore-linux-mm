Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id DE3266B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 09:27:42 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id 20so26291861wmh.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 06:27:42 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id t189si16590074wmf.102.2016.03.29.06.27.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 06:27:41 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i204so3665341wmd.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 06:27:41 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] mm, oom: move GFP_NOFS check to out_of_memory
Date: Tue, 29 Mar 2016 15:27:35 +0200
Message-Id: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__alloc_pages_may_oom is the central place to decide when the
out_of_memory should be invoked. This is a good approach for most checks
there because they are page allocator specific and the allocation fails
right after.

The notable exception is GFP_NOFS context which is faking
did_some_progress and keep the page allocator looping even though there
couldn't have been any progress from the OOM killer. This patch doesn't
change this behavior because we are not ready to allow those allocation
requests to fail yet. Instead __GFP_FS check is moved down to
out_of_memory and prevent from OOM victim selection there. There are
two reasons for that
	- OOM notifiers might release some memory even from this context
	  as none of the registered notifier seems to be FS related
	- this might help a dying thread to get an access to memory
          reserves and move on which will make the behavior more
          consistent with the case when the task gets killed from a
          different context.

Keep a comment in __alloc_pages_may_oom to make sure we do not forget
how GFP_NOFS is special and that we really want to do something about
it.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
I am sending this as an RFC now even though I think this makes more
sense than what we have right now. Maybe there are some side effects
I do not see, though. A more tricky part is the OOM notifier part
becasue future notifiers might decide to depend on the FS and we can
lockup. Is this something to worry about, though? Would such a notifier
be correct at all? I would call it broken as it would put OOM killer out
of the way on the contended system which is a plain bug IMHO.

If this looks like a reasonable approach I would go on think about how
we can extend this for the oom_reaper and queue the current thread for
the reaper to free some of the memory.

Any thoughts

 mm/oom_kill.c   |  4 ++++
 mm/page_alloc.c | 24 ++++++++++--------------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 86349586eacb..1c2b7a82f0c4 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -876,6 +876,10 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
+	/* The OOM killer does not compensate for IO-less reclaim. */
+	if (!(oc->gfp_mask & __GFP_FS))
+		return true;
+
 	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1b889dba7bd4..736ea28abfcf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2872,22 +2872,18 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		/* The OOM killer does not needlessly kill tasks for lowmem */
 		if (ac->high_zoneidx < ZONE_NORMAL)
 			goto out;
-		/* The OOM killer does not compensate for IO-less reclaim */
-		if (!(gfp_mask & __GFP_FS)) {
-			/*
-			 * XXX: Page reclaim didn't yield anything,
-			 * and the OOM killer can't be invoked, but
-			 * keep looping as per tradition.
-			 *
-			 * But do not keep looping if oom_killer_disable()
-			 * was already called, for the system is trying to
-			 * enter a quiescent state during suspend.
-			 */
-			*did_some_progress = !oom_killer_disabled;
-			goto out;
-		}
 		if (pm_suspended_storage())
 			goto out;
+		/*
+		 * XXX: GFP_NOFS allocations should rather fail than rely on
+		 * other request to make a forward progress.
+		 * We are in an unfortunate situation where out_of_memory cannot
+		 * do much for this context but let's try it to at least get
+		 * access to memory reserved if the current task is killed (see
+		 * out_of_memory). Once filesystems are ready to handle allocation
+		 * failures more gracefully we should just bail out here.
+		 */
+
 		/* The OOM killer may not free memory on a specific node */
 		if (gfp_mask & __GFP_THISNODE)
 			goto out;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
