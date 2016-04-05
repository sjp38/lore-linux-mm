Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 706DF828DF
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:46:07 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id c20so18822298pfc.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:46:07 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id w1si10155274par.40.2016.04.05.14.46.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:46:06 -0700 (PDT)
Received: by mail-pa0-x229.google.com with SMTP id zm5so18543534pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:46:06 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:46:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 19/31] huge tmpfs: mem_cgroup shmem_pmdmapped accounting
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051444130.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Andres Lagar-Cavilla <andreslc@google.com>

Grep now for shmem_pmdmapped in memory.stat (and also for
"total_..." in a hierarchical setting).

This metric allows for easy checking on a per-cgroup basis of the
amount of page team memory hugely mapped (at least once) out there.

The metric is counted towards the cgroup owning the page (unlike in an
event such as THP split) because the team page may be mapped hugely
for the first time via a shared map in some other process.

Moved up mem_group_move_account()'s PageWriteback block:
that movement is irrelevant to this patch, but lets us concentrate
better on the PageTeam locking issues which follow in the next patch.

Signed-off-by: Andres Lagar-Cavilla <andreslc@google.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/memcontrol.h |    2 ++
 include/linux/pageteam.h   |   16 ++++++++++++++++
 mm/huge_memory.c           |    4 ++++
 mm/memcontrol.c            |   35 ++++++++++++++++++++++++++---------
 4 files changed, 48 insertions(+), 9 deletions(-)

--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -50,6 +50,8 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_DIRTY,          /* # of dirty pages in page cache */
 	MEM_CGROUP_STAT_WRITEBACK,	/* # of pages under writeback */
 	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
+	/* # of pages charged as hugely mapped teams */
+	MEM_CGROUP_STAT_SHMEM_PMDMAPPED,
 	MEM_CGROUP_STAT_NSTATS,
 	/* default hierarchy stats */
 	MEMCG_KERNEL_STACK = MEM_CGROUP_STAT_NSTATS,
--- a/include/linux/pageteam.h
+++ b/include/linux/pageteam.h
@@ -135,6 +135,22 @@ static inline bool dec_team_pmd_mapped(s
 }
 
 /*
+ * Supplies those values which mem_cgroup_move_account()
+ * needs to maintain memcg's huge tmpfs stats correctly.
+ */
+static inline void count_team_pmd_mapped(struct page *head, int *file_mapped,
+					 bool *pmd_mapped)
+{
+	long team_usage;
+
+	*file_mapped = 1;
+	team_usage = atomic_long_read(&head->team_usage);
+	*pmd_mapped = team_usage >= TEAM_PMD_MAPPED;
+	if (*pmd_mapped)
+		*file_mapped = HPAGE_PMD_NR - team_pte_count(team_usage);
+}
+
+/*
  * Returns true if this pte mapping is of a non-team page, or of a team page not
  * covered by an existing huge pmd mapping: whereupon stats need to be updated.
  * Only called when mapcount goes up from 0 to 1 i.e. _mapcount from -1 to 0.
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3514,6 +3514,8 @@ static void page_add_team_rmap(struct pa
 		__mod_zone_page_state(zone, NR_FILE_MAPPED, nr_pages);
 		mem_cgroup_update_page_stat(page,
 				MEM_CGROUP_STAT_FILE_MAPPED, nr_pages);
+		mem_cgroup_update_page_stat(page,
+				MEM_CGROUP_STAT_SHMEM_PMDMAPPED, HPAGE_PMD_NR);
 	}
 	unlock_page_memcg(page);
 }
@@ -3533,6 +3535,8 @@ static void page_remove_team_rmap(struct
 		__mod_zone_page_state(zone, NR_FILE_MAPPED, -nr_pages);
 		mem_cgroup_update_page_stat(page,
 				MEM_CGROUP_STAT_FILE_MAPPED, -nr_pages);
+		mem_cgroup_update_page_stat(page,
+				MEM_CGROUP_STAT_SHMEM_PMDMAPPED, -HPAGE_PMD_NR);
 	}
 	unlock_page_memcg(page);
 }
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -37,6 +37,7 @@
 #include <linux/mm.h>
 #include <linux/hugetlb.h>
 #include <linux/pagemap.h>
+#include <linux/pageteam.h>
 #include <linux/smp.h>
 #include <linux/page-flags.h>
 #include <linux/backing-dev.h>
@@ -106,6 +107,7 @@ static const char * const mem_cgroup_sta
 	"dirty",
 	"writeback",
 	"swap",
+	"shmem_pmdmapped",
 };
 
 static const char * const mem_cgroup_events_names[] = {
@@ -4447,7 +4449,8 @@ static int mem_cgroup_move_account(struc
 				   struct mem_cgroup *to)
 {
 	unsigned long flags;
-	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
+	int nr_pages = compound ? hpage_nr_pages(page) : 1;
+	int file_mapped = 1;
 	int ret;
 	bool anon;
 
@@ -4471,10 +4474,10 @@ static int mem_cgroup_move_account(struc
 
 	spin_lock_irqsave(&from->move_lock, flags);
 
-	if (!anon && page_mapped(page)) {
-		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
+	if (PageWriteback(page)) {
+		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_WRITEBACK],
 			       nr_pages);
-		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
+		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_WRITEBACK],
 			       nr_pages);
 	}
 
@@ -4494,11 +4497,25 @@ static int mem_cgroup_move_account(struc
 		}
 	}
 
-	if (PageWriteback(page)) {
-		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_WRITEBACK],
-			       nr_pages);
-		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_WRITEBACK],
-			       nr_pages);
+	if (!anon && PageTeam(page)) {
+		if (page == team_head(page)) {
+			bool pmd_mapped;
+
+			count_team_pmd_mapped(page, &file_mapped, &pmd_mapped);
+			if (pmd_mapped) {
+				__this_cpu_sub(from->stat->count[
+				MEM_CGROUP_STAT_SHMEM_PMDMAPPED], HPAGE_PMD_NR);
+				__this_cpu_add(to->stat->count[
+				MEM_CGROUP_STAT_SHMEM_PMDMAPPED], HPAGE_PMD_NR);
+			}
+		}
+	}
+
+	if (!anon && page_mapped(page)) {
+		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
+			       file_mapped);
+		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
+			       file_mapped);
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
