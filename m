Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 634B36B0003
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 20:36:50 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b8-v6so21845667oib.4
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 17:36:50 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l77-v6si14731910oig.48.2018.08.14.17.36.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 17:36:49 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [RFC PATCH 2/2] mm: drain memcg stocks on css offlining
Date: Tue, 14 Aug 2018 17:36:20 -0700
Message-ID: <20180815003620.15678-2-guro@fb.com>
In-Reply-To: <20180815003620.15678-1-guro@fb.com>
References: <20180815003620.15678-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

Memcg charge is batched using per-cpu stocks, so an offline memcg
can be pinned by a cached charge up to a moment, when a process
belonging to some other cgroup will charge some memory on the same
cpu. In other words, cached charges can prevent a memory cgroup
from being reclaimed for some time, without any clear need.

Let's optimize it by explicit draining of all stocks on css offlining.
As draining is performed asynchronously, and is skipped if any
parallel draining is happening, it's cheap.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4e3c1315b1de..cfb64b5b9957 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4575,6 +4575,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	memcg_offline_kmem(memcg);
 	wb_memcg_offline(memcg);
 
+	drain_all_stock(memcg);
+
 	mem_cgroup_id_put(memcg);
 }
 
-- 
2.14.4
