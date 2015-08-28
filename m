Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id CB2A06B0255
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 11:25:39 -0400 (EDT)
Received: by ykdz80 with SMTP id z80so18626154ykd.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 08:25:39 -0700 (PDT)
Received: from mail-yk0-x234.google.com (mail-yk0-x234.google.com. [2607:f8b0:4002:c07::234])
        by mx.google.com with ESMTPS id r62si4256752ywe.153.2015.08.28.08.25.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 08:25:36 -0700 (PDT)
Received: by ykay144 with SMTP id y144so3324899yka.2
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 08:25:34 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/4] memcg: fix over-high reclaim amount
Date: Fri, 28 Aug 2015 11:25:27 -0400
Message-Id: <1440775530-18630-2-git-send-email-tj@kernel.org>
In-Reply-To: <1440775530-18630-1-git-send-email-tj@kernel.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com, Tejun Heo <tj@kernel.org>

When memory usage is over the high limit, try_charge() performs direct
reclaim; however, it uses the current charging amount @nr_pages as the
reclamation target which is incorrect as we want to reclaim down to
the high limit.  In practice, this doesn't matter all that much
because the minimum target pages that try_to_free_mem_cgroup_pages()
uses is SWAP_CLUSTER_MAX which is rather large.

Fix it by setting the target number of pages to the difference between
the current usage and the high limit.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 mm/memcontrol.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index aacc767..18ecf75 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2078,10 +2078,13 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * make the charging task trim their excess contribution.
 	 */
 	do {
-		if (page_counter_read(&memcg->memory) <= memcg->high)
+		unsigned long usage = page_counter_read(&memcg->memory);
+		unsigned long high = ACCESS_ONCE(memcg->high);
+
+		if (usage <= high)
 			continue;
 		mem_cgroup_events(memcg, MEMCG_HIGH, 1);
-		try_to_free_mem_cgroup_pages(memcg, nr_pages, gfp_mask, true);
+		try_to_free_mem_cgroup_pages(memcg, high - usage, gfp_mask, true);
 	} while ((memcg = parent_mem_cgroup(memcg)));
 done:
 	return ret;
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
