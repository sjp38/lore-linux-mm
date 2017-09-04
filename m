Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4B20B6B04B8
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 10:22:02 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t3so887354pgt.7
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 07:22:02 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id t64si5053769pgc.705.2017.09.04.07.21.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Sep 2017 07:22:00 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v7 3/5] mm, oom: introduce oom_priority for memory cgroups
Date: Mon, 4 Sep 2017 15:21:06 +0100
Message-ID: <20170904142108.7165-4-guro@fb.com>
In-Reply-To: <20170904142108.7165-1-guro@fb.com>
References: <20170904142108.7165-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Introduce a per-memory-cgroup oom_priority setting: an integer number,
which defines the order in which the OOM killer selects victim memory
cgroups.

OOM killer prefers memory cgroups with larger priority if they are
populated with eligible tasks.

The oom_priority value is compared within sibling cgroups.

If two or more sibling cgroups have the same oom_priority,
the decision is based on their memory footprint.

The root cgroup has the oom_priority 0, which cannot be changed.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 include/linux/memcontrol.h |  3 +++
 mm/memcontrol.c            | 49 ++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5b5c2b89968e..73a0291948fd 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -206,6 +206,9 @@ struct mem_cgroup {
 	/* cached OOM score */
 	long oom_score;
 
+	/* OOM killer priority */
+	int oom_priority;
+
 	/* handle for "memory.events" */
 	struct cgroup_file events_file;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 97813c56163b..d7dd293897ca 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2757,6 +2757,7 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 	for (;;) {
 		struct cgroup_subsys_state *css;
 		struct mem_cgroup *memcg = NULL;
+		int prio = INT_MIN;
 		long score = LONG_MIN;
 
 		css_for_each_child(css, &root->css) {
@@ -2768,7 +2769,12 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 			if (iter->oom_score == 0)
 				continue;
 
-			if (iter->oom_score > score) {
+			if (iter->oom_priority > prio) {
+				memcg = iter;
+				prio = iter->oom_priority;
+				score = iter->oom_score;
+			} else if (iter->oom_priority == prio &&
+				   iter->oom_score > score) {
 				memcg = iter;
 				score = iter->oom_score;
 			}
@@ -2838,7 +2844,15 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
 	 * For system-wide OOMs we should consider tasks in the root cgroup
 	 * with oom_score larger than oc->chosen_points.
 	 */
-	if (!oc->memcg) {
+	if (!oc->memcg && !(oc->chosen_memcg &&
+			    oc->chosen_memcg->oom_priority > 0)) {
+		/*
+		 * Root memcg has priority 0, so if chosen memcg has lower
+		 * priority, any task in root cgroup is preferable.
+		 */
+		if (oc->chosen_memcg && oc->chosen_memcg->oom_priority < 0)
+			oc->chosen_points = 0;
+
 		select_victim_root_cgroup_task(oc);
 
 		if (oc->chosen_task && oc->chosen_memcg) {
@@ -5480,6 +5494,31 @@ static ssize_t memory_oom_group_write(struct kernfs_open_file *of,
 	return nbytes;
 }
 
+static int memory_oom_priority_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+
+	seq_printf(m, "%d\n", memcg->oom_priority);
+
+	return 0;
+}
+
+static ssize_t memory_oom_priority_write(struct kernfs_open_file *of,
+				char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	int oom_priority;
+	int err;
+
+	err = kstrtoint(strstrip(buf), 0, &oom_priority);
+	if (err)
+		return err;
+
+	memcg->oom_priority = oom_priority;
+
+	return nbytes;
+}
+
 static int memory_events_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
@@ -5606,6 +5645,12 @@ static struct cftype memory_files[] = {
 		.write = memory_oom_group_write,
 	},
 	{
+		.name = "oom_priority",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_oom_priority_show,
+		.write = memory_oom_priority_write,
+	},
+	{
 		.name = "events",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.file_offset = offsetof(struct mem_cgroup, events_file),
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
