Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id D45886B0088
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:13 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/49] mm: migrate: Add a tracepoint for migrate_pages
Date: Fri,  7 Dec 2012 10:23:12 +0000
Message-Id: <1354875832-9700-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The pgmigrate_success and pgmigrate_fail vmstat counters tells the user
about migration activity but not the type or the reason. This patch adds
a tracepoint to identify the type of page migration and why the page is
being migrated.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/migrate.h        |   13 ++++++++--
 include/trace/events/migrate.h |   51 ++++++++++++++++++++++++++++++++++++++++
 mm/compaction.c                |    3 ++-
 mm/memory-failure.c            |    3 ++-
 mm/memory_hotplug.c            |    3 ++-
 mm/mempolicy.c                 |    6 +++--
 mm/migrate.c                   |   10 ++++++--
 mm/page_alloc.c                |    3 ++-
 8 files changed, 82 insertions(+), 10 deletions(-)
 create mode 100644 include/trace/events/migrate.h

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index ce7e667..9d1c159 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -7,6 +7,15 @@
 
 typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
+enum migrate_reason {
+	MR_COMPACTION,
+	MR_MEMORY_FAILURE,
+	MR_MEMORY_HOTPLUG,
+	MR_SYSCALL,		/* also applies to cpusets */
+	MR_MEMPOLICY_MBIND,
+	MR_CMA
+};
+
 #ifdef CONFIG_MIGRATION
 
 extern void putback_lru_pages(struct list_head *l);
@@ -14,7 +23,7 @@ extern int migrate_page(struct address_space *,
 			struct page *, struct page *, enum migrate_mode);
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
-			enum migrate_mode mode);
+			enum migrate_mode mode, int reason);
 extern int migrate_huge_page(struct page *, new_page_t x,
 			unsigned long private, bool offlining,
 			enum migrate_mode mode);
@@ -35,7 +44,7 @@ extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 static inline void putback_lru_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, bool offlining,
-		enum migrate_mode mode) { return -ENOSYS; }
+		enum migrate_mode mode, int reason) { return -ENOSYS; }
 static inline int migrate_huge_page(struct page *page, new_page_t x,
 		unsigned long private, bool offlining,
 		enum migrate_mode mode) { return -ENOSYS; }
diff --git a/include/trace/events/migrate.h b/include/trace/events/migrate.h
new file mode 100644
index 0000000..ec2a6cc
--- /dev/null
+++ b/include/trace/events/migrate.h
@@ -0,0 +1,51 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM migrate
+
+#if !defined(_TRACE_MIGRATE_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_MIGRATE_H
+
+#define MIGRATE_MODE						\
+	{MIGRATE_ASYNC,		"MIGRATE_ASYNC"},		\
+	{MIGRATE_SYNC_LIGHT,	"MIGRATE_SYNC_LIGHT"},		\
+	{MIGRATE_SYNC,		"MIGRATE_SYNC"}		
+
+#define MIGRATE_REASON						\
+	{MR_COMPACTION,		"compaction"},			\
+	{MR_MEMORY_FAILURE,	"memory_failure"},		\
+	{MR_MEMORY_HOTPLUG,	"memory_hotplug"},		\
+	{MR_SYSCALL,		"syscall_or_cpuset"},		\
+	{MR_MEMPOLICY_MBIND,	"mempolicy_mbind"},		\
+	{MR_CMA,		"cma"}
+
+TRACE_EVENT(mm_migrate_pages,
+
+	TP_PROTO(unsigned long succeeded, unsigned long failed,
+		 enum migrate_mode mode, int reason),
+
+	TP_ARGS(succeeded, failed, mode, reason),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,		succeeded)
+		__field(	unsigned long,		failed)
+		__field(	enum migrate_mode,	mode)
+		__field(	int,			reason)
+	),
+
+	TP_fast_assign(
+		__entry->succeeded	= succeeded;
+		__entry->failed		= failed;
+		__entry->mode		= mode;
+		__entry->reason		= reason;
+	),
+
+	TP_printk("nr_succeeded=%lu nr_failed=%lu mode=%s reason=%s",
+		__entry->succeeded,
+		__entry->failed,
+		__print_symbolic(__entry->mode, MIGRATE_MODE),
+		__print_symbolic(__entry->reason, MIGRATE_REASON))
+);
+
+#endif /* _TRACE_MIGRATE_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/compaction.c b/mm/compaction.c
index 00ad883..2c077a7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -990,7 +990,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		nr_migrate = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
 				(unsigned long)cc, false,
-				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC);
+				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC,
+				MR_COMPACTION);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 6c5899b..ddb68a1 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1558,7 +1558,8 @@ int soft_offline_page(struct page *page, int flags)
 					    page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
-							false, MIGRATE_SYNC);
+							false, MIGRATE_SYNC,
+							MR_MEMORY_FAILURE);
 		if (ret) {
 			putback_lru_pages(&pagelist);
 			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e4eeaca..e598bd1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -812,7 +812,8 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		 * migrate_pages returns # of failed pages.
 		 */
 		ret = migrate_pages(&source, alloc_migrate_target, 0,
-							true, MIGRATE_SYNC);
+							true, MIGRATE_SYNC,
+							MR_MEMORY_HOTPLUG);
 		if (ret)
 			putback_lru_pages(&source);
 	}
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d04a8a5..66e90ec 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -961,7 +961,8 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_node_page, dest,
-							false, MIGRATE_SYNC);
+							false, MIGRATE_SYNC,
+							MR_SYSCALL);
 		if (err)
 			putback_lru_pages(&pagelist);
 	}
@@ -1202,7 +1203,8 @@ static long do_mbind(unsigned long start, unsigned long len,
 		if (!list_empty(&pagelist)) {
 			nr_failed = migrate_pages(&pagelist, new_vma_page,
 						(unsigned long)vma,
-						false, MIGRATE_SYNC);
+						false, MIGRATE_SYNC,
+						MR_MEMPOLICY_MBIND);
 			if (nr_failed)
 				putback_lru_pages(&pagelist);
 		}
diff --git a/mm/migrate.c b/mm/migrate.c
index 04687f6..27be9c9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -38,6 +38,9 @@
 
 #include <asm/tlbflush.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/migrate.h>
+
 #include "internal.h"
 
 /*
@@ -958,7 +961,7 @@ out:
  */
 int migrate_pages(struct list_head *from,
 		new_page_t get_new_page, unsigned long private, bool offlining,
-		enum migrate_mode mode)
+		enum migrate_mode mode, int reason)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -1004,6 +1007,8 @@ out:
 		count_vm_events(PGMIGRATE_SUCCESS, nr_succeeded);
 	if (nr_failed)
 		count_vm_events(PGMIGRATE_FAIL, nr_failed);
+	trace_mm_migrate_pages(nr_succeeded, nr_failed, mode, reason);
+
 	if (!swapwrite)
 		current->flags &= ~PF_SWAPWRITE;
 
@@ -1145,7 +1150,8 @@ set_status:
 	err = 0;
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_page_node,
-				(unsigned long)pm, 0, MIGRATE_SYNC);
+				(unsigned long)pm, 0, MIGRATE_SYNC,
+				MR_SYSCALL);
 		if (err)
 			putback_lru_pages(&pagelist);
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7bb35ac..5953dc2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5707,7 +5707,8 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 
 		ret = migrate_pages(&cc->migratepages,
 				    alloc_migrate_target,
-				    0, false, MIGRATE_SYNC);
+				    0, false, MIGRATE_SYNC,
+				    MR_CMA);
 	}
 
 	putback_lru_pages(&cc->migratepages);
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
