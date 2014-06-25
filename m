Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id C5A416B0035
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 14:40:24 -0400 (EDT)
Received: by mail-vc0-f180.google.com with SMTP id im17so2319972vcb.25
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 11:40:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id yx20si875631vcb.70.2014.06.25.11.40.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jun 2014 11:40:23 -0700 (PDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH] mm: export NR_SHMEM via sysinfo(2) / si_meminfo() interfaces
Date: Wed, 25 Jun 2014 15:39:49 -0300
Message-Id: <4b46c5b21263c446923caf3da3f0dca6febc7b55.1403709665.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org

This patch leverages the addition of explicit accounting for pages used by
shmem/tmpfs -- "4b02108 mm: oom analysis: add shmem vmstat" -- in order to
make the users of sysinfo(2) and si_meminfo*() friends aware of that
vmstat entry consistently across the interfaces.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
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
