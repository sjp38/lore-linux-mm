Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2A206B0010
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 19:37:06 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f9-v6so18316633pfn.22
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:37:06 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id o184-v6si21060983pga.520.2018.07.12.16.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 16:37:05 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH 4/6] swap: Unify normal/huge code path in put_swap_page()
Date: Fri, 13 Jul 2018 07:36:34 +0800
Message-Id: <20180712233636.20629-5-ying.huang@intel.com>
In-Reply-To: <20180712233636.20629-1-ying.huang@intel.com>
References: <20180712233636.20629-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

From: Huang Ying <ying.huang@intel.com>

In this patch, the normal/huge code path in put_swap_page() and
several helper functions are unified to avoid duplicated code, bugs,
etc. and make it easier to review the code.

The removed lines are more than added lines.  And the binary size is
kept exactly same when CONFIG_TRANSPARENT_HUGEPAGE=n.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Suggested-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/swapfile.c | 83 ++++++++++++++++++++++++++---------------------------------
 1 file changed, 37 insertions(+), 46 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 160f78072667..e0df8d22ac92 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -205,8 +205,16 @@ static void discard_swap_cluster(struct swap_info_struct *si,
 
 #ifdef CONFIG_THP_SWAP
 #define SWAPFILE_CLUSTER	HPAGE_PMD_NR
+
+#define nr_swap_entries(nr)	(nr)
 #else
 #define SWAPFILE_CLUSTER	256
+
+/*
+ * Define nr_swap_entries() as constant to let compiler to optimize
+ * out some code if !CONFIG_THP_SWAP
+ */
+#define nr_swap_entries(nr)	1
 #endif
 #define LATENCY_LIMIT		256
 
@@ -1249,18 +1257,7 @@ void swap_free(swp_entry_t entry)
 /*
  * Called after dropping swapcache to decrease refcnt to swap entries.
  */
-static void swapcache_free(swp_entry_t entry)
-{
-	struct swap_info_struct *p;
-
-	p = _swap_info_get(entry);
-	if (p) {
-		if (!__swap_entry_free(p, entry, SWAP_HAS_CACHE))
-			free_swap_slot(entry);
-	}
-}
-
-static void swapcache_free_cluster(swp_entry_t entry)
+void put_swap_page(struct page *page, swp_entry_t entry)
 {
 	unsigned long offset = swp_offset(entry);
 	unsigned long idx = offset / SWAPFILE_CLUSTER;
@@ -1269,39 +1266,41 @@ static void swapcache_free_cluster(swp_entry_t entry)
 	unsigned char *map;
 	unsigned int i, free_entries = 0;
 	unsigned char val;
-
-	if (!IS_ENABLED(CONFIG_THP_SWAP))
-		return;
+	int nr = nr_swap_entries(hpage_nr_pages(page));
 
 	si = _swap_info_get(entry);
 	if (!si)
 		return;
 
-	ci = lock_cluster(si, offset);
-	VM_BUG_ON(!cluster_is_huge(ci));
-	map = si->swap_map + offset;
-	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
-		val = map[i];
-		VM_BUG_ON(!(val & SWAP_HAS_CACHE));
-		if (val == SWAP_HAS_CACHE)
-			free_entries++;
-	}
-	if (!free_entries) {
-		for (i = 0; i < SWAPFILE_CLUSTER; i++)
-			map[i] &= ~SWAP_HAS_CACHE;
-	}
-	cluster_clear_huge(ci);
-	unlock_cluster(ci);
-	if (free_entries == SWAPFILE_CLUSTER) {
-		spin_lock(&si->lock);
+	if (nr == SWAPFILE_CLUSTER) {
 		ci = lock_cluster(si, offset);
-		memset(map, 0, SWAPFILE_CLUSTER);
+		VM_BUG_ON(!cluster_is_huge(ci));
+		map = si->swap_map + offset;
+		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
+			val = map[i];
+			VM_BUG_ON(!(val & SWAP_HAS_CACHE));
+			if (val == SWAP_HAS_CACHE)
+				free_entries++;
+		}
+		if (!free_entries) {
+			for (i = 0; i < SWAPFILE_CLUSTER; i++)
+				map[i] &= ~SWAP_HAS_CACHE;
+		}
+		cluster_clear_huge(ci);
 		unlock_cluster(ci);
-		mem_cgroup_uncharge_swap(entry, SWAPFILE_CLUSTER);
-		swap_free_cluster(si, idx);
-		spin_unlock(&si->lock);
-	} else if (free_entries) {
-		for (i = 0; i < SWAPFILE_CLUSTER; i++, entry.val++) {
+		if (free_entries == SWAPFILE_CLUSTER) {
+			spin_lock(&si->lock);
+			ci = lock_cluster(si, offset);
+			memset(map, 0, SWAPFILE_CLUSTER);
+			unlock_cluster(ci);
+			mem_cgroup_uncharge_swap(entry, SWAPFILE_CLUSTER);
+			swap_free_cluster(si, idx);
+			spin_unlock(&si->lock);
+			return;
+		}
+	}
+	if (nr == 1 || free_entries) {
+		for (i = 0; i < nr; i++, entry.val++) {
 			if (!__swap_entry_free(si, entry, SWAP_HAS_CACHE))
 				free_swap_slot(entry);
 		}
@@ -1325,14 +1324,6 @@ int split_swap_cluster(swp_entry_t entry)
 }
 #endif
 
-void put_swap_page(struct page *page, swp_entry_t entry)
-{
-	if (!PageTransHuge(page))
-		swapcache_free(entry);
-	else
-		swapcache_free_cluster(entry);
-}
-
 static int swp_entry_cmp(const void *ent1, const void *ent2)
 {
 	const swp_entry_t *e1 = ent1, *e2 = ent2;
-- 
2.16.4
