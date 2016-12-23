Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3142280270
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 05:52:02 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w13so40489608wmw.0
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 02:52:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jj1si35210218wjb.195.2016.12.23.02.52.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Dec 2016 02:52:01 -0800 (PST)
Date: Fri, 23 Dec 2016 11:51:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM: Better, but still there on
Message-ID: <20161223105157.GB23109@dhcp22.suse.cz>
References: <20161217000203.GC23392@dhcp22.suse.cz>
 <20161217125950.GA3321@boerne.fritz.box>
 <862a1ada-17f1-9cff-c89b-46c47432e89f@I-love.SAKURA.ne.jp>
 <20161217210646.GA11358@boerne.fritz.box>
 <20161219134534.GC5164@dhcp22.suse.cz>
 <20161220020829.GA5449@boerne.fritz.box>
 <20161221073658.GC16502@dhcp22.suse.cz>
 <20161222101028.GA11105@ppc-nas.fritz.box>
 <20161222191719.GA19898@dhcp22.suse.cz>
 <20161222214611.GA3015@boerne.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161222214611.GA3015@boerne.fritz.box>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nils Holland <nholland@tisys.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

TL;DR
drop the last patch, check whether memory cgroup is enabled and retest
with cgroup_disable=memory to see whether this is memcg related and if
it is _not_ then try to test with the patch below

On Thu 22-12-16 22:46:11, Nils Holland wrote:
> On Thu, Dec 22, 2016 at 08:17:19PM +0100, Michal Hocko wrote:
> > TL;DR I still do not see what is going on here and it still smells like
> > multiple issues. Please apply the patch below on _top_ of what you had.
> 
> I've run the usual procedure again with the new patch on top and the
> log is now up at:
> 
> http://ftp.tisys.org/pub/misc/boerne_2016-12-22_2.log.xz

OK, so there are still large page cache fluctuations even with the
locking applied:
472.042409 kswapd0-32 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=450451 inactive=0 total_active=210056 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
472.042442 kswapd0-32 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=0 inactive=0 total_active=0 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
472.042451 kswapd0-32 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=0 inactive=0 total_active=12 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
472.042484 kswapd0-32 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=11944 inactive=0 total_active=117286 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB

One thing that didn't occure to me previously was that this might be an
effect of the memory cgroups. Do you have memory cgroups enabled? If
yes then reruning with cgroup_disable=memory would be interesting
as well.

Anyway, now I am looking at get_scan_count which determines how many pages
we should scan on each LRU list. The problem I can see there is that
it doesn't reflect eligible zones (or at least it doesn't do that
consistently). So it might happen we simply decide to scan the whole LRU
list (when we get down to prio 0 because we cannot make any progress)
and then _slowly_ scan through it in SWAP_CLUSTER_MAX chunks each
time. This can take a lot of time and who knows what might have happened
if there are many such reclaimers in parallel.

[...]

> This might suggest - although I have to admit, again, that this is
> inconclusive, as I've not used a final 4.9 kernel - that you could
> very easily reproduce the issue yourself by just setting up a 32 bit
> system with a btrfs filesystem and then unpacking a few huge tarballs.
> Of course, I'm more than happy to continue giving any patches sent to
> me a spin, but I thought I'd still mention this in case it makes
> things easier for you. :-)

I would appreciate to stick with your setup to not pull new unknows into
the picture.
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index cb82913b62bb..533bb591b0be 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -243,6 +243,35 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
 }
 
 /*
+ * Return the number of pages on the given lru which are eligibne for the
+ * given zone_idx
+ */
+static unsigned long lruvec_lru_size_zone_idx(struct lruvec *lruvec,
+		enum lru_list lru, int zone_idx)
+{
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
+	unsigned long lru_size;
+	int zid;
+
+	if (!mem_cgroup_disabled())
+		return mem_cgroup_get_lru_size(lruvec, lru);
+
+	lru_size = lruvec_lru_size(lruvec, lru);
+	for (zid = zone_idx + 1; zid < MAX_NR_ZONES; zid++) {
+		struct zone *zone = &pgdat->node_zones[zid];
+		unsigned long size;
+
+		if (!managed_zone(zone))
+			continue;
+
+		size = zone_page_state(zone, NR_ZONE_LRU_BASE + lru);
+		lru_size -= min(size, lru_size);
+	}
+
+	return lru_size;
+}
+
+/*
  * Add a shrinker callback to be called from the vm.
  */
 int register_shrinker(struct shrinker *shrinker)
@@ -2228,7 +2257,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * system is under heavy pressure.
 	 */
 	if (!inactive_list_is_low(lruvec, true, sc) &&
-	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority) {
+	    lruvec_lru_size_zone_idx(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -2295,7 +2324,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			unsigned long size;
 			unsigned long scan;
 
-			size = lruvec_lru_size(lruvec, lru);
+			size = lruvec_lru_size_zone_idx(lruvec, lru, sc->reclaim_idx);
 			scan = size >> sc->priority;
 
 			if (!scan && pass && force_scan)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
