Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 89EC96B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 11:18:22 -0400 (EDT)
Date: Thu, 31 May 2012 23:18:16 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120531151816.GA32252@localhost>
References: <1338219535-7874-1-git-send-email-mhocko@suse.cz>
 <20120529030857.GA7762@localhost>
 <20120529072853.GD1734@cmpxchg.org>
 <20120529084848.GC10469@localhost>
 <20120529093511.GE1734@cmpxchg.org>
 <20120529135101.GD15293@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
Content-Disposition: inline
In-Reply-To: <20120529135101.GD15293@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, May 29, 2012 at 03:51:01PM +0200, Michal Hocko wrote:
> On Tue 29-05-12 11:35:11, Johannes Weiner wrote:
> [...]
> >         if (nr_writeback && nr_writeback >= (nr_taken >> (DEF_PRIORITY-priority)))
> >                 wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> > 
> > But the problem is the part declaring the zone congested:
> > 
> >         /*
> >          * Tag a zone as congested if all the dirty pages encountered were
> >          * backed by a congested BDI. In this case, reclaimers should just
> >          * back off and wait for congestion to clear because further reclaim
> >          * will encounter the same problem
> >          */
> >         if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
> >                 zone_set_flag(mz->zone, ZONE_CONGESTED);
> > 
> > Note the global_reclaim().  It would be nice to have these two operate
> > against the lruvec of sc->target_mem_cgroup and mz->zone instead.  The
> > problem is that ZONE_CONGESTED clearing happens in kswapd alone, which
> > is not necessarily involved in a memcg-constrained load, so we need to
> > find clearing sites that work for both global and memcg reclaim.
> 
> OK, I have tried it with a simpler approach:
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c978ce4..e45cf2a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1294,8 +1294,12 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	 *                     isolated page is PageWriteback
>  	 */
>  	if (nr_writeback && nr_writeback >=
> -			(nr_taken >> (DEF_PRIORITY - sc->priority)))
> -		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> +			(nr_taken >> (DEF_PRIORITY - sc->priority))) {
> +		if (global_reclaim(sc))
> +			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> +		else
> +			congestion_wait(BLK_RW_ASYNC, HZ/10);
> +	}
>  
>  	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
>  		zone_idx(zone),
> 
> without 'lruvec-zone' congestion flag and it worked reasonably well, for
> my testcase at least (no OOM). We still could stall even if we managed
> to writeback pages in the meantime but we should at least prevent from
> the problem you are mentioning (most of the time).
> 
> The issue with pagevec zone tagging is, as you mentioned, that the
> flag clearing places are not that easy to get right because we do
> not have anything like zone_watermark_ok in a memcg context. I am even
> thinking whether it is possible without per-memcg dirtly accounting.
> 
> To be honest, I was considering congestion waiting at the beginning as
> well but I hate using an arbitrary timeout when we are, in fact, waiting
> for a specific event.
> Nevertheless I do acknowledge your concern with accidental page reclaim
> pages in the middle of the LRU because of clean page cache which would
> lead to an unnecessary stalls.

Hi Michal,

Now the only concern is, to confirm whether the patch will impact
interactive performance when there are not so many dirty pages in the
memcg.

For example, running a dd write to disk plus several another dd's read
from either disk or sparse file.

There is no dirty accounting for memcg, however if you run workloads
in one single 100MB memcg, the global dirty pages in /proc/vmstat will
be exactly the dirty number inside that memcg. Thus we can create
situations with eg. 10%, 30%, 50% dirty pages inside memcg and watch
how well your patch performs.

I happen to have a debug patch for showing the number of page reclaim
stalls.  It applies cleanly to 3.4, and you'll need to add accounting
to your new code. If it shows low stall numbers in the cases of 10-30%
dirty pages even if they are quickly rotated due to fast reads, we may
go ahead with any approach :-)

Thanks,
Fengguang

--VS++wcV0S1rZb1Fb
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="mm-debugfs-vmscan-stalls-0.patch"

Subject: mm: create /debug/vm for page reclaim stalls
Date: Fri Sep 10 13:05:57 CST 2010

Create /debug/vm/ -- a convenient place for kernel hackers to play with
VM variables.

The first exported is vm_dirty_pressure for avoiding excessive pageout()s.
It ranges from 0 to 1024, the lower value, the lower dirty limit.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/backing-dev.c |   10 ++++++++++
 mm/internal.h    |    5 +++++
 mm/migrate.c     |    3 +++
 mm/vmscan.c      |   45 +++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 61 insertions(+), 2 deletions(-)

--- linux.orig/mm/vmscan.c	2012-05-31 22:43:42.239868770 +0800
+++ linux/mm/vmscan.c	2012-05-31 22:43:49.815868950 +0800
@@ -759,6 +759,8 @@ static enum page_references page_check_r
 	return PAGEREF_RECLAIM;
 }
 
