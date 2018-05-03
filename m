Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2674A6B000A
	for <linux-mm@kvack.org>; Thu,  3 May 2018 07:45:12 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id d11so13045775qkg.20
        for <linux-mm@kvack.org>; Thu, 03 May 2018 04:45:12 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 11-v6si5261326qvq.149.2018.05.03.04.45.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 04:45:11 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v3 2/2] mm: ignore memory.min of abandoned memory cgroups
Date: Thu, 3 May 2018 12:43:58 +0100
Message-ID: <20180503114358.7952-2-guro@fb.com>
In-Reply-To: <20180503114358.7952-1-guro@fb.com>
References: <20180503114358.7952-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

If a cgroup has no associated tasks, invoking the OOM killer
won't help release any memory, so respecting the memory.min
can lead to an infinite OOM loop or system stall.

Let's ignore memory.min of unpopulated cgroups.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h | 10 ++++++++++
 mm/vmscan.c                |  6 +++++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3b65d092614f..7d8472022aae 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -374,6 +374,11 @@ static inline void mem_cgroup_put(struct mem_cgroup *memcg)
 	css_put(&memcg->css);
 }
 
+static inline bool mem_cgroup_is_populated(struct mem_cgroup *memcg)
+{
+	return cgroup_is_populated(memcg->css.cgroup);
+}
+
 #define mem_cgroup_from_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
@@ -835,6 +840,11 @@ static inline void mem_cgroup_put(struct mem_cgroup *memcg)
 {
 }
 
+static inline bool mem_cgroup_is_populated(struct mem_cgroup *memcg)
+{
+	return false;
+}
+
 static inline struct mem_cgroup *
 mem_cgroup_iter(struct mem_cgroup *root,
 		struct mem_cgroup *prev,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 50055d72f294..5e2047e04770 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2549,8 +2549,12 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 				/*
 				 * Hard protection.
 				 * If there is no reclaimable memory, OOM.
+				 * Abandoned cgroups are losing protection,
+				 * because OOM killer won't release any memory.
 				 */
-				continue;
+				if (mem_cgroup_is_populated(memcg))
+					continue;
+				break;
 			case MEMCG_PROT_LOW:
 				/*
 				 * Soft protection.
-- 
2.14.3
