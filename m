Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC936B0011
	for <linux-mm@kvack.org>; Fri, 13 May 2011 04:50:09 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [RFC][PATCH v7 04/14] memcg: add dirty page accounting infrastructure
Date: Fri, 13 May 2011 01:47:43 -0700
Message-Id: <1305276473-14780-5-git-send-email-gthelen@google.com>
In-Reply-To: <1305276473-14780-1-git-send-email-gthelen@google.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>

Add memcg routines to count dirty, writeback, and unstable_NFS pages.
These routines are not yet used by the kernel to count such pages.  A
later change adds kernel calls to these new routines.

As inode pages are marked dirty, if the dirtied page's cgroup differs
from the inode's cgroup, then mark the inode shared across several
cgroup.

Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Andrea Righi <arighi@develer.com>
---
Changelog since v6:
- Mark inode as cgroup-shared if charging a page from a cgroup other than
  the inode cgroup.
- Mark inode as cgroup-shared if migrating a page to a different cgroup.

 include/linux/memcontrol.h |    8 +++-
 mm/memcontrol.c            |  105 +++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 105 insertions(+), 8 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 14b6d67..f1261e5 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
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
 
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3a792b7..a4cb991 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
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
@@ -1860,6 +1863,7 @@ void mem_cgroup_update_page_stat(struct page *page,
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc = lookup_page_cgroup(page);
+	struct address_space *mapping;
 	bool need_unlock = false;
 	unsigned long uninitialized_var(flags);
 
@@ -1888,6 +1892,53 @@ void mem_cgroup_update_page_stat(struct page *page,
 			ClearPageCgroupFileMapped(pc);
 		idx = MEM_CGROUP_STAT_FILE_MAPPED;
 		break;
+
+	case MEMCG_NR_FILE_DIRTY:
+		/* Use Test{Set,Clear} to only un/charge the memcg once. */
+		if (val > 0) {
+			mapping = page_mapping(page);
+			if (TestSetPageCgroupFileDirty(pc))
+				val = 0;
+			else if (mapping &&
+				 (mapping->i_memcg != css_id(&mem->css)))
+				/*
+				 * If the inode is being dirtied by a memcg
+				 * other than the one that marked it dirty, then
+				 * mark the inode shared by multiple memcg.
+				 */
+				mapping->i_memcg = I_MEMCG_SHARED;
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
@@ -2447,6 +2498,17 @@ void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
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
@@ -2495,13 +2557,28 @@ static int mem_cgroup_move_account(struct page *page,
 
 	move_lock_page_cgroup(pc, &flags);
 
-	if (PageCgroupFileMapped(pc)) {
-		/* Update mapped_file data for mem_cgroup */
-		preempt_disable();
-		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		preempt_enable();
+	if (PageCgroupFileMapped(pc))
+		mem_cgroup_move_account_page_stat(from, to,
+					MEM_CGROUP_STAT_FILE_MAPPED);
+	if (PageCgroupFileDirty(pc)) {
+		mem_cgroup_move_account_page_stat(from, to,
+						  MEM_CGROUP_STAT_FILE_DIRTY);
+		/*
+		 * Moving a dirty file page between memcg makes the underlying
+		 * inode shared.  If the new (to) cgroup attempts writeback it
+		 * should consider this inode.  If the old (from) cgroup
+		 * attempts writeback it likely has other pages in the same
+		 * inode.  The inode is now shared by the to and from cgroups.
+		 * So mark the inode as shared.
+		 */
+		page_mapping(page)->i_memcg = I_MEMCG_SHARED;
 	}
+	if (PageCgroupFileWriteback(pc))
+		mem_cgroup_move_account_page_stat(from, to,
+					MEM_CGROUP_STAT_FILE_WRITEBACK);
+	if (PageCgroupFileUnstableNFS(pc))
+		mem_cgroup_move_account_page_stat(from, to,
+					MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
 	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -nr_pages);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
@@ -3981,6 +4058,9 @@ enum {
 	MCS_SOFT_KSWAPD_SCAN,
 	MCS_SOFT_DIRECT_STEAL,
 	MCS_SOFT_DIRECT_SCAN,
+	MCS_FILE_DIRTY,
+	MCS_WRITEBACK,
+	MCS_UNSTABLE_NFS,
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
 	MCS_INACTIVE_FILE,
@@ -4009,6 +4089,9 @@ struct {
 	{"soft_kswapd_scan", "total_soft_scan"},
 	{"soft_direct_steal", "total_soft_direct_steal"},
 	{"soft_direct_scan", "total_soft_direct_scan"},
+	{"dirty", "total_dirty"},
+	{"writeback", "total_writeback"},
+	{"nfs_unstable", "total_nfs_unstable"},
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
@@ -4050,6 +4133,14 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGMAJFAULT);
 	s->stat[MCS_PGMAJFAULT] += val;
 
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
