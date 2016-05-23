Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id E1CE26B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 12:02:18 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id f11so106170128igo.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 09:02:18 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0140.outbound.protection.outlook.com. [157.55.234.140])
        by mx.google.com with ESMTPS id m139si4536938oig.158.2016.05.23.09.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 May 2016 09:02:17 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] mm: memcontrol: fix possible css ref leak on oom
Date: Mon, 23 May 2016 19:02:10 +0300
Message-ID: <1464019330-7579-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

mem_cgroup_oom may be invoked multiple times while a process is handling
a page fault, in which case current->memcg_in_oom will be overwritten
leaking the previously taken css reference.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5b48cd25951b..ef8797d34039 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1608,7 +1608,7 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 
 static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 {
-	if (!current->memcg_may_oom)
+	if (!current->memcg_may_oom || current->memcg_in_oom)
 		return;
 	/*
 	 * We are in the middle of the charge context here, so we
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
