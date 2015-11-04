Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4A43B82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 17:22:33 -0500 (EST)
Received: by wicfv8 with SMTP id fv8so41340646wic.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 14:22:32 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e17si4122882wjr.24.2015.11.04.14.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 14:22:32 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/8] mm: memcontrol: export root_mem_cgroup
Date: Wed,  4 Nov 2015 17:22:07 -0500
Message-Id: <1446675734-25671-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1446675734-25671-1-git-send-email-hannes@cmpxchg.org>
References: <1446675734-25671-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

A later patch will need this symbol in files other than memcontrol.c,
so export it now and replace mem_cgroup_root_css at the same time.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/memcontrol.h | 3 ++-
 mm/backing-dev.c           | 2 +-
 mm/memcontrol.c            | 5 ++---
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 805da1f..19ff87b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -275,7 +275,8 @@ struct mem_cgroup {
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
-extern struct cgroup_subsys_state *mem_cgroup_root_css;
+
+extern struct mem_cgroup *root_mem_cgroup;
 
 /**
  * mem_cgroup_events - count memory events against a cgroup
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 095b23b..73ab967 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -702,7 +702,7 @@ static int cgwb_bdi_init(struct backing_dev_info *bdi)
 
 	ret = wb_init(&bdi->wb, bdi, 1, GFP_KERNEL);
 	if (!ret) {
-		bdi->wb.memcg_css = mem_cgroup_root_css;
+		bdi->wb.memcg_css = &root_mem_cgroup->css;
 		bdi->wb.blkcg_css = blkcg_root_css;
 	}
 	return ret;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c71fe40..7049e55 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -76,9 +76,9 @@
 struct cgroup_subsys memory_cgrp_subsys __read_mostly;
 EXPORT_SYMBOL(memory_cgrp_subsys);
 
+struct mem_cgroup *root_mem_cgroup __read_mostly;
+
 #define MEM_CGROUP_RECLAIM_RETRIES	5
-static struct mem_cgroup *root_mem_cgroup __read_mostly;
-struct cgroup_subsys_state *mem_cgroup_root_css __read_mostly;
 
 /* Whether the swap controller is active */
 #ifdef CONFIG_MEMCG_SWAP
@@ -4214,7 +4214,6 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	/* root ? */
 	if (parent_css == NULL) {
 		root_mem_cgroup = memcg;
-		mem_cgroup_root_css = &memcg->css;
 		page_counter_init(&memcg->memory, NULL);
 		memcg->high = PAGE_COUNTER_MAX;
 		memcg->soft_limit = PAGE_COUNTER_MAX;
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
