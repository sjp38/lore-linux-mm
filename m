Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B9FF06B0279
	for <linux-mm@kvack.org>; Tue,  8 May 2018 08:47:23 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k16-v6so21551062wrh.6
        for <linux-mm@kvack.org>; Tue, 08 May 2018 05:47:23 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 62-v6si365644edc.141.2018.05.08.05.47.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 05:47:22 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v2] mm: fix oom_kill event handling
Date: Tue, 8 May 2018 13:46:37 +0100
Message-ID: <20180508124637.29984-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-team@fb.com
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

Commit e27be240df53 ("mm: memcg: make sure memory.events is
uptodate when waking pollers") converted most of memcg event
counters to per-memcg atomics, which made them less confusing
for a user. The "oom_kill" counter remained untouched, so now
it behaves differently than other counters (including "oom").
This adds nothing but confusion.

Let's fix this by adding the MEMCG_OOM_KILL event, and follow
the MEMCG_OOM approach. This also removes a hack from
count_memcg_event_mm(), introduced earlier specially for the
OOM_KILL counter.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
---
 include/linux/memcontrol.h | 26 ++++++++++++++++++++++----
 mm/memcontrol.c            |  6 ++++--
 mm/oom_kill.c              |  2 +-
 3 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6cbea2f25a87..794475db7368 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -54,6 +54,7 @@ enum memcg_memory_event {
 	MEMCG_HIGH,
 	MEMCG_MAX,
 	MEMCG_OOM,
+	MEMCG_OOM_KILL,
 	MEMCG_SWAP_MAX,
 	MEMCG_SWAP_FAIL,
 	MEMCG_NR_MEMORY_EVENTS,
@@ -721,11 +722,8 @@ static inline void count_memcg_event_mm(struct mm_struct *mm,
 
 	rcu_read_lock();
 	memcg = rcu_dereference(mm->memcg);
-	if (likely(memcg)) {
+	if (likely(memcg))
 		count_memcg_events(memcg, idx, 1);
-		if (idx == OOM_KILL)
-			cgroup_file_notify(&memcg->events_file);
-	}
 	rcu_read_unlock();
 }
 
@@ -736,6 +734,21 @@ static inline void memcg_memory_event(struct mem_cgroup *memcg,
 	cgroup_file_notify(&memcg->events_file);
 }
 
+static inline void memcg_memory_event_mm(struct mm_struct *mm,
+					 enum memcg_memory_event event)
+{
+	struct mem_cgroup *memcg;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	rcu_read_lock();
+	memcg = rcu_dereference(mm->memcg);
+	if (likely(memcg))
+		memcg_memory_event(memcg, event);
+	rcu_read_unlock();
+}
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
@@ -757,6 +770,11 @@ static inline void memcg_memory_event(struct mem_cgroup *memcg,
 {
 }
 
+static inline void memcg_memory_event_mm(struct mm_struct *mm,
+					 enum memcg_memory_event event)
+{
+}
+
 static inline bool mem_cgroup_low(struct mem_cgroup *root,
 				  struct mem_cgroup *memcg)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 10973671e562..38717630305d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3772,7 +3772,8 @@ static int mem_cgroup_oom_control_read(struct seq_file *sf, void *v)
 
 	seq_printf(sf, "oom_kill_disable %d\n", memcg->oom_kill_disable);
 	seq_printf(sf, "under_oom %d\n", (bool)memcg->under_oom);
-	seq_printf(sf, "oom_kill %lu\n", memcg_sum_events(memcg, OOM_KILL));
+	seq_printf(sf, "oom_kill %lu\n",
+		   atomic_long_read(&memcg->memory_events[MEMCG_OOM_KILL]));
 	return 0;
 }
 
@@ -5529,7 +5530,8 @@ static int memory_events_show(struct seq_file *m, void *v)
 		   atomic_long_read(&memcg->memory_events[MEMCG_MAX]));
 	seq_printf(m, "oom %lu\n",
 		   atomic_long_read(&memcg->memory_events[MEMCG_OOM]));
-	seq_printf(m, "oom_kill %lu\n", memcg_sum_events(memcg, OOM_KILL));
+	seq_printf(m, "oom_kill %lu\n",
+		   atomic_long_read(&memcg->memory_events[MEMCG_OOM_KILL]));
 
 	return 0;
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8f7d8dd99e5d..6b74142a1259 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -868,7 +868,7 @@ static void __oom_kill_process(struct task_struct *victim)
 
 	/* Raise event before sending signal: task reaper must see this */
 	count_vm_event(OOM_KILL);
-	count_memcg_event_mm(mm, OOM_KILL);
+	memcg_memory_event_mm(mm, MEMCG_OOM_KILL);
 
 	/*
 	 * We should send SIGKILL before granting access to memory reserves
-- 
2.14.3
