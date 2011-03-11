Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A4E018D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:44:50 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v6 3/9] memcg: add dirty page accounting infrastructure
Date: Fri, 11 Mar 2011 10:43:25 -0800
Message-Id: <1299869011-26152-4-git-send-email-gthelen@google.com>
In-Reply-To: <1299869011-26152-1-git-send-email-gthelen@google.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>, Greg Thelen <gthelen@google.com>

Add memcg routines to track dirty, writeback, and unstable_NFS pages.
These routines are not yet used by the kernel to count such pages.
A later change adds kernel calls to these new routines.

Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Andrea Righi <arighi@develer.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
Changelog since v5:
- Updated enum mem_cgroup_page_stat_item comment.

Changelog since v1:
- Renamed "nfs"/"total_nfs" to "nfs_unstable"/"total_nfs_unstable" in per cgroup
  memory.stat to match /proc/meminfo.
- Rename (for clarity):
  - mem_cgroup_write_page_stat_item -> mem_cgroup_page_stat_item
  - mem_cgroup_read_page_stat_item -> mem_cgroup_nr_pages_item
- Remove redundant comments.
- Made mem_cgroup_move_account_page_stat() inline.

 include/linux/memcontrol.h |    8 ++++-
 mm/memcontrol.c            |   87 ++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 86 insertions(+), 9 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5a5ce70..549fa7c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -25,9 +25,15 @@ struct page_cgroup;
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
 
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4407dd0..b8f517d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -83,8 +83,11 @@ enum mem_cgroup_stat_index {
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
@@ -1692,6 +1695,44 @@ void mem_cgroup_update_page_stat(struct page *page,
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
@@ -2251,6 +2292,17 @@ void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
 }
 #endif
 
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
@@ -2299,13 +2351,18 @@ static int mem_cgroup_move_account(struct page *page,
 
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
+					MEM_CGROUP_STAT_FILE_DIRTY);
+	if (PageCgroupFileWriteback(pc))
+		mem_cgroup_move_account_page_stat(from, to,
+					MEM_CGROUP_STAT_FILE_WRITEBACK);
+	if (PageCgroupFileUnstableNFS(pc))
+		mem_cgroup_move_account_page_stat(from, to,
+					MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
 	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -nr_pages);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
@@ -3772,6 +3829,9 @@ enum {
 	MCS_PGPGIN,
 	MCS_PGPGOUT,
 	MCS_SWAP,
+	MCS_FILE_DIRTY,
+	MCS_WRITEBACK,
+	MCS_UNSTABLE_NFS,
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
 	MCS_INACTIVE_FILE,
@@ -3794,6 +3854,9 @@ struct {
 	{"pgpgin", "total_pgpgin"},
 	{"pgpgout", "total_pgpgout"},
 	{"swap", "total_swap"},
+	{"dirty", "total_dirty"},
+	{"writeback", "total_writeback"},
+	{"nfs_unstable", "total_nfs_unstable"},
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
@@ -3823,6 +3886,14 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
 	}
 
+	/* dirty stat */
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
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
