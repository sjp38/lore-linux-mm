Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A957D6B0269
	for <linux-mm@kvack.org>; Fri,  4 May 2018 16:55:58 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id m68so18147022pfm.20
        for <linux-mm@kvack.org>; Fri, 04 May 2018 13:55:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f9-v6sor3306127pge.41.2018.05.04.13.55.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 May 2018 13:55:57 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] mm: memcontrol: drain stocks on resize limit
Date: Fri,  4 May 2018 13:55:48 -0700
Message-Id: <20180504205548.110696-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>

Resizing the memcg limit for cgroup-v2 drains the stocks before
triggering the memcg reclaim. Do the same for cgroup-v1 to make the
behavior consistent.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/memcontrol.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 25b148c2d222..e2d33a37f971 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2463,6 +2463,7 @@ static int mem_cgroup_resize_max(struct mem_cgroup *memcg,
 				 unsigned long max, bool memsw)
 {
 	bool enlarge = false;
+	bool drained = false;
 	int ret;
 	bool limits_invariant;
 	struct page_counter *counter = memsw ? &memcg->memsw : &memcg->memory;
@@ -2493,6 +2494,12 @@ static int mem_cgroup_resize_max(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
+		if (!drained) {
+			drain_all_stock(memcg);
+			drained = true;
+			continue;
+		}
+
 		if (!try_to_free_mem_cgroup_pages(memcg, 1,
 					GFP_KERNEL, !memsw)) {
 			ret = -EBUSY;
-- 
2.17.0.441.gb46fe60e1d-goog
