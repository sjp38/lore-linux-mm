Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB1F96B02C3
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 14:36:23 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 10so12086069wml.4
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:36:23 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id y2si18874234ede.296.2017.06.01.11.36.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 11:36:22 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [RFC PATCH v2 5/7] mm, oom: introduce oom_score_adj for memory cgroups
Date: Thu, 1 Jun 2017 19:35:13 +0100
Message-ID: <1496342115-3974-6-git-send-email-guro@fb.com>
In-Reply-To: <1496342115-3974-1-git-send-email-guro@fb.com>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Introduce a per-memory-cgroup oom_score_adj setting.
A read-write single value file which exits on non-root
cgroups. The default is "0".

It will have a similar meaning to a per-process value,
available via /proc/<pid>/oom_score_adj.
Should be in a range [-1000, 1000].

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 include/linux/memcontrol.h |  3 +++
 mm/memcontrol.c            | 36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 8a308c9..818a42e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -198,6 +198,9 @@ struct mem_cgroup {
 	/* kill all tasks below in case of OOM */
 	bool oom_kill_all_tasks;
 
+	/* OOM kill score adjustment */
+	short oom_score_adj;
+
 	/* handle for "memory.events" */
 	struct cgroup_file events_file;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d4ffa79..f979ac7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5183,6 +5183,36 @@ static ssize_t memory_oom_kill_all_tasks_write(struct kernfs_open_file *of,
 	return nbytes;
 }
 
+static int memory_oom_score_adj_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	short oom_score_adj = memcg->oom_score_adj;
+
+	seq_printf(m, "%d\n", oom_score_adj);
+
+	return 0;
+}
+
+static ssize_t memory_oom_score_adj_write(struct kernfs_open_file *of,
+				char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	int oom_score_adj;
+	int err;
+
+	err = kstrtoint(strstrip(buf), 0, &oom_score_adj);
+	if (err)
+		return err;
+
+	if (oom_score_adj < OOM_SCORE_ADJ_MIN ||
+			oom_score_adj > OOM_SCORE_ADJ_MAX)
+		return -EINVAL;
+
+	memcg->oom_score_adj = (short)oom_score_adj;
+
+	return nbytes;
+}
+
 static int memory_events_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
@@ -5298,6 +5328,12 @@ static struct cftype memory_files[] = {
 		.write = memory_oom_kill_all_tasks_write,
 	},
 	{
+		.name = "oom_score_adj",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_oom_score_adj_show,
+		.write = memory_oom_score_adj_write,
+	},
+	{
 		.name = "events",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.file_offset = offsetof(struct mem_cgroup, events_file),
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
