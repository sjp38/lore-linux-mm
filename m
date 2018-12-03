Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 498AE6B6801
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 03:01:25 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id m1-v6so9635385plb.13
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 00:01:25 -0800 (PST)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id b10si14271752plz.233.2018.12.03.00.01.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 00:01:23 -0800 (PST)
From: Xunlei Pang <xlpang@linux.alibaba.com>
Subject: [PATCH 2/3] mm/vmscan: Enable kswapd to reclaim low-protected memory
Date: Mon,  3 Dec 2018 16:01:18 +0800
Message-Id: <20181203080119.18989-2-xlpang@linux.alibaba.com>
In-Reply-To: <20181203080119.18989-1-xlpang@linux.alibaba.com>
References: <20181203080119.18989-1-xlpang@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

There may be cgroup memory overcommitment, it will become
even common in the future.

Let's enable kswapd to reclaim low-protected memory in case
of memory pressure, to mitigate the global direct reclaim
pressures which could cause jitters to the response time of
lantency-sensitive groups.

Signed-off-by: Xunlei Pang <xlpang@linux.alibaba.com>
---
 mm/vmscan.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 62ac0c488624..3d412eb91f73 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3531,6 +3531,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
 	count_vm_event(PAGEOUTRUN);
 
+retry:
 	do {
 		unsigned long nr_reclaimed = sc.nr_reclaimed;
 		bool raise_priority = true;
@@ -3622,6 +3623,13 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			sc.priority--;
 	} while (sc.priority >= 1);
 
+	if (!sc.nr_reclaimed && sc.memcg_low_skipped) {
+		sc.priority = DEF_PRIORITY;
+		sc.memcg_low_reclaim = 1;
+		sc.memcg_low_skipped = 0;
+		goto retry;
+	}
+
 	if (!sc.nr_reclaimed)
 		pgdat->kswapd_failures++;
 
-- 
2.13.5 (Apple Git-94)
