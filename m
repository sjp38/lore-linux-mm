Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 116AC6B0253
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 06:31:43 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id n186so127232872wmn.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 03:31:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pi3si48042423wjb.134.2016.03.03.03.31.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 03:31:41 -0800 (PST)
Subject: Re: [PATCH 02/27] mm, vmscan: Check if cpusets are enabled during
 direct reclaim
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-3-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D8209C.5020103@suse.cz>
Date: Thu, 3 Mar 2016 12:31:40 +0100
MIME-Version: 1.0
In-Reply-To: <1456239890-20737-3-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Li Zefan <lizefan@huawei.com>, cgroups@vger.kernel.org

On 02/23/2016 04:04 PM, Mel Gorman wrote:
> Direct reclaim obeys cpusets but misses the cpusets_enabled() check.
> The overhead is unlikely to be measurable in the direct reclaim
> path which is expensive but there is no harm is doing it.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 86eb21491867..de8d6226e026 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2566,7 +2566,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  		 * to global LRU.
>  		 */
>  		if (global_reclaim(sc)) {
> -			if (!cpuset_zone_allowed(zone,
> +			if (cpusets_enabled() && !cpuset_zone_allowed(zone,
>  						 GFP_KERNEL | __GFP_HARDWALL))
>  				continue;

Hmm, wouldn't it be nicer if cpuset_zone_allowed() itself did the right
thing, and not each caller?

How about the patch below? (+CC)

----8<----
From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 3 Mar 2016 12:12:09 +0100
Subject: [PATCH] cpuset: use static key better and convert to new API

An important function for cpusets is cpuset_node_allowed(), which acknowledges
that if there's a single root CPU set, it must be trivially allowed. But the
check "nr_cpusets() <= 1" doesn't use the cpusets_enabled_key static key in a
proper way where static keys can reduce the overhead.

This patch converts it so that static key is used properly. It's also switched
to the new static key API and the checking functions are converted to return
bool instead of int. We also provide a new variant __cpuset_zone_allowed()
which expects that the static key check was already done and was true. This is
needed for get_page_from_freelist() where we want to avoid the relatively
slower check if ALLOC_CPUSET is not set in alloc_flags.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/cpuset.h | 29 +++++++++++++++++++----------
 kernel/cpuset.c        | 14 +++++++-------
 mm/page_alloc.c        |  2 +-
 3 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index fea160ee5803..d5f5c7f87e36 100644
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
+{
+	return __cpuset_node_allowed(zone_to_nid(z), gfp_mask);
+}
+
+static inline bool cpuset_zone_allowed(struct zone *z, gfp_t gfp_mask)
 {
-	return cpuset_node_allowed(zone_to_nid(z), gfp_mask);
+	if (cpusets_enabled())
+		return __cpuset_zone_allowed(z, gfp_mask);
+	return true;
 }
 
 extern int cpuset_mems_allowed_intersects(const struct task_struct *tsk1,
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
index 1993894b4219..b857e9f8bc58 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2628,7 +2628,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 
 		if (cpusets_enabled() &&
 			(alloc_flags & ALLOC_CPUSET) &&
-			!cpuset_zone_allowed(zone, gfp_mask))
+			!__cpuset_zone_allowed(zone, gfp_mask))
 				continue;
 		/*
 		 * Distribute pages in proportion to the individual
-- 
2.7.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
