Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A9606B0261
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 11:48:24 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k10so5852099wrk.23
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 08:48:24 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 82si7772176ljc.195.2017.10.04.08.48.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 08:48:23 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v10 5/6] mm, oom: add cgroup v2 mount option for cgroup-aware OOM killer
Date: Wed, 4 Oct 2017 16:46:37 +0100
Message-ID: <20171004154638.710-6-guro@fb.com>
In-Reply-To: <20171004154638.710-1-guro@fb.com>
References: <20171004154638.710-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

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
index 3e55bbd31ad1..cae5343a8b21 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -80,6 +80,11 @@ enum {
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
index c3421ee0d230..8d8aa46ff930 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -1709,6 +1709,9 @@ static int parse_cgroup_root_flags(char *data, unsigned int *root_flags)
 		if (!strcmp(token, "nsdelegate")) {
 			*root_flags |= CGRP_ROOT_NS_DELEGATE;
 			continue;
+		} else if (!strcmp(token, "groupoom")) {
+			*root_flags |= CGRP_GROUP_OOM;
+			continue;
 		}
 
 		pr_err("cgroup2: unknown option \"%s\"\n", token);
@@ -1725,6 +1728,11 @@ static void apply_cgroup_root_flags(unsigned int root_flags)
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
 
@@ -1732,6 +1740,8 @@ static int cgroup_show_options(struct seq_file *seq, struct kernfs_root *kf_root
 {
 	if (cgrp_dfl_root.flags & CGRP_ROOT_NS_DELEGATE)
 		seq_puts(seq, ",nsdelegate");
+	if (cgrp_dfl_root.flags & CGRP_GROUP_OOM)
+		seq_puts(seq, ",groupoom");
 	return 0;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1fcd6cc353d5..2e82625bd354 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2865,6 +2865,9 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
 		return false;
 
+	if (!(cgrp_dfl_root.flags & CGRP_GROUP_OOM))
+		return false;
+
 	if (oc->memcg)
 		root = oc->memcg;
 	else
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
