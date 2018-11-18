Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7606B1741
	for <linux-mm@kvack.org>; Sun, 18 Nov 2018 18:27:17 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 4so8006711plc.5
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 15:27:17 -0800 (PST)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id l24si20377143pgb.489.2018.11.18.15.27.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Nov 2018 15:27:15 -0800 (PST)
From: Jiang Biao <jiangbiao@linux.alibaba.com>
Subject: [PATCH] mm/memcontrol: improve memory.stat reporting
Date: Mon, 19 Nov 2018 07:27:03 +0800
Message-Id: <1542583623-101514-1-git-send-email-jiangbiao@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, jiangbiao@linux.alibaba.com, yang.shi@linux.alibaba.com, xlpang@linux.alibaba.com

commit a983b5ebee57 ("mm:memcontrol: fix excessive complexity in
memory.stat reporting") introduce 8%+ performance regression for
page_fault3 of will-it-scale benchmark:

Before commit a983b5ebee57,
#./runtest.py page_fault3
tasks,processes,processes_idle,threads,threads_idle,linear
0,0,100,0,100,0
1,729990,95.68,725437,95.66,725437 (Single process)
...
24,11476599,0.18,2185947,32.67,17410488 (24 processes for 24 cores)

After commit,
#./runtest.py page_fault3
tasks,processes,processes_idle,threads,threads_idle,linear
0,0,100,0,100,0
1,697310,95.61,703615,95.66,703615 (-4.48%)
...
24,10485783,0.20,2047735,35.99,16886760 (-8.63%)

Get will-it-scale benchmark and test page_fault3,
 # git clone https://github.com/antonblanchard/will-it-scale.git
 # cd will-it-scale/
 # ./runtest.py page_fault3

There are to factors that affect the proformance,
1, CHARGE_BATCH is too small that causes bad contention when charge
global stats/events.
2, Disabling interrupt in count_memcg_events/mod_memcg_stat.

This patch increase the CHARGE_BATCH to 256 to ease the contention,
And narrow the scope of disabling interrupt(only if x > CHARGE_BATCH)
when charging global stats/events, taking percpu counter's
implementation as reference.

This patch could fix the performance regression,
#./runtest.py page_fault3
tasks,processes,processes_idle,threads,threads_idle,linear
0,0,100,0,100,0
1,729975,95.64,730302,95.68,730302
24,11441125,0.07,2100586,31.08,17527248

Signed-off-by: Jiang Biao <jiangbiao@linux.alibaba.com>
---
 include/linux/memcontrol.h | 28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index db3e6bb..7546774 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -595,7 +595,7 @@ static inline void set_task_memcg_oom_skip(struct task_struct *p)
  * size of first charge trial. "32" comes from vmscan.c's magic value.
  * TODO: maybe necessary to use big numbers in big irons.
  */
-#define CHARGE_BATCH	32U
+#define CHARGE_BATCH	256U

 static inline void __count_memcg_events(struct mem_cgroup *memcg,
 				enum mem_cgroup_events_index idx,
@@ -608,22 +608,21 @@ static inline void __count_memcg_events(struct mem_cgroup *memcg,

 	x = count + __this_cpu_read(memcg->stat->events[idx]);
 	if (unlikely(x > CHARGE_BATCH)) {
+		unsigned long flags;
+		local_irq_save(flags);
 		atomic_long_add(x, &memcg->events[idx]);
-		x = 0;
+		__this_cpu_sub(memcg->stat->events[idx], x - count);
+		local_irq_restore(flags);
+	} else {
+		this_cpu_add(memcg->stat->events[idx], count);
 	}
-
-	__this_cpu_write(memcg->stat->events[idx], x);
 }

 static inline void count_memcg_events(struct mem_cgroup *memcg,
 				enum mem_cgroup_events_index idx,
 				unsigned long count)
 {
-	unsigned long flags;
-
-	local_irq_save(flags);
 	__count_memcg_events(memcg, idx, count);
-	local_irq_restore(flags);
 }

 static inline void
@@ -698,25 +697,24 @@ static inline void __mod_memcg_stat(struct mem_cgroup *memcg,

 	if (mem_cgroup_disabled())
 		return;
-
 	if (memcg) {
 		x = val + __this_cpu_read(memcg->stat->count[idx]);
 		if (unlikely(abs(x) > CHARGE_BATCH)) {
+			unsigned long flags;
+			local_irq_save(flags);
 			atomic_long_add(x, &memcg->stats[idx]);
-			x = 0;
+			__this_cpu_sub(memcg->stat->count[idx], x - val);
+			local_irq_restore(flags);
+		} else {
+			this_cpu_add(memcg->stat->count[idx], val);
 		}
-		__this_cpu_write(memcg->stat->count[idx], x);
 	}
 }

 static inline void mod_memcg_stat(struct mem_cgroup *memcg,
 			enum mem_cgroup_stat_index idx, int val)
 {
-	unsigned long flags;
-
-	local_irq_save(flags);
 	__mod_memcg_stat(memcg, idx, val);
-	local_irq_restore(flags);
 }

 /**
--
1.8.3.1
