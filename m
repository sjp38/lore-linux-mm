Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id A4D346B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 12:51:24 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH resend 3/3] vmpressure: Make sure there are no events queued after memcg is offlined
Date: Fri, 19 Jul 2013 18:51:11 +0200
Message-Id: <1374252671-11939-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1374252671-11939-1-git-send-email-mhocko@suse.cz>
References: <1374252671-11939-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

vmpressure is called synchronously from the reclaim where the
target_memcg is guaranteed to be alive but the eventfd is signaled from
the work queue context. This means that memcg (along with vmpressure
structure which is embedded into it) might go away while the work item
is pending which would result in use-after-release bug.

We have two possible ways how to fix this. Either vmpressure pins memcg
before it schedules vmpr->work and unpin it in vmpressure_work_fn or
explicitely flush the work item from the css_offline context (as
suggested by Tejun).

This patch implements the later one and it introduces vmpressure_cleanup
which flushes the vmpressure work queue item item. It hooks into
mem_cgroup_css_offline after the memcg itself is cleaned up.

Reported-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/vmpressure.h |  1 +
 mm/memcontrol.c            |  1 +
 mm/vmpressure.c            | 16 ++++++++++++++++
 3 files changed, 18 insertions(+)

diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index 2081680..0c9bc9a 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -30,6 +30,7 @@ extern void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
 extern void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio);
 
 extern void vmpressure_init(struct vmpressure *vmpr);
+extern void vmpressure_cleanup(struct vmpressure * vmpr);
 extern struct vmpressure *memcg_to_vmpressure(struct mem_cgroup *memcg);
 extern struct cgroup_subsys_state *vmpressure_to_css(struct vmpressure *vmpr);
 extern struct vmpressure *css_to_vmpressure(struct cgroup_subsys_state *css);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6e120e4..198759c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6326,6 +6326,7 @@ static void mem_cgroup_css_offline(struct cgroup *cont)
 	mem_cgroup_invalidate_reclaim_iterators(memcg);
 	mem_cgroup_reparent_charges(memcg);
 	mem_cgroup_destroy_all_caches(memcg);
+	vmpressure_cleanup(&memcg->vmpressure);
 }
 
 static void mem_cgroup_css_free(struct cgroup *cont)
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 192f973..0c1e37d 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -372,3 +372,19 @@ void vmpressure_init(struct vmpressure *vmpr)
 	INIT_LIST_HEAD(&vmpr->events);
 	INIT_WORK(&vmpr->work, vmpressure_work_fn);
 }
+
+/**
+ * vmpressure_cleanup() - shuts down vmpressure control structure
+ * @vmpr:	Structure to be cleaned up
+ *
+ * This function should be called before the structure in which it is
+ * embedded is cleaned up.
+ */
+void vmpressure_cleanup(struct vmpressure *vmpr)
+{
+	/*
+	 * Make sure there is no pending work before eventfd infrastructure
+	 * goes away.
+	 */
+	flush_work(&vmpr->work);
+}
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
