Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 2E6A76B0037
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 05:34:21 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC v2 4/4] memcg: Ignore soft limit until it is explicitly specified
Date: Tue, 23 Apr 2013 11:33:59 +0200
Message-Id: <1366709639-10240-5-git-send-email-mhocko@suse.cz>
In-Reply-To: <1366709639-10240-1-git-send-email-mhocko@suse.cz>
References: <20130422183020.GF12543@htj.dyndns.org>
 <1366709639-10240-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

The soft limit has been traditionally initialized to RESOURCE_MAX
which means that the group is soft unlimited by default and so it
gets reclaimed only after all groups that set their limit are bellow
their limits. While this scheme is working it is not ideal because it
makes hard to configure isolated workloads without setting a limit to
basically all groups. Let's consider the following simple hierarchy
  __A_____
 /    \   \
A1....An   C

and let's assume we would like to keep C's working set intact as much
as possible (with soft limit set to the estimated working set size)
so that A{i} groups do not interfere with it (A{i} might represent
backup processes or other maintenance activities which can consume
quite a lot of memory). If A{i} groups have a default soft limit then C
would be preferred for the reclaim until it eventually gets to its soft
limit and then be reclaimed again as the memory pressure from A{i} is
bigger and when also A{i} get reclaimed.
There are basically 2 options how to handle A{i} groups:
	- distribute hard limit to (A.limit - C.soft_limit)
	- set soft limit to 0
The first option is impractical because it would throttle A{i} even
though there is quite some idle memory laying around. The later option
would certainly work because A{i} would get reclaimed all the time there
is a pressure coming from A. This however basically disables any soft
limit settings down A{i} hierarchies which sounds unnecessarily strict
(not mentioning that we have to set up a limit for every A{i}).
Moreover if A is the root memcg then there is no reasonable way to make
it stop interefering with other loads because setting the soft limit
would kill the limits downwards and the hard limit is not possible to
set.

Neither of the extremes - unlimited vs. 0 - are ideal apparently. There
is a compromise we can do, though. This patch doesn't change the default
soft limit value. Rather than that it distinguishes groups with soft
limit enabled - it has been set by an user - and disabled which comes
as a default. Unlike groups with the limit set to 0 such groups do not
propagate their reclaimable state down the hierarchy so they act only
for themselves.

Getting back to the previous example. Only C would get a limit from
admin and the reclaim would reclaim all A{i} and C eventually when it
crosses its limit.

This means that soft limit is much easier to maintain now because only
those groups that are interesting (that the administrator know how much
pushback makes sense for a graceful overcommit handling) need to be
taken care about and the rest of the groups is reclaimed proportionally.

TODO: How do we present default unlimited vs. RESOURCE_MAX set by
the user? One possible way could be returning -1 for RES_SOFT_LIMIT &&
!soft_limited.
TODO: update doc

Changes since v1
- return -1 when reading memory.soft_limit_in_bytes for unlimited
  groups.
- reorganized checks in mem_cgroup_soft_reclaim_eligible to be more
  readable.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   32 +++++++++++++++++++++++++++-----
 1 file changed, 27 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 14d3d23..03ddbcc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -266,6 +266,10 @@ struct mem_cgroup {
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
 	bool use_hierarchy;
+	/*
+	 * Is the group soft limited?
+	 */
+	bool soft_limited;
 	unsigned long kmem_account_flags; /* See KMEM_ACCOUNTED_*, below */
 
 	bool		oom_lock;
@@ -1843,14 +1847,20 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
 /*
  * A group is eligible for the soft limit reclaim under the given root
  * hierarchy if
- * 	a) it is over its soft limit
- * 	b) any parent up the hierarchy is over its soft limit
+ * 	a) doesn't have any soft limit set
+ * 	b) is over its soft limit
+ * 	c) any parent up the hierarchy is over its soft limit
  */
 bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
 		struct mem_cgroup *root)
 {
 	struct mem_cgroup *parent = memcg;
 
+	/* No specific soft limit set, eligible for soft reclaim */
+	if (!memcg->soft_limited)
+		return true;
+
+	/* Soft limit exceeded, eligible for soft reclaim */
 	if (res_counter_soft_limit_excess(&memcg->res))
 		return true;
 
@@ -1859,7 +1869,8 @@ bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
 	 * then we have to obey and reclaim from this group as well.
 	 */
 	while((parent = parent_mem_cgroup(parent))) {
-		if (res_counter_soft_limit_excess(&parent->res))
+		if (parent->soft_limited &&
+				res_counter_soft_limit_excess(&parent->res))
 			return true;
 		if (parent == root)
 			break;
@@ -4754,10 +4765,13 @@ static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
 
 	switch (type) {
 	case _MEM:
-		if (name == RES_USAGE)
+		if (name == RES_USAGE) {
 			val = mem_cgroup_usage(memcg, false);
-		else
+		} else if (name == RES_SOFT_LIMIT && !memcg->soft_limited) {
+			return simple_read_from_buffer(buf, nbytes, ppos, "-1\n", 3);
+		} else {
 			val = res_counter_read_u64(&memcg->res, name);
+		}
 		break;
 	case _MEMSWAP:
 		if (name == RES_USAGE)
@@ -5019,6 +5033,14 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 			ret = res_counter_set_soft_limit(&memcg->res, val);
 		else
 			ret = -EINVAL;
+
+		/*
+		 * We could disable soft_limited when we get RESOURCE_MAX but
+		 * then we have a little problem to distinguish the default
+		 * unlimited and limitted but never soft reclaimed groups.
+		 */
+		if (!ret)
+			memcg->soft_limited = true;
 		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
