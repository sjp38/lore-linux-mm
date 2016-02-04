Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EACBF4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 08:03:57 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id o185so44645874pfb.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 05:03:57 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id i13si16617000pat.171.2016.02.04.05.03.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 05:03:57 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 3/3] mm: memcontrol: report kernel stack usage in cgroup2 memory.stat
Date: Thu, 4 Feb 2016 16:03:39 +0300
Message-ID: <1d7473a8f8b814e536f9fdbd29d90591f1952f73.1454589800.git.vdavydov@virtuozzo.com>
In-Reply-To: <57ff0330b597738127ae0f9ca331016719bea7d8.1454589800.git.vdavydov@virtuozzo.com>
References: <57ff0330b597738127ae0f9ca331016719bea7d8.1454589800.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Show how much memory is allocated to kernel stacks.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 Documentation/cgroup-v2.txt |  4 ++++
 include/linux/memcontrol.h  |  1 +
 kernel/fork.c               | 10 +++++++++-
 mm/memcontrol.c             |  2 ++
 4 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index e4e0c1d78cee..e2f4e7948a66 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -843,6 +843,10 @@ PAGE_SIZE multiple when read back.
 		Amount of memory used to cache filesystem data,
 		including tmpfs and shared memory.
 
+	  kernel_stack
+
+		Amount of memory allocated to kernel stacks.
+
 	  slab
 
 		Amount of memory used for storing in-kernel data
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e7af4834ffea..aaf564881303 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -55,6 +55,7 @@ enum mem_cgroup_stat_index {
 	MEMCG_SOCK = MEM_CGROUP_STAT_NSTATS,
 	MEMCG_SLAB_RECLAIMABLE,
 	MEMCG_SLAB_UNRECLAIMABLE,
+	MEMCG_KERNEL_STACK,
 	MEMCG_NR_STAT,
 };
 
diff --git a/kernel/fork.c b/kernel/fork.c
index f9c2a24615c1..e439932b82fa 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -164,12 +164,20 @@ static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
 	struct page *page = alloc_kmem_pages_node(node, THREADINFO_GFP,
 						  THREAD_SIZE_ORDER);
 
+	if (page)
+		memcg_kmem_update_page_stat(page, MEMCG_KERNEL_STACK,
+					    1 << THREAD_SIZE_ORDER);
+
 	return page ? page_address(page) : NULL;
 }
 
 static inline void free_thread_info(struct thread_info *ti)
 {
-	free_kmem_pages((unsigned long)ti, THREAD_SIZE_ORDER);
+	struct page *page = virt_to_page(ti);
+
+	memcg_kmem_update_page_stat(page, MEMCG_KERNEL_STACK,
+				    -(1 << THREAD_SIZE_ORDER));
+	__free_kmem_pages(page, THREAD_SIZE_ORDER);
 }
 # else
 static struct kmem_cache *thread_info_cache;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b198ed5a8928..59f74074c04c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5100,6 +5100,8 @@ static int memory_stat_show(struct seq_file *m, void *v)
 		   (u64)stat[MEM_CGROUP_STAT_RSS] * PAGE_SIZE);
 	seq_printf(m, "file %llu\n",
 		   (u64)stat[MEM_CGROUP_STAT_CACHE] * PAGE_SIZE);
+	seq_printf(m, "kernel_stack %llu\n",
+		   (u64)stat[MEMCG_KERNEL_STACK] * PAGE_SIZE);
 	seq_printf(m, "slab %llu\n",
 		   (u64)(stat[MEMCG_SLAB_RECLAIMABLE] +
 			 stat[MEMCG_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
