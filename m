Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7752E6B0072
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 15:59:04 -0400 (EDT)
Received: by qcbii10 with SMTP id ii10so15126697qcb.2
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 12:59:04 -0700 (PDT)
Received: from mail-qk0-x22c.google.com (mail-qk0-x22c.google.com. [2607:f8b0:400d:c09::22c])
        by mx.google.com with ESMTPS id c82si5152053qka.52.2015.04.06.12.58.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 12:58:59 -0700 (PDT)
Received: by qku63 with SMTP id 63so30965540qku.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 12:58:59 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 05/49] memcg: add mem_cgroup_root_css
Date: Mon,  6 Apr 2015 15:57:54 -0400
Message-Id: <1428350318-8215-6-git-send-email-tj@kernel.org>
In-Reply-To: <1428350318-8215-1-git-send-email-tj@kernel.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

Add global mem_cgroup_root_css which points to the root memcg css.
This will be used by cgroup writeback support.  If memcg is disabled,
it's defined as ERR_PTR(-EINVAL).

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
aCc: Michal Hocko <mhocko@suse.cz>
---
 include/linux/memcontrol.h | 4 ++++
 mm/memcontrol.c            | 2 ++
 2 files changed, 6 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5fe6411..294498f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -68,6 +68,8 @@ enum mem_cgroup_events_index {
 };
 
 #ifdef CONFIG_MEMCG
+extern struct cgroup_subsys_state *mem_cgroup_root_css;
+
 void mem_cgroup_events(struct mem_cgroup *memcg,
 		       enum mem_cgroup_events_index idx,
 		       unsigned int nr);
@@ -196,6 +198,8 @@ void mem_cgroup_split_huge_fixup(struct page *head);
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
+#define mem_cgroup_root_css ((struct cgroup_subsys_state *)ERR_PTR(-EINVAL))
+
 static inline void mem_cgroup_events(struct mem_cgroup *memcg,
 				     enum mem_cgroup_events_index idx,
 				     unsigned int nr)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cf25d1a..fda7025 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -71,6 +71,7 @@ EXPORT_SYMBOL(memory_cgrp_subsys);
 
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 static struct mem_cgroup *root_mem_cgroup __read_mostly;
+struct cgroup_subsys_state *mem_cgroup_root_css __read_mostly;
 
 /* Whether the swap controller is active */
 #ifdef CONFIG_MEMCG_SWAP
@@ -4551,6 +4552,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	/* root ? */
 	if (parent_css == NULL) {
 		root_mem_cgroup = memcg;
+		mem_cgroup_root_css = &memcg->css;
 		page_counter_init(&memcg->memory, NULL);
 		memcg->high = PAGE_COUNTER_MAX;
 		memcg->soft_limit = PAGE_COUNTER_MAX;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
