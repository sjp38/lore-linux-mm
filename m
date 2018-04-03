Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Li RongQing <lirongqing@baidu.com>
Subject: [PATCH] mm: avoid the unnecessary waiting when force empty a cgroup
Date: Tue,  3 Apr 2018 15:12:09 +0800
Message-Id: <1522739529-5602-1-git-send-email-lirongqing@baidu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The number of writeback and dirty page can be read out from memcg,
the unnecessary waiting can be avoided by these counts

Signed-off-by: Li RongQing <lirongqing@baidu.com>
---
 mm/memcontrol.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9ec024b862ac..5258651bd4ec 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2613,9 +2613,13 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 		progress = try_to_free_mem_cgroup_pages(memcg, 1,
 							GFP_KERNEL, true);
 		if (!progress) {
+			unsigned long num;
+
+			num = memcg_page_state(memcg, NR_WRITEBACK) +
+					memcg_page_state(memcg, NR_FILE_DIRTY);
 			nr_retries--;
-			/* maybe some writeback is necessary */
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+			if (num)
+				congestion_wait(BLK_RW_ASYNC, HZ/10);
 		}
 
 	}
-- 
2.11.0
