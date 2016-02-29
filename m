Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A15FE6B0253
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:16:43 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fy10so95025527pac.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:16:43 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id 79si44123010pfm.61.2016.02.29.09.16.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 09:16:42 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] mm: memcontrol: reset memory.low on css offline
Date: Mon, 29 Feb 2016 20:16:33 +0300
Message-ID: <1456766193-16255-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When a cgroup directory is removed, the memory cgroup subsys state does
not disappear immediately. Instead, it's left hanging around until the
last reference to it is gone, which implies reclaiming all pages from
its lruvec.

In the unified hierarchy, there's the memory.low knob, which can be used
to set a best-effort protection for a memory cgroup - the reclaimer
first scans those cgroups whose consumption is above memory.low, and
only if it fails to reclaim enough pages, it gets to the rest.

Currently this protection is not reset when the cgroup directory is
removed. As a result, if a dead memory cgroup has a lot of page cache
charged to it and a high value of memory.low, it will result in higher
pressure exerted on live cgroups, and userspace will have no ways to
detect such consumers and reconfigure memory.low properly.

To fix this, let's reset memory.low on css offline.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ae8b81c55685..ab7bfe870c7d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4214,6 +4214,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 
 	memcg_offline_kmem(memcg);
 	wb_memcg_offline(memcg);
+
+	memcg->low = 0;
 }
 
 static void mem_cgroup_css_released(struct cgroup_subsys_state *css)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
