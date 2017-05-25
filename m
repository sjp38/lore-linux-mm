Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB3A36B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 06:28:36 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id o139so26329168lfe.15
        for <linux-mm@kvack.org>; Thu, 25 May 2017 03:28:36 -0700 (PDT)
Received: from forwardcorp1m.cmail.yandex.net (forwardcorp1m.cmail.yandex.net. [2a02:6b8:b030::ee])
        by mx.google.com with ESMTPS id r10si4577491ljd.156.2017.05.25.03.28.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 03:28:34 -0700 (PDT)
Subject: [PATCH v2] mm/oom_kill: count global and memory cgroup oom kills
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 25 May 2017 13:28:30 +0300
Message-ID: <149570810989.203600.9492483715840752937.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Roman Guschin <guroan@gmail.com>, David Rientjes <rientjes@google.com>

Show count of oom killer invocations in /proc/vmstat and count of
processes killed in memory cgroup in knob "memory.events"
(in memory.oom_control for v1 cgroup).

Also describe difference between "oom" and "oom_kill" in memory
cgroup documentation. Currently oom in memory cgroup kills tasks
iff shortage has happened inside page fault.

These counters helps in monitoring oom kills - for now
the only way is grepping for magic words in kernel log.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

---

v1: https://lkml.kernel.org/r/149520375057.74196.2843113275800730971.stgit@buzz

v2:
* count all oom kills in /proc/vmstat
* update counter for cgroup which tasks belongs to
---
 Documentation/cgroup-v2.txt   |   20 ++++++++++++++++----
 include/linux/memcontrol.h    |    5 ++++-
 include/linux/vm_event_item.h |    1 +
 mm/memcontrol.c               |    2 ++
 mm/oom_kill.c                 |    5 +++++
 mm/vmstat.c                   |    1 +
 6 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index dc5e2dcdbef4..738b1c7023ad 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -826,13 +826,25 @@ PAGE_SIZE multiple when read back.
 
 		The number of times the cgroup's memory usage was
 		about to go over the max boundary.  If direct reclaim
-		fails to bring it down, the OOM killer is invoked.
+		fails to bring it down, the cgroup goes to OOM state.
 
 	  oom
 
-		The number of times the OOM killer has been invoked in
-		the cgroup.  This may not exactly match the number of
-		processes killed but should generally be close.
+		The number of time the cgroup's memory usage was
+		reached the limit and allocation was about to fail.
+
+		Depending on context result could be invocation of OOM
+		killer and retrying allocation or failing alloction.
+
+		Failed allocation in its turn could be returned into
+		userspace as -ENOMEM or siletly ignored in cases like
+		disk readahead.	 For now OOM in memory cgroup kills
+		tasks iff shortage has happened inside page fault.
+
+	  oom_kill
+
+		The number of processes belonging to this cgroup
+		killed by any kind of OOM killer.
 
   memory.stat
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 899949bbb2f9..42296f7001da 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -556,8 +556,11 @@ static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
 
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
-	if (likely(memcg))
+	if (likely(memcg)) {
 		this_cpu_inc(memcg->stat->events[idx]);
+		if (idx == OOM_KILL)
+			cgroup_file_notify(&memcg->events_file);
+	}
 	rcu_read_unlock();
 }
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index d84ae90ccd5c..1707e0a7d943 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -41,6 +41,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
 		PAGEOUTRUN, PGROTATED,
 		DROP_PAGECACHE, DROP_SLAB,
+		OOM_KILL,
 #ifdef CONFIG_NUMA_BALANCING
 		NUMA_PTE_UPDATES,
 		NUMA_HUGE_PTE_UPDATES,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 94172089f52f..7011ebf2b90e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3574,6 +3574,7 @@ static int mem_cgroup_oom_control_read(struct seq_file *sf, void *v)
 
 	seq_printf(sf, "oom_kill_disable %d\n", memcg->oom_kill_disable);
 	seq_printf(sf, "under_oom %d\n", (bool)memcg->under_oom);
+	seq_printf(sf, "oom_kill %lu\n", memcg_sum_events(memcg, OOM_KILL));
 	return 0;
 }
 
@@ -5165,6 +5166,7 @@ static int memory_events_show(struct seq_file *m, void *v)
 	seq_printf(m, "high %lu\n", memcg_sum_events(memcg, MEMCG_HIGH));
 	seq_printf(m, "max %lu\n", memcg_sum_events(memcg, MEMCG_MAX));
 	seq_printf(m, "oom %lu\n", memcg_sum_events(memcg, MEMCG_OOM));
+	seq_printf(m, "oom_kill %lu\n", memcg_sum_events(memcg, OOM_KILL));
 
 	return 0;
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 04c9143a8625..dd30a045ef5b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -876,6 +876,11 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	/* Get a reference to safely compare mm after task_unlock(victim) */
 	mm = victim->mm;
 	mmgrab(mm);
+
+	/* Raise event before sending signal: reaper must see this */
+	count_vm_event(OOM_KILL);
+	mem_cgroup_count_vm_event(mm, OOM_KILL);
+
 	/*
 	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
 	 * the OOM victim from depleting the memory reserves from the user
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 76f73670200a..fe80b81a86e0 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1018,6 +1018,7 @@ const char * const vmstat_text[] = {
 
 	"drop_pagecache",
 	"drop_slab",
+	"oom_kill",
 
 #ifdef CONFIG_NUMA_BALANCING
 	"numa_pte_updates",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
