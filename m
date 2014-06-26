Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id C6AC96B00A6
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 16:01:09 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id u56so4323154wes.35
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 13:01:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cq8si14276001wib.49.2014.06.26.13.01.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jun 2014 13:01:08 -0700 (PDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v2] mm: export NR_SHMEM via sysinfo(2) / si_meminfo() interfaces
Date: Thu, 26 Jun 2014 17:00:17 -0300
Message-Id: <198dc298821a20a476656dccc85a8d77f166c61a.1403812625.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

Historically, we exported shared pages to userspace via sysinfo(2) sharedram
and /proc/meminfo's "MemShared" fields. With the advent of tmpfs, from kernel
v2.4 onward, that old way for accounting shared mem was deemed inaccurate and
we started to export a hard-coded 0 for sysinfo.sharedram. Later on, during
the 2.6 timeframe, "MemShared" got re-introduced to /proc/meminfo re-branded
as "Shmem", but we're still reporting sysinfo.sharedmem as that old hard-coded
zero, which makes the "shared memory" report inconsistent across interfaces.

This patch leverages the addition of explicit accounting for pages used by
shmem/tmpfs -- "4b02108 mm: oom analysis: add shmem vmstat" -- in order to
make the users of sysinfo(2) and si_meminfo*() friends aware of that
vmstat entry and make them report it consistently across the interfaces,
as well to make sysinfo(2) returned data consistent with our current API
documentation states.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
Changelog from v1:
- updated commit log message to include historical context       (kosaki-san)

 drivers/base/node.c | 2 +-
 fs/proc/meminfo.c   | 2 +-
 mm/page_alloc.c     | 3 ++-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 8f7ed99..c6d3ae0 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -126,7 +126,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
-		       nid, K(node_page_state(nid, NR_SHMEM)),
+		       nid, K(i.sharedram),
 		       nid, node_page_state(nid, NR_KERNEL_STACK) *
 				THREAD_SIZE / 1024,
 		       nid, K(node_page_state(nid, NR_PAGETABLE)),
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 7445af0..aa1eee0 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -168,7 +168,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		K(global_page_state(NR_WRITEBACK)),
 		K(global_page_state(NR_ANON_PAGES)),
 		K(global_page_state(NR_FILE_MAPPED)),
-		K(global_page_state(NR_SHMEM)),
+		K(i.sharedram),
 		K(global_page_state(NR_SLAB_RECLAIMABLE) +
 				global_page_state(NR_SLAB_UNRECLAIMABLE)),
 		K(global_page_state(NR_SLAB_RECLAIMABLE)),
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 20d17f8..f72ea38 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3040,7 +3040,7 @@ static inline void show_node(struct zone *zone)
 void si_meminfo(struct sysinfo *val)
 {
 	val->totalram = totalram_pages;
-	val->sharedram = 0;
+	val->sharedram = global_page_state(NR_SHMEM);
 	val->freeram = global_page_state(NR_FREE_PAGES);
 	val->bufferram = nr_blockdev_pages();
 	val->totalhigh = totalhigh_pages;
@@ -3060,6 +3060,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
 		managed_pages += pgdat->node_zones[zone_type].managed_pages;
 	val->totalram = managed_pages;
+	val->sharedram = node_page_state(nid, NR_SHMEM);
 	val->freeram = node_page_state(nid, NR_FREE_PAGES);
 #ifdef CONFIG_HIGHMEM
 	val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].managed_pages;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
