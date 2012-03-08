Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 66F9B6B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 01:02:29 -0500 (EST)
Received: by iajr24 with SMTP id r24so304208iaj.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 22:02:28 -0800 (PST)
Date: Wed, 7 Mar 2012 22:01:50 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3.3] memcg: free mem_cgroup by RCU to fix oops
Message-ID: <alpine.LSU.2.00.1203072155140.11048@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Tejun Heo <tj@kernel.org>, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

After fixing the GPF in mem_cgroup_lru_del_list(), three times one
machine running a similar load (moving and removing memcgs while swapping)
has oopsed in mem_cgroup_zone_nr_lru_pages(), when retrieving memcg zone
numbers for get_scan_count() for shrink_mem_cgroup_zone(): this is where a
struct mem_cgroup is first accessed after being chosen by mem_cgroup_iter().

Just what protects a struct mem_cgroup from being freed, in between
mem_cgroup_iter()'s css_get_next() and its css_tryget()?  css_tryget()
fails once css->refcnt is zero with CSS_REMOVED set in flags, yes: but
what if that memory is freed and reused for something else, which sets
"refcnt" non-zero?  Hmm, and scope for an indefinite freeze if refcnt
is left at zero but flags are cleared.

It's tempting to move the css_tryget() into css_get_next(), to make it
really "get" the css, but I don't think that actually solves anything:
the same difficulty in moving from css_id found to stable css remains.

But we already have rcu_read_lock() around the two, so it's easily
fixed if __mem_cgroup_free() just uses kfree_rcu() to free mem_cgroup.

However, a big struct mem_cgroup is allocated with vzalloc() instead
of kzalloc(), and we're not allowed to vfree() at interrupt time:
there doesn't appear to be a general vfree_rcu() to help with this,
so roll our own using schedule_work().  The compiler decently removes
vfree_work() and vfree_rcu() when the config doesn't need them.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

I'm posting this a little prematurely to get eyes on it, since it's
more than a two-liner, but 3.3 time is running out.  If it is what's
needed to fix my oopses, I won't really be sure before Friday morning.
What's running now on the machine affected is using kfree_rcu(), but I
did hack it earlier to check that the vfree_rcu() alternative works.

 mm/memcontrol.c |   53 ++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 47 insertions(+), 6 deletions(-)

--- 3.3-rc6+/mm/memcontrol.c	2012-03-05 22:03:45.940000832 -0800
+++ linux/mm/memcontrol.c	2012-03-07 20:00:21.142520811 -0800
@@ -230,10 +230,30 @@ struct mem_cgroup {
 	 * the counter to account for memory usage
 	 */
 	struct res_counter res;
-	/*
-	 * the counter to account for mem+swap usage.
-	 */
-	struct res_counter memsw;
+
+	union {
+		/*
+		 * the counter to account for mem+swap usage.
+		 */
+		struct res_counter memsw;
+
+		/*
+		 * rcu_freeing is used only when freeing struct mem_cgroup,
+		 * so put it into a union to avoid wasting more memory.
+		 * It must be disjoint from the css field.  It could be
+		 * in a union with the res field, but res plays a much
+		 * larger part in mem_cgroup life than memsw, and might
+		 * be of interest, even at time of free, when debugging.
+		 * So share rcu_head with the less interesting memsw.
+		 */
+		struct rcu_head rcu_freeing;
+		/*
+		 * But when using vfree(), that cannot be done at
+		 * interrupt time, so we must then queue the work.
+		 */
+		struct work_struct work_freeing;
+	};
+
 	/*
 	 * Per cgroup active and inactive list, similar to the
 	 * per zone LRU lists.
@@ -4780,6 +4800,27 @@ out_free:
 }
 
 /*
+ * Helpers for freeing a vzalloc()ed mem_cgroup by RCU,
+ * but in process context.  The work_freeing structure is overlaid
+ * on the rcu_freeing structure, which itself is overlaid on memsw.
+ */
+static void vfree_work(struct work_struct *work)
+{
+	struct mem_cgroup *memcg;
+
+	memcg = container_of(work, struct mem_cgroup, work_freeing);
+	vfree(memcg);
+}
+static void vfree_rcu(struct rcu_head *rcu_head)
+{
+	struct mem_cgroup *memcg;
+
+	memcg = container_of(rcu_head, struct mem_cgroup, rcu_freeing);
+	INIT_WORK(&memcg->work_freeing, vfree_work);
+	schedule_work(&memcg->work_freeing);
+}
+
+/*
  * At destroying mem_cgroup, references from swap_cgroup can remain.
  * (scanning all at force_empty is too costly...)
  *
@@ -4802,9 +4843,9 @@ static void __mem_cgroup_free(struct mem
 
 	free_percpu(memcg->stat);
 	if (sizeof(struct mem_cgroup) < PAGE_SIZE)
-		kfree(memcg);
+		kfree_rcu(memcg, rcu_freeing);
 	else
-		vfree(memcg);
+		call_rcu(&memcg->rcu_freeing, vfree_rcu);
 }
 
 static void mem_cgroup_get(struct mem_cgroup *memcg)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
