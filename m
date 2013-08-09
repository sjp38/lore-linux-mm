Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id B0FCD6B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 03:22:11 -0400 (EDT)
Date: Fri, 9 Aug 2013 09:22:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [HEADSUP] conflicts between cgroup/for-3.12 and memcg
Message-ID: <20130809072207.GA16531@dhcp22.suse.cz>
References: <20130809003402.GC13427@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="PNTmBPCT7hxwcZjr"
Content-Disposition: inline
In-Reply-To: <20130809003402.GC13427@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu 08-08-13 20:34:02, Tejun Heo wrote:
> Hello, Stephen, Andrew.
> 
> I just applied rather invasive API update to cgroup/for-3.12, which
> led to conflicts in two files - include/net/netprio_cgroup.h and
> mm/memcontrol.c.  The former is trivial context conflict and the two
> changes conflicting are independent.  The latter contains several
> conflicts and unfortunately isn't trivial, especially the iterator
> update and the memcg patches should probably be rebased.
> 
> I can hold back pushing for-3.12 into for-next until the memcg patches
> are rebased.  Would that work?

I have just tried to merge cgroups/for-3.12 into my memcg tree and there
were some conflicts indeed. They are attached for reference. The
resolving is trivial. I've just picked up HEAD as all the conflicts are
for added resp. removed code in mmotm.

Andrew, let me know if you need a help with rebasing.

HTH
-- 
Michal Hocko
SUSE Labs

--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="memcontrol.conflicts"

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b73988a..c208154 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -182,6 +182,29 @@ struct mem_cgroup_per_node {
 	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
 };
 
+<<<<<<< HEAD
+=======
+/*
+ * Cgroups above their limits are maintained in a RB-Tree, independent of
+ * their hierarchy representation
+ */
+
+struct mem_cgroup_tree_per_zone {
+	struct rb_root rb_root;
+	spinlock_t lock;
+};
+
+struct mem_cgroup_tree_per_node {
+	struct mem_cgroup_tree_per_zone rb_tree_per_zone[MAX_NR_ZONES];
+};
+
+struct mem_cgroup_tree {
+	struct mem_cgroup_tree_per_node *rb_tree_per_node[MAX_NUMNODES];
+};
+
+static struct mem_cgroup_tree soft_limit_tree __read_mostly;
+
+>>>>>>> tj-cgroups/for-3.12
 struct mem_cgroup_threshold {
 	struct eventfd_ctx *eventfd;
 	u64 threshold;
@@ -255,7 +278,10 @@ struct mem_cgroup {
 
 	bool		oom_lock;
 	atomic_t	under_oom;
+<<<<<<< HEAD
 	atomic_t	oom_wakeups;
+=======
+>>>>>>> tj-cgroups/for-3.12
 
 	int	swappiness;
 	/* OOM-Killer disable */
@@ -323,6 +349,7 @@ struct mem_cgroup {
 	 */
 	spinlock_t soft_lock;
 
+<<<<<<< HEAD
 	/*
 	 * If true then this group has increased parents' children_in_excess
 	 * when it got over the soft limit.
@@ -334,6 +361,8 @@ struct mem_cgroup {
 	/* Number of children that are in soft limit excess */
 	atomic_t children_in_excess;
 
+=======
+>>>>>>> tj-cgroups/for-3.12
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
@@ -3573,9 +3602,15 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
 	 * the page allocator. Therefore, the following sequence when backed by
 	 * the SLUB allocator:
 	 *
+<<<<<<< HEAD
 	 *	memcg_stop_kmem_account();
 	 *	kmalloc(<large_number>)
 	 *	memcg_resume_kmem_account();
+=======
+	 * 	memcg_stop_kmem_account();
+	 * 	kmalloc(<large_number>)
+	 * 	memcg_resume_kmem_account();
+>>>>>>> tj-cgroups/for-3.12
 	 *
 	 * would effectively ignore the fact that we should skip accounting,
 	 * since it will drive us directly to this function without passing

--PNTmBPCT7hxwcZjr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
