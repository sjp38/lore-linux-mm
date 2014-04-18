Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id D46B26B0039
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:50:47 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id b57so1673549eek.26
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:50:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q2si40599711eep.132.2014.04.18.07.50.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:50:46 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/16] mm: page_alloc: Use jump labels to avoid checking number_of_cpusets
Date: Fri, 18 Apr 2014 15:50:32 +0100
Message-Id: <1397832643-14275-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1397832643-14275-1-git-send-email-mgorman@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

If cpusets are not in use then we still check a global variable on every
page allocation. Use jump labels to avoid the overhead.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/cpuset.h | 29 +++++++++++++++++++++++++++++
 kernel/cpuset.c        |  8 ++++++--
 mm/page_alloc.c        |  3 ++-
 3 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index b19d3dc..9c840e3 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -17,6 +17,35 @@
 
 extern int number_of_cpusets;	/* How many cpusets are defined in system? */
 
+#ifdef HAVE_JUMP_LABEL
+extern struct static_key cpusets_enabled_key;
+static inline bool cpusets_enabled(void)
+{
+	return static_key_false(&cpusets_enabled_key);
+}
+#else
+static inline bool cpusets_enabled(void)
+{
+	return number_of_cpusets > 1;
+}
+#endif
+
+static inline void cpuset_inc(void)
+{
+	number_of_cpusets++;
+#ifdef HAVE_JUMP_LABEL
+	static_key_slow_inc(&cpusets_enabled_key);
+#endif
+}
+
+static inline void cpuset_dec(void)
+{
+	number_of_cpusets--;
+#ifdef HAVE_JUMP_LABEL
+	static_key_slow_dec(&cpusets_enabled_key);
+#endif
+}
+
 extern int cpuset_init(void);
 extern void cpuset_init_smp(void);
 extern void cpuset_update_active_cpus(bool cpu_online);
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 3d54c41..34ada52 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -68,6 +68,10 @@
  */
 int number_of_cpusets __read_mostly;
 
+#ifdef HAVE_JUMP_LABEL
+struct static_key cpusets_enabled_key = STATIC_KEY_INIT_FALSE;
+#endif
+
 /* See "Frequency meter" comments, below. */
 
 struct fmeter {
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
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ad702e9..3f2a9dd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1916,7 +1916,8 @@ zonelist_scan:
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
