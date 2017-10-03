Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 18D1D6B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 03:26:30 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y11so575429wme.6
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 00:26:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j28sor4597106wrd.78.2017.10.03.00.26.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Oct 2017 00:26:28 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] mm, hugetlb: drop hugepages_treat_as_movable sysctl
Date: Tue,  3 Oct 2017 09:26:19 +0200
Message-Id: <20171003072619.8654-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Alexandru Moise <00moses.alexander00@gmail.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

hugepages_treat_as_movable has been introduced by 396faf0303d2 ("Allow
huge page allocations to use GFP_HIGH_MOVABLE") to allow hugetlb
allocations from ZONE_MOVABLE even when hugetlb pages were not
migrateable. The purpose of the movable zone was different at the time.
It aimed at reducing memory fragmentation and hugetlb pages being long
lived and large werre not contributing to the fragmentation so it was
acceptable to use the zone back then.

Things have changed though and the primary purpose of the zone became
migratability guarantee. If we allow non migrateable hugetlb pages to
be in ZONE_MOVABLE memory hotplug might fail to offline the memory.

Remove the knob and only rely on hugepage_migration_supported to allow
movable zones.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
Alexandru Moise has noticed that hugepages_treat_as_movable has a weird
semantic [1] and tried to fix it. I think that the sysctl is a relict
which should go away finaly because assumptions which it was based on
no longer hold.

What do you think?

[1] http://lkml.kernel.org/r/20171001225111.GA16432@gmail.com

 Documentation/sysctl/vm.txt | 25 -------------------------
 include/linux/hugetlb.h     |  1 -
 kernel/sysctl.c             |  7 -------
 mm/hugetlb.c                |  4 +---
 4 files changed, 1 insertion(+), 36 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 0752430d4562..44a6c7f226f5 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -30,7 +30,6 @@ files can be found in mm/swap.c.
 - dirty_writeback_centisecs
 - drop_caches
 - extfrag_threshold
-- hugepages_treat_as_movable
 - hugetlb_shm_group
 - laptop_mode
 - legacy_va_layout
@@ -268,30 +267,6 @@ any throttling.
 
 ==============================================================
 
-hugepages_treat_as_movable
-
-This parameter controls whether we can allocate hugepages from ZONE_MOVABLE
-or not. If set to non-zero, hugepages can be allocated from ZONE_MOVABLE.
-ZONE_MOVABLE is created when kernel boot parameter kernelcore= is specified,
-so this parameter has no effect if used without kernelcore=.
-
-Hugepage migration is now available in some situations which depend on the
-architecture and/or the hugepage size. If a hugepage supports migration,
-allocation from ZONE_MOVABLE is always enabled for the hugepage regardless
-of the value of this parameter.
-IOW, this parameter affects only non-migratable hugepages.
-
-Assuming that hugepages are not migratable in your system, one usecase of
-this parameter is that users can make hugepage pool more extensible by
-enabling the allocation from ZONE_MOVABLE. This is because on ZONE_MOVABLE
-page reclaim/migration/compaction work more and you can get contiguous
-memory more likely. Note that using ZONE_MOVABLE for non-migratable
-hugepages can do harm to other features like memory hotremove (because
-memory hotremove expects that memory blocks on ZONE_MOVABLE are always
-removable,) so it's a trade-off responsible for the users.
-
-==============================================================
-
 hugetlb_shm_group
 
 hugetlb_shm_group contains group id that is allowed to create SysV
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 19a3ed54a1b7..c78654421e7d 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -128,7 +128,6 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
 
-extern int hugepages_treat_as_movable;
 extern int sysctl_hugetlb_shm_group;
 extern struct list_head huge_boot_pages;
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c848c3652472..50c813ef1747 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1389,13 +1389,6 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	 },
-	 {
-		.procname	= "hugepages_treat_as_movable",
-		.data		= &hugepages_treat_as_movable,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
 	{
 		.procname	= "nr_overcommit_hugepages",
 		.data		= NULL,
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 34625b257128..ab7f665b83e6 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -36,8 +36,6 @@
 #include <linux/userfaultfd_k.h>
 #include "internal.h"
 
-int hugepages_treat_as_movable;
-
 int hugetlb_max_hstate __read_mostly;
 unsigned int default_hstate_idx;
 struct hstate hstates[HUGE_MAX_HSTATE];
@@ -926,7 +924,7 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
 /* Movability of hugepages depends on migration support. */
 static inline gfp_t htlb_alloc_mask(struct hstate *h)
 {
-	if (hugepages_treat_as_movable || hugepage_migration_supported(h))
+	if (hugepage_migration_supported(h))
 		return GFP_HIGHUSER_MOVABLE;
 	else
 		return GFP_HIGHUSER;
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
