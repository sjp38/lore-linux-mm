Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C98996B039A
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 21:43:42 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id e12so41545292ioj.0
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 18:43:42 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0094.hostedemail.com. [216.40.44.94])
        by mx.google.com with ESMTPS id u131si1992258itf.72.2017.03.15.18.43.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 18:43:42 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/3] mm: page_alloc: Fix misordered logging output, reduce code size
Date: Wed, 15 Mar 2017 18:43:14 -0700
Message-Id: <2aaf6f1701ee78582743d91359018689d5826e82.1489628459.git.joe@perches.com>
In-Reply-To: <cover.1489628459.git.joe@perches.com>
References: <cover.1489628459.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

When CONFIG_TRANSPARENT_HUGEPAGE is set, there is an output defect
where the values emitted do not match the textual descriptions.

Reorder the arguments appropriately.

As with commit f5f93a2657ab ("mm: page_alloc: Reduce object size
by neatening printks"), register spilling occurs when there are
a large number of arguments to a function call.

$ size mm/page_alloc.o* (defconfig)
   text    data     bss     dec     hex filename
  35874    1699     628   38201    9539 mm/page_alloc.o.new
  35914    1699     628   38241    9561 mm/page_alloc.o.old

Miscellanea:

o Break up the long printk into multiple printk and printk(KERN_CONT
  calls to avoid register spilling

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 39 ++++++++++++++++++++-------------------
 1 file changed, 20 insertions(+), 19 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5db9710cb932..6816bb167394 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4540,40 +4540,41 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		       " inactive_anon:%lukB"
 		       " active_file:%lukB"
 		       " inactive_file:%lukB"
-		       " unevictable:%lukB"
-		       " isolated(anon):%lukB"
-		       " isolated(file):%lukB"
-		       " mapped:%lukB"
-		       " dirty:%lukB"
-		       " writeback:%lukB"
-		       " shmem:%lukB"
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		       " shmem_thp: %lukB"
-		       " shmem_pmdmapped: %lukB"
-		       " anon_thp: %lukB"
-#endif
-		       " writeback_tmp:%lukB"
-		       " unstable:%lukB"
-		       " all_unreclaimable? %s"
-		       "\n",
+		       " unevictable:%lukB",
 		       pgdat->node_id,
 		       K(node_page_state(pgdat, NR_ACTIVE_ANON)),
 		       K(node_page_state(pgdat, NR_INACTIVE_ANON)),
 		       K(node_page_state(pgdat, NR_ACTIVE_FILE)),
 		       K(node_page_state(pgdat, NR_INACTIVE_FILE)),
-		       K(node_page_state(pgdat, NR_UNEVICTABLE)),
+		       K(node_page_state(pgdat, NR_UNEVICTABLE)));
+		printk(KERN_CONT
+		       " isolated(anon):%lukB"
+		       " isolated(file):%lukB"
+		       " mapped:%lukB"
+		       " dirty:%lukB"
+		       " writeback:%lukB"
+		       " shmem:%lukB",
 		       K(node_page_state(pgdat, NR_ISOLATED_ANON)),
 		       K(node_page_state(pgdat, NR_ISOLATED_FILE)),
 		       K(node_page_state(pgdat, NR_FILE_MAPPED)),
 		       K(node_page_state(pgdat, NR_FILE_DIRTY)),
 		       K(node_page_state(pgdat, NR_WRITEBACK)),
+		       K(node_page_state(pgdat, NR_SHMEM)));
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		printk(KERN_CONT
+		       " shmem_thp: %lukB"
+		       " shmem_pmdmapped: %lukB"
+		       " anon_thp: %lukB",
 		       K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
 		       K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
 			 * HPAGE_PMD_NR),
-		       K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR),
+		       K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR));
 #endif
-		       K(node_page_state(pgdat, NR_SHMEM)),
+		printk(KERN_CONT
+		       " writeback_tmp:%lukB"
+		       " unstable:%lukB"
+		       " all_unreclaimable? %s"
+		       "\n",
 		       K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
 		       K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
 		       pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES ?
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
