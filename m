Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F0EE66B0317
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:49:13 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id o3so53618265wjo.1
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:49:13 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id p188si19042029wmp.142.2016.12.20.05.49.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:49:12 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id kp2so27731263wjc.0
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:49:12 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL automatically
Date: Tue, 20 Dec 2016 14:49:03 +0100
Message-Id: <20161220134904.21023-3-mhocko@kernel.org>
In-Reply-To: <20161220134904.21023-1-mhocko@kernel.org>
References: <20161220134904.21023-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__alloc_pages_may_oom makes sure to skip the OOM killer depending on
the allocation request. This includes lowmem requests, costly high
order requests and others. For a long time __GFP_NOFAIL acted as an
override for all those rules. This is not documented and it can be quite
surprising as well. E.g. GFP_NOFS requests are not invoking the OOM
killer but GFP_NOFS|__GFP_NOFAIL does so if we try to convert some of
the existing open coded loops around allocator to nofail request (and we
have done that in the past) then such a change would have a non trivial
side effect which is far from obvious. Note that the primary motivation
for skipping the OOM killer is to prevent from pre-mature invocation.

The exception has been added by 82553a937f12 ("oom: invoke oom killer
for __GFP_NOFAIL"). The changelog points out that the oom killer has to
be invoked otherwise the request would be looping for ever. But this
argument is rather weak because the OOM killer doesn't really guarantee
a forward progress for those exceptional cases:
	- it will hardly help to form costly order which in turn can
	  result in the system panic because of no oom killable task in
	  the end - I believe we certainly do not want to put the system
	  down just because there is a nasty driver asking for order-9
	  page with GFP_NOFAIL not realizing all the consequences. It is
	  much better this request would loop for ever than the massive
	  system disruption
	- lowmem is also highly unlikely to be freed during OOM killer
	- GFP_NOFS request could trigger while there is still a lot of
	  memory pinned by filesystems.

The pre-mature OOM killer is a real issue as reported by Nils Holland
	kworker/u4:5 invoked oom-killer: gfp_mask=0x2400840(GFP_NOFS|__GFP_NOFAIL), nodemask=0, order=0, oom_score_adj=0
	kworker/u4:5 cpuset=/ mems_allowed=0
	CPU: 1 PID: 2603 Comm: kworker/u4:5 Not tainted 4.9.0-gentoo #2
	Hardware name: Hewlett-Packard Compaq 15 Notebook PC/21F7, BIOS F.22 08/06/2014
	Workqueue: writeback wb_workfn (flush-btrfs-1)
	 eff0b604 c142bcce eff0b734 00000000 eff0b634 c1163332 00000000 00000292
	 eff0b634 c1431876 eff0b638 e7fb0b00 e7fa2900 e7fa2900 c1b58785 eff0b734
	 eff0b678 c110795f c1043895 eff0b664 c11075c7 00000007 00000000 00000000
	Call Trace:
	 [<c142bcce>] dump_stack+0x47/0x69
	 [<c1163332>] dump_header+0x60/0x178
	 [<c1431876>] ? ___ratelimit+0x86/0xe0
	 [<c110795f>] oom_kill_process+0x20f/0x3d0
	 [<c1043895>] ? has_capability_noaudit+0x15/0x20
	 [<c11075c7>] ? oom_badness.part.13+0xb7/0x130
	 [<c1107df9>] out_of_memory+0xd9/0x260
	 [<c110ba0b>] __alloc_pages_nodemask+0xbfb/0xc80
	 [<c110414d>] pagecache_get_page+0xad/0x270
	 [<c13664a6>] alloc_extent_buffer+0x116/0x3e0
	 [<c1334a2e>] btrfs_find_create_tree_block+0xe/0x10
	[...]
	Normal free:41332kB min:41368kB low:51708kB high:62048kB active_anon:0kB inactive_anon:0kB active_file:532748kB inactive_file:44kB unevictable:0kB writepending:24kB present:897016kB managed:836248kB mlocked:0kB slab_reclaimable:159448kB slab_unreclaimable:69608kB kernel_stack:1112kB pagetables:1404kB bounce:0kB free_pcp:528kB local_pcp:340kB free_cma:0kB
	lowmem_reserve[]: 0 0 21292 21292
	HighMem free:781660kB min:512kB low:34356kB high:68200kB active_anon:234740kB inactive_anon:360kB active_file:557232kB inactive_file:1127804kB unevictable:0kB writepending:2592kB present:2725384kB managed:2725384kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:800kB local_pcp:608kB free_cma:0kB

this is a GFP_NOFS|__GFP_NOFAIL request which invokes the OOM killer
because there is clearly nothing reclaimable in the zone Normal while
there is a lot of page cache which is most probably pinned by the fs but
GFP_NOFS cannot reclaim it.

This patch simply removes the __GFP_NOFAIL special case in order to have
a more clear semantic without surprising side effects.

Reported-by: Nils Holland <nholland@tisys.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c   |  2 +-
 mm/page_alloc.c | 49 ++++++++++++++++++++++++-------------------------
 2 files changed, 25 insertions(+), 26 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ec9f11d4f094..12a6fce85f61 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1013,7 +1013,7 @@ bool out_of_memory(struct oom_control *oc)
 	 * make sure exclude 0 mask - all other users should have at least
 	 * ___GFP_DIRECT_RECLAIM to get here.
 	 */
-	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
+	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
 		return true;
 
 	/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c8eed66d8abb..2dda7c3eba52 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3098,32 +3098,31 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	if (page)
 		goto out;
 
-	if (!(gfp_mask & __GFP_NOFAIL)) {
-		/* Coredumps can quickly deplete all memory reserves */
-		if (current->flags & PF_DUMPCORE)
-			goto out;
-		/* The OOM killer will not help higher order allocs */
-		if (order > PAGE_ALLOC_COSTLY_ORDER)
-			goto out;
-		/* The OOM killer does not needlessly kill tasks for lowmem */
-		if (ac->high_zoneidx < ZONE_NORMAL)
-			goto out;
-		if (pm_suspended_storage())
-			goto out;
-		/*
-		 * XXX: GFP_NOFS allocations should rather fail than rely on
-		 * other request to make a forward progress.
-		 * We are in an unfortunate situation where out_of_memory cannot
-		 * do much for this context but let's try it to at least get
-		 * access to memory reserved if the current task is killed (see
-		 * out_of_memory). Once filesystems are ready to handle allocation
-		 * failures more gracefully we should just bail out here.
-		 */
+	/* Coredumps can quickly deplete all memory reserves */
+	if (current->flags & PF_DUMPCORE)
+		goto out;
+	/* The OOM killer will not help higher order allocs */
+	if (order > PAGE_ALLOC_COSTLY_ORDER)
+		goto out;
+	/* The OOM killer does not needlessly kill tasks for lowmem */
+	if (ac->high_zoneidx < ZONE_NORMAL)
+		goto out;
+	if (pm_suspended_storage())
+		goto out;
+	/*
+	 * XXX: GFP_NOFS allocations should rather fail than rely on
+	 * other request to make a forward progress.
+	 * We are in an unfortunate situation where out_of_memory cannot
+	 * do much for this context but let's try it to at least get
+	 * access to memory reserved if the current task is killed (see
+	 * out_of_memory). Once filesystems are ready to handle allocation
+	 * failures more gracefully we should just bail out here.
+	 */
+
+	/* The OOM killer may not free memory on a specific node */
+	if (gfp_mask & __GFP_THISNODE)
+		goto out;
 
-		/* The OOM killer may not free memory on a specific node */
-		if (gfp_mask & __GFP_THISNODE)
-			goto out;
-	}
 	/* Exhausted what can be done so it's blamo time */
 	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
 		*did_some_progress = 1;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
