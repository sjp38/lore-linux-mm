Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 6FA956B0074
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 20:44:37 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so4087468pad.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 17:44:36 -0800 (PST)
Date: Mon, 19 Nov 2012 17:44:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, memcg: avoid unnecessary function call when memcg is
 disabled
Message-ID: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

While profiling numa/core v16 with cgroup_disable=memory on the command 
line, I noticed mem_cgroup_count_vm_event() still showed up as high as 
0.60% in perftop.

This occurs because the function is called extremely often even when memcg 
is disabled.

To fix this, inline the check for mem_cgroup_disabled() so we avoid the 
unnecessary function call if memcg is disabled.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/memcontrol.h |    9 ++++++++-
 mm/memcontrol.c            |    9 ++++-----
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -181,7 +181,14 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask,
 						unsigned long *total_scanned);
 
-void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
+void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
+static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
+					     enum vm_event_item idx)
+{
+	if (mem_cgroup_disabled() || !mm)
+		return;
+	__mem_cgroup_count_vm_event(mm, idx);
+}
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -59,6 +59,8 @@
 #include <trace/events/vmscan.h>
 
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
+EXPORT_SYMBOL(mem_cgroup_subsys);
+
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 static struct mem_cgroup *root_mem_cgroup __read_mostly;
 
@@ -1015,13 +1017,10 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
 	     iter != NULL;				\
 	     iter = mem_cgroup_iter(NULL, iter, NULL))
 
-void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
+void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 	struct mem_cgroup *memcg;
 
-	if (!mm)
-		return;
-
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
 	if (unlikely(!memcg))
@@ -1040,7 +1039,7 @@ void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 out:
 	rcu_read_unlock();
 }
-EXPORT_SYMBOL(mem_cgroup_count_vm_event);
+EXPORT_SYMBOL(__mem_cgroup_count_vm_event);
 
 /**
  * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
