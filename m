Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 83F5D6B0005
	for <linux-mm@kvack.org>; Mon,  7 May 2018 16:16:59 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f10-v6so391828pln.21
        for <linux-mm@kvack.org>; Mon, 07 May 2018 13:16:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b6-v6sor4946968plx.0.2018.05.07.13.16.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 May 2018 13:16:58 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] mm: memcontrol: drain memcg stock on force_empty
Date: Mon,  7 May 2018 13:16:51 -0700
Message-Id: <20180507201651.165879-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Junaid Shahid <junaids@google.com>, Junaid Shahid <juanids@google.com>, Shakeel Butt <shakeelb@google.com>

From: Junaid Shahid <junaids@google.com>

The per-cpu memcg stock can retain a charge of upto 32 pages. On a
machine with large number of cpus, this can amount to a decent amount
of memory. Additionally force_empty interface might be triggering
unneeded memcg reclaims.

Signed-off-by: Junaid Shahid <juanids@google.com>
Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/memcontrol.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e2d33a37f971..2c3c69524b49 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2841,6 +2841,9 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 
 	/* we call try-to-free pages for make this cgroup empty */
 	lru_add_drain_all();
+
+	drain_all_stock(memcg);
+
 	/* try to free all pages in this cgroup */
 	while (nr_retries && page_counter_read(&memcg->memory)) {
 		int progress;
-- 
2.17.0.441.gb46fe60e1d-goog
