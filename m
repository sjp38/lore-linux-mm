Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id ECA2682F65
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 00:22:02 -0400 (EDT)
Received: by wijp11 with SMTP id p11so13004392wij.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 21:22:02 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qb5si15958757wjc.139.2015.10.21.21.21.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 21:21:59 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/8] mm: memcontrol: export root_mem_cgroup
Date: Thu, 22 Oct 2015 00:21:30 -0400
Message-Id: <1445487696-21545-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

A later patch will need this symbol in files other than memcontrol.c,
so export it now and replace mem_cgroup_root_css at the same time.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
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
index a8ccdbc..e54f434 100644
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
@@ -4213,7 +4213,6 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	/* root ? */
 	if (parent_css == NULL) {
 		root_mem_cgroup = memcg;
-		mem_cgroup_root_css = &memcg->css;
 		page_counter_init(&memcg->memory, NULL);
 		memcg->high = PAGE_COUNTER_MAX;
 		memcg->soft_limit = PAGE_COUNTER_MAX;
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
