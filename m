Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD0C6B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 09:02:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 139so13380873wmf.5
        for <linux-mm@kvack.org>; Mon, 29 May 2017 06:02:22 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 135si12361616wmx.59.2017.05.29.06.02.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 May 2017 06:02:20 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH] mm: bump PGSTEAL*/PGSCAN*/ALLOCSTALL counters in memcg reclaim
Date: Mon, 29 May 2017 14:01:41 +0100
Message-ID: <1496062901-21456-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Historically, PGSTEAL*/PGSCAN*/ALLOCSTALL counters were used to
account only for global reclaim events, memory cgroup targeted reclaim
was ignored.

It doesn't make sense anymore, because the whole reclaim path
is designed around cgroups. Also, per-cgroup counters can exceed the
corresponding global counters, what can be confusing.

So, make PGSTEAL*/PGSCAN*/ALLOCSTALL counters reflect sum of any
reclaim activity in the system.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: kernel-team@fb.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/vmscan.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7c2a36b..77253b1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1765,13 +1765,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	if (current_is_kswapd()) {
-		if (global_reclaim(sc))
-			__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
+		__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
 		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD,
 				   nr_scanned);
 	} else {
-		if (global_reclaim(sc))
-			__count_vm_events(PGSCAN_DIRECT, nr_scanned);
+		__count_vm_events(PGSCAN_DIRECT, nr_scanned);
 		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_DIRECT,
 				   nr_scanned);
 	}
@@ -1786,13 +1784,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	spin_lock_irq(&pgdat->lru_lock);
 
 	if (current_is_kswapd()) {
-		if (global_reclaim(sc))
-			__count_vm_events(PGSTEAL_KSWAPD, nr_reclaimed);
+		__count_vm_events(PGSTEAL_KSWAPD, nr_reclaimed);
 		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_KSWAPD,
 				   nr_reclaimed);
 	} else {
-		if (global_reclaim(sc))
-			__count_vm_events(PGSTEAL_DIRECT, nr_reclaimed);
+		__count_vm_events(PGSTEAL_DIRECT, nr_reclaimed);
 		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_DIRECT,
 				   nr_reclaimed);
 	}
@@ -2828,8 +2824,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 retry:
 	delayacct_freepages_start();
 
-	if (global_reclaim(sc))
-		__count_zid_vm_events(ALLOCSTALL, sc->reclaim_idx, 1);
+	__count_zid_vm_events(ALLOCSTALL, sc->reclaim_idx, 1);
 
 	do {
 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
