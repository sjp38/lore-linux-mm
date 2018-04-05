Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 58B226B000D
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 15:01:55 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z15so14006974wrh.10
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 12:01:55 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w55si5100075edd.51.2018.04.05.12.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 12:01:54 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v3 3/4] mm: treat memory.low value inclusive
Date: Thu, 5 Apr 2018 19:59:20 +0100
Message-ID: <20180405185921.4942-3-guro@fb.com>
In-Reply-To: <20180405185921.4942-1-guro@fb.com>
References: <20180405185921.4942-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

If memcg's usage is equal to the memory.low value, avoid reclaiming
from this cgroup while there is a surplus of reclaimable memory.

This sounds more logical and also matches memory.high and memory.max
behavior: both are inclusive.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: kernel-team@fb.com
Cc: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 mm/memcontrol.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 78cf21f2a943..1cd6e9bf24f2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5608,14 +5608,14 @@ struct cgroup_subsys memory_cgrp_subsys = {
 };
 
 /**
- * mem_cgroup_low - check if memory consumption is below the normal range
+ * mem_cgroup_low - check if memory consumption is in the normal range
  * @root: the top ancestor of the sub-tree being checked
  * @memcg: the memory cgroup to check
  *
  * WARNING: This function is not stateless! It can only be used as part
  *          of a top-down tree iteration, not for isolated queries.
  *
- * Returns %true if memory consumption of @memcg is below the normal range.
+ * Returns %true if memory consumption of @memcg is in the normal range.
  *
  * @root is exclusive; it is never low when looked at directly
  *
@@ -5709,7 +5709,7 @@ bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
 	elow = min(elow, parent_elow * low_usage / siblings_low_usage);
 exit:
 	memcg->memory.elow = elow;
-	return usage < elow;
+	return usage <= elow;
 }
 
 /**
-- 
2.14.3
