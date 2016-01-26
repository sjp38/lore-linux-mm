Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id B062A6B025E
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:46:50 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id r129so102687656wmr.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:46:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yn6si1641940wjc.37.2016.01.26.04.46.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 04:46:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 12/14] mm, page_owner: track and print last migrate reason
Date: Tue, 26 Jan 2016 13:45:51 +0100
Message-Id: <1453812353-26744-13-git-send-email-vbabka@suse.cz>
In-Reply-To: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
References: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>

During migration, page_owner info is now copied with the rest of the page, so
the stacktrace leading to free page allocation during migration is overwritten.
For debugging purposes, it might be however useful to know that the page has
been migrated since its initial allocation. This might happen many times during
the lifetime for different reasons and fully tracking this, especially with
stacktraces would incur extra memory costs. As a compromise, store and print
the migrate_reason of the last migration that occurred to the page. This is
enough to distinguish compaction, numa balancing etc.

Example page_owner entry after the patch:

Page allocated via order 0, mask 0x24200ca(GFP_HIGHUSER_MOVABLE)
PFN 628753 type Movable Block 1228 type Movable Flags 0x1fffff80040030(dirty|lru|swapbacked)
 [<ffffffff811682c4>] __alloc_pages_nodemask+0x134/0x230
 [<ffffffff811b6325>] alloc_pages_vma+0xb5/0x250
 [<ffffffff81177491>] shmem_alloc_page+0x61/0x90
 [<ffffffff8117a438>] shmem_getpage_gfp+0x678/0x960
 [<ffffffff8117c2b9>] shmem_fallocate+0x329/0x440
 [<ffffffff811de600>] vfs_fallocate+0x140/0x230
 [<ffffffff811df434>] SyS_fallocate+0x44/0x70
 [<ffffffff8158cc2e>] entry_SYSCALL_64_fastpath+0x12/0x71
Page has been migrated, last migrate reason: compaction

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Hugh Dickins <hughd@google.com>
---
 include/linux/migrate.h    |  6 +++++-
 include/linux/page_ext.h   |  1 +
 include/linux/page_owner.h |  9 +++++++++
 mm/debug.c                 | 11 +++++++++++
 mm/migrate.c               | 10 +++++++---
 mm/page_owner.c            | 17 +++++++++++++++++
 6 files changed, 50 insertions(+), 4 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index cac1c0904d5f..9b50325e4ddf 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -23,9 +23,13 @@ enum migrate_reason {
 	MR_SYSCALL,		/* also applies to cpusets */
 	MR_MEMPOLICY_MBIND,
 	MR_NUMA_MISPLACED,
-	MR_CMA
+	MR_CMA,
+	MR_TYPES
 };
 
+/* In mm/debug.c; also keep sync with include/trace/events/migrate.h */
+extern char *migrate_reason_names[MR_TYPES];
+
 #ifdef CONFIG_MIGRATION
 
 extern void putback_movable_pages(struct list_head *l);
diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index 17f118a82854..e1fe7cf5bddf 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -45,6 +45,7 @@ struct page_ext {
 	unsigned int order;
 	gfp_t gfp_mask;
 	unsigned int nr_entries;
+	int last_migrate_reason;
 	unsigned long trace_entries[8];
 #endif
 };
diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
index 6440daab4ef8..555893bf13d7 100644
--- a/include/linux/page_owner.h
+++ b/include/linux/page_owner.h
@@ -12,6 +12,7 @@ extern void __set_page_owner(struct page *page,
 			unsigned int order, gfp_t gfp_mask);
 extern gfp_t __get_page_owner_gfp(struct page *page);
 extern void __copy_page_owner(struct page *oldpage, struct page *newpage);
+extern void __set_page_owner_migrate_reason(struct page *page, int reason);
 
 static inline void reset_page_owner(struct page *page, unsigned int order)
 {
@@ -38,6 +39,11 @@ static inline void copy_page_owner(struct page *oldpage, struct page *newpage)
 	if (static_branch_unlikely(&page_owner_inited))
 		__copy_page_owner(oldpage, newpage);
 }
