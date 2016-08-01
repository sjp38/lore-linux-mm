Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE5A6B0260
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 13:41:33 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so86698736wmz.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 10:41:33 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id v3si32489669wjc.147.2016.08.01.10.41.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 10:41:31 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i5so27177821wmg.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 10:41:30 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2] memcg: put soft limit reclaim out of way if the excess tree is empty
Date: Mon,  1 Aug 2016 19:41:17 +0200
Message-Id: <1470073277-1056-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

We've had a report about soft lockups caused by lock bouncing in the
soft reclaim path:

[331404.849734] BUG: soft lockup - CPU#0 stuck for 22s! [kav4proxy-kavic:3128]
[331404.849920] RIP: 0010:[<ffffffff81469798>]  [<ffffffff81469798>] _raw_spin_lock+0x18/0x20
[331404.849997] Call Trace:
[331404.850010]  [<ffffffff811557ea>] mem_cgroup_soft_limit_reclaim+0x25a/0x280
[331404.850020]  [<ffffffff8111041d>] shrink_zones+0xed/0x200
[331404.850027]  [<ffffffff81111a94>] do_try_to_free_pages+0x74/0x320
[331404.850034]  [<ffffffff81112072>] try_to_free_pages+0x112/0x180
[331404.850042]  [<ffffffff81104a6f>] __alloc_pages_slowpath+0x3ff/0x820
[331404.850049]  [<ffffffff81105079>] __alloc_pages_nodemask+0x1e9/0x200
[331404.850056]  [<ffffffff81141e01>] alloc_pages_vma+0xe1/0x290
[331404.850064]  [<ffffffff8112402f>] do_wp_page+0x19f/0x840
[331404.850071]  [<ffffffff811257cd>] handle_pte_fault+0x1cd/0x230
[331404.850079]  [<ffffffff8146d3ed>] do_page_fault+0x1fd/0x4c0
[331404.850087]  [<ffffffff81469ec5>] page_fault+0x25/0x30

There are no memcgs created so there cannot be any in the soft limit
excess obviously:
[...]
memory  0       1       1

so all this just seems to be mem_cgroup_largest_soft_limit_node
trying to get spin_lock_irq(&mctz->lock) just to find out that the soft
limit excess tree is empty. This is just pointless waisting of cycles
and cache line bouncing during heavy parallel reclaim on large machines.
The particular machine wasn't very healthy and most probably suffering
from a memory leak which just caused the memory reclaim to trash
heavily. But bouncing on the lock certainly didn't help...

Fix this by optimistic lockless check and bail out early if the tree is
empty. This is theoretically racy but that shouldn't matter all that
much. First of all soft limit is a best effort feature and it is slowly
getting deprecated and its usage should be really scarce. Bouncing on a
lock without a good reason is surely much bigger problem, especially on
large CPU machines.

Changes since v1
- drop the helper function and use RB_EMPTY_ROOT directly with some
  explanation

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memcontrol.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c265212bec8c..66beca1ad92f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2559,6 +2559,15 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
 		return 0;
 
 	mctz = soft_limit_tree_node(pgdat->node_id);
+
+	/*
+	 * Do not even bother to check the largest node if the root
+	 * is empty. Do it lockless to prevent lock bouncing. Races
+	 * are acceptable as soft limit is best effort anyway.
+	 */
+	if (RB_EMPTY_ROOT(&mctz->rb_root))
+		return 0;
+
 	/*
 	 * This loop can run a while, specially if mem_cgroup's continuously
 	 * keep exceeding their soft limit and putting the system under
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
