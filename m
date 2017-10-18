Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6869C6B0261
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 02:31:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h28so2869670pfh.16
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 23:31:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t14sor3754645plm.54.2017.10.17.23.31.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Oct 2017 23:31:39 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [rfc 2/2] smaps: Show zone device memory used
Date: Wed, 18 Oct 2017 17:31:23 +1100
Message-Id: <20171018063123.21983-2-bsingharora@gmail.com>
In-Reply-To: <20171018063123.21983-1-bsingharora@gmail.com>
References: <20171018063123.21983-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, mhocko@suse.com, Balbir Singh <bsingharora@gmail.com>

With HMM, we can have either public or private zone
device pages. With private zone device pages, they should
show up as swapped entities. For public zone device pages
the smaps output can be confusing and incomplete.

This patch adds a new attribute to just smaps to show
device memory usage.

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 fs/proc/task_mmu.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 9f1e2b2b5f5a..b7f32f42ee93 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -451,6 +451,7 @@ struct mem_size_stats {
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
 	unsigned long first_vma_start;
+	unsigned long device_memory;
 	u64 pss;
 	u64 pss_locked;
 	u64 swap_pss;
@@ -463,12 +464,22 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 	int i, nr = compound ? 1 << compound_order(page) : 1;
 	unsigned long size = nr * PAGE_SIZE;
 
+	/*
+	 * We don't want to process public zone device pages further
+	 * than just showing how much device memory we have
+	 */
+	if (is_zone_device_page(page)) {
+		mss->device_memory += size;
+		return;
+	}
+
 	if (PageAnon(page)) {
 		mss->anonymous += size;
 		if (!PageSwapBacked(page) && !dirty && !PageDirty(page))
 			mss->lazyfree += size;
 	}
 
+
 	mss->resident += size;
 	/* Accumulate the size in pages that have been accessed. */
 	if (young || page_is_young(page) || PageReferenced(page))
@@ -833,7 +844,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 			   "Private_Hugetlb: %7lu kB\n"
 			   "Swap:           %8lu kB\n"
 			   "SwapPss:        %8lu kB\n"
-			   "Locked:         %8lu kB\n",
+			   "Locked:         %8lu kB\n"
+			   "DeviceMem:      %8lu kB\n",
 			   mss->resident >> 10,
 			   (unsigned long)(mss->pss >> (10 + PSS_SHIFT)),
 			   mss->shared_clean  >> 10,
@@ -849,7 +861,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 			   mss->private_hugetlb >> 10,
 			   mss->swap >> 10,
 			   (unsigned long)(mss->swap_pss >> (10 + PSS_SHIFT)),
-			   (unsigned long)(mss->pss >> (10 + PSS_SHIFT)));
+			   (unsigned long)(mss->pss >> (10 + PSS_SHIFT)),
+			   mss->device_memory >> 10);
 
 	if (!rollup_mode) {
 		arch_show_smap(m, vma);
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
