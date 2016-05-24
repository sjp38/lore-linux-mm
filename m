Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42EC86B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 01:37:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b124so13017828pfb.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 22:37:57 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id lx17si2312989pab.66.2016.05.23.22.37.56
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 May 2016 22:37:56 -0700 (PDT)
From: roy.qing.li@gmail.com
Subject: [PATCH][V2] mm: memcontrol: fix the margin computation in mem_cgroup_margin
Date: Tue, 24 May 2016 13:37:46 +0800
Message-Id: <1464068266-27736-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov@virtuozzo.com

From: Li RongQing <roy.qing.li@gmail.com>

The margin may be set to the difference value between memory limit and
memory count firstly. which maybe returned wrongly if memsw.count excess
memsw.limit, because try_charge forces charging __GFP_NOFAIL allocations,
which may result in memsw.limit excess. If we are below memory.limit
and there's nothing to reclaim to reduce memsw.usage, might end up
looping in try_charge forever.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Michal Hocko <mhocko@suse.com>
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 00981d2..12aaadd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1090,6 +1090,8 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
 		limit = READ_ONCE(memcg->memsw.limit);
 		if (count <= limit)
 			margin = min(margin, limit - count);
+		else
+			margin = 0;
 	}
 
 	return margin;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
