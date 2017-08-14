Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4BB3D6B02F3
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 14:33:00 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 123so148663179pga.5
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 11:33:00 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id j1si4419193pgf.548.2017.08.14.11.32.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 11:32:59 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v5 4/4] mm, oom, docs: describe the cgroup-aware OOM killer
Date: Mon, 14 Aug 2017 19:32:13 +0100
Message-ID: <20170814183213.12319-5-guro@fb.com>
In-Reply-To: <20170814183213.12319-1-guro@fb.com>
References: <20170814183213.12319-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Update cgroups v2 docs.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 Documentation/cgroup-v2.txt | 62 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 62 insertions(+)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index dec5afdaa36d..22108f31e09d 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -48,6 +48,7 @@ v1 is available under Documentation/cgroup-v1/.
        5-2-1. Memory Interface Files
        5-2-2. Usage Guidelines
        5-2-3. Memory Ownership
+       5-2-4. Cgroup-aware OOM Killer
      5-3. IO
        5-3-1. IO Interface Files
        5-3-2. Writeback
@@ -1002,6 +1003,37 @@ PAGE_SIZE multiple when read back.
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
+	If set, OOM killer will kill all belonging tasks in
+	corresponding cgroup is selected as an OOM victim.
+
+	Be default, OOM killer respect /proc/pid/oom_score_adj value
+	-1000, and will never kill the task, unless oom_kill_all_tasks
+	is set.
+
+  memory.oom_priority
+
+	A read-write single value file which exits on non-root
+	cgroups.  The default is "0".
+
+	An integer number within the [-10000, 10000] range,
+	which defines the order in which the OOM killer selects victim
+	memory cgroups.
+
+	OOM killer prefers memory cgroups with larger priority if they
+	are populated with elegible tasks.
+
+	The oom_priority value is compared within sibling cgroups.
+
+	The root cgroup has the oom_priority 0, which cannot be changed.
+
   memory.events
 	A read-only flat-keyed file which exists on non-root cgroups.
 	The following entries are defined.  Unless specified
@@ -1206,6 +1238,36 @@ POSIX_FADV_DONTNEED to relinquish the ownership of memory areas
 belonging to the affected files to ensure correct memory ownership.
 
 
+Cgroup-aware OOM Killer
+~~~~~~~~~~~~~~~~~~~~~~~
+
+Cgroup v2 memory controller implements a cgroup-aware OOM killer.
+It means that it treats memory cgroups as first class OOM entities.
+
+Under OOM conditions the memory controller tries to make the best
+choise of a victim, hierarchically looking for the largest memory
+consumer. By default, it will look for the biggest task in the
+biggest leaf cgroup.
+
+Be default, all cgroups have oom_priority 0, and OOM killer will
+chose the largest cgroup recursively on each level. For non-root
+cgroups it's possible to change the oom_priority, and it will cause
+the OOM killer to look athe the priority value first, and compare
+sizes only of cgroups with equal priority.
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
 IO
 --
 
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
