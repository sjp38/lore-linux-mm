Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3326B4167
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 12:27:17 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id o4-v6so3665734lfg.11
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 09:27:17 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v66-v6si6779745lfd.107.2018.08.27.09.27.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 09:27:15 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v3 2/3] mm: drain memcg stocks on css offlining
Date: Mon, 27 Aug 2018 09:26:20 -0700
Message-ID: <20180827162621.30187-2-guro@fb.com>
In-Reply-To: <20180827162621.30187-1-guro@fb.com>
References: <20180827162621.30187-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-team@fb.com, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

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
index 29d9d1a69b36..17ce6f2e6caf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4573,6 +4573,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	memcg_offline_kmem(memcg);
 	wb_memcg_offline(memcg);
 
+	drain_all_stock(memcg);
+
 	mem_cgroup_id_put(memcg);
 }
 
-- 
2.17.1
