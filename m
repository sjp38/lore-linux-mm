Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85EA58E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:39:03 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id x7so13954102pll.23
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:39:03 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e68si15371744pfb.101.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Message-Id: <20181226133352.246320288@intel.com>
Date: Wed, 26 Dec 2018 21:15:06 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 20/21] mm/vmscan.c: migrate anon DRAM pages to PMEM node
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0012-vmscan-migrate-anonymous-pages-to-pmem-node-before-s.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, Jingqi Liu <jingqi.liu@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

From: Jingqi Liu <jingqi.liu@intel.com>

With PMEM nodes, the demotion path could be

1) DRAM pages: migrate to PMEM node
2) PMEM pages: swap out

This patch does (1) for anonymous pages only. Since we cannot
detect hotness of (unmapped) page cache pages for now.

The user space daemon can do migration in both directions:
- PMEM=>DRAM hot page migration
- DRAM=>PMEM cold page migration
However it's more natural for user space to do hot page migration
and kernel to do cold page migration. Especially, only kernel can
guarantee on-demand migration when there is memory pressure.

So the big picture will look like this: user space daemon does regular
hot page migration to DRAM, creating memory pressure on DRAM nodes,
which triggers kernel cold page migration to PMEM nodes.

Du Fan:
- Support multiple NUMA nodes.
- Don't migrate clean MADV_FREE pages to PMEM node.

With advise(MADV_FREE) syscall, both vma structure and
its corresponding page entries still lives, but we got
MADV_FREE page, anonymous but WITHOUT SwapBacked.

In case of page reclaim, clean MADV_FREE pages will be
freed and return to buddy system, the dirty ones then
turn into canonical anonymous page with
PageSwapBacked(page) set, and put into LRU_INACTIVE_FILE
list falling into standard aging routine.

Point is clean MADV_FREE pages should not be migrated,
it has steal (useless) user data once madvise(MADV_FREE)
called and guard against thus scenarios.

P.S. MADV_FREE is heavily used by jemalloc engine, and
workload like redis, refer to [1] for detailed backgroud,
usecase, and benchmark result.

[1]
https://lore.kernel.org/patchwork/patch/622179/

Fengguang:
- detect migrate thp and hugetlb
- avoid moving pages to a non-existent node

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Jingqi Liu <jingqi.liu@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/vmscan.c |   33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

--- linux.orig/mm/vmscan.c	2018-12-23 20:37:58.305551976 +0800
+++ linux/mm/vmscan.c	2018-12-23 20:37:58.305551976 +0800
@@ -1112,6 +1112,7 @@ static unsigned long shrink_page_list(st
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
+	LIST_HEAD(move_pages);
 	int pgactivate = 0;
 	unsigned nr_unqueued_dirty = 0;
 	unsigned nr_dirty = 0;
@@ -1121,6 +1122,7 @@ static unsigned long shrink_page_list(st
 	unsigned nr_immediate = 0;
 	unsigned nr_ref_keep = 0;
 	unsigned nr_unmap_fail = 0;
+	int page_on_dram = is_node_dram(pgdat->node_id);
 
 	cond_resched();
 
@@ -1275,6 +1277,21 @@ static unsigned long shrink_page_list(st
 		}
 
 		/*
+		 * Check if the page is in DRAM numa node.
+		 * Skip MADV_FREE pages as it might be freed
+		 * immediately to buddy system if it's clean.
+		 */
+		if (node_online(pgdat->peer_node) &&
+			PageAnon(page) && (PageSwapBacked(page) || PageTransHuge(page))) {
+			if (page_on_dram) {
+				/* Add to the page list which will be moved to pmem numa node. */
+				list_add(&page->lru, &move_pages);
+				unlock_page(page);
+				continue;
+			}
+		}
+
+		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 * Lazyfree page could be freed directly
@@ -1496,6 +1513,22 @@ keep:
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
 
+	/* Move the anonymous pages to PMEM numa node. */
+	if (!list_empty(&move_pages)) {
+		int err;
+
+		/* Could not block. */
+		err = migrate_pages(&move_pages, alloc_new_node_page, NULL,
+					pgdat->peer_node,
+					MIGRATE_ASYNC, MR_NUMA_MISPLACED);
+		if (err) {
+			putback_movable_pages(&move_pages);
+
+			/* Join the pages which were not migrated.  */
+			list_splice(&ret_pages, &move_pages);
+		}
+	}
+
 	mem_cgroup_uncharge_list(&free_pages);
 	try_to_unmap_flush();
 	free_unref_page_list(&free_pages);
