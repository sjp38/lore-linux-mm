Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 28C636B0032
	for <linux-mm@kvack.org>; Thu, 28 May 2015 13:26:20 -0400 (EDT)
Received: by pabru16 with SMTP id ru16so28259606pab.1
        for <linux-mm@kvack.org>; Thu, 28 May 2015 10:26:19 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id re12si4589619pdb.36.2015.05.28.10.26.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 10:26:19 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] memcg: do not call reclaim if !__GFP_WAIT
Date: Thu, 28 May 2015 20:26:06 +0300
Message-ID: <1432833966-25538-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

When trimming memcg consumption excess (see memory.high), we call
try_to_free_mem_cgroup_pages without checking if we are allowed to sleep
in the current context, which can result in a deadlock. Fix this.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 14c2f2017e37..9da23a7ec4c0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2323,6 +2323,8 @@ done_restock:
 	css_get_many(&memcg->css, batch);
 	if (batch > nr_pages)
 		refill_stock(memcg, batch - nr_pages);
+	if (!(gfp_mask & __GFP_WAIT))
+		goto done;
 	/*
 	 * If the hierarchy is above the normal consumption range,
 	 * make the charging task trim their excess contribution.
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
