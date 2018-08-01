Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Li RongQing <lirongqing@baidu.com>
Subject: [PATCH 1/2] mm: add a function to return a bdi_writeback dirty page statistic
Date: Wed,  1 Aug 2018 18:48:35 +0800
Message-Id: <1533120516-18279-1-git-send-email-lirongqing@baidu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
List-ID: <linux-mm.kvack.org>

this is a preparation to optimise a full writeback
when reclaim memory

Signed-off-by: Zhang Yu <zhangyu31@baidu.com>
Signed-off-by: Li RongQing <lirongqing@baidu.com>
---
 include/linux/memcontrol.h | 2 +-
 mm/memcontrol.c            | 6 ++++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6c6fb116e925..58e29555ac81 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1141,7 +1141,7 @@ struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb);
 void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
 			 unsigned long *pheadroom, unsigned long *pdirty,
 			 unsigned long *pwriteback);
-
+unsigned long mem_cgroup_wb_dirty_stats(struct bdi_writeback *wb);
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static inline struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8c0280b3143e..82d3061e91d1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3640,6 +3640,12 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
 	}
 }
 
+unsigned long mem_cgroup_wb_dirty_stats(struct bdi_writeback *wb)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
+
+	return memcg_page_state(memcg, NR_FILE_DIRTY);
+}
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static int memcg_wb_domain_init(struct mem_cgroup *memcg, gfp_t gfp)
-- 
2.16.2
