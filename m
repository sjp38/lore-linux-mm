Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2E546B02EF
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 07:00:39 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id j1-v6so392547pll.8
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 04:00:39 -0700 (PDT)
Received: from alexa-out-blr-01.qualcomm.com (alexa-out-blr-01.qualcomm.com. [103.229.18.197])
        by mx.google.com with ESMTPS id d124-v6si11312035pfd.93.2018.10.26.04.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 04:00:38 -0700 (PDT)
From: Arun KS <arunks@codeaurora.org>
Subject: [PATCH v1 1/4] mm: Fix multiple evaluvations of totalram_pages and managed_pages
Date: Fri, 26 Oct 2018 16:30:28 +0530
Message-Id: <1540551631-24208-2-git-send-email-arunks@codeaurora.org>
In-Reply-To: <1540551631-24208-1-git-send-email-arunks@codeaurora.org>
References: <1540551631-24208-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: keescook@chromium.org, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Arun KS <arunks@codeaurora.org>

This patch is in preparation to a later patch which converts totalram_pages
and zone->managed_pages to atomic variables. This patch does not introduce
any functional changes.

Signed-off-by: Arun KS <arunks@codeaurora.org>
---
 arch/um/kernel/mem.c                 |  3 +--
 arch/x86/kernel/cpu/microcode/core.c |  5 +++--
 drivers/hv/hv_balloon.c              | 19 ++++++++++---------
 fs/file_table.c                      |  7 ++++---
 kernel/fork.c                        |  5 +++--
 kernel/kexec_core.c                  |  5 +++--
 mm/page_alloc.c                      |  5 +++--
 mm/shmem.c                           |  3 ++-
 net/dccp/proto.c                     |  7 ++++---
 net/netfilter/nf_conntrack_core.c    |  7 ++++---
 net/netfilter/xt_hashlimit.c         |  5 +++--
 net/sctp/protocol.c                  |  7 ++++---
 12 files changed, 44 insertions(+), 34 deletions(-)

diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 1067469..134d3fd 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -51,8 +51,7 @@ void __init mem_init(void)
 
 	/* this will put all low memory onto the freelists */
 	memblock_free_all();
-	max_low_pfn = totalram_pages;
-	max_pfn = totalram_pages;
+	max_pfn = max_low_pfn = totalram_pages;
 	mem_init_print_info(NULL);
 	kmalloc_ok = 1;
 }
