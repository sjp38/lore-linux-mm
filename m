Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5316B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:05:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e3so211605006pfc.4
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 06:05:09 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 3si3983157pli.627.2017.07.27.06.05.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 06:05:08 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH 1/2] mm, memcg: reset memory.low during memcg offlining
Date: Thu, 27 Jul 2017 14:04:27 +0100
Message-ID: <20170727130428.28856-1-guro@fb.com>
In-Reply-To: <20170726083017.3yzeucmi7lcj46qd@esperanza>
References: <20170726083017.3yzeucmi7lcj46qd@esperanza>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

A removed memory cgroup with a defined memory.low and some belonging
pagecache has very low chances to be freed.

If a cgroup has been removed, there is likely no memory pressure inside
the cgroup, and the pagecache is protected from the external pressure
by the defined low limit. The cgroup will be freed only after
the reclaim of all belonging pages. And it will not happen until
there are any reclaimable memory in the system. That means,
there is a good chance, that a cold pagecache will reside
in the memory for an undefined amount of time, wasting
system resources.

This problem was fixed earlier by commit fa06235b8eb0
("cgroup: reset css on destruction"), but it's not a best way
to do it, as we can't really reset all limits/counters during
cgroup offlining.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d61133e6af99..7b24210596ea 100644
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
