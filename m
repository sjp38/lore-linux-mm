Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 69D776B004D
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:56:24 -0500 (EST)
Message-Id: <20120228144746.971869014@intel.com>
Date: Tue, 28 Feb 2012 22:00:24 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH 2/9] memcg: add dirty page accounting infrastructure
References: <20120228140022.614718843@intel.com>
Content-Disposition: inline; filename=memcg-add-dirty-page-accounting-infrastructure.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

From: Greg Thelen <gthelen@google.com>

Add memcg routines to count dirty, writeback, and unstable_NFS pages.
These routines are not yet used by the kernel to count such pages.  A
later change adds kernel calls to these new routines.

As inode pages are marked dirty, if the dirtied page's cgroup differs
from the inode's cgroup, then mark the inode shared across several
cgroup.

Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Andrea Righi <andrea@betterlinux.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
Changelog since v8:
- In v8 this patch was applied after 'memcg: add mem_cgroup_mark_inode_dirty()'.
  In this version (v9), this patch comes first.  The result is that this patch
  does not contain code to mark inode with I_MEMCG_SHARED.  That logic is
  deferred until the later 'memcg: add mem_cgroup_mark_inode_dirty()' patch.

Fengguang: "unstable_nfs" seems a more consistent name?

 include/linux/memcontrol.h |    8 ++-
 mm/memcontrol.c            |   87 +++++++++++++++++++++++++++++++----
 2 files changed, 86 insertions(+), 9 deletions(-)

--- linux.orig/include/linux/memcontrol.h	2012-02-19 11:29:59.000000000 +0800
+++ linux/include/linux/memcontrol.h	2012-02-19 11:30:05.000000000 +0800
@@ -27,9 +27,15 @@ struct page_cgroup;
 struct page;
 struct mm_struct;
 
