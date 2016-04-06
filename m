Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id B2A116B007E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 10:13:29 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id 191so59827127wmq.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 07:13:29 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id k11si22218454wmg.101.2016.04.06.07.13.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 07:13:28 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n3so13658789wmn.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 07:13:28 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/3] mm, oom: move GFP_NOFS check to out_of_memory
Date: Wed,  6 Apr 2016 16:13:14 +0200
Message-Id: <1459951996-12875-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Daniel Vetter <daniel.vetter@intel.com>, Raushaniya Maksudova <rmaksudova@parallels.com>, "Michael S . Tsirkin" <mst@redhat.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>

From: Michal Hocko <mhocko@suse.com>

__alloc_pages_may_oom is the central place to decide when the
out_of_memory should be invoked. This is a good approach for most checks
there because they are page allocator specific and the allocation fails
right after for all of them.

The notable exception is GFP_NOFS context which is faking
did_some_progress and keep the page allocator looping even though there
couldn't have been any progress from the OOM killer. This patch doesn't
change this behavior because we are not ready to allow those allocation
requests to fail yet (and maybe we will face the reality that we will
never manage to safely fail these request). Instead __GFP_FS check
is moved down to out_of_memory and prevent from OOM victim selection
there. There are two reasons for that
	- OOM notifiers might release some memory even from this context
	  as none of the registered notifier seems to be FS related
	- this might help a dying thread to get an access to memory
          reserves and move on which will make the behavior more
          consistent with the case when the task gets killed from a
          different context.

Keep a comment in __alloc_pages_may_oom to make sure we do not forget
how GFP_NOFS is special and that we really want to do something about
it.

Note to the current oom_notifier users:
The observable difference for you is that oom notifiers cannot depend on
any fs locks because we could deadlock. Not that this would be allowed
today because that would just lockup machine in most of the cases and
ruling out the OOM killer along the way. Another difference is that
callbacks might be invoked sooner now because GFP_NOFS is a weaker
reclaim context and so there could be reclaimable memory which is just
not reachable now. That would require GFP_NOFS only loads which are
really rare and more importantly the observable result would be dropping
of reconstructible object and potential performance drop which is not
such a big deal when we are struggling to fulfill other important
allocation requests.

Cc: Daniel Vetter <daniel.vetter@intel.com>
Cc: Raushaniya Maksudova <rmaksudova@parallels.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c   |  9 +++++++++
 mm/page_alloc.c | 24 ++++++++++--------------
 2 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 86349586eacb..32d8210b8773 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -877,6 +877,15 @@ bool out_of_memory(struct oom_control *oc)
 	}
 
 	/*
+	 * The OOM killer does not compensate for IO-less reclaim.
+	 * pagefault_out_of_memory lost its gfp context so we have to
+	 * make sure exclude 0 mask - all other users should have at least
+	 * ___GFP_DIRECT_RECLAIM to get here.
+	 */
+	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
+		return true;
+
+	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
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
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
