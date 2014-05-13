Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6926B0039
	for <linux-mm@kvack.org>; Tue, 13 May 2014 05:46:00 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so208289eei.0
        for <linux-mm@kvack.org>; Tue, 13 May 2014 02:45:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 44si12690041eef.10.2014.05.13.02.45.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 02:45:59 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/19] mm: page_alloc: Use jump labels to avoid checking number_of_cpusets
Date: Tue, 13 May 2014 10:45:35 +0100
Message-Id: <1399974350-11089-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1399974350-11089-1-git-send-email-mgorman@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

If cpusets are not in use then we still check a global variable on every
page allocation. Use jump labels to avoid the overhead.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/cpuset.h | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 kernel/cpuset.c        | 10 +++++++---
 mm/page_alloc.c        |  3 ++-
 3 files changed, 55 insertions(+), 4 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index b19d3dc..561cdb1 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -15,8 +15,52 @@
 
 #ifdef CONFIG_CPUSETS
 
+#ifdef HAVE_JUMP_LABEL
+extern struct static_key cpusets_enabled_key;
+static inline bool cpusets_enabled(void)
+{
+	return static_key_false(&cpusets_enabled_key);
+}
+
+/* jump label reference count + the top-level cpuset */
+#define number_of_cpusets (static_key_count(&cpusets_enabled_key) + 1)
+
+static inline void cpuset_inc(void)
+{
+	static_key_slow_inc(&cpusets_enabled_key);
+}
+
+static inline void cpuset_dec(void)
+{
+	static_key_slow_dec(&cpusets_enabled_key);
+}
+
+static inline void cpuset_init_count(void) { }
+
+#else
 extern int number_of_cpusets;	/* How many cpusets are defined in system? */
 
+static inline bool cpusets_enabled(void)
+{
+	return number_of_cpusets > 1;
+}
+
+static inline void cpuset_inc(void)
+{
+	number_of_cpusets++;
+}
+
+static inline void cpuset_dec(void)
+{
+	number_of_cpusets--;
+}
+
+static inline void cpuset_init_count(void)
+{
+	number_of_cpusets = 1;
+}
+#endif /* HAVE_JUMP_LABEL */
+
 extern int cpuset_init(void);
 extern void cpuset_init_smp(void);
 extern void cpuset_update_active_cpus(bool cpu_online);
@@ -124,6 +168,8 @@ static inline void set_mems_allowed(nodemask_t nodemask)
 
 #else /* !CONFIG_CPUSETS */
 
+static inline bool cpusets_enabled(void) { return false; }
+
 static inline int cpuset_init(void) { return 0; }
 static inline void cpuset_init_smp(void) {}
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 3d54c41..d503f26 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -61,12 +61,16 @@
 #include <linux/cgroup.h>
 #include <linux/wait.h>
 
+#ifdef HAVE_JUMP_LABEL
+struct static_key cpusets_enabled_key = STATIC_KEY_INIT_FALSE;
+#else
 /*
  * Tracks how many cpusets are currently defined in system.
  * When there is only one cpuset (the root cpuset) we can
  * short circuit some hooks.
  */
 int number_of_cpusets __read_mostly;
+#endif
 
 /* See "Frequency meter" comments, below. */
 
@@ -1888,7 +1892,7 @@ static int cpuset_css_online(struct cgroup_subsys_state *css)
 	if (is_spread_slab(parent))
 		set_bit(CS_SPREAD_SLAB, &cs->flags);
 
-	number_of_cpusets++;
+	cpuset_inc();
 
 	if (!test_bit(CGRP_CPUSET_CLONE_CHILDREN, &css->cgroup->flags))
 		goto out_unlock;
@@ -1939,7 +1943,7 @@ static void cpuset_css_offline(struct cgroup_subsys_state *css)
 	if (is_sched_load_balance(cs))
 		update_flag(CS_SCHED_LOAD_BALANCE, cs, 0);
 
-	number_of_cpusets--;
+	cpuset_dec();
 	clear_bit(CS_ONLINE, &cs->flags);
 
 	mutex_unlock(&cpuset_mutex);
@@ -1992,7 +1996,7 @@ int __init cpuset_init(void)
 	if (!alloc_cpumask_var(&cpus_attach, GFP_KERNEL))
 		BUG();
 
-	number_of_cpusets = 1;
+	cpuset_init_count();
 	return 0;
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5c559e3..cb12b9a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1930,7 +1930,8 @@ zonelist_scan:
 		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
-		if ((alloc_flags & ALLOC_CPUSET) &&
+		if (cpusets_enabled() &&
+			(alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				continue;
 		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
