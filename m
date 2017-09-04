Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id E110D6B04B8
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 10:22:02 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id w138so843315yww.2
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 07:22:02 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id o185si1762754ybg.236.2017.09.04.07.22.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Sep 2017 07:22:01 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v7 4/5] mm, oom, docs: describe the cgroup-aware OOM killer
Date: Mon, 4 Sep 2017 15:21:07 +0100
Message-ID: <20170904142108.7165-5-guro@fb.com>
In-Reply-To: <20170904142108.7165-1-guro@fb.com>
References: <20170904142108.7165-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Update cgroups v2 docs.

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
 Documentation/cgroup-v2.txt | 56 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 56 insertions(+)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index a86f3cb88125..5d21bd2e7d55 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -44,6 +44,7 @@ CONTENTS
     5-2-1. Memory Interface Files
     5-2-2. Usage Guidelines
     5-2-3. Memory Ownership
+    5-2-4. OOM Killer
   5-3. IO
     5-3-1. IO Interface Files
     5-3-2. Writeback
@@ -799,6 +800,33 @@ PAGE_SIZE multiple when read back.
 	high limit is used and monitored properly, this limit's
 	utility is limited to providing the final safety net.
 
+  memory.oom_group
+
+	A read-write single value file which exists on non-root
+	cgroups.  The default is "0".
+
+	If set, OOM killer will kill all processes attached to the cgroup
+	if selected as an OOM victim.
+
+	OOM killer respects the /proc/pid/oom_score_adj value -1000,
+	and will never kill the unkillable task, even if memory.oom_group
+	is set.
+
+  memory.oom_priority
+
+	A read-write single value file which exists on non-root
+	cgroups.  The default is "0".
+
+	An integer number, which defines the order in which
+	the OOM killer selects victim memory cgroups.
+
+	OOM killer prefers memory cgroups with larger priority if they
+	are populated with eligible tasks.
+
+	The oom_priority value is compared within sibling cgroups.
+
+	The root cgroup has the oom_priority 0, which cannot be changed.
+
   memory.events
 
 	A read-only flat-keyed file which exists on non-root cgroups.
@@ -1028,6 +1056,34 @@ POSIX_FADV_DONTNEED to relinquish the ownership of memory areas
 belonging to the affected files to ensure correct memory ownership.
 
 
+5-2-4. OOM Killer
+
+Cgroup v2 memory controller implements a cgroup-aware OOM killer.
+It means that it treats cgroups as first class OOM entities.
+
+Under OOM conditions the memory controller tries to make the best
+choice of a victim, hierarchically looking for a cgroup with the
+largest oom_priority. If sibling cgroups have the same priority,
+the OOM killer selects one which is the largest memory consumer.
+
+By default, OOM killer will kill the biggest task in the selected
+memory cgroup. A user can change this behavior by enabling
+the per-cgroup oom_group option. If set, it causes the OOM killer
+to kill all processes attached to the cgroup.
+
+Tasks in the root cgroup are treated as independent memory consumers,
+and are compared with other memory consumers (memory cgroups and
+other tasks in root cgroup).
+The root cgroup doesn't support the oom_group feature.
+
+This affects both system- and cgroup-wide OOMs. For a cgroup-wide OOM
+the memory controller considers only cgroups belonging to the sub-tree
+of the OOM'ing cgroup.
+
+If there are no cgroups with the enabled memory controller,
+the OOM killer is using the "traditional" process-based approach.
+
+
 5-3. IO
 
 The "io" controller regulates the distribution of IO resources.  This
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
