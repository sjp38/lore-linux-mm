Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A621D6B0007
	for <linux-mm@kvack.org>; Tue, 22 May 2018 09:28:46 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s3-v6so11231261pfh.0
        for <linux-mm@kvack.org>; Tue, 22 May 2018 06:28:46 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u13-v6si15971021plq.161.2018.05.22.06.28.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 06:28:45 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH 2/2] mm: don't skip memory guarantee calculations
Date: Tue, 22 May 2018 14:25:28 +0100
Message-ID: <20180522132528.23769-2-guro@fb.com>
In-Reply-To: <20180522132528.23769-1-guro@fb.com>
References: <20180522132528.23769-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

There are two cases when effective memory guarantee calculation
is mistakenly skipped:

1) If memcg is a child of the root cgroup, and the root
cgroup is not root_mem_cgroup (in other words, if the reclaim
is targeted). Top-level memory cgroups are handled specially
in mem_cgroup_protected(), because the root memory cgroup doesn't
have memory guarantee and can't limit its children guarantees.
So, all effective guarantee calculation is skipped.
But in case of targeted reclaim things are different:
cgroups, which parent exceeded its memory limit aren't special.

2) If memcg has no charged memory (memory usage is 0). In this
case mem_cgroup_protected() always returns MEMCG_PROT_NONE, which
is correct and prevents to generate fake memory low events for
empty cgroups. But skipping memory emin/elow calculation is wrong:
if there is no global memory pressure there might be no good
chance again, so we can end up with effective guarantees set to 0
without any reason.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Greg Thelen <gthelen@google.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b9cd0bb63759..20c4f0a97d4c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5809,20 +5809,15 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
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
 
 	parent = parent_mem_cgroup(memcg);
-	if (parent == root)
+	if (parent == root_mem_cgroup)
 		goto exit;
 
 	parent_emin = READ_ONCE(parent->memory.emin);
@@ -5857,6 +5852,12 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
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
2.14.3
