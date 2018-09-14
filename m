Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0D68E0004
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 10:59:35 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id u12-v6so10504502wrc.1
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 07:59:35 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b192-v6si1894684wmd.110.2018.09.14.07.59.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 14 Sep 2018 07:59:33 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 2/2] mm/swap: Access struct pagevec remotely
Date: Fri, 14 Sep 2018 16:59:24 +0200
Message-Id: <20180914145924.22055-3-bigeasy@linutronix.de>
In-Reply-To: <20180914145924.22055-1-bigeasy@linutronix.de>
References: <20180914145924.22055-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, Vlastimil Babka <vbabka@suse.cz>, frederic@kernel.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

From: Thomas Gleixner <tglx@linutronix.de>

Now that struct pagevec is locked during access, it is possible to
access it from a remote CPU. The advantage is that the work can be done
from the "requesting" CPU without firing a worker on a remote CPU and
waiting for it to complete the work.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
[bigeasy: +commit message]
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/swap.c | 37 +------------------------------------
 1 file changed, 1 insertion(+), 36 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 17702ee5bf81c..ec36e733aab5d 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -733,54 +733,19 @@ void lru_add_drain(void)
 	lru_add_drain_cpu(raw_smp_processor_id());
 }
 
-static void lru_add_drain_per_cpu(struct work_struct *dummy)
-{
-	lru_add_drain();
-}
-
-static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
-
-/*
- * Doesn't need any cpu hotplug locking because we do rely on per-cpu
- * kworkers being shut down before our page_alloc_cpu_dead callback is
- * executed on the offlined cpu.
- * Calling this function with cpu hotplug locks held can actually lead
- * to obscure indirect dependencies via WQ context.
- */
 void lru_add_drain_all(void)
 {
-	static DEFINE_MUTEX(lock);
-	static struct cpumask has_work;
 	int cpu;
 
-	/*
-	 * Make sure nobody triggers this path before mm_percpu_wq is fully
-	 * initialized.
-	 */
-	if (WARN_ON(!mm_percpu_wq))
-		return;
-
-	mutex_lock(&lock);
-	cpumask_clear(&has_work);
-
 	for_each_online_cpu(cpu) {
-		struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);
-
 		if (pagevec_count(&per_cpu(lru_add_pvec.pvec, cpu)) ||
 		    pagevec_count(&per_cpu(lru_rotate_pvecs.pvec, cpu)) ||
 		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs.pvec, cpu)) ||
 		    pagevec_count(&per_cpu(lru_lazyfree_pvecs.pvec, cpu)) ||
 		    need_activate_page_drain(cpu)) {
-			INIT_WORK(work, lru_add_drain_per_cpu);
-			queue_work_on(cpu, mm_percpu_wq, work);
-			cpumask_set_cpu(cpu, &has_work);
+			lru_add_drain_cpu(cpu);
 		}
 	}
-
-	for_each_cpu(cpu, &has_work)
-		flush_work(&per_cpu(lru_add_drain_work, cpu));
-
-	mutex_unlock(&lock);
 }
 
 /**
-- 
2.19.0