+u32 nr_reclaim_wait_writeback;
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -820,9 +822,10 @@ static unsigned long shrink_page_list(st
 			 * for the IO to complete.
 			 */
 			if ((sc->reclaim_mode & RECLAIM_MODE_SYNC) &&
-			    may_enter_fs)
+			    may_enter_fs) {
 				wait_on_page_writeback(page);
-			else {
+				nr_reclaim_wait_writeback++;
+			} else {
 				unlock_page(page);
 				goto keep_lumpy;
 			}
@@ -3660,3 +3663,41 @@ void scan_unevictable_unregister_node(st
 	device_remove_file(&node->dev, &dev_attr_scan_unevictable_pages);
 }
 #endif
+
+#if defined(CONFIG_DEBUG_FS)
+#include <linux/debugfs.h>
+
+static struct dentry *vm_debug_root;
+
+static int __init vm_debug_init(void)
+{
+	struct dentry *dentry;
+
+	vm_debug_root = debugfs_create_dir("vm", NULL);
+	if (!vm_debug_root)
+		goto fail;
+
+#ifdef CONFIG_MIGRATION
+	dentry = debugfs_create_u32("nr_migrate_wait_writeback", 0644,
+				    vm_debug_root, &nr_migrate_wait_writeback);
+#endif
+
+	dentry = debugfs_create_u32("nr_reclaim_wait_writeback", 0644,
+				    vm_debug_root, &nr_reclaim_wait_writeback);
+
+	dentry = debugfs_create_u32("nr_reclaim_wait_congested", 0644,
+				    vm_debug_root, &nr_reclaim_wait_congested);
+
+	dentry = debugfs_create_u32("nr_congestion_wait", 0644,
+				    vm_debug_root, &nr_congestion_wait);
+
+	if (!dentry)
+		goto fail;
+
+	return 0;
+fail:
+	return -ENOMEM;
+}
+
+module_init(vm_debug_init);
+#endif /* CONFIG_DEBUG_FS */
--- linux.orig/mm/migrate.c	2012-05-31 22:43:42.215868770 +0800
+++ linux/mm/migrate.c	2012-05-31 22:43:49.815868950 +0800
@@ -674,6 +674,8 @@ static int move_to_new_page(struct page
 	return rc;
 }
 
+u32 nr_migrate_wait_writeback;
+
 static int __unmap_and_move(struct page *page, struct page *newpage,
 			int force, bool offlining, enum migrate_mode mode)
 {
@@ -742,6 +744,7 @@ static int __unmap_and_move(struct page
 		if (!force)
 			goto uncharge;
 		wait_on_page_writeback(page);
+		nr_migrate_wait_writeback++;
 	}
 	/*
 	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
--- linux.orig/mm/internal.h	2012-05-31 22:43:42.231868771 +0800
+++ linux/mm/internal.h	2012-05-31 22:43:49.815868950 +0800
@@ -309,3 +309,8 @@ extern u64 hwpoison_filter_flags_mask;
 extern u64 hwpoison_filter_flags_value;
 extern u64 hwpoison_filter_memcg;
 extern u32 hwpoison_filter_enable;
+
+extern u32 nr_migrate_wait_writeback;
+extern u32 nr_reclaim_wait_congested;
+extern u32 nr_congestion_wait;
+
--- linux.orig/mm/backing-dev.c	2012-05-31 22:43:42.223868770 +0800
+++ linux/mm/backing-dev.c	2012-05-31 22:43:49.815868950 +0800
@@ -12,6 +12,8 @@
 #include <linux/device.h>
 #include <trace/events/writeback.h>
 
+#include "internal.h"
+
 static atomic_long_t bdi_seq = ATOMIC_LONG_INIT(0);
 
 struct backing_dev_info default_backing_dev_info = {
@@ -805,6 +807,9 @@ void set_bdi_congested(struct backing_de
 }
 EXPORT_SYMBOL(set_bdi_congested);
 
+u32 nr_reclaim_wait_congested;
+u32 nr_congestion_wait;
+
 /**
  * congestion_wait - wait for a backing_dev to become uncongested
  * @sync: SYNC or ASYNC IO
@@ -825,6 +830,10 @@ long congestion_wait(int sync, long time
 	ret = io_schedule_timeout(timeout);
 	finish_wait(wqh, &wait);
 
+	nr_congestion_wait++;
+	trace_printk("%pS %pS\n",
+		     __builtin_return_address(0),
+		     __builtin_return_address(1));
 	trace_writeback_congestion_wait(jiffies_to_usecs(timeout),
 					jiffies_to_usecs(jiffies - start));
 
@@ -879,6 +888,7 @@ long wait_iff_congested(struct zone *zon
 	ret = io_schedule_timeout(timeout);
 	finish_wait(wqh, &wait);
 
+	nr_reclaim_wait_congested++;
 out:
 	trace_writeback_wait_iff_congested(jiffies_to_usecs(timeout),
 					jiffies_to_usecs(jiffies - start));

--VS++wcV0S1rZb1Fb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
