Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 97A55828E6
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:10:20 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l6so13248767wml.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:10:20 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id c202si10934906wme.60.2016.04.15.02.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:10:19 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 0B1751C1BA6
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:10:19 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 26/28] cpuset: use static key better and convert to new API
Date: Fri, 15 Apr 2016 10:07:53 +0100
Message-Id: <1460711275-1130-14-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

From: Vlastimil Babka <vbabka@suse.cz>

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

The impact on the page allocator microbenchmark is less than expected but the
cleanup in itself is worthwhile.

                                           4.6.0-rc2                  4.6.0-rc2
                                     multcheck-v1r20               cpuset-v1r20
Min      alloc-odr0-1               348.00 (  0.00%)           348.00 (  0.00%)
Min      alloc-odr0-2               254.00 (  0.00%)           254.00 (  0.00%)
Min      alloc-odr0-4               213.00 (  0.00%)           213.00 (  0.00%)
Min      alloc-odr0-8               186.00 (  0.00%)           183.00 (  1.61%)
Min      alloc-odr0-16              173.00 (  0.00%)           171.00 (  1.16%)
Min      alloc-odr0-32              166.00 (  0.00%)           163.00 (  1.81%)
Min      alloc-odr0-64              162.00 (  0.00%)           159.00 (  1.85%)
Min      alloc-odr0-128             160.00 (  0.00%)           157.00 (  1.88%)
Min      alloc-odr0-256             169.00 (  0.00%)           166.00 (  1.78%)
Min      alloc-odr0-512             180.00 (  0.00%)           180.00 (  0.00%)
Min      alloc-odr0-1024            188.00 (  0.00%)           187.00 (  0.53%)
Min      alloc-odr0-2048            194.00 (  0.00%)           193.00 (  0.52%)
Min      alloc-odr0-4096            199.00 (  0.00%)           198.00 (  0.50%)
Min      alloc-odr0-8192            202.00 (  0.00%)           201.00 (  0.50%)
Min      alloc-odr0-16384           203.00 (  0.00%)           202.00 (  0.49%)

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
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
index f038d06192c7..e63afe07c032 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2847,7 +2847,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 
 		if (cpusets_enabled() &&
 			(alloc_flags & ALLOC_CPUSET) &&
-			!cpuset_zone_allowed(zone, gfp_mask))
+			!__cpuset_zone_allowed(zone, gfp_mask))
 				continue;
 		/*
 		 * Distribute pages in proportion to the individual
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
