Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 45A6B6B0008
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 13:55:05 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g82-v6so3059292lfg.4
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:55:05 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id z3-v6si6960352lfj.162.2018.06.11.10.55.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 10:55:03 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v2 3/3] mm, memcg: don't skip memory guarantee calculations
Date: Mon, 11 Jun 2018 10:54:18 -0700
Message-ID: <20180611175418.7007-4-guro@fb.com>
In-Reply-To: <20180611175418.7007-1-guro@fb.com>
References: <20180611175418.7007-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linuxfoundation.org>

There are two cases when effective memory guarantee calculation is
mistakenly skipped:

1) If memcg is a child of the root cgroup, and the root cgroup is not
   root_mem_cgroup (in other words, if the reclaim is targeted).
   Top-level memory cgroups are handled specially in
   mem_cgroup_protected(), because the root memory cgroup doesn't have
   memory guarantee and can't limit its children guarantees.  So, all
   effective guarantee calculation is skipped.  But in case of targeted
   reclaim things are different: cgroups, which parent exceeded its memory
   limit aren't special.

2) If memcg has no charged memory (memory usage is 0).  In this case
   mem_cgroup_protected() always returns MEMCG_PROT_NONE, which is correct
   and prevents to generate fake memory low events for empty cgroups.  But
   skipping memory emin/elow calculation is wrong: if there is no global
   memory pressure there might be no good chance again, so we can end up
   with effective guarantees set to 0 without any reason.

Link: http://lkml.kernel.org/r/20180522132528.23769-2-guro@fb.com
Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Greg Thelen <gthelen@google.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Shuah Khan <shuah@kernel.org>
Signed-off-by: Andrew Morton <akpm@linuxfoundation.org>
---
 mm/memcontrol.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 485df6f63d26..3220c992ee26 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5477,15 +5477,10 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
 	if (mem_cgroup_disabled())
 		return MEMCG_PROT_NONE;
 
-	if (!root)
-		root = root_mem_cgroup;
-	if (memcg == root)
+	if (memcg == root_mem_cgroup)
 		return MEMCG_PROT_NONE;
 
 	usage = page_counter_read(&memcg->memory);
-	if (!usage)
-		return MEMCG_PROT_NONE;
-
 	emin = memcg->memory.min;
 	elow = memcg->memory.low;
 
@@ -5494,7 +5489,7 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
 	if (!parent)
 		return MEMCG_PROT_NONE;
 
-	if (parent == root)
+	if (parent == root_mem_cgroup)
 		goto exit;
 
 	parent_emin = READ_ONCE(parent->memory.emin);
@@ -5529,6 +5524,12 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
 	memcg->memory.emin = emin;
 	memcg->memory.elow = elow;
 
+	if (root && memcg == root)
+		return MEMCG_PROT_NONE;
+
+	if (!usage)
+		return MEMCG_PROT_NONE;
+
 	if (usage <= emin)
 		return MEMCG_PROT_MIN;
 	else if (usage <= elow)
-- 
2.14.4
