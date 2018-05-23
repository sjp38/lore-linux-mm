Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2F36B0008
	for <linux-mm@kvack.org>; Wed, 23 May 2018 14:50:46 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id m5-v6so876834ywc.11
        for <linux-mm@kvack.org>; Wed, 23 May 2018 11:50:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 2-v6sor1558916ybm.141.2018.05.23.11.50.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 May 2018 11:50:45 -0700 (PDT)
Date: Wed, 23 May 2018 11:50:41 -0700
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH REPOST] mm: memcg: allow lowering memory.swap.max below the
 current usage
Message-ID: <20180523185041.GR1718769@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@kernel.org>, Shaohua Li <shli@fb.com>, Rik van Riel <riel@surriel.com>, cgroups@vger.kernel.org

Currently an attempt to set swap.max into a value lower than the
actual swap usage fails, which causes configuration problems as
there's no way of lowering the configuration below the current usage
short of turning off swap entirely.  This makes swap.max difficult to
use and allows delegatees to lock the delegator out of reducing swap
allocation.

This patch updates swap_max_write() so that the limit can be lowered
below the current usage.  It doesn't implement active reclaiming of
swap entries for the following reasons.

* mem_cgroup_swap_full() already tells the swap machinary to
  aggressively reclaim swap entries if the usage is above 50% of
  limit, so simply lowering the limit automatically triggers gradual
  reclaim.

* Forcing back swapped out pages is likely to heavily impact the
  workload and mess up the working set.  Given that swap usually is a
  lot less valuable and less scarce, letting the existing usage
  dissipate over time through the above gradual reclaim and as they're
  falted back in is likely the better behavior.

Signed-off-by: Tejun Heo <tj@kernel.org>
Acked-by: Roman Gushchin <guro@fb.com>
Acked-by: Rik van Riel <riel@surriel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Shaohua Li <shli@fb.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org
---
Hello, Andrew.

This was buried in the thread discussing Roman's original patch.  The
consensus seems to be that this simple approach is what we wanna do at
least for now.  Can you please pick it up?

Thanks.

 Documentation/cgroup-v2.txt |    5 +++++
 mm/memcontrol.c             |    6 +-----
 2 files changed, 6 insertions(+), 5 deletions(-)

--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1199,6 +1199,11 @@ PAGE_SIZE multiple when read back.
 	Swap usage hard limit.  If a cgroup's swap usage reaches this
 	limit, anonymous memory of the cgroup will not be swapped out.
 
+	When reduced under the current usage, the existing swap
+	entries are reclaimed gradually and the swap usage may stay
+	higher than the limit for an extended period of time.  This
+	reduces the impact on the workload and memory management.
+
 
 Usage Guidelines
 ~~~~~~~~~~~~~~~~
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6144,11 +6144,7 @@ static ssize_t swap_max_write(struct ker
 	if (err)
 		return err;
 
-	mutex_lock(&memcg_limit_mutex);
-	err = page_counter_limit(&memcg->swap, max);
-	mutex_unlock(&memcg_limit_mutex);
-	if (err)
-		return err;
+	xchg(&memcg->swap.limit, max);
 
 	return nbytes;
 }
