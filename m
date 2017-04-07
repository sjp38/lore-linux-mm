Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8072B6B039F
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 02:49:06 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 34so61853472pgx.6
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 23:49:06 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id g3si4156471pld.88.2017.04.06.23.49.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 23:49:05 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v3] mm, swap: Sort swap entries before free
Date: Fri,  7 Apr 2017 14:49:01 +0800
Message-Id: <20170407064901.25398-1-ying.huang@intel.com>
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
device before freeing the swap entries.  Test shows that the time
spent by swapcache_free_entries() could be reduced after the patch.

Test the patch via measuring the run time of swap_cache_free_entries()
during the exit phase of the applications use much swap space.  The
results shows that the average run time of swap_cache_free_entries()
reduced about 20% after applying the patch.

Signed-off-by: Huang Ying <ying.huang@intel.com>
Acked-by: Tim Chen <tim.c.chen@intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>

v3:

- Add some comments in code per Rik's suggestion.

v2:

- Avoid sort swap entries if there is only one swap device.
---
 mm/swapfile.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 90054f3c2cdc..f23c56e9be39 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -37,6 +37,7 @@
 #include <linux/swapfile.h>
 #include <linux/export.h>
 #include <linux/swap_slots.h>
+#include <linux/sort.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -1065,6 +1066,13 @@ void swapcache_free(swp_entry_t entry)
 	}
 }
 
+static int swp_entry_cmp(const void *ent1, const void *ent2)
+{
+	const swp_entry_t *e1 = ent1, *e2 = ent2;
+
+	return (long)(swp_type(*e1) - swp_type(*e2));
+}
+
 void swapcache_free_entries(swp_entry_t *entries, int n)
 {
 	struct swap_info_struct *p, *prev;
@@ -1075,6 +1083,10 @@ void swapcache_free_entries(swp_entry_t *entries, int n)
 
 	prev = NULL;
 	p = NULL;
+
+	/* Sort swap entries by swap device, so each lock is only taken once. */
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
