Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F16106B0008
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 03:01:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h76-v6so445052pfd.10
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 00:01:45 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id z7-v6si17186280pgi.178.2018.10.09.00.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 00:01:44 -0700 (PDT)
Date: Tue, 9 Oct 2018 00:01:25 -0700
From: tip-bot for Srikar Dronamraju <tipbot@zytor.com>
Message-ID: <tip-e054637597ba36d3729ba6a3a3dd7aad8e2a3003@git.kernel.org>
Reply-To: peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org,
        mgorman@techsingularity.net, riel@surriel.com, linux-mm@kvack.org,
        torvalds@linux-foundation.org, tglx@linutronix.de,
        srikar@linux.vnet.ibm.com, hpa@zytor.com
In-Reply-To: <1538824999-31230-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1538824999-31230-1-git-send-email-srikar@linux.vnet.ibm.com>
Subject: [tip:sched/urgent] mm, sched/numa: Remove remaining traces of NUMA
 rate-limiting
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: mgorman@techsingularity.net, linux-kernel@vger.kernel.org, mingo@kernel.org, peterz@infradead.org, linux-mm@kvack.org, riel@surriel.com, tglx@linutronix.de, torvalds@linux-foundation.org, hpa@zytor.com, srikar@linux.vnet.ibm.com

Commit-ID:  e054637597ba36d3729ba6a3a3dd7aad8e2a3003
Gitweb:     https://git.kernel.org/tip/e054637597ba36d3729ba6a3a3dd7aad8e2a3003
Author:     Srikar Dronamraju <srikar@linux.vnet.ibm.com>
AuthorDate: Sat, 6 Oct 2018 16:53:19 +0530
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Tue, 9 Oct 2018 08:30:51 +0200

mm, sched/numa: Remove remaining traces of NUMA rate-limiting

Remove the leftover pglist_data::numabalancing_migrate_lock and its
initialization, we stopped using this lock with:

  efaffc5e40ae ("mm, sched/numa: Remove rate-limiting of automatic NUMA balancing migration")

[ mingo: Rewrote the changelog. ]

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Link: http://lkml.kernel.org/r/1538824999-31230-1-git-send-email-srikar@linux.vnet.ibm.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/mmzone.h |  4 ----
 mm/page_alloc.c        | 10 ----------
 2 files changed, 14 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3f4c0b167333..d4b0c79d2924 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -667,10 +667,6 @@ typedef struct pglist_data {
 	enum zone_type kcompactd_classzone_idx;
 	wait_queue_head_t kcompactd_wait;
 	struct task_struct *kcompactd;
-#endif
-#ifdef CONFIG_NUMA_BALANCING
-	/* Lock serializing the migrate rate limiting window */
-	spinlock_t numabalancing_migrate_lock;
 #endif
 	/*
 	 * This is a per-node reserve of pages that are not available
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 706a738c0aee..e2ef1c17942f 100644
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
 