-/* Stats that can be updated by kernel. */
+/*
+ * Per mem_cgroup page counts tracked by kernel.  As pages enter and leave these
+ * states, the kernel notifies memcg using mem_cgroup_{inc,dec}_page_stat().
+ */
 enum mem_cgroup_page_stat_item {
 	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
+	MEMCG_NR_FILE_DIRTY, /* # of dirty pages in page cache */
+	MEMCG_NR_FILE_WRITEBACK, /* # of pages under writeback */
+	MEMCG_NR_FILE_UNSTABLE_NFS, /* # of NFS unstable pages */
 };
 
 struct mem_cgroup_reclaim_cookie {
--- linux.orig/mm/memcontrol.c	2012-02-19 11:29:59.000000000 +0800
+++ linux/mm/memcontrol.c	2012-02-19 11:30:25.000000000 +0800
@@ -86,8 +86,11 @@ enum mem_cgroup_stat_index {
 	 */
 	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
-	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
+	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
+	MEM_CGROUP_STAT_FILE_DIRTY,	/* # of dirty pages in page cache */
+	MEM_CGROUP_STAT_FILE_WRITEBACK,		/* # of pages under writeback */
+	MEM_CGROUP_STAT_FILE_UNSTABLE_NFS,	/* # of NFS unstable pages */
 	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
 	MEM_CGROUP_ON_MOVE,	/* someone is moving account between groups */
 	MEM_CGROUP_STAT_NSTATS,
@@ -1885,6 +1888,44 @@ void mem_cgroup_update_page_stat(struct 
 			ClearPageCgroupFileMapped(pc);
 		idx = MEM_CGROUP_STAT_FILE_MAPPED;
 		break;
+
+	case MEMCG_NR_FILE_DIRTY:
+		/* Use Test{Set,Clear} to only un/charge the memcg once. */
+		if (val > 0) {
+			if (TestSetPageCgroupFileDirty(pc))
+				val = 0;
+		} else {
+			if (!TestClearPageCgroupFileDirty(pc))
+				val = 0;
+		}
+		idx = MEM_CGROUP_STAT_FILE_DIRTY;
+		break;
+
+	case MEMCG_NR_FILE_WRITEBACK:
+		/*
+		 * This counter is adjusted while holding the mapping's
+		 * tree_lock.  Therefore there is no race between settings and
+		 * clearing of this flag.
+		 */
+		if (val > 0)
+			SetPageCgroupFileWriteback(pc);
+		else
+			ClearPageCgroupFileWriteback(pc);
+		idx = MEM_CGROUP_STAT_FILE_WRITEBACK;
+		break;
+
+	case MEMCG_NR_FILE_UNSTABLE_NFS:
+		/* Use Test{Set,Clear} to only un/charge the memcg once. */
+		if (val > 0) {
+			if (TestSetPageCgroupFileUnstableNFS(pc))
+				val = 0;
+		} else {
+			if (!TestClearPageCgroupFileUnstableNFS(pc))
+				val = 0;
+		}
+		idx = MEM_CGROUP_STAT_FILE_UNSTABLE_NFS;
+		break;
+
 	default:
 		BUG();
 	}
@@ -2481,6 +2522,17 @@ void mem_cgroup_split_huge_fixup(struct 
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+static inline
+void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
+				       struct mem_cgroup *to,
+				       enum mem_cgroup_stat_index idx)
+{
+	preempt_disable();
+	__this_cpu_dec(from->stat->count[idx]);
+	__this_cpu_inc(to->stat->count[idx]);
+	preempt_enable();
+}
+
 /**
  * mem_cgroup_move_account - move account of the page
  * @page: the page
@@ -2529,13 +2581,18 @@ static int mem_cgroup_move_account(struc
 
 	move_lock_page_cgroup(pc, &flags);
 
-	if (PageCgroupFileMapped(pc)) {
-		/* Update mapped_file data for mem_cgroup */
-		preempt_disable();
-		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		preempt_enable();
-	}
+	if (PageCgroupFileMapped(pc))
+		mem_cgroup_move_account_page_stat(from, to,
+					MEM_CGROUP_STAT_FILE_MAPPED);
+	if (PageCgroupFileDirty(pc))
+		mem_cgroup_move_account_page_stat(from, to,
+						  MEM_CGROUP_STAT_FILE_DIRTY);
+	if (PageCgroupFileWriteback(pc))
+		mem_cgroup_move_account_page_stat(from, to,
+					MEM_CGROUP_STAT_FILE_WRITEBACK);
+	if (PageCgroupFileUnstableNFS(pc))
+		mem_cgroup_move_account_page_stat(from, to,
+					MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
 	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -nr_pages);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
@@ -3994,6 +4051,9 @@ enum {
 	MCS_SWAP,
 	MCS_PGFAULT,
 	MCS_PGMAJFAULT,
+	MCS_FILE_DIRTY,
+	MCS_WRITEBACK,
+	MCS_UNSTABLE_NFS,
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
 	MCS_INACTIVE_FILE,
@@ -4018,6 +4078,9 @@ struct {
 	{"swap", "total_swap"},
 	{"pgfault", "total_pgfault"},
 	{"pgmajfault", "total_pgmajfault"},
+	{"dirty", "total_dirty"},
+	{"writeback", "total_writeback"},
+	{"nfs_unstable", "total_nfs_unstable"},
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
@@ -4051,6 +4114,14 @@ mem_cgroup_get_local_stat(struct mem_cgr
 	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGMAJFAULT);
 	s->stat[MCS_PGMAJFAULT] += val;
 
+	/* dirty stat */
+	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_FILE_DIRTY);
+	s->stat[MCS_FILE_DIRTY] += val * PAGE_SIZE;
+	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_FILE_WRITEBACK);
+	s->stat[MCS_WRITEBACK] += val * PAGE_SIZE;
+	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
+	s->stat[MCS_UNSTABLE_NFS] += val * PAGE_SIZE;
+
 	/* per zone stat */
 	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_ANON));
 	s->stat[MCS_INACTIVE_ANON] += val * PAGE_SIZE;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
