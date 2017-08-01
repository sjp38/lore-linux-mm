Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D50F46B0551
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 09:43:11 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x64so2494288wmg.11
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 06:43:11 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z44si18633367ede.201.2017.08.01.06.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 01 Aug 2017 06:43:10 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/2] mm: fix global NR_SLAB_.*CLAIMABLE counter reads
Date: Tue,  1 Aug 2017 09:42:55 -0400
Message-Id: <20170801134256.5400-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Josef Bacik <josef@toxicpanda.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

As Tetsuo points out:

    Commit 385386cff4c6f047 ("mm: vmstat: move slab statistics from
    zone to node counters") broke "Slab:" field of /proc/meminfo . It
    shows nearly 0kB.

In addition to /proc/meminfo, this problem also affects the slab
counters OOM/allocation failure info dumps, can cause early -ENOMEM
from overcommit protection, and miscalculate image size requirements
during suspend-to-disk.

This is because the patch in question switched the slab counters from
the zone level to the node level, but forgot to update the global
accessor functions to read the aggregate node data instead of the
aggregate zone data.

Use global_node_page_state() to access the global slab counters.

Fixes: 385386cff4c6 ("mm: vmstat: move slab statistics from zone to node counters")
Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/proc/meminfo.c       | 8 ++++----
 kernel/power/snapshot.c | 2 +-
 mm/page_alloc.c         | 9 +++++----
 mm/util.c               | 2 +-
 4 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 8a428498d6b2..509a61668d90 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -106,13 +106,13 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		    global_node_page_state(NR_FILE_MAPPED));
 	show_val_kb(m, "Shmem:          ", i.sharedram);
 	show_val_kb(m, "Slab:           ",
-		    global_page_state(NR_SLAB_RECLAIMABLE) +
-		    global_page_state(NR_SLAB_UNRECLAIMABLE));
+		    global_node_page_state(NR_SLAB_RECLAIMABLE) +
+		    global_node_page_state(NR_SLAB_UNRECLAIMABLE));
 
 	show_val_kb(m, "SReclaimable:   ",
-		    global_page_state(NR_SLAB_RECLAIMABLE));
+		    global_node_page_state(NR_SLAB_RECLAIMABLE));
 	show_val_kb(m, "SUnreclaim:     ",
-		    global_page_state(NR_SLAB_UNRECLAIMABLE));
+		    global_node_page_state(NR_SLAB_UNRECLAIMABLE));
 	seq_printf(m, "KernelStack:    %8lu kB\n",
 		   global_page_state(NR_KERNEL_STACK_KB));
 	show_val_kb(m, "PageTables:     ",
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 222317721c5a..0972a8e09d08 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1650,7 +1650,7 @@ static unsigned long minimum_image_size(unsigned long saveable)
 {
 	unsigned long size;
 
-	size = global_page_state(NR_SLAB_RECLAIMABLE)
+	size = global_node_page_state(NR_SLAB_RECLAIMABLE)
 		+ global_node_page_state(NR_ACTIVE_ANON)
 		+ global_node_page_state(NR_INACTIVE_ANON)
 		+ global_node_page_state(NR_ACTIVE_FILE)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d30e914afb6..3e89731a86bd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4458,8 +4458,9 @@ long si_mem_available(void)
 	 * Part of the reclaimable slab consists of items that are in use,
 	 * and cannot be freed. Cap this estimate at the low watermark.
 	 */
-	available += global_page_state(NR_SLAB_RECLAIMABLE) -
-		     min(global_page_state(NR_SLAB_RECLAIMABLE) / 2, wmark_low);
+	available += global_node_page_state(NR_SLAB_RECLAIMABLE) -
+		     min(global_node_page_state(NR_SLAB_RECLAIMABLE) / 2,
+			 wmark_low);
 
 	if (available < 0)
 		available = 0;
@@ -4602,8 +4603,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		global_node_page_state(NR_FILE_DIRTY),
 		global_node_page_state(NR_WRITEBACK),
 		global_node_page_state(NR_UNSTABLE_NFS),
-		global_page_state(NR_SLAB_RECLAIMABLE),
-		global_page_state(NR_SLAB_UNRECLAIMABLE),
+		global_node_page_state(NR_SLAB_RECLAIMABLE),
+		global_node_page_state(NR_SLAB_UNRECLAIMABLE),
 		global_node_page_state(NR_FILE_MAPPED),
 		global_node_page_state(NR_SHMEM),
 		global_page_state(NR_PAGETABLE),
diff --git a/mm/util.c b/mm/util.c
index 7b07ec852e01..9ecddf568fe3 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -633,7 +633,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		 * which are reclaimable, under pressure.  The dentry
 		 * cache and most inode caches should fall into this
 		 */
-		free += global_page_state(NR_SLAB_RECLAIMABLE);
+		free += global_node_page_state(NR_SLAB_RECLAIMABLE);
 
 		/*
 		 * Leave reserved pages. The pages are not for anonymous pages.
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
