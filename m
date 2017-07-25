Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id ACC066B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 07:41:50 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id q50so28004713wrb.14
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 04:41:50 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 77si7353767wmi.90.2017.07.25.04.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 04:41:48 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH] mm, memcg: reset low limit during memcg offlining
Date: Tue, 25 Jul 2017 12:40:47 +0100
Message-ID: <20170725114047.4073-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

A removed memory cgroup with a defined low limit and some belonging
pagecache has very low chances to be freed.

If a cgroup has been removed, there is likely no memory pressure inside
the cgroup, and the pagecache is protected from the external pressure
by the defined low limit. The cgroup will be freed only after
the reclaim of all belonging pages. And it will not happen until
there are any reclaimable memory in the system. That means,
there is a good chance, that a cold pagecache will reside
in the memory for an undefined amount of time, wasting
system resources.

Fix this issue by zeroing memcg->low during memcg offlining.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index aed11b2d0251..2aa204b8f9fd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4300,6 +4300,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	}
 	spin_unlock(&memcg->event_list_lock);
 
+	memcg->low = 0;
+
 	memcg_offline_kmem(memcg);
 	wb_memcg_offline(memcg);
 
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
