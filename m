Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DFF5C6B0007
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 01:48:16 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id q12-v6so2143529pgp.6
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 22:48:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o19-v6sor973708pgk.118.2018.08.02.22.48.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Aug 2018 22:48:15 -0700 (PDT)
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Subject: [PATCH v1] mm:memcg: skip memcg of current in mem_cgroup_soft_limit_reclaim
Date: Fri,  3 Aug 2018 13:48:05 +0800
Message-Id: <1533275285-12387-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org

for the soft_limit reclaim has more directivity than global reclaim, we
have current memcg be skipped to avoid potential page thrashing.

Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
---
 mm/memcontrol.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8c0280b..9d09e95 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2537,12 +2537,21 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
 			mz = mem_cgroup_largest_soft_limit_node(mctz);
 		if (!mz)
 			break;
-
+		/*
+		 * skip current memcg to avoid page thrashing, for the
+		 * mem_cgroup_soft_reclaim has more directivity than
+		 * global reclaim.
+		 */
+		if (get_mem_cgroup_from_mm(current->mm) == mz->memcg) {
+			reclaimed = 0;
+			goto next;
+		}
 		nr_scanned = 0;
 		reclaimed = mem_cgroup_soft_reclaim(mz->memcg, pgdat,
 						    gfp_mask, &nr_scanned);
 		nr_reclaimed += reclaimed;
 		*total_scanned += nr_scanned;
+next:
 		spin_lock_irq(&mctz->lock);
 		__mem_cgroup_remove_exceeded(mz, mctz);
 
-- 
1.9.1
