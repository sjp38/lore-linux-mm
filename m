Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD276B02C7
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 09:18:28 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id p2so4058711ywc.7
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 06:18:28 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id j3si1955608ybm.471.2017.09.11.06.18.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Sep 2017 06:18:27 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v8 3/4] mm, oom: add cgroup v2 mount option for cgroup-aware OOM killer
Date: Mon, 11 Sep 2017 14:17:41 +0100
Message-ID: <20170911131742.16482-4-guro@fb.com>
In-Reply-To: <20170911131742.16482-1-guro@fb.com>
References: <20170911131742.16482-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir
 Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Add a "groupoom" cgroup v2 mount option to enable the cgroup-aware
OOM killer. If not set, the OOM selection is performed in
a "traditional" per-process way.

The behavior can be changed dynamically by remounting the cgroupfs.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 include/linux/cgroup-defs.h |  5 +++++
 kernel/cgroup/cgroup.c      | 10 ++++++++++
 mm/memcontrol.c             |  3 +++
 3 files changed, 18 insertions(+)

diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index ade4a78a54c2..db4ff3e233a9 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -79,6 +79,11 @@ enum {
 	 * Enable cpuset controller in v1 cgroup to use v2 behavior.
 	 */
 	CGRP_ROOT_CPUSET_V2_MODE = (1 << 4),
+
+	/*
+	 * Enable cgroup-aware OOM killer.
+	 */
+	CGRP_GROUP_OOM = (1 << 5),
 };
 
 /* cftype->flags */
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index d6551cd45238..5f8a97a233bb 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -1699,6 +1699,9 @@ static int parse_cgroup_root_flags(char *data, unsigned int *root_flags)
 		if (!strcmp(token, "nsdelegate")) {
 			*root_flags |= CGRP_ROOT_NS_DELEGATE;
 			continue;
+		} else if (!strcmp(token, "groupoom")) {
+			*root_flags |= CGRP_GROUP_OOM;
+			continue;
 		}
 
 		pr_err("cgroup2: unknown option \"%s\"\n", token);
@@ -1715,6 +1718,11 @@ static void apply_cgroup_root_flags(unsigned int root_flags)
 			cgrp_dfl_root.flags |= CGRP_ROOT_NS_DELEGATE;
 		else
 			cgrp_dfl_root.flags &= ~CGRP_ROOT_NS_DELEGATE;
+
+		if (root_flags & CGRP_GROUP_OOM)
+			cgrp_dfl_root.flags |= CGRP_GROUP_OOM;
+		else
+			cgrp_dfl_root.flags &= ~CGRP_GROUP_OOM;
 	}
 }
 
@@ -1722,6 +1730,8 @@ static int cgroup_show_options(struct seq_file *seq, struct kernfs_root *kf_root
 {
 	if (cgrp_dfl_root.flags & CGRP_ROOT_NS_DELEGATE)
 		seq_puts(seq, ",nsdelegate");
+	if (cgrp_dfl_root.flags & CGRP_GROUP_OOM)
+		seq_puts(seq, ",groupoom");
 	return 0;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index da2b12ea4667..d645f70cb3a7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2871,6 +2871,9 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
 		return false;
 
+	if (!(cgrp_dfl_root.flags & CGRP_GROUP_OOM))
+		return false;
+
 	if (oc->memcg)
 		root = oc->memcg;
 	else
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
