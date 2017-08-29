Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5381E6B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 06:02:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v2so3699266wmd.11
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 03:02:41 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id k18si2040576wrd.354.2017.08.29.03.02.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 03:02:39 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH] mm: memcontrol: use per-cpu stocks for socket memory uncharging
Date: Tue, 29 Aug 2017 11:01:50 +0100
Message-ID: <20170829100150.4580-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, kernel-team@fb.com, linux-kernel@vger.kernel.org

We've noticed a quite sensible performance overhead on some hosts
with significant network traffic when socket memory accounting
is enabled.

Perf top shows that socket memory uncharging path is hot:
  2.13%  [kernel]                [k] page_counter_cancel
  1.14%  [kernel]                [k] __sk_mem_reduce_allocated
  1.14%  [kernel]                [k] _raw_spin_lock
  0.87%  [kernel]                [k] _raw_spin_lock_irqsave
  0.84%  [kernel]                [k] tcp_ack
  0.84%  [kernel]                [k] ixgbe_poll
  0.83%  < workload >
  0.82%  [kernel]                [k] enqueue_entity
  0.68%  [kernel]                [k] __fget
  0.68%  [kernel]                [k] tcp_delack_timer_handler
  0.67%  [kernel]                [k] __schedule
  0.60%  < workload >
  0.59%  [kernel]                [k] __inet6_lookup_established
  0.55%  [kernel]                [k] __switch_to
  0.55%  [kernel]                [k] menu_select
  0.54%  libc-2.20.so            [.] __memcpy_avx_unaligned

To address this issue, the existing per-cpu stock infrastructure
can be used.

refill_stock() can be called from mem_cgroup_uncharge_skmem()
to move charge to a per-cpu stock instead of calling atomic
page_counter_uncharge().

To prevent the uncontrolled growth of per-cpu stocks,
refill_stock() will explicitly drain the cached charge,
if the cached value exceeds CHARGE_BATCH.

This allows significantly optimize the load:
  1.21%  [kernel]                [k] _raw_spin_lock
  1.01%  [kernel]                [k] ixgbe_poll
  0.92%  [kernel]                [k] _raw_spin_lock_irqsave
  0.90%  [kernel]                [k] enqueue_entity
  0.86%  [kernel]                [k] tcp_ack
  0.85%  < workload >
  0.74%  perf-11120.map          [.] 0x000000000061bf24
  0.73%  [kernel]                [k] __schedule
  0.67%  [kernel]                [k] __fget
  0.63%  [kernel]                [k] __inet6_lookup_established
  0.62%  [kernel]                [k] menu_select
  0.59%  < workload >
  0.59%  [kernel]                [k] __switch_to
  0.57%  libc-2.20.so            [.] __memcpy_avx_unaligned

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: cgroups@vger.kernel.org
Cc: kernel-team@fb.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/memcontrol.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b9cf3cf4a3d0..a69d23082abf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1792,6 +1792,9 @@ static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
 	}
 	stock->nr_pages += nr_pages;
 
+	if (stock->nr_pages > CHARGE_BATCH)
+		drain_stock(stock);
+
 	local_irq_restore(flags);
 }
 
@@ -5886,8 +5889,7 @@ void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 
 	this_cpu_sub(memcg->stat->count[MEMCG_SOCK], nr_pages);
 
-	page_counter_uncharge(&memcg->memory, nr_pages);
-	css_put_many(&memcg->css, nr_pages);
+	refill_stock(memcg, nr_pages);
 }
 
 static int __init cgroup_memory(char *s)
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
