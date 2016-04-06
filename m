Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4EA906B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 05:19:59 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id u206so36692888wme.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 02:19:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si1225110wjz.199.2016.04.06.02.19.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 02:19:58 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2] cpuset: use static key better and convert to new API
Date: Wed,  6 Apr 2016 11:19:52 +0200
Message-Id: <1459934392-12756-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1459931973-29247-1-git-send-email-vbabka@suse.cz>
References: <1459931973-29247-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

An important function for cpusets is cpuset_node_allowed(), which optimizes on
the fact if there's a single root CPU set, it must be trivially allowed. But
the check "nr_cpusets() <= 1" doesn't use the cpusets_enabled_key static key
the right way where static keys eliminate branching overhead with jump labels.

This patch converts it so that static key is used properly. It's also switched
to the new static key API and the checking functions are converted to return
bool instead of int. We also provide a new variant __cpuset_zone_allowed()
which expects that the static key check was already done and they key was
enabled. This is needed for get_page_from_freelist() where we want to also
avoid the relatively slower check when ALLOC_CPUSET is not set in alloc_flags.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 v2: fix !CONFIG_CPUSETS thanks to kbuild test robot

 include/linux/cpuset.h | 42 ++++++++++++++++++++++++++++--------------
 kernel/cpuset.c        | 14 +++++++-------
 mm/page_alloc.c        |  2 +-
 3 files changed, 36 insertions(+), 22 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index fea160ee5803..054c734d0170 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -16,26 +16,26 @@
 
 #ifdef CONFIG_CPUSETS
 
-extern struct static_key cpusets_enabled_key;
+extern struct static_key_false cpusets_enabled_key;
 static inline bool cpusets_enabled(void)
 {
-	return static_key_false(&cpusets_enabled_key);
+	return static_branch_unlikely(&cpusets_enabled_key);
 }
 
 static inline int nr_cpusets(void)
 {
 	/* jump label reference count + the top-level cpuset */
-	return static_key_count(&cpusets_enabled_key) + 1;
+	return static_key_count(&cpusets_enabled_key.key) + 1;
 }
 
 static inline void cpuset_inc(void)
 {
-	static_key_slow_inc(&cpusets_enabled_key);
+	static_branch_inc(&cpusets_enabled_key);
 }
 
 static inline void cpuset_dec(void)
 {
-	static_key_slow_dec(&cpusets_enabled_key);
+	static_branch_dec(&cpusets_enabled_key);
 }
 
 extern int cpuset_init(void);
@@ -48,16 +48,25 @@ extern nodemask_t cpuset_mems_allowed(struct task_struct *p);
 void cpuset_init_current_mems_allowed(void);
 int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask);
 
-extern int __cpuset_node_allowed(int node, gfp_t gfp_mask);
+extern bool __cpuset_node_allowed(int node, gfp_t gfp_mask);
 
-static inline int cpuset_node_allowed(int node, gfp_t gfp_mask)
+static inline bool cpuset_node_allowed(int node, gfp_t gfp_mask)
 {
-	return nr_cpusets() <= 1 || __cpuset_node_allowed(node, gfp_mask);
+	if (cpusets_enabled())
+		return __cpuset_node_allowed(node, gfp_mask);
+	return true;
 }
 
-static inline int cpuset_zone_allowed(struct zone *z, gfp_t gfp_mask)
+static inline bool __cpuset_zone_allowed(struct zone *z, gfp_t gfp_mask)
 {
-	return cpuset_node_allowed(zone_to_nid(z), gfp_mask);
+	return __cpuset_node_allowed(zone_to_nid(z), gfp_mask);
+}
+
+static inline bool cpuset_zone_allowed(struct zone *z, gfp_t gfp_mask)
+{
+	if (cpusets_enabled())
+		return __cpuset_zone_allowed(z, gfp_mask);
+	return true;
 }
 
 extern int cpuset_mems_allowed_intersects(const struct task_struct *tsk1,
@@ -174,14 +183,19 @@ static inline int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
 	return 1;
 }
 
-static inline int cpuset_node_allowed(int node, gfp_t gfp_mask)
+static inline bool cpuset_node_allowed(int node, gfp_t gfp_mask)
 {
-	return 1;
+	return true;
 }
 
-static inline int cpuset_zone_allowed(struct zone *z, gfp_t gfp_mask)
+static inline bool __cpuset_zone_allowed(struct zone *z, gfp_t gfp_mask)
 {
-	return 1;
+	return true;
+}
+
+static inline bool cpuset_zone_allowed(struct zone *z, gfp_t gfp_mask)
+{
+	return true;
 }
 
 static inline int cpuset_mems_allowed_intersects(const struct task_struct *tsk1,
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 00ab5c2b7c5b..37a0b44d101f 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -62,7 +62,7 @@
 #include <linux/cgroup.h>
 #include <linux/wait.h>
 
-struct static_key cpusets_enabled_key __read_mostly = STATIC_KEY_INIT_FALSE;
+DEFINE_STATIC_KEY_FALSE(cpusets_enabled_key);
 
 /* See "Frequency meter" comments, below. */
 
@@ -2528,27 +2528,27 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
  *	GFP_KERNEL   - any node in enclosing hardwalled cpuset ok
  *	GFP_USER     - only nodes in current tasks mems allowed ok.
  */
-int __cpuset_node_allowed(int node, gfp_t gfp_mask)
+bool __cpuset_node_allowed(int node, gfp_t gfp_mask)
 {
 	struct cpuset *cs;		/* current cpuset ancestors */
 	int allowed;			/* is allocation in zone z allowed? */
 	unsigned long flags;
 
 	if (in_interrupt())
-		return 1;
+		return true;
 	if (node_isset(node, current->mems_allowed))
-		return 1;
+		return true;
 	/*
 	 * Allow tasks that have access to memory reserves because they have
 	 * been OOM killed to get memory anywhere.
 	 */
 	if (unlikely(test_thread_flag(TIF_MEMDIE)))
-		return 1;
+		return true;
 	if (gfp_mask & __GFP_HARDWALL)	/* If hardwall request, stop here */
-		return 0;
+		return false;
 
 	if (current->flags & PF_EXITING) /* Let dying task have memory */
-		return 1;
+		return true;
 
 	/* Not hardwall and node outside mems_allowed: scan up cpusets */
 	spin_lock_irqsave(&callback_lock, flags);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59de90d5d3a3..69edac810084 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2650,7 +2650,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 
 		if (cpusets_enabled() &&
 			(alloc_flags & ALLOC_CPUSET) &&
-			!cpuset_zone_allowed(zone, gfp_mask))
+			!__cpuset_zone_allowed(zone, gfp_mask))
 				continue;
 		/*
 		 * Distribute pages in proportion to the individual
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
