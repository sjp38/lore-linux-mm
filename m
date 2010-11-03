Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A034D6B0098
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 18:41:11 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id oA3Mf85U009614
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 15:41:08 -0700
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by kpbe20.cbf.corp.google.com with ESMTP id oA3Medr4023589
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 15:41:06 -0700
Received: by pwj9 with SMTP id 9so513953pwj.35
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 15:41:06 -0700 (PDT)
Date: Wed, 3 Nov 2010 15:40:55 -0700
From: Mandeep Singh Baines <msb@chromium.org>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
Message-ID: <20101103224055.GC19646@google.com>
References: <20101028191523.GA14972@google.com>
 <20101101012322.605C.A69D9226@jp.fujitsu.com>
 <20101101182416.GB31189@google.com>
 <4CCF0BE3.2090700@redhat.com>
 <AANLkTi=src1L0gAFsogzCmejGOgg5uh=9O4Uw+ZmfBg4@mail.gmail.com>
 <4CCF8151.3010202@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CCF8151.3010202@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mandeep Singh Baines <msb@chromium.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

Rik van Riel (riel@redhat.com) wrote:
> On 11/01/2010 03:43 PM, Mandeep Singh Baines wrote:
> 
> >Yes, this prevents you from reclaiming the active list all at once. But if the
> >memory pressure doesn't go away, you'll start to reclaim the active list
> >little by little. First you'll empty the inactive list, and then
> >you'll start scanning
> >the active list and pulling pages from inactive to active. The problem is that
> >there is no minimum time limit to how long a page will sit in the inactive list
> >before it is reclaimed. Just depends on scan rate which does not depend
> >on time.
> >
> >In my experiments, I saw the active list get smaller and smaller
> >over time until eventually it was only a few MB at which point the system came
> >grinding to a halt due to thrashing.
> 
> I believe that changing the active/inactive ratio has other
> potential thrashing issues.  Specifically, when the inactive
> list is too small, pages may not stick around long enough to
> be accessed multiple times and get promoted to the active
> list, even when they are in active use.
> 
> I prefer a more flexible solution, that automatically does
> the right thing.
> 
> The problem you see is that the file list gets reclaimed
> very quickly, even when it is already very small.
> 
> I wonder if a possible solution would be to limit how fast
> file pages get reclaimed, when the page cache is very small.
> Say, inactive_file * active_file < 2 * zone->pages_high ?
> 
> At that point, maybe we could slow down the reclaiming of
> page cache pages to be significantly slower than they can
> be refilled by the disk.  Maybe 100 pages a second - that
> can be refilled even by an actual spinning metal disk
> without even the use of readahead.
> 
> That can be rounded up to one batch of SWAP_CLUSTER_MAX
> file pages every 1/4 second, when the number of page cache
> pages is very low.
> 
> This way HPC and virtual machine hosting nodes can still
> get rid of totally unused page cache, but on any system
> that actually uses page cache, some minimal amount of
> cache will be protected under heavy memory pressure.
> 
> Does this sound like a reasonable approach?
> 
> I realize the threshold may have to be tweaked...
> 
> The big question is, how do we integrate this with the
> OOM killer?  Do we pretend we are out of memory when
> we've hit our file cache eviction quota and kill something?
> 
> Would there be any downsides to this approach?
> 
> Are there any volunteers for implementing this idea?
> (Maybe someone who needs the feature?)
> 

I've created a patch which takes a slightly different approach.
Instead of limiting how fast pages get reclaimed, the patch limits
how fast the active list gets scanned. This should result in the
active list being a better measure of the working set. I've seen
fairly good results with this patch and a scan inteval of 1
centisecond. I see no thrashing when the scan interval is non-zero.

I've made it a tunable because I don't know what to set the scan
interval. The final patch could set the value based on HZ and some
other system parameters. Maybe relate it to sched_period?

---

[PATCH] vmscan: add a configurable scan interval

On ChromiumOS, we see a lot of thrashing under low memory. We do not
use swap, so the mm system can only free file-backed pages. Eventually,
we are left with little file back pages remaining (a few MB) and the
system becomes unresponsive due to thrashing.

Our preference is for the system to OOM instead of becoming unresponsive.

This patch create a tunable, vmscan_interval_centisecs, for controlling
the minimum interval between active list scans. At 0, I see the same
thrashing. At 1, I see no thrashing. The mm system does a good job
of protecting the working set. If a page has been referenced in the
last vmscan_interval_centisecs it is kept in memory.

Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
---
 include/linux/mm.h     |    2 ++
 include/linux/mmzone.h |    9 +++++++++
 kernel/sysctl.c        |    7 +++++++
 mm/page_alloc.c        |    2 ++
 mm/vmscan.c            |   21 +++++++++++++++++++--
 5 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 721f451..af058f6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -36,6 +36,8 @@ extern int sysctl_legacy_va_layout;
 #define sysctl_legacy_va_layout 0
 #endif
 
+extern unsigned int vmscan_interval;
+
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 39c24eb..6c4b6e1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -415,6 +415,15 @@ struct zone {
 	unsigned long		present_pages;	/* amount of memory (excluding holes) */
 
 	/*
+	 * To avoid over-scanning, we store the time of the last
+	 * scan (in jiffies).
+	 *
+	 * The anon LRU stats live in [0], file LRU stats in [1]
+	 */
+
+	unsigned long		last_scan[2];
+
+	/*
 	 * rarely used fields:
 	 */
 	const char		*name;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c33a1ed..c34251d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1318,6 +1318,13 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.procname	= "scan_interval_centisecs",
+		.data		= &vmscan_interval,
+		.maxlen		= sizeof(vmscan_interval),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 
 /*
  * NOTE: do not add new entries to this table unless you have read
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 07a6544..46991d2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -51,6 +51,7 @@
 #include <linux/kmemleak.h>
 #include <linux/memory.h>
 #include <linux/compaction.h>
+#include <linux/jiffies.h>
 #include <trace/events/kmem.h>
 #include <linux/ftrace_event.h>
 
@@ -4150,6 +4151,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		BUG_ON(ret);
 		memmap_init(size, nid, j, zone_start_pfn);
 		zone_start_pfn += size;
+		zone->last_scan[0] = zone->last_scan[1] = jiffies;
 	}
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b8a6fdc..be45b91 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -40,6 +40,7 @@
 #include <linux/memcontrol.h>
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
+#include <linux/jiffies.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -136,6 +137,11 @@ struct scan_control {
 int vm_swappiness = 60;
 long vm_total_pages;	/* The total number of pages which the VM controls */
 
+/*
+ * Minimum interval between active list scans.
+ */
+unsigned int vmscan_interval = 0;
+
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
@@ -1659,14 +1665,25 @@ static int inactive_list_is_low(struct zone *zone, struct scan_control *sc,
 		return inactive_anon_is_low(zone, sc);
 }
 
+static int list_scanned_recently(struct zone *zone, int file)
+{
+	unsigned long now = jiffies;
+	unsigned long delta = vmscan_interval * HZ / 100;
+
+	return time_after(zone->last_scan[file] + delta, now);
+}
+
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 	struct zone *zone, struct scan_control *sc, int priority)
 {
 	int file = is_file_lru(lru);
 
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(zone, sc, file))
-		    shrink_active_list(nr_to_scan, zone, sc, priority, file);
+		if (inactive_list_is_low(zone, sc, file) &&
+		    !list_scanned_recently(zone, file)) {
+			shrink_active_list(nr_to_scan, zone, sc, priority, file);
+			zone->last_scan[file] = jiffies;
+		}
 		return 0;
 	}
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
