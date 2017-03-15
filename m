Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9032C6B0390
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 05:00:05 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o126so21520070pfb.2
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 02:00:05 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n16si1050996pfk.309.2017.03.15.02.00.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 02:00:04 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v2 5/5] mm: add debugfs interface for parallel free tuning
Date: Wed, 15 Mar 2017 17:00:04 +0800
Message-Id: <1489568404-7817-6-git-send-email-aaron.lu@intel.com>
In-Reply-To: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>

Make it possible to set different values for async_free_threshold and
max_gather_batch_count through debugfs.

With this, we can do tests for different purposes:
1 Restore vanilla kernel bahaviour for performance comparison.
  Set max_gather_batch_count to a value like 20 to effectively restore
  the behaviour of vanilla kernel since this will make page gathered
  always smaller than async_free_threshold(effectively disable parallel
  free);
2 Debug purpose.
  Set async_free_threshold to a very small value(like 128) to trigger
  parallel free even on ordinary processes, ideal for debug purpose with
  a virtual machine that doesn't have much memory assigned to it;
3 Performance tuning.
  Use a different value for async_free_threshold and max_gather_batch_count
  other than the default to test if parallel free performs better or worse.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/memory.c | 33 +++++++++++++++++++++++++++++++--
 1 file changed, 31 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 83b38823aaba..3a971cc1fc3b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -183,6 +183,35 @@ static void check_sync_rss_stat(struct task_struct *task)
 
 #ifdef HAVE_GENERIC_MMU_GATHER
 
+static unsigned long async_free_threshold = ASYNC_FREE_THRESHOLD;
+static unsigned long max_gather_batch_count = MAX_GATHER_BATCH_COUNT;
+
+#ifdef CONFIG_DEBUG_FS
+static int __init tlb_mmu_parallel_free_debugfs(void)
+{
+	umode_t mode = 0644;
+	struct dentry *dir;
+
+	dir = debugfs_create_dir("parallel_free", NULL);
+	if (!dir)
+		return -ENOMEM;
+
+	if (!debugfs_create_ulong("async_free_threshold", mode, dir,
+				&async_free_threshold))
+		goto fail;
+	if (!debugfs_create_ulong("max_gather_batch_count", mode, dir,
+				&max_gather_batch_count))
+		goto fail;
+
+	return 0;
+
+fail:
+	debugfs_remove_recursive(dir);
+	return -ENOMEM;
+}
+late_initcall(tlb_mmu_parallel_free_debugfs);
+#endif
+
 static bool tlb_next_batch(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
@@ -193,7 +222,7 @@ static bool tlb_next_batch(struct mmu_gather *tlb)
 		return true;
 	}
 
-	if (tlb->batch_count == MAX_GATHER_BATCH_COUNT)
+	if (tlb->batch_count == max_gather_batch_count)
 		return false;
 
 	batch = (void *)__get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
@@ -307,7 +336,7 @@ static void tlb_flush_mmu_free(struct mmu_gather *tlb)
 {
 	struct batch_free_struct *batch_free = NULL;
 
-	if (tlb->page_nr >= ASYNC_FREE_THRESHOLD)
+	if (tlb->page_nr >= async_free_threshold)
 		batch_free = kmalloc(sizeof(*batch_free),
 				     GFP_NOWAIT | __GFP_NOWARN);
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
