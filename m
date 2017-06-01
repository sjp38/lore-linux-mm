Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B72B66B02FA
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 14:36:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a66so53159534pfl.6
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:36:29 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f21si20787301pfk.205.2017.06.01.11.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 11:36:28 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [RFC PATCH v2 7/7] mm,oom,docs: describe the cgroup-aware OOM killer
Date: Thu, 1 Jun 2017 19:35:15 +0100
Message-ID: <1496342115-3974-8-git-send-email-guro@fb.com>
In-Reply-To: <1496342115-3974-1-git-send-email-guro@fb.com>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Update cgroups v2 docs.

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
 Documentation/cgroup-v2.txt | 47 +++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 45 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index dc5e2dc..bb1e45c 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -44,6 +44,7 @@ CONTENTS
     5-2-1. Memory Interface Files
     5-2-2. Usage Guidelines
     5-2-3. Memory Ownership
+    5-2-4. Cgroup-aware OOM Killer
   5-3. IO
     5-3-1. IO Interface Files
     5-3-2. Writeback
@@ -799,6 +800,26 @@ PAGE_SIZE multiple when read back.
 	high limit is used and monitored properly, this limit's
 	utility is limited to providing the final safety net.
 
+  memory.oom_kill_all_tasks
+
+	A read-write single value file which exits on non-root
+	cgroups.  The default is "0".
+
+	Defines whether the OOM killer should treat the cgroup
+	as a single entity during the victim selection.
+
+	If set, it will cause the OOM killer to kill all belonging
+	tasks, both in case of a system-wide or cgroup-wide OOM.
+
+  memory.oom_score_adj
+
+	A read-write single value file which exits on non-root
+	cgroups.  The default is "0".
+
+	OOM killer score adjustment, which has as similar meaning
+	to a per-process value, available via /proc/<pid>/oom_score_adj.
+	Should be in a range [-1000, 1000].
+
   memory.events
 
 	A read-only flat-keyed file which exists on non-root cgroups.
@@ -831,8 +852,7 @@ PAGE_SIZE multiple when read back.
 	  oom
 
 		The number of times the OOM killer has been invoked in
-		the cgroup.  This may not exactly match the number of
-		processes killed but should generally be close.
+		the cgroup.
 
   memory.stat
 
@@ -988,6 +1008,29 @@ POSIX_FADV_DONTNEED to relinquish the ownership of memory areas
 belonging to the affected files to ensure correct memory ownership.
 
 
+5-2-4. Cgroup-aware OOM Killer
+
+Cgroup v2 memory controller implements a cgroup-aware OOM killer.
+It means that it treats memory cgroups as first class OOM entities.
+
+Under OOM conditions the memory controller tries to make the best
+choise of a victim, hierarchically looking for the largest memory
+consumer. By default, it will look for the biggest task in the
+biggest leaf cgroup.
+
+But a user can change this behavior by enabling the per-cgroup
+oom_kill_all_tasks option. If set, it causes the OOM killer treat
+the whole cgroup as an indivisible memory consumer. In case if it's
+selected as on OOM victim, all belonging tasks will be killed.
+
+Tasks in the root cgroup are treated as independent memory consumers,
+and are compared with other memory consumers (e.g. leaf cgroups).
+The root cgroup doesn't support the oom_kill_all_tasks feature.
+
+This affects both system- and cgroup-wide OOMs. For a cgroup-wide OOM
+the memory controller considers only cgroups belonging to the sub-tree
+of the OOM'ing cgroup.
+
 5-3. IO
 
 The "io" controller regulates the distribution of IO resources.  This
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
