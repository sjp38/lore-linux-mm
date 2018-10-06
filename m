Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 48D4D6B000A
	for <linux-mm@kvack.org>; Sat,  6 Oct 2018 07:23:51 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id r68-v6so10577284oie.12
        for <linux-mm@kvack.org>; Sat, 06 Oct 2018 04:23:51 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b23si5396676otb.226.2018.10.06.04.23.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Oct 2018 04:23:49 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w96BNflu132353
	for <linux-mm@kvack.org>; Sat, 6 Oct 2018 07:23:48 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mxqcq2duj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 06 Oct 2018 07:23:48 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Sat, 6 Oct 2018 12:23:46 +0100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [PATCH] mm,numa: Remove remaining traces of rate-limiting.
Date: Sat,  6 Oct 2018 16:53:19 +0530
Message-Id: <1538824999-31230-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@surriel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>

With Commit efaffc5e40ae ("mm, sched/numa: Remove rate-limiting of automatic
NUMA balancing migration"), we no more require migrate lock and its
initialization. Its redundant. Hence remove it.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/mmzone.h |  4 ----
 mm/page_alloc.c        | 10 ----------
 2 files changed, 14 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3f4c0b1..d4b0c79 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -668,10 +668,6 @@ typedef struct pglist_data {
 	wait_queue_head_t kcompactd_wait;
 	struct task_struct *kcompactd;
 #endif
-#ifdef CONFIG_NUMA_BALANCING
-	/* Lock serializing the migrate rate limiting window */
-	spinlock_t numabalancing_migrate_lock;
-#endif
 	/*
 	 * This is a per-node reserve of pages that are not available
 	 * to userspace allocations.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 706a738..e2ef1c1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6193,15 +6193,6 @@ static unsigned long __init calc_memmap_size(unsigned long spanned_pages,
 	return PAGE_ALIGN(pages * sizeof(struct page)) >> PAGE_SHIFT;
 }
 
-#ifdef CONFIG_NUMA_BALANCING
-static void pgdat_init_numabalancing(struct pglist_data *pgdat)
-{
-	spin_lock_init(&pgdat->numabalancing_migrate_lock);
-}
-#else
-static void pgdat_init_numabalancing(struct pglist_data *pgdat) {}
-#endif
-
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 static void pgdat_init_split_queue(struct pglist_data *pgdat)
 {
@@ -6226,7 +6217,6 @@ static void __meminit pgdat_init_internals(struct pglist_data *pgdat)
 {
 	pgdat_resize_init(pgdat);
 
-	pgdat_init_numabalancing(pgdat);
 	pgdat_init_split_queue(pgdat);
 	pgdat_init_kcompactd(pgdat);
 
-- 
2.7.4
