Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id C41A76B0070
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 06:43:08 -0400 (EDT)
Received: by wiax7 with SMTP id x7so108895122wia.0
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 03:43:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id he1si9308147wib.34.2015.04.15.03.43.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 03:43:04 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/4] mm: Gather more PFNs before sending a TLB to flush unmapped pages
Date: Wed, 15 Apr 2015 11:42:55 +0100
Message-Id: <1429094576-5877-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1429094576-5877-1-git-send-email-mgorman@suse.de>
References: <1429094576-5877-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The patch "mm: Send a single IPI to TLB flush multiple pages when unmapping"
would batch 32 pages before sending an IPI. This patch increases the size of
the data structure to hold a pages worth of PFNs before sending an IPI. This
is a trade-off between memory usage and reducing IPIS sent. In the ideal
case where multiple processes are reading large mapped files, this patch
reduces interrupts/second from roughly 180K per second to 60K per second.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 9d51841806f4..abff66ecc302 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1275,11 +1275,16 @@ enum perf_event_task_context {
 	perf_nr_task_contexts,
 };
 
-/* Matches SWAP_CLUSTER_MAX but refined to limit header dependencies */
-#define BATCH_TLBFLUSH_SIZE 32UL
+/*
+ * Use a page to store as many PFNs as possible for batch unmapping. Adjusting
+ * this trades memory usage for number of IPIs sent
+ */
+#define BATCH_TLBFLUSH_SIZE \
+	((PAGE_SIZE - sizeof(struct cpumask) - sizeof(unsigned long)) / sizeof(unsigned long))
 
 /* Track pages that require TLB flushes */
 struct unmap_batch {
+	/* Update BATCH_TLBFLUSH_SIZE when adjusting this structure */
 	struct cpumask cpumask;
 	unsigned long nr_pages;
 	unsigned long pfns[BATCH_TLBFLUSH_SIZE];
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
