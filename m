Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id CBCEB6B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 22:14:52 -0500 (EST)
Received: by iajr24 with SMTP id r24so95541iaj.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 19:14:52 -0800 (PST)
Date: Wed, 7 Mar 2012 19:14:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, memcg: do not allow tasks to be attached with zero
 limit
Message-ID: <alpine.DEB.2.00.1203071914150.15244@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

This patch prevents tasks from being attached to a memcg if there is a
hard limit of zero.  Additionally, the hard limit may not be changed to
zero if there are tasks attached.

This is consistent with cpusets which do not allow tasks to be attached
if there are no mems and prevents all mems from being removed if there
are tasks attached.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/memcontrol.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3868,9 +3868,14 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 		ret = res_counter_memparse_write_strategy(buffer, &val);
 		if (ret)
 			break;
-		if (type == _MEM)
+		if (type == _MEM) {
+			/* Don't allow zero limit with tasks attached */
+			if (!val && cgroup_task_count(cont)) {
+				ret = -ENOSPC;
+				break;
+			}
 			ret = mem_cgroup_resize_limit(memcg, val);
-		else
+		} else
 			ret = mem_cgroup_resize_memsw_limit(memcg, val);
 		break;
 	case RES_SOFT_LIMIT:
@@ -5306,6 +5311,10 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 	int ret = 0;
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
 
+	/* Don't allow tasks attached with a zero limit */
+	if (!res_counter_read_u64(&memcg->res, RES_LIMIT))
+		return -ENOSPC;
+
 	if (memcg->move_charge_at_immigrate) {
 		struct mm_struct *mm;
 		struct mem_cgroup *from = mem_cgroup_from_task(p);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
