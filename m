Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3E5626B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 04:37:49 -0400 (EDT)
Date: Tue, 9 Jun 2009 17:07:35 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when
	zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
Message-ID: <20090609090735.GC7108@localhost>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-2-git-send-email-mel@csn.ul.ie> <20090609015822.GA6740@localhost> <20090609081424.GD18380@csn.ul.ie> <20090609082539.GA6897@localhost> <20090609083153.GG18380@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090609083153.GG18380@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "linuxram@us.ibm.com" <linuxram@us.ibm.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 04:31:54PM +0800, Mel Gorman wrote:
> On Tue, Jun 09, 2009 at 04:25:39PM +0800, Wu Fengguang wrote:
> > On Tue, Jun 09, 2009 at 04:14:25PM +0800, Mel Gorman wrote:
> > > On Tue, Jun 09, 2009 at 09:58:22AM +0800, Wu Fengguang wrote:
> > > > On Mon, Jun 08, 2009 at 09:01:28PM +0800, Mel Gorman wrote:
> > > > > On NUMA machines, the administrator can configure zone_reclaim_mode that is a
> > > > > more targetted form of direct reclaim. On machines with large NUMA distances,
> > > > > zone_reclaim_mode defaults to 1 meaning that clean unmapped pages will be
> > > > > reclaimed if the zone watermarks are not being met. The problem is that
> > > > > zone_reclaim() can be in a situation where it scans excessively without
> > > > > making progress.
> > > > > 
> > > > > One such situation is where a large tmpfs mount is occupying a large
> > > > > percentage of memory overall. The pages do not get cleaned or reclaimed by
> > > > > zone_reclaim(), but the lists are uselessly scanned frequencly making the
> > > > > CPU spin at 100%. The scanning occurs because zone_reclaim() cannot tell
> > > > > in advance the scan is pointless because the counters do not distinguish
> > > > > between pagecache pages backed by disk and by RAM.  The observation in
> > > > > the field is that malloc() stalls for a long time (minutes in some cases)
> > > > > when this situation occurs.
> > > > > 
> > > > > Accounting for ram-backed file pages was considered but not implemented on
> > > > > the grounds it would be introducing new branches and expensive checks into
> > > > > the page cache add/remove patches and increase the number of statistics
> > > > > needed in the zone. As zone_reclaim() failing is currently considered a
> > > > > corner case, this seemed like overkill. Note, if there are a large number
> > > > > of reports about CPU spinning at 100% on NUMA that is fixed by disabling
> > > > > zone_reclaim, then this assumption is false and zone_reclaim() scanning
> > > > > and failing is not a corner case but a common occurance
> > > > > 
> > > > > This patch reintroduces zone_reclaim_interval which was removed by commit
> > > > > 34aa1330f9b3c5783d269851d467326525207422 [zoned vm counters: zone_reclaim:
> > > > > remove /proc/sys/vm/zone_reclaim_interval] because the zone counters were
> > > > > considered sufficient to determine in advance if the scan would succeed.
> > > > > As unsuccessful scans can still occur, zone_reclaim_interval is still
> > > > > required.
> > > > 
> > > > Can we avoid the user visible parameter zone_reclaim_interval?
> > > > 
> > > 
> > > You could, but then there is no way of disabling it by setting it to 0
> > > either. I can't imagine why but the desired behaviour might really be to
> > > spin and never go off-node unless there is no other option. They might
> > > want to set it to 0 for example when determining what the right value for
> > > zone_reclaim_mode is for their workloads.
> > > 
> > > > That means to introduce some heuristics for it.
> > > 
> > > I suspect the vast majority of users will ignore it unless they are runing
> > > zone_reclaim_mode at the same time and even then will probably just leave
> > > it as 30 as a LRU scan every 30 seconds worst case is not going to show up
> > > on many profiles.
> > > 
> > > > Since the whole point
> > > > is to avoid 100% CPU usage, we can take down the time used for this
> > > > failed zone reclaim (T) and forbid zone reclaim until (NOW + 100*T).
> > > > 
> > > 
> > > i.e. just fix it internally at 100 seconds? How is that better than
> > > having an obscure tunable? I think if this heuristic exists at all, it's
> > > important that an administrator be able to turn it off if absolutly
> > > necessary and so something must be user-visible.
> > 
> > That 100*T don't mean 100 seconds. It means to keep CPU usage under 1%:
> > after busy scanning for time T, let's go relax for 100*T.
> > 
> 
> Do I have a means of calculating what my CPU usage is as a result of
> scanning the LRU list?
> 
> If I don't and the machine is busy, would I not avoid scanning even in
> situations where it should have been scanned?

I guess we don't really care about the exact number for the ratio 100.
If the box is busy, it automatically scales the effective ratio to 200
or more, which I think is reasonable behavior.

Something like this.

Thanks,
Fengguang

---
 include/linux/mmzone.h |    2 ++
 mm/vmscan.c            |   11 +++++++++++
 2 files changed, 13 insertions(+)

--- linux.orig/include/linux/mmzone.h
+++ linux/include/linux/mmzone.h
@@ -334,6 +334,8 @@ struct zone {
 	/* Zone statistics */
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
 
+	unsigned long		zone_reclaim_relax;
+
 	/*
 	 * prev_priority holds the scanning priority for this zone.  It is
 	 * defined as the scanning priority at which we achieved our reclaim
--- linux.orig/mm/vmscan.c
+++ linux/mm/vmscan.c
@@ -2453,6 +2453,7 @@ int zone_reclaim(struct zone *zone, gfp_
 	int ret;
 	long nr_unmapped_file_pages;
 	long nr_slab_reclaimable;
+	unsigned long t;
 
 	/*
 	 * Zone reclaim reclaims unmapped file backed pages and
@@ -2475,6 +2476,11 @@ int zone_reclaim(struct zone *zone, gfp_
 	if (zone_is_all_unreclaimable(zone))
 		return 0;
 
+	if (time_in_range(zone->zone_reclaim_relax - 10000 * HZ,
+			  jiffies,
+			  zone->zone_reclaim_relax))
+		return 0;
+
 	/*
 	 * Do not scan if the allocation should not be delayed.
 	 */
@@ -2493,7 +2499,12 @@ int zone_reclaim(struct zone *zone, gfp_
 
 	if (zone_test_and_set_flag(zone, ZONE_RECLAIM_LOCKED))
 		return 0;
+	t = jiffies;
 	ret = __zone_reclaim(zone, gfp_mask, order);
+	if (sc.nr_reclaimed == 0) {
+		t = min_t(unsigned long, 10000 * HZ, 100 * (jiffies - t));
+		zone->zone_reclaim_relax = jiffies + t;
+	}
 	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
 
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
