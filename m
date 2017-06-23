Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC036B0350
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 03:14:56 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 132so36011593pgb.6
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 00:14:56 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id m29si3124833pli.455.2017.06.23.00.14.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 00:14:55 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v2 10/12] memcg, THP, swap: Make mem_cgroup_swapout() support THP
Date: Fri, 23 Jun 2017 15:13:01 +0800
Message-Id: <20170623071303.13469-11-ying.huang@intel.com>
In-Reply-To: <20170623071303.13469-1-ying.huang@intel.com>
References: <20170623071303.13469-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm@lists.01.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Huang Ying <ying.huang@intel.com>

This patch makes mem_cgroup_swapout() works for the transparent huge
page (THP).  Which will move the memory cgroup charge from memory to
swap for a THP.

This will be used for the THP swap support.  Where a THP may be
swapped out as a whole to a set of (HPAGE_PMD_NR) continuous swap
slots on the swap device.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
---
 mm/memcontrol.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 123564bcdd77..266832b0507d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4631,8 +4631,8 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /*
- * We don't consider swapping or file mapped pages because THP does not
- * support them for now.
+ * We don't consider PMD mapped swapping or file mapped pages because THP does
+ * not support them for now.
  * Caller should make sure that pmd_trans_huge(pmd) is true.
  */
 static enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
@@ -5890,6 +5890,7 @@ static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
 void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 {
 	struct mem_cgroup *memcg, *swap_memcg;
+	unsigned int nr_entries;
 	unsigned short oldid;
 
 	VM_BUG_ON_PAGE(PageLRU(page), page);
@@ -5910,19 +5911,24 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	 * ancestor for the swap instead and transfer the memory+swap charge.
 	 */
 	swap_memcg = mem_cgroup_id_get_online(memcg);
-	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg), 1);
+	nr_entries = hpage_nr_pages(page);
+	/* Get references for the tail pages, too */
+	if (nr_entries > 1)
+		mem_cgroup_id_get_many(swap_memcg, nr_entries - 1);
+	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg),
+				   nr_entries);
 	VM_BUG_ON_PAGE(oldid, page);
-	mem_cgroup_swap_statistics(swap_memcg, 1);
+	mem_cgroup_swap_statistics(swap_memcg, nr_entries);
 
 	page->mem_cgroup = NULL;
 
 	if (!mem_cgroup_is_root(memcg))
-		page_counter_uncharge(&memcg->memory, 1);
+		page_counter_uncharge(&memcg->memory, nr_entries);
 
 	if (memcg != swap_memcg) {
 		if (!mem_cgroup_is_root(swap_memcg))
-			page_counter_charge(&swap_memcg->memsw, 1);
-		page_counter_uncharge(&memcg->memsw, 1);
+			page_counter_charge(&swap_memcg->memsw, nr_entries);
+		page_counter_uncharge(&memcg->memsw, nr_entries);
 	}
 
 	/*
@@ -5932,7 +5938,8 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	 * only synchronisation we have for udpating the per-CPU variables.
 	 */
 	VM_BUG_ON(!irqs_disabled());
-	mem_cgroup_charge_statistics(memcg, page, false, -1);
+	mem_cgroup_charge_statistics(memcg, page, PageTransHuge(page),
+				     -nr_entries);
 	memcg_check_events(memcg, page);
 
 	if (!mem_cgroup_is_root(memcg))
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
