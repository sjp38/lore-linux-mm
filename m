Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 10C186B0038
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 11:49:41 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 89so26768125wrr.2
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 08:49:41 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s93si28707338wrc.222.2017.02.21.08.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 08:49:39 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: memcontrol: provide shmem statistics
Date: Tue, 21 Feb 2017 11:43:43 -0500
Message-Id: <20170221164343.32252-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Chris Down <cdown@fb.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Cgroups currently don't report how much shmem they use, which can be
useful data to have, in particular since shmem is included in the
cache/file item while being reclaimed like anonymous memory.

Add a counter to track shmem pages during charging and uncharging.

Reported-by: Chris Down <cdown@fb.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/cgroup-v2.txt |  5 +++++
 include/linux/memcontrol.h  |  1 +
 mm/memcontrol.c             | 28 ++++++++++++++++++++--------
 3 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index 4cc07ce3b8dd..d99389ce7b01 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -867,6 +867,11 @@ PAGE_SIZE multiple when read back.
 
 		Amount of memory used in network transmission buffers
 
+	  shmem
+
+		Amount of cached filesystem data that is swap-backed,
+		such as tmpfs, shm segments, shared anonymous mmap()s
+
 	  file_mapped
 
 		Amount of cached filesystem data mapped with mmap()
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 61d20c17f3b7..47bdf727d1ad 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -46,6 +46,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
 	MEM_CGROUP_STAT_RSS,		/* # of pages charged as anon rss */
 	MEM_CGROUP_STAT_RSS_HUGE,	/* # of pages charged as anon huge */
+	MEM_CGROUP_STAT_SHMEM,		/* # of pages charged as shmem */
 	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
 	MEM_CGROUP_STAT_DIRTY,          /* # of dirty pages in page cache */
 	MEM_CGROUP_STAT_WRITEBACK,	/* # of pages under writeback */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9c9cde768d40..49409f5c0238 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -102,6 +102,7 @@ static const char * const mem_cgroup_stat_names[] = {
 	"cache",
 	"rss",
 	"rss_huge",
+	"shmem",
 	"mapped_file",
 	"dirty",
 	"writeback",
@@ -601,9 +602,13 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 	if (PageAnon(page))
 		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS],
 				nr_pages);
-	else
+	else {
 		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_CACHE],
 				nr_pages);
+		if (PageSwapBacked(page))
+			__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SHMEM],
+				       nr_pages);
+	}
 
 	if (compound) {
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
@@ -5200,6 +5205,8 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	seq_printf(m, "sock %llu\n",
 		   (u64)stat[MEMCG_SOCK] * PAGE_SIZE);
 
+	seq_printf(m, "shmem %llu\n",
+		   (u64)stat[MEM_CGROUP_STAT_SHMEM] * PAGE_SIZE);
 	seq_printf(m, "file_mapped %llu\n",
 		   (u64)stat[MEM_CGROUP_STAT_FILE_MAPPED] * PAGE_SIZE);
 	seq_printf(m, "file_dirty %llu\n",
@@ -5468,8 +5475,8 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
 
 static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
 			   unsigned long nr_anon, unsigned long nr_file,
-			   unsigned long nr_huge, unsigned long nr_kmem,
-			   struct page *dummy_page)
+			   unsigned long nr_kmem, unsigned long nr_huge,
+			   unsigned long nr_shmem, struct page *dummy_page)
 {
 	unsigned long nr_pages = nr_anon + nr_file + nr_kmem;
 	unsigned long flags;
@@ -5487,6 +5494,7 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
 	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS], nr_anon);
 	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_CACHE], nr_file);
 	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE], nr_huge);
+	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_SHMEM], nr_shmem);
 	__this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGOUT], pgpgout);
 	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
 	memcg_check_events(memcg, dummy_page);
@@ -5499,6 +5507,7 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
 static void uncharge_list(struct list_head *page_list)
 {
 	struct mem_cgroup *memcg = NULL;
+	unsigned long nr_shmem = 0;
 	unsigned long nr_anon = 0;
 	unsigned long nr_file = 0;
 	unsigned long nr_huge = 0;
@@ -5531,9 +5540,9 @@ static void uncharge_list(struct list_head *page_list)
 		if (memcg != page->mem_cgroup) {
 			if (memcg) {
 				uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
-					       nr_huge, nr_kmem, page);
-				pgpgout = nr_anon = nr_file =
-					nr_huge = nr_kmem = 0;
+					       nr_kmem, nr_huge, nr_shmem, page);
+				pgpgout = nr_anon = nr_file = nr_kmem = 0;
+				nr_huge = nr_shmem = 0;
 			}
 			memcg = page->mem_cgroup;
 		}
@@ -5547,8 +5556,11 @@ static void uncharge_list(struct list_head *page_list)
 			}
 			if (PageAnon(page))
 				nr_anon += nr_pages;
-			else
+			else {
 				nr_file += nr_pages;
+				if (PageSwapBacked(page))
+					nr_shmem += nr_pages;
+			}
 			pgpgout++;
 		} else {
 			nr_kmem += 1 << compound_order(page);
@@ -5560,7 +5572,7 @@ static void uncharge_list(struct list_head *page_list)
 
 	if (memcg)
 		uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
-			       nr_huge, nr_kmem, page);
+			       nr_kmem, nr_huge, nr_shmem, page);
 }
 
 /**
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
