Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id AFD4D6B0035
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 23:29:39 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so2770479pad.10
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 20:29:38 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id sz8si4341001pac.181.2014.07.30.20.29.36
        for <linux-mm@kvack.org>;
        Wed, 30 Jul 2014 20:29:37 -0700 (PDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH] swap: remove the struct cpumask has_work
Date: Thu, 31 Jul 2014 11:30:19 +0800
Message-ID: <1406777421-12830-3-git-send-email-laijs@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, akpm@linux-foundation.org, Chris Metcalf <cmetcalf@tilera.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@gentwo.org>, Frederic Weisbecker <fweisbec@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Khalid Aziz <khalid.aziz@oracle.com>, linux-mm@kvack.org

It is suggested that cpumask_var_t and alloc_cpumask_var() should be used
instead of struct cpumask.  But I don't want to add this complicity nor
leave this unwelcome "static struct cpumask has_work;", so I just remove
it and use flush_work() to perform on all online drain_work.  flush_work()
performs very quickly on initialized but unused work item, thus we don't
need the struct cpumask has_work for performance.

CC: akpm@linux-foundation.org
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: Mel Gorman <mgorman@suse.de>
CC: Tejun Heo <tj@kernel.org>
CC: Christoph Lameter <cl@gentwo.org>
CC: Frederic Weisbecker <fweisbec@gmail.com>
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/swap.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 9e8e347..bb524ca 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -833,27 +833,24 @@ static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
 void lru_add_drain_all(void)
 {
 	static DEFINE_MUTEX(lock);
-	static struct cpumask has_work;
 	int cpu;
 
 	mutex_lock(&lock);
 	get_online_cpus();
-	cpumask_clear(&has_work);
 
 	for_each_online_cpu(cpu) {
 		struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);
 
+		INIT_WORK(work, lru_add_drain_per_cpu);
+
 		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
 		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
 		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
-		    need_activate_page_drain(cpu)) {
-			INIT_WORK(work, lru_add_drain_per_cpu);
+		    need_activate_page_drain(cpu))
 			schedule_work_on(cpu, work);
-			cpumask_set_cpu(cpu, &has_work);
-		}
 	}
 
-	for_each_cpu(cpu, &has_work)
+	for_each_online_cpu(cpu)
 		flush_work(&per_cpu(lru_add_drain_work, cpu));
 
 	put_online_cpus();
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