diff --git a/arch/x86/kernel/cpu/microcode/core.c b/arch/x86/kernel/cpu/microcode/core.c
index 2637ff0..99c67ca 100644
--- a/arch/x86/kernel/cpu/microcode/core.c
+++ b/arch/x86/kernel/cpu/microcode/core.c
@@ -434,9 +434,10 @@ static ssize_t microcode_write(struct file *file, const char __user *buf,
 			       size_t len, loff_t *ppos)
 {
 	ssize_t ret = -EINVAL;
+	unsigned long totalram_pgs = totalram_pages;
 
-	if ((len >> PAGE_SHIFT) > totalram_pages) {
-		pr_err("too much data (max %ld pages)\n", totalram_pages);
+	if ((len >> PAGE_SHIFT) > totalram_pgs) {
+		pr_err("too much data (max %ld pages)\n", totalram_pgs);
 		return ret;
 	}
 
diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index c5bc0b5..2a60f9a 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -1092,6 +1092,7 @@ static void process_info(struct hv_dynmem_device *dm, struct dm_info_msg *msg)
 static unsigned long compute_balloon_floor(void)
 {
 	unsigned long min_pages;
+	unsigned long totalram_pgs = totalram_pages;
 #define MB2PAGES(mb) ((mb) << (20 - PAGE_SHIFT))
 	/* Simple continuous piecewiese linear function:
 	 *  max MiB -> min MiB  gradient
@@ -1104,16 +1105,16 @@ static unsigned long compute_balloon_floor(void)
 	 *    8192       744    (1/16)
 	 *   32768      1512	(1/32)
 	 */
-	if (totalram_pages < MB2PAGES(128))
-		min_pages = MB2PAGES(8) + (totalram_pages >> 1);
-	else if (totalram_pages < MB2PAGES(512))
-		min_pages = MB2PAGES(40) + (totalram_pages >> 2);
-	else if (totalram_pages < MB2PAGES(2048))
-		min_pages = MB2PAGES(104) + (totalram_pages >> 3);
-	else if (totalram_pages < MB2PAGES(8192))
-		min_pages = MB2PAGES(232) + (totalram_pages >> 4);
+	if (totalram_pgs < MB2PAGES(128))
+		min_pages = MB2PAGES(8) + (totalram_pgs >> 1);
+	else if (totalram_pgs < MB2PAGES(512))
+		min_pages = MB2PAGES(40) + (totalram_pgs >> 2);
+	else if (totalram_pgs < MB2PAGES(2048))
+		min_pages = MB2PAGES(104) + (totalram_pgs >> 3);
+	else if (totalram_pgs < MB2PAGES(8192))
+		min_pages = MB2PAGES(232) + (totalram_pgs >> 4);
 	else
-		min_pages = MB2PAGES(488) + (totalram_pages >> 5);
+		min_pages = MB2PAGES(488) + (totalram_pgs >> 5);
 #undef MB2PAGES
 	return min_pages;
 }
diff --git a/fs/file_table.c b/fs/file_table.c
index e03c8d1..5d36655 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -383,10 +383,11 @@ void __init files_init(void)
 void __init files_maxfiles_init(void)
 {
 	unsigned long n;
-	unsigned long memreserve = (totalram_pages - nr_free_pages()) * 3/2;
+	unsigned long totalram_pgs = totalram_pages;
+	unsigned long memreserve = (totalram_pgs - nr_free_pages()) * 3/2;
 
-	memreserve = min(memreserve, totalram_pages - 1);
-	n = ((totalram_pages - memreserve) * (PAGE_SIZE / 1024)) / 10;
+	memreserve = min(memreserve, totalram_pgs - 1);
+	n = ((totalram_pgs - memreserve) * (PAGE_SIZE / 1024)) / 10;
 
 	files_stat.max_files = max_t(unsigned long, n, NR_FILE);
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index 2f78d32..63d57f7 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -739,15 +739,16 @@ void __init __weak arch_task_cache_init(void) { }
 static void set_max_threads(unsigned int max_threads_suggested)
 {
 	u64 threads;
+	unsigned long totalram_pgs = totalram_pages;
 
 	/*
 	 * The number of threads shall be limited such that the thread
 	 * structures may only consume a small part of the available memory.
 	 */
-	if (fls64(totalram_pages) + fls64(PAGE_SIZE) > 64)
+	if (fls64(totalram_pgs) + fls64(PAGE_SIZE) > 64)
 		threads = MAX_THREADS;
 	else
-		threads = div64_u64((u64) totalram_pages * (u64) PAGE_SIZE,
+		threads = div64_u64((u64) totalram_pgs * (u64) PAGE_SIZE,
 				    (u64) THREAD_SIZE * 8UL);
 
 	if (threads > max_threads_suggested)
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 86ef06d..dff217c 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -152,6 +152,7 @@ int sanity_check_segment_list(struct kimage *image)
 	int i;
 	unsigned long nr_segments = image->nr_segments;
 	unsigned long total_pages = 0;
+	unsigned long totalram_pgs = totalram_pages;
 
 	/*
 	 * Verify we have good destination addresses.  The caller is
@@ -217,13 +218,13 @@ int sanity_check_segment_list(struct kimage *image)
 	 * wasted allocating pages, which can cause a soft lockup.
 	 */
 	for (i = 0; i < nr_segments; i++) {
-		if (PAGE_COUNT(image->segment[i].memsz) > totalram_pages / 2)
+		if (PAGE_COUNT(image->segment[i].memsz) > totalram_pgs / 2)
 			return -EINVAL;
 
 		total_pages += PAGE_COUNT(image->segment[i].memsz);
 	}
 
-	if (total_pages > totalram_pages / 2)
+	if (total_pages > totalram_pgs / 2)
 		return -EINVAL;
 
 	/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4bd858d..f045191 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7243,6 +7243,7 @@ static void calculate_totalreserve_pages(void)
 		for (i = 0; i < MAX_NR_ZONES; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 			long max = 0;
+			unsigned long managed_pages = zone->managed_pages;
 
 			/* Find valid and maximum lowmem_reserve in the zone */
 			for (j = i; j < MAX_NR_ZONES; j++) {
@@ -7253,8 +7254,8 @@ static void calculate_totalreserve_pages(void)
 			/* we treat the high watermark as reserved pages. */
 			max += high_wmark_pages(zone);
 
-			if (max > zone->managed_pages)
-				max = zone->managed_pages;
+			if (max > managed_pages)
+				max = managed_pages;
 
 			pgdat->totalreserve_pages += max;
 
diff --git a/mm/shmem.c b/mm/shmem.c
index a6964ba..6556e86 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -114,7 +114,8 @@ static unsigned long shmem_default_max_blocks(void)
 
 static unsigned long shmem_default_max_inodes(void)
 {
-	return min(totalram_pages - totalhigh_pages, totalram_pages / 2);
+	unsigned long totalram_pgs = totalram_pages;
+	return min(totalram_pgs - totalhigh_pages, totalram_pgs / 2);
 }
 #endif
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 875858c..0cef31e 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1131,6 +1131,7 @@ static inline void dccp_mib_exit(void)
 static int __init dccp_init(void)
 {
 	unsigned long goal;
+	unsigned long totalram_pgs = totalram_pages;
 	int ehash_order, bhash_order, i;
 	int rc;
 
@@ -1154,10 +1155,10 @@ static int __init dccp_init(void)
 	 *
 	 * The methodology is similar to that of the buffer cache.
 	 */
-	if (totalram_pages >= (128 * 1024))
-		goal = totalram_pages >> (21 - PAGE_SHIFT);
+	if (totalram_pgs >= (128 * 1024))
+		goal = totalram_pgs >> (21 - PAGE_SHIFT);
 	else
-		goal = totalram_pages >> (23 - PAGE_SHIFT);
+		goal = totalram_pgs >> (23 - PAGE_SHIFT);
 
 	if (thash_entries)
 		goal = (thash_entries *
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ca1168d..0b1801e 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -2248,6 +2248,7 @@ static __always_inline unsigned int total_extension_size(void)
 
 int nf_conntrack_init_start(void)
 {
+	unsigned long totalram_pgs = totalram_pages;
 	int max_factor = 8;
 	int ret = -ENOMEM;
 	int i;
@@ -2267,11 +2268,11 @@ int nf_conntrack_init_start(void)
 		 * >= 4GB machines have 65536 buckets.
 		 */
 		nf_conntrack_htable_size
-			= (((totalram_pages << PAGE_SHIFT) / 16384)
+			= (((totalram_pgs << PAGE_SHIFT) / 16384)
 			   / sizeof(struct hlist_head));
-		if (totalram_pages > (4 * (1024 * 1024 * 1024 / PAGE_SIZE)))
+		if (totalram_pgs > (4 * (1024 * 1024 * 1024 / PAGE_SIZE)))
 			nf_conntrack_htable_size = 65536;
-		else if (totalram_pages > (1024 * 1024 * 1024 / PAGE_SIZE))
+		else if (totalram_pgs > (1024 * 1024 * 1024 / PAGE_SIZE))
 			nf_conntrack_htable_size = 16384;
 		if (nf_conntrack_htable_size < 32)
 			nf_conntrack_htable_size = 32;
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 3e7d259..6cb9a74 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -274,14 +274,15 @@ static int htable_create(struct net *net, struct hashlimit_cfg3 *cfg,
 	struct xt_hashlimit_htable *hinfo;
 	const struct seq_operations *ops;
 	unsigned int size, i;
+	unsigned long totalram_pgs = totalram_pages;
 	int ret;
 
 	if (cfg->size) {
 		size = cfg->size;
 	} else {
-		size = (totalram_pages << PAGE_SHIFT) / 16384 /
+		size = (totalram_pgs << PAGE_SHIFT) / 16384 /
 		       sizeof(struct hlist_head);
-		if (totalram_pages > 1024 * 1024 * 1024 / PAGE_SIZE)
+		if (totalram_pgs > 1024 * 1024 * 1024 / PAGE_SIZE)
 			size = 8192;
 		if (size < 16)
 			size = 16;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 9b277bd..7128f85 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1368,6 +1368,7 @@ static __init int sctp_init(void)
 	int status = -EINVAL;
 	unsigned long goal;
 	unsigned long limit;
+	unsigned long totalram_pages;
 	int max_share;
 	int order;
 	int num_entries;
@@ -1426,10 +1427,10 @@ static __init int sctp_init(void)
 	 * The methodology is similar to that of the tcp hash tables.
 	 * Though not identical.  Start by getting a goal size
 	 */
-	if (totalram_pages >= (128 * 1024))
-		goal = totalram_pages >> (22 - PAGE_SHIFT);
+	if (totalram_pgs >= (128 * 1024))
+		goal = totalram_pgs >> (22 - PAGE_SHIFT);
 	else
-		goal = totalram_pages >> (24 - PAGE_SHIFT);
+		goal = totalram_pgs >> (24 - PAGE_SHIFT);
 
 	/* Then compute the page order for said goal */
 	order = get_order(goal);
-- 
1.9.1
