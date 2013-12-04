Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id E1B156B0038
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 00:20:09 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id z6so11135886yhz.29
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 21:20:09 -0800 (PST)
Received: from mail-yh0-x22f.google.com (mail-yh0-x22f.google.com [2607:f8b0:4002:c01::22f])
        by mx.google.com with ESMTPS id l5si1820046yhl.74.2013.12.03.21.20.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 21:20:09 -0800 (PST)
Received: by mail-yh0-f47.google.com with SMTP id 29so10850353yhl.20
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 21:20:08 -0800 (PST)
Date: Tue, 3 Dec 2013 21:20:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 4/8] mm, memcg: add tunable for oom reserves
In-Reply-To: <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1312032118050.29733@chino.kir.corp.google.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com> <20131120152251.GA18809@dhcp22.suse.cz> <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
 <20131128115458.GK2761@dhcp22.suse.cz> <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

Userspace needs a way to define the amount of memory reserves that
processes handling oom conditions may utilize.  This patch adds a per-
memcg oom reserve field and file, memory.oom_reserve_in_bytes, to
manipulate its value.

If currently utilized memory reserves are attempted to be reduced by
writing a smaller value to memory.oom_reserve_in_bytes, it will fail with
-EBUSY until some memory is uncharged.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/memcontrol.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -274,6 +274,9 @@ struct mem_cgroup {
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
+	/* reserves for handling oom conditions, protected by res.lock */
+	unsigned long long	oom_reserve;
+
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
 
@@ -5893,6 +5896,51 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
 	return 0;
 }
 
+static int mem_cgroup_resize_oom_reserve(struct mem_cgroup *memcg,
+					 unsigned long long new_limit)
+{
+	struct res_counter *res = &memcg->res;
+	u64 limit, usage;
+	int ret = 0;
+
+	spin_lock(&res->lock);
+	limit = res->limit;
+	usage = res->usage;
+
+	if (usage > limit && usage - limit > new_limit) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	memcg->oom_reserve = new_limit;
+out:
+	spin_unlock(&res->lock);
+	return ret;
+}
+
+static u64 mem_cgroup_oom_reserve_read(struct cgroup_subsys_state *css,
+				       struct cftype *cft)
+{
+	return mem_cgroup_from_css(css)->oom_reserve;
+}
+
+static int mem_cgroup_oom_reserve_write(struct cgroup_subsys_state *css,
+					struct cftype *cft, const char *buffer)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	unsigned long long val;
+	int ret;
+
+	if (mem_cgroup_is_root(memcg))
+		return -EINVAL;
+
+	ret = res_counter_memparse_write_strategy(buffer, &val);
+	if (ret)
+		return ret;
+
+	return mem_cgroup_resize_oom_reserve(memcg, val);
+}
+
 #ifdef CONFIG_MEMCG_KMEM
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
@@ -6024,6 +6072,11 @@ static struct cftype mem_cgroup_files[] = {
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
 	{
+		.name = "oom_reserve_in_bytes",
+		.read_u64 = mem_cgroup_oom_reserve_read,
+		.write_string = mem_cgroup_oom_reserve_write,
+	},
+	{
 		.name = "pressure_level",
 		.register_event = vmpressure_register_event,
 		.unregister_event = vmpressure_unregister_event,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
