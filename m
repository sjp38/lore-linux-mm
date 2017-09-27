Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C29B6B026A
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 09:11:06 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id i14so18780821qke.6
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 06:11:06 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id i4si10951442qta.167.2017.09.27.06.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 06:11:05 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v9 5/5] mm, oom, docs: describe the cgroup-aware OOM killer
Date: Wed, 27 Sep 2017 14:09:36 +0100
Message-ID: <20170927130936.8601-6-guro@fb.com>
In-Reply-To: <20170927130936.8601-1-guro@fb.com>
References: <20170927130936.8601-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Document the cgroup-aware OOM killer.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 Documentation/cgroup-v2.txt | 44 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 44 insertions(+)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index 3f8216912df0..936dd60b8d6a 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -48,6 +48,7 @@ v1 is available under Documentation/cgroup-v1/.
        5-2-1. Memory Interface Files
        5-2-2. Usage Guidelines
        5-2-3. Memory Ownership
+       5-2-4. OOM Killer
      5-3. IO
        5-3-1. IO Interface Files
        5-3-2. Writeback
@@ -1043,6 +1044,21 @@ PAGE_SIZE multiple when read back.
 	high limit is used and monitored properly, this limit's
 	utility is limited to providing the final safety net.
 
+  memory.oom_group
+
+	A read-write single value file which exists on non-root
+	cgroups.  The default is "0".
+
+	If set, OOM killer will consider the memory cgroup and all
+	descendant cgroups as indivisible memory consumers and compare
+	them with other memory consumers by their memory footprint.
+	If such memory cgroup is selected as an OOM victim, all
+	processes belonging to it or it's descendants will be killed.
+
+	OOM killer respects the /proc/pid/oom_score_adj value -1000,
+	and will never kill the unkillable task, even if memory.oom_group
+	is set.
+
   memory.events
 	A read-only flat-keyed file which exists on non-root cgroups.
 	The following entries are defined.  Unless specified
@@ -1246,6 +1262,34 @@ to be accessed repeatedly by other cgroups, it may make sense to use
 POSIX_FADV_DONTNEED to relinquish the ownership of memory areas
 belonging to the affected files to ensure correct memory ownership.
 
+OOM Killer
+~~~~~~~~~~
+
+Cgroup v2 memory controller implements a cgroup-aware OOM killer.
+It means that it treats cgroups as first class OOM entities.
+
+Under OOM conditions the memory controller tries to make the best
+choice of a victim, looking for a memory cgroup with the largest
+memory footprint, considering leaf cgroups and cgroups with the
+memory.oom_group option set, which are considered to be an indivisible
+memory consumers.
+
+By default, OOM killer will kill the biggest task in the selected
+memory cgroup. A user can change this behavior by enabling
+the per-cgroup memory.oom_group option. If set, it causes
+the OOM killer to kill all processes attached to the cgroup,
+except processes with oom_score_adj set to -1000.
+
+This affects both system- and cgroup-wide OOMs. For a cgroup-wide OOM
+the memory controller considers only cgroups belonging to the sub-tree
+of the OOM'ing cgroup.
+
+The root cgroup is treated as a leaf memory cgroup, so it's compared
+with other leaf memory cgroups and cgroups with oom_group option set.
+
+If there are no cgroups with the enabled memory controller,
+the OOM killer is using the "traditional" process-based approach.
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
