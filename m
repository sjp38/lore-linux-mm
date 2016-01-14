Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF99828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 15:27:36 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id f206so450825949wmf.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 12:27:36 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ha10si12015430wjc.117.2016.01.14.12.27.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 12:27:35 -0800 (PST)
Date: Thu, 14 Jan 2016 15:26:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/2 V2] mm: memcontrol: add "sock" to cgroup2 memory.stat
Message-ID: <20160114202658.GC20218@cmpxchg.org>
References: <1452722469-24704-1-git-send-email-hannes@cmpxchg.org>
 <1452722469-24704-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452722469-24704-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Provide statistics on how much of a cgroup's memory footprint is made
up of socket buffers from network connections owned by the group.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

v2: add item description in cgroup.txt and rebase to updated 1/2

 Documentation/cgroup.txt   | 4 ++++
 include/linux/memcontrol.h | 5 ++++-
 mm/memcontrol.c            | 6 ++++++
 3 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/Documentation/cgroup.txt b/Documentation/cgroup.txt
index 65b3eac..e8d25e7 100644
--- a/Documentation/cgroup.txt
+++ b/Documentation/cgroup.txt
@@ -843,6 +843,10 @@ PAGE_SIZE multiple when read back.
 		Amount of memory used to cache filesystem data,
 		including tmpfs and shared memory.
 
+	  sock
+
+		Amount of memory used in network transmission buffers
+
 	  file_mapped
 
 		Amount of cached filesystem data mapped with mmap()
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1666617..9ae48d4 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -50,6 +50,9 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_WRITEBACK,	/* # of pages under writeback */
 	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
 	MEM_CGROUP_STAT_NSTATS,
+	/* default hierarchy stats */
+	MEMCG_SOCK,
+	MEMCG_NR_STAT,
 };
 
 struct mem_cgroup_reclaim_cookie {
@@ -87,7 +90,7 @@ enum mem_cgroup_events_target {
 
 #ifdef CONFIG_MEMCG
 struct mem_cgroup_stat_cpu {
-	long count[MEM_CGROUP_STAT_NSTATS];
+	long count[MEMCG_NR_STAT];
 	unsigned long events[MEMCG_NR_EVENTS];
 	unsigned long nr_page_events;
 	unsigned long targets[MEM_CGROUP_NTARGETS];
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cdb51a9..97e47de 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5127,6 +5127,8 @@ static int memory_stat_show(struct seq_file *m, void *v)
 		   (u64)tree_stat(memcg, MEM_CGROUP_STAT_RSS) * PAGE_SIZE);
 	seq_printf(m, "file %llu\n",
 		   (u64)tree_stat(memcg, MEM_CGROUP_STAT_CACHE) * PAGE_SIZE);
+	seq_printf(m, "sock %llu\n",
+		   (u64)tree_stat(memcg, MEMCG_SOCK) * PAGE_SIZE);
 
 	seq_printf(m, "file_mapped %llu\n",
 		   (u64)tree_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED) *
@@ -5630,6 +5632,8 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 	if (in_softirq())
 		gfp_mask = GFP_NOWAIT;
 
+	this_cpu_add(memcg->stat->count[MEMCG_SOCK], nr_pages);
+
 	if (try_charge(memcg, gfp_mask, nr_pages) == 0)
 		return true;
 
@@ -5649,6 +5653,8 @@ void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 		return;
 	}
 
+	this_cpu_sub(memcg->stat->count[MEMCG_SOCK], nr_pages);
+
 	page_counter_uncharge(&memcg->memory, nr_pages);
 	css_put_many(&memcg->css, nr_pages);
 }
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
