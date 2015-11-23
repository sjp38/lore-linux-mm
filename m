Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id F14D06B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 07:22:43 -0500 (EST)
Received: by padhx2 with SMTP id hx2so189908102pad.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:22:43 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id p26si19130082pfi.217.2015.11.23.04.22.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 04:22:43 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] memcg: fix memory.high target
Date: Mon, 23 Nov 2015 15:22:31 +0300
Message-ID: <1448281351-15103-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When the memory.high threshold is exceeded, try_charge() schedules a
task_work to reclaim the excess. The reclaim target is set to the number
of pages requested by try_charge(). This is wrong, because try_charge()
usually charges more pages than requested (batch > nr_pages) in order to
refill per cpu stocks. As a result, a process in a cgroup can easily
exceed memory.high significantly when doing a lot of charges w/o
returning to userspace (e.g. reading a file in big chunks).

Fix this issue by assuring that when exceeding memory.high a process
reclaims as many pages as were actually charged (i.e. batch).

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 648cc9f02437..06c476ab0f2c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2133,7 +2133,7 @@ done_restock:
 	 */
 	do {
 		if (page_counter_read(&memcg->memory) > memcg->high) {
-			current->memcg_nr_pages_over_high += nr_pages;
+			current->memcg_nr_pages_over_high += batch;
 			set_notify_resume(current);
 			break;
 		}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
