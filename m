Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBC868E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 20:56:52 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id j13so22912884oii.8
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 17:56:52 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id x2sor28012424ota.72.2019.01.02.17.56.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 17:56:51 -0800 (PST)
Date: Wed,  2 Jan 2019 17:56:38 -0800
Message-Id: <20190103015638.205424-1-shakeelb@google.com>
Mime-Version: 1.0
Subject: [PATCH] memcg: schedule high reclaim for remote memcgs on high_work
From: Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

If a memcg is over high limit, memory reclaim is scheduled to run on
return-to-userland. However it is assumed that the memcg is the current
process's memcg. With remote memcg charging for kmem or swapping in a
page charged to remote memcg, current process can trigger reclaim on
remote memcg. So, schduling reclaim on return-to-userland for remote
memcgs will ignore the high reclaim altogether. So, punt the high
reclaim of remote memcgs to high_work.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/memcontrol.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e9db1160ccbc..47439c84667a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2302,19 +2302,23 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * reclaim on returning to userland.  We can perform reclaim here
 	 * if __GFP_RECLAIM but let's always punt for simplicity and so that
 	 * GFP_KERNEL can consistently be used during reclaim.  @memcg is
-	 * not recorded as it most likely matches current's and won't
-	 * change in the meantime.  As high limit is checked again before
-	 * reclaim, the cost of mismatch is negligible.
+	 * not recorded as the return-to-userland high reclaim will only reclaim
+	 * from current's memcg (or its ancestor). For other memcgs we punt them
+	 * to work queue.
 	 */
 	do {
 		if (page_counter_read(&memcg->memory) > memcg->high) {
-			/* Don't bother a random interrupted task */
-			if (in_interrupt()) {
+			/*
+			 * Don't bother a random interrupted task or if the
+			 * memcg is not current's memcg's ancestor.
+			 */
+			if (in_interrupt() ||
+			    !mm_match_cgroup(current->mm, memcg)) {
 				schedule_work(&memcg->high_work);
-				break;
+			} else {
+				current->memcg_nr_pages_over_high += batch;
+				set_notify_resume(current);
 			}
-			current->memcg_nr_pages_over_high += batch;
-			set_notify_resume(current);
 			break;
 		}
 	} while ((memcg = parent_mem_cgroup(memcg)));
-- 
2.20.1.415.g653613c723-goog
