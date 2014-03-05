Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id E56FA6B009E
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 22:59:22 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rp16so498477pbb.17
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:59:22 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id mt5si626360pbb.6.2014.03.04.19.59.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 19:59:21 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id ld10so503709pab.40
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:59:21 -0800 (PST)
Date: Tue, 4 Mar 2014 19:59:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 04/11] mm, memcg: add tunable for oom reserves
In-Reply-To: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1403041955050.8067@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

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
@@ -315,6 +315,9 @@ struct mem_cgroup {
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
+	/* reserves for handling oom conditions, protected by res.lock */
+	unsigned long long	oom_reserve;
+
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
 
@@ -5936,6 +5939,51 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
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
@@ -6291,6 +6339,11 @@ static struct cftype mem_cgroup_files[] = {
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
 	{
+		.name = "oom_reserve_in_bytes",
+		.read_u64 = mem_cgroup_oom_reserve_read,
+		.write_string = mem_cgroup_oom_reserve_write,
+	},
+	{
 		.name = "pressure_level",
 	},
 #ifdef CONFIG_NUMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