+static inline void set_page_owner_migrate_reason(struct page *page, int reason)
+{
+	if (static_branch_unlikely(&page_owner_inited))
+		__set_page_owner_migrate_reason(page, reason);
+}
 #else
 static inline void reset_page_owner(struct page *page, unsigned int order)
 {
@@ -53,5 +59,8 @@ static inline gfp_t get_page_owner_gfp(struct page *page)
 static inline void copy_page_owner(struct page *oldpage, struct page *newpage)
 {
 }
+static inline void set_page_owner_migrate_reason(struct page *page, int reason)
+{
+}
 #endif /* CONFIG_PAGE_OWNER */
 #endif /* __LINUX_PAGE_OWNER_H */
diff --git a/mm/debug.c b/mm/debug.c
index 231e1452a912..78dc54877075 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -10,9 +10,20 @@
 #include <linux/trace_events.h>
 #include <linux/memcontrol.h>
 #include <trace/events/mmflags.h>
+#include <linux/migrate.h>
 
 #include "internal.h"
 
+char *migrate_reason_names[MR_TYPES] = {
+	"compaction",
+	"memory_failure",
+	"memory_hotplug",
+	"syscall_or_cpuset",
+	"mempolicy_mbind",
+	"numa_misplaced",
+	"cma",
+};
+
 const struct trace_print_flags pageflag_names[] = {
 	__def_pageflag_names,
 	{0, NULL}
diff --git a/mm/migrate.c b/mm/migrate.c
index 863a0f1fe23f..1c11b73cd834 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -955,8 +955,10 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 	}
 
 	rc = __unmap_and_move(page, newpage, force, mode);
-	if (rc == MIGRATEPAGE_SUCCESS)
+	if (rc == MIGRATEPAGE_SUCCESS) {
 		put_new_page = NULL;
+		set_page_owner_migrate_reason(newpage, reason);
+	}
 
 out:
 	if (rc != -EAGAIN) {
@@ -1021,7 +1023,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 static int unmap_and_move_huge_page(new_page_t get_new_page,
 				free_page_t put_new_page, unsigned long private,
 				struct page *hpage, int force,
-				enum migrate_mode mode)
+				enum migrate_mode mode, int reason)
 {
 	int rc = -EAGAIN;
 	int *result = NULL;
@@ -1079,6 +1081,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	if (rc == MIGRATEPAGE_SUCCESS) {
 		hugetlb_cgroup_migrate(hpage, new_hpage);
 		put_new_page = NULL;
+		set_page_owner_migrate_reason(new_hpage, reason);
 	}
 
 	unlock_page(hpage);
@@ -1151,7 +1154,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 			if (PageHuge(page))
 				rc = unmap_and_move_huge_page(get_new_page,
 						put_new_page, private, page,
-						pass > 2, mode);
+						pass > 2, mode, reason);
 			else
 				rc = unmap_and_move(get_new_page, put_new_page,
 						private, page, pass > 2, mode,
@@ -1842,6 +1845,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	set_page_memcg(new_page, page_memcg(page));
 	set_page_memcg(page, NULL);
 	page_remove_rmap(page, true);
+	set_page_owner_migrate_reason(new_page, MR_NUMA_MISPLACED);
 
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 774b55623212..a57068cfe52f 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -6,6 +6,7 @@
 #include <linux/stacktrace.h>
 #include <linux/page_owner.h>
 #include <linux/jump_label.h>
+#include <linux/migrate.h>
 #include "internal.h"
 
 static bool page_owner_disabled = true;
@@ -73,10 +74,18 @@ void __set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
 	page_ext->order = order;
 	page_ext->gfp_mask = gfp_mask;
 	page_ext->nr_entries = trace.nr_entries;
+	page_ext->last_migrate_reason = -1;
 
 	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
 }
 
+void __set_page_owner_migrate_reason(struct page *page, int reason)
+{
+	struct page_ext *page_ext = lookup_page_ext(page);
+
+	page_ext->last_migrate_reason = reason;
+}
+
 gfp_t __get_page_owner_gfp(struct page *page)
 {
 	struct page_ext *page_ext = lookup_page_ext(page);
@@ -151,6 +160,14 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 	if (ret >= count)
 		goto err;
 
+	if (page_ext->last_migrate_reason != -1) {
+		ret += snprintf(kbuf + ret, count - ret,
+			"Page has been migrated, last migrate reason: %s\n",
+			migrate_reason_names[page_ext->last_migrate_reason]);
+		if (ret >= count)
+			goto err;
+	}
+
 	ret += snprintf(kbuf + ret, count - ret, "\n");
 	if (ret >= count)
 		goto err;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
