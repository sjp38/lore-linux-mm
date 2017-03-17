Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 49A126B0390
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 02:50:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x63so119266973pfx.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 23:50:21 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id s21si7664825pgg.375.2017.03.16.23.50.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 23:50:20 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH 5/5] mm, swap: Sort swap entries before free
Date: Fri, 17 Mar 2017 14:46:23 +0800
Message-Id: <20170317064635.12792-5-ying.huang@intel.com>
In-Reply-To: <20170317064635.12792-1-ying.huang@intel.com>
References: <20170317064635.12792-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vegard Nossum <vegard.nossum@oracle.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
---
 mm/swapfile.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 1fb966cf2175..dc1716c7997f 100644
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
@@ -1075,6 +1083,7 @@ void swapcache_free_entries(swp_entry_t *entries, int n)
 
 	prev = NULL;
 	p = NULL;
+	sort(entries, n, sizeof(entries[0]), swp_entry_cmp, NULL);
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
