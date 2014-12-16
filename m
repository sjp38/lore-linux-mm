Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 99A566B0038
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 08:25:53 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so13940171pdb.38
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 05:25:53 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id q5si1048919pdi.134.2014.12.16.05.25.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Dec 2014 05:25:51 -0800 (PST)
From: Chintan Pandya <cpandya@codeaurora.org>
Subject: [PATCH] memcg: Provide knob for force OOM into the memcg
Date: Tue, 16 Dec 2014 18:55:35 +0530
Message-Id: <1418736335-30915-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org, linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>

We may want to use memcg to limit the total memory
footprint of all the processes within the one group.
This may lead to a situation where any arbitrary
process cannot get migrated to that one  memcg
because its limits will be breached. Or, process can
get migrated but even being most recently used
process, it can get killed by in-cgroup OOM. To
avoid such scenarios, provide a convenient knob
by which we can forcefully trigger OOM and make
a room for upcoming process.

To trigger force OOM,
$ echo 1 > /<memcg_path>/memory.force_oom

Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
---
 mm/memcontrol.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ef91e85..4c68aa7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3305,6 +3305,30 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 	return 0;
 }
 
+static int mem_cgroup_force_oom(struct cgroup *cont, unsigned int event)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	int ret;
+
+	if (mem_cgroup_is_root(memcg))
+		return -EINVAL;
+
+	css_get(&memcg->css);
+	ret = mem_cgroup_handle_oom(memcg, GFP_KERNEL, 0);
+	css_put(&memcg->css);
+
+	return ret;
+}
+
+static int mem_cgroup_force_oom_write(struct cgroup *cgrp,
+				struct cftype *cft, u64 val)
+{
+	if (val > 1 || val < 1)
+		return -EINVAL;
+
+	return mem_cgroup_force_oom(cgrp, 0);
+}
+
 static ssize_t mem_cgroup_force_empty_write(struct kernfs_open_file *of,
 					    char *buf, size_t nbytes,
 					    loff_t off)
@@ -4442,6 +4466,11 @@ static struct cftype mem_cgroup_files[] = {
 		.write = mem_cgroup_force_empty_write,
 	},
 	{
+		.name = "force_oom",
+		.trigger = mem_cgroup_force_oom,
+		.write_u64 = mem_cgroup_force_oom_write,
+	},
+	{
 		.name = "use_hierarchy",
 		.write_u64 = mem_cgroup_hierarchy_write,
 		.read_u64 = mem_cgroup_hierarchy_read,
-- 
Chintan Pandya

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
