Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A998C6B0256
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:52:24 -0500 (EST)
Received: by wmww144 with SMTP id w144so44989068wmw.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:52:24 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id im4si22711677wjb.193.2015.11.24.13.52.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 13:52:22 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 01/13] mm: memcontrol: export root_mem_cgroup
Date: Tue, 24 Nov 2015 16:51:53 -0500
Message-Id: <1448401925-22501-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

A later patch will need this symbol in files other than memcontrol.c,
so export it now and replace mem_cgroup_root_css at the same time.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: David S. Miller <davem@davemloft.net>
Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/memcontrol.h | 3 ++-
 mm/backing-dev.c           | 2 +-
 mm/memcontrol.c            | 5 ++---
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9d5472b..320b690 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -265,7 +265,8 @@ struct mem_cgroup {
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
-extern struct cgroup_subsys_state *mem_cgroup_root_css;
+
+extern struct mem_cgroup *root_mem_cgroup;
 
 /**
  * mem_cgroup_events - count memory events against a cgroup
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 9160853..fdc6f4d 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -707,7 +707,7 @@ static int cgwb_bdi_init(struct backing_dev_info *bdi)
 
 	ret = wb_init(&bdi->wb, bdi, 1, GFP_KERNEL);
 	if (!ret) {
-		bdi->wb.memcg_css = mem_cgroup_root_css;
+		bdi->wb.memcg_css = &root_mem_cgroup->css;
 		bdi->wb.blkcg_css = blkcg_root_css;
 	}
 	return ret;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 79a29d5..f6ea649 100644
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
@@ -4217,7 +4217,6 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
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
