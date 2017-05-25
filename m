Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2AC196B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 20:59:22 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e7so203864787pfk.9
        for <linux-mm@kvack.org>; Wed, 24 May 2017 17:59:22 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id q5si1852398pgs.129.2017.05.24.17.59.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 17:59:21 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v6] mm, swap: Sort swap entries before free
Date: Thu, 25 May 2017 08:59:16 +0800
Message-Id: <20170525005916.25249-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

To reduce the lock contention of swap_info_struct->lock when freeing
swap entry.  The freed swap entries will be collected in a per-CPU
buffer firstly, and be really freed later in batch.  During the batch
freeing, if the consecutive swap entries in the per-CPU buffer belongs
to same swap device, the swap_info_struct->lock needs to be
acquired/released only once, so that the lock contention could be
reduced greatly.  But if there are multiple swap devices, it is
possible that the lock may be unnecessarily released/acquired because
the swap entries belong to the same swap device are non-consecutive in
the per-CPU buffer.

To solve the issue, the per-CPU buffer is sorted according to the swap
device before freeing the swap entries.

With the patch, the memory (some swapped out) free time reduced
11.6% (from 2.65s to 2.35s) in the vm-scalability swap-w-rand test
case with 16 processes.  The test is done on a Xeon E5 v3 system.  The
swap device used is a RAM simulated PMEM (persistent memory) device.
To test swapping, the test case creates 16 processes, which allocate
and write to the anonymous pages until the RAM and part of the swap
device is used up, finally the memory (some swapped out) is freed
before exit.

Signed-off-by: Huang Ying <ying.huang@intel.com>
Acked-by: Tim Chen <tim.c.chen@intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>

v6:

- Revert to a simpler way to determine whether sort is necessary,
  because it is found the overhead of sort is very small.

v5:

- Use a smarter way to determine whether sort is necessary.

v4:

- Avoid unnecessary sort if all entries are from one swap device.

v3:

- Add some comments in code per Rik's suggestion.

v2:

- Avoid sort swap entries if there is only one swap device.
---
 mm/swapfile.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8a6cdf9e55f9..07b1a3d4910a 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -37,6 +37,7 @@
 #include <linux/swapfile.h>
 #include <linux/export.h>
 #include <linux/swap_slots.h>
+#include <linux/sort.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -1198,6 +1199,13 @@ void put_swap_page(struct page *page, swp_entry_t entry)
 		swapcache_free_cluster(entry);
 }
 
+static int swp_entry_cmp(const void *ent1, const void *ent2)
+{
+	const swp_entry_t *e1 = ent1, *e2 = ent2;
+
+	return (int)swp_type(*e1) - (int)swp_type(*e2);
+}
+
 void swapcache_free_entries(swp_entry_t *entries, int n)
 {
 	struct swap_info_struct *p, *prev;
@@ -1208,6 +1216,15 @@ void swapcache_free_entries(swp_entry_t *entries, int n)
 
 	prev = NULL;
 	p = NULL;
+
+	/*
+	 * Sort swap entries by swap device, so each lock is only
+	 * taken once.  Although nr_swapfiles isn't absolute correct,
+	 * but the overhead of sort() is so low that it isn't
+	 * necessary to optimize further.
+	 */
+	if (nr_swapfiles > 1)
+		sort(entries, n, sizeof(entries[0]), swp_entry_cmp, NULL);
 	for (i = 0; i < n; ++i) {
 		p = swap_info_get_cont(entries[i], prev);
 		if (p)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
