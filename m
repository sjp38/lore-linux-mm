Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A9EBD5F0047
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:16:49 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v2 05/11] memcg: add dirty page accounting infrastructure
Date: Fri, 15 Oct 2010 14:14:33 -0700
Message-Id: <1287177279-30876-6-git-send-email-gthelen@google.com>
In-Reply-To: <1287177279-30876-1-git-send-email-gthelen@google.com>
References: <1287177279-30876-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

Add memcg routines to track dirty, writeback, and unstable_NFS pages.
These routines are not yet used by the kernel to count such pages.
A later change adds kernel calls to these new routines.

Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Andrea Righi <arighi@develer.com>
---
 include/linux/memcontrol.h |    3 ++
 mm/memcontrol.c            |   86 +++++++++++++++++++++++++++++++++++++++----
 2 files changed, 81 insertions(+), 8 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 067115c..ef2eec7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -28,6 +28,9 @@ struct mm_struct;
 /* Stats that can be updated by kernel. */
 enum mem_cgroup_page_stat_item {
 	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
+	MEMCG_NR_FILE_DIRTY, /* # of dirty pages in page cache */
+	MEMCG_NR_FILE_WRITEBACK, /* # of pages under writeback */
+	MEMCG_NR_FILE_UNSTABLE_NFS, /* # of NFS unstable pages */
 };
 
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 369879a..3884a85 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -85,10 +85,13 @@ enum mem_cgroup_stat_index {
 	 */
 	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
-	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
 	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
 	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
+	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
+	MEM_CGROUP_STAT_FILE_DIRTY,	/* # of dirty pages in page cache */
+	MEM_CGROUP_STAT_FILE_WRITEBACK,		/* # of pages under writeback */
+	MEM_CGROUP_STAT_FILE_UNSTABLE_NFS,	/* # of NFS unstable pages */
 	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
 	/* incremented at every  pagein/pageout */
 	MEM_CGROUP_EVENTS = MEM_CGROUP_STAT_DATA,
@@ -1641,6 +1644,44 @@ void mem_cgroup_update_page_stat(struct page *page,
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
@@ -2145,6 +2186,17 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 	memcg_check_events(mem, pc->page);
 }
 
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
  * __mem_cgroup_move_account - move account of the page
  * @pc:	page_cgroup of the page.
@@ -2171,13 +2223,18 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
 	VM_BUG_ON(!PageCgroupUsed(pc));
 	VM_BUG_ON(pc->mem_cgroup != from);
 
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
+					MEM_CGROUP_STAT_FILE_DIRTY);
+	if (PageCgroupFileWriteback(pc))
+		mem_cgroup_move_account_page_stat(from, to,
+					MEM_CGROUP_STAT_FILE_WRITEBACK);
+	if (PageCgroupFileUnstableNFS(pc))
+		mem_cgroup_move_account_page_stat(from, to,
+					MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
 	mem_cgroup_charge_statistics(from, pc, false);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
@@ -3552,6 +3609,9 @@ enum {
 	MCS_PGPGIN,
 	MCS_PGPGOUT,
 	MCS_SWAP,
+	MCS_FILE_DIRTY,
+	MCS_WRITEBACK,
+	MCS_UNSTABLE_NFS,
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
 	MCS_INACTIVE_FILE,
@@ -3574,6 +3634,9 @@ struct {
 	{"pgpgin", "total_pgpgin"},
 	{"pgpgout", "total_pgpgout"},
 	{"swap", "total_swap"},
+	{"dirty", "total_dirty"},
+	{"writeback", "total_writeback"},
+	{"nfs_unstable", "total_nfs_unstable"},
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
@@ -3603,6 +3666,13 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
 	}
 
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_DIRTY);
+	s->stat[MCS_FILE_DIRTY] += val * PAGE_SIZE;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_WRITEBACK);
+	s->stat[MCS_WRITEBACK] += val * PAGE_SIZE;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
+	s->stat[MCS_UNSTABLE_NFS] += val * PAGE_SIZE;
+
 	/* per zone stat */
 	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
 	s->stat[MCS_INACTIVE_ANON] += val * PAGE_SIZE;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
