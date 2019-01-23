Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0318E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:31:47 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id n1so1792158ybd.10
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 14:31:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p9sor3532936ywc.175.2019.01.23.14.31.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 14:31:45 -0800 (PST)
Date: Wed, 23 Jan 2019 17:31:44 -0500
From: Chris Down <chris@chrisdown.name>
Subject: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190123223144.GA10798@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

memory.stat and other files already consider subtrees in their output,
and we should too in order to not present an inconsistent interface.

The current situation is fairly confusing, because people interacting
with cgroups expect hierarchical behaviour in the vein of memory.stat,
cgroup.events, and other files. For example, this causes confusion when
debugging reclaim events under low, as currently these always read "0"
at non-leaf memcg nodes, which frequently causes people to misdiagnose
breach behaviour. The same confusion applies to other counters in this
file when debugging issues.

Aggregation is done at write time instead of at read-time since these
counters aren't hot (unlike memory.stat which is per-page, so it does it
at read time), and it makes sense to bundle this with the file
notifications.

After this patch, events are propagated up the hierarchy:

    [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
    low 0
    high 0
    max 0
    oom 0
    oom_kill 0
    [root@ktst ~]# systemd-run -p MemoryMax=1 true
    Running as unit: run-r251162a189fb4562b9dabfdc9b0422f5.service
    [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
    low 0
    high 0
    max 7
    oom 1
    oom_kill 1

Signed-off-by: Chris Down <chris@chrisdown.name>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>
Cc: Dennis Zhou <dennis@kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 include/linux/memcontrol.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 380a212a8c52..5428b372def4 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -769,8 +769,10 @@ static inline void count_memcg_event_mm(struct mm_struct *mm,
 static inline void memcg_memory_event(struct mem_cgroup *memcg,
 				      enum memcg_memory_event event)
 {
-	atomic_long_inc(&memcg->memory_events[event]);
-	cgroup_file_notify(&memcg->events_file);
+	do {
+		atomic_long_inc(&memcg->memory_events[event]);
+		cgroup_file_notify(&memcg->events_file);
+	} while ((memcg = parent_mem_cgroup(memcg)));
 }
 
 static inline void memcg_memory_event_mm(struct mm_struct *mm,
-- 
2.20.1
