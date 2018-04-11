Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 164516B0005
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 03:00:28 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k70so274410pgc.3
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 00:00:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u6-v6si527374pls.11.2018.04.11.00.00.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 00:00:26 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, slab: reschedule cache_reap() on the same CPU
Date: Wed, 11 Apr 2018 09:00:07 +0200
Message-Id: <20180411070007.32225-1-vbabka@suse.cz>
In-Reply-To: <20180410081531.18053-1-vbabka@suse.cz>
References: <20180410081531.18053-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, John Stultz <john.stultz@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>

cache_reap() is initially scheduled in start_cpu_timer() via
schedule_delayed_work_on(). But then the next iterations are scheduled via
schedule_delayed_work(), i.e. using WORK_CPU_UNBOUND.

Thus since commit ef557180447f ("workqueue: schedule WORK_CPU_UNBOUND work on
wq_unbound_cpumask CPUs") there is no guarantee the future iterations will run
on the originally intended cpu, although it's still preferred. I was able to
demonstrate this with /sys/module/workqueue/parameters/debug_force_rr_cpu.
IIUC, it may also happen due to migrating timers in nohz context. As a result,
some cpu's would be calling cache_reap() more frequently and others never.

This patch uses schedule_delayed_work_on() with the current cpu when scheduling
the next iteration.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Fixes: ef557180447f ("workqueue: schedule WORK_CPU_UNBOUND work on wq_unbound_cpumask CPUs")
CC: <stable@vger.kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Stephen Boyd <sboyd@kernel.org>
---
 mm/slab.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9095c3945425..a76006aae857 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4074,7 +4074,8 @@ static void cache_reap(struct work_struct *w)
 	next_reap_node();
 out:
 	/* Set up the next iteration */
-	schedule_delayed_work(work, round_jiffies_relative(REAPTIMEOUT_AC));
+	schedule_delayed_work_on(smp_processor_id(), work,
+				round_jiffies_relative(REAPTIMEOUT_AC));
 }
 
 void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
-- 
2.16.3
