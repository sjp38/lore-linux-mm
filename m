Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC186B0003
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 21:39:08 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id a20so9390752ywe.18
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 18:39:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c187-v6sor735235ybb.23.2018.04.15.18.39.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 15 Apr 2018 18:39:07 -0700 (PDT)
Date: Sun, 15 Apr 2018 18:39:02 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: allow to decrease swap.max below actual swap usage
Message-ID: <20180416013902.GD1911913@devbig577.frc2.facebook.com>
References: <20180412132705.30316-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180412132705.30316-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Shaohua Li <shli@fb.com>, Rik van Riel <riel@surriel.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com

Hello, Roman.

The reclaim behavior is a bit worrisome.

* It disables an entire swap area while reclaim is in progress.  Most
  systems only have one swap area, so this would disable allocating
  new swap area for everyone.

* The reclaim seems very inefficient.  IIUC, it has to read every swap
  page to see whether the page belongs to the target memcg and for
  each matching page, which involves walking page mm's and page
  tables.

An easy optimization would be walking swap_cgroup_ctrl so that it only
reads swap entries which belong to the target cgroup and avoid
disabling swap for others, but looking at the code, I wonder whether
we need active reclaim at all.

Swap already tries to aggressively reclaim swap entries when swap
usage > 50% of the limit, so simply reducing the limit already
triggers aggressive reclaim, and given that it's swap, just waiting it
out could be the better behavior anyway, so how about something like
the following?

------ 8< ------
From: Tejun Heo <tj@kernel.org>
Subject: mm: memcg: allow lowering memory.swap.max below the current usage

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
Cc: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Shaohua Li <shli@fb.com>
Cc: Rik van Riel <riel@surriel.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org
---
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
