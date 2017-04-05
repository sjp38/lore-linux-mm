Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E265B6B03A3
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 03:10:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 197so2565839pfv.13
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 00:10:53 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d76si19807043pfe.306.2017.04.05.00.10.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 00:10:53 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v2] mm, swap: Sort swap entries before free
Date: Wed,  5 Apr 2017 15:10:41 +0800
Message-Id: <20170405071041.24469-1-ying.huang@intel.com>
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

v2:

- Avoid sort swap entries if there is only one swap device.
---
 mm/swapfile.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 90054f3c2cdc..b91b0b0088c5 100644
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
@@ -1075,6 +1083,8 @@ void swapcache_free_entries(swp_entry_t *entries, int n)
 
 	prev = NULL;
 	p = NULL;
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
