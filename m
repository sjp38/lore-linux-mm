Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 630A56B0037
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 12:11:35 -0400 (EDT)
Date: Thu, 27 Jun 2013 18:11:27 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 5/8] sched: Favour moving tasks towards the preferred node
Message-ID: <20130627161127.GZ28407@twins.programming.kicks-ass.net>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-6-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372257487-9749-6-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 26, 2013 at 03:38:04PM +0100, Mel Gorman wrote:
> +/* Returns true if the destination node has incurred more faults */
> +static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
> +{
> +	int src_nid, dst_nid;
> +
> +	if (!p->numa_faults || !(env->sd->flags & SD_NUMA))
> +		return false;
> +
> +	src_nid = cpu_to_node(env->src_cpu);
> +	dst_nid = cpu_to_node(env->dst_cpu);
> +
> +	if (src_nid == dst_nid)
> +		return false;
> +
> +	if (p->numa_migrate_seq < sysctl_numa_balancing_settle_count &&
> +	    p->numa_preferred_nid == dst_nid)
> +		return true;
> +
> +	return false;
> +}

Also, until I just actually _read_ that function; I assumed it would
compare p->numa_faults[src_nid] and p->numa_faults[dst_nid]. Because
even when the dst_nid isn't the preferred nid; it might still have more
pages than where we currently are.

Idem with the proposed migrate_degrades_locality().

Something like so I suppose

---
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -3969,6 +3969,7 @@ task_hot(struct task_struct *p, u64 now,
 	return delta < (s64)sysctl_sched_migration_cost;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
 /* Returns true if the destination node has incurred more faults */
 static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
 {
@@ -3983,13 +3984,50 @@ static bool migrate_improves_locality(st
 	if (src_nid == dst_nid)
 		return false;
 
-	if (p->numa_migrate_seq < sysctl_numa_balancing_settle_count &&
-	    p->numa_preferred_nid == dst_nid)
+	if (p->numa_migrate_seq >= sysctl_numa_balancing_settle_count)
+		return false;
+
+	if (p->numa_preferred_nid == dst_nid)
+		return true;
+
+	if (p->numa_faults[src_nid] < p->numa_faults[dst_nid])
+		return true;
+
+	return false;
+}
+
+static vool migrate_degrades_locality(struct task_struct *p, struct lb_env *env)
+{
+	int src_nid, dst_nid;
+
+	if (!p->numa_faults || !(env->sd->flags & SD_NUMA))
+		return false;
+
+	src_nid = cpu_to_node(env->src_cpu);
+	dst_nid = cpu_to_node(env->dst_cpu);
+
+	if (src_nid == dst_nid)
+		return false;
+
+	if (p->numa_faults[src_nid] > p->numa_faults[dst_nid])
 		return true;
 
 	return false;
 }
 
+#else
+
+static inline bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
+{
+	return false;
+}
+
+static inline bool migrate_degrades_locality(struct task_struct *p, struct lb_env *env)
+{
+	return false;
+}
+
+#endif /* CONFIG_NUMA_BALANCING */
 
 /*
  * can_migrate_task - may task p from runqueue rq be migrated to this_cpu?
@@ -4055,8 +4093,10 @@ int can_migrate_task(struct task_struct
 		return 1;
 
 	tsk_cache_hot = task_hot(p, rq_clock_task(env->src_rq), env->sd);
+	if (!tsk_cache_hot)
+		tsk_cache_hot = migrate_degrades_locality(p, env);
 	if (!tsk_cache_hot ||
-		env->sd->nr_balance_failed > env->sd->cache_nice_tries) {
+	    env->sd->nr_balance_failed > env->sd->cache_nice_tries) {
 
 		if (tsk_cache_hot) {
 			schedstat_inc(env->sd, lb_hot_gained[env->idle]);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
