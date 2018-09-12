Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Li RongQing <lirongqing@baidu.com>
Subject: [PATCH] memcg: remove congestion wait when force empty
Date: Wed, 12 Sep 2018 17:19:20 +0800
Message-Id: <1536743960-19703-1-git-send-email-lirongqing@baidu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
List-ID: <linux-mm.kvack.org>

memory.force_empty is used to empty a memory cgoup memory before
rmdir it, avoid to charge those memory into parent cgroup

when try_to_free_mem_cgroup_pages returns 0, guess there maybe be
lots of writeback, so wait. but the waiting and sleep will called
in shrink_inactive_list, based on numbers of isolated page, so
remove this wait to reduce unnecessary delay

Signed-off-by: Li RongQing <lirongqing@baidu.com>
---
 mm/memcontrol.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4ead5a4817de..35bd43eaa97e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2897,12 +2897,8 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 
 		progress = try_to_free_mem_cgroup_pages(memcg, 1,
 							GFP_KERNEL, true);
-		if (!progress) {
+		if (!progress)
 			nr_retries--;
-			/* maybe some writeback is necessary */
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
-		}
-
 	}
 
 	return 0;
-- 
2.16.2
