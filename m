Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 146FC6B20AE
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 17:36:34 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g15-v6so71405edm.11
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 14:36:34 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id t16-v6si198265edb.65.2018.08.21.14.36.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 14:36:32 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v2 2/3] mm: drain memcg stocks on css offlining
Date: Tue, 21 Aug 2018 14:35:58 -0700
Message-ID: <20180821213559.14694-2-guro@fb.com>
In-Reply-To: <20180821213559.14694-1-guro@fb.com>
References: <20180821213559.14694-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

Memcg charge is batched using per-cpu stocks, so an offline memcg
can be pinned by a cached charge up to a moment, when a process
belonging to some other cgroup will charge some memory on the same
cpu. In other words, cached charges can prevent a memory cgroup
from being reclaimed for some time, without any clear need.

Let's optimize it by explicit draining of all stocks on css offlining.
As draining is performed asynchronously, and is skipped if any
parallel draining is happening, it's cheap.

Signed-off-by: Roman Gushchin <guro@fb.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6a921890739f..c2a254f74f30 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4518,6 +4518,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	memcg_offline_kmem(memcg);
 	wb_memcg_offline(memcg);
 
+	drain_all_stock(memcg);
+
 	mem_cgroup_id_put(memcg);
 }
 
-- 
2.17.1
