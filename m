Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 752956B025F
	for <linux-mm@kvack.org>; Sun,  6 Aug 2017 20:04:17 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v102so12754160wrb.2
        for <linux-mm@kvack.org>; Sun, 06 Aug 2017 17:04:17 -0700 (PDT)
Received: from mail.kmu-office.ch (mail.kmu-office.ch. [2a02:418:6a02::a2])
        by mx.google.com with ESMTPS id r6si8860804edb.546.2017.08.06.17.04.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Aug 2017 17:04:16 -0700 (PDT)
From: Stefan Agner <stefan@agner.ch>
Subject: [PATCH] mm: vmstat: get slab statistics always from node counters
Date: Sun,  6 Aug 2017 17:04:09 -0700
Message-Id: <20170807000409.2423-1-stefan@agner.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stefan Agner <stefan@agner.ch>

After the move of slab statistics from zone to node counters some
users still try to get the counters from the zone counters. This has
been caught while compiling with clang printing a warning like:

  implicit conversion from enumeration type 'enum node_stat_item' to
  different enumeration type 'enum zone_stat_item' [-Wenum-conversion]

Fixes: 385386cff4 ("mm: vmstat: move slab statistics from zone to node counters")
Signed-off-by: Stefan Agner <stefan@agner.ch>
---
 kernel/power/snapshot.c | 2 +-
 mm/page_alloc.c         | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

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
index 6d30e914afb6..10aa91b58487 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4458,8 +4458,8 @@ long si_mem_available(void)
 	 * Part of the reclaimable slab consists of items that are in use,
 	 * and cannot be freed. Cap this estimate at the low watermark.
 	 */
-	available += global_page_state(NR_SLAB_RECLAIMABLE) -
-		     min(global_page_state(NR_SLAB_RECLAIMABLE) / 2, wmark_low);
+	available += global_node_page_state(NR_SLAB_RECLAIMABLE) -
+		     min(global_node_page_state(NR_SLAB_RECLAIMABLE) / 2, wmark_low);
 
 	if (available < 0)
 		available = 0;
@@ -4602,8 +4602,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
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
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
