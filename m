Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f72.google.com (mail-qg0-f72.google.com [209.85.192.72])
	by kanga.kvack.org (Postfix) with ESMTP id E72E46B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 11:14:24 -0400 (EDT)
Received: by mail-qg0-f72.google.com with SMTP id k63so95335512qgf.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 08:14:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u144si30259541qka.104.2016.05.23.08.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 08:14:23 -0700 (PDT)
Date: Mon, 23 May 2016 17:14:19 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: zone_reclaimable() leads to livelock in __alloc_pages_slowpath()
Message-ID: <20160523151419.GA8284@redhat.com>
References: <20160520202817.GA22201@redhat.com>
 <20160523072904.GC2278@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160523072904.GC2278@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/23, Michal Hocko wrote:
>
> > 	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
> > 	if (nr_scanned)
> > 		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
> >
> > and this doesn't look exactly right: zone_page_state() ignores the per-cpu
> > ->vm_stat_diff[] counters (and we probably do not want for_each_online_cpu()
> > loop here). And I do not know if this is really bad or not, but note that if
> > I change calculate_normal_threshold() to return 0, the problem goes away too.
>
> You are absolutely right that this is racy. In the worst case we would
> end up missing nr_cpus*threshold scanned pages which would stay behind.

and the sum of ->vm_diff[] can be negative, so...

> But
>
> bool zone_reclaimable(struct zone *zone)
> {
> 	return zone_page_state_snapshot(zone, NR_PAGES_SCANNED) <
> 		zone_reclaimable_pages(zone) * 6;
> }
>
> So the left over shouldn't cause it to return true all the time.

well if NR_PAGES_SCANNED doesn't grow enough it can even stay negative,
but zone_page_state_snapshot() returns zero in this case. In any case
we can underestimate zone_page_state_snapshot(NR_PAGES_SCANNED).

> In
> fact it could prematurely say false, right? (note that _snapshot variant
> considers per-cpu diffs [1]).

exactly because _snapshot() doesn't ignore the per-cpu counters.

> That being said I am not really sure why would the 0 threshold help for
> your test case.

Neither me. Except, of course, threshold==0 means the the code above will
work correctly. But I do not think this was the root of the problem.

> Could you add some tracing and see what are the numbers
> above?

with the patch below I can press Ctrl-C when it hangs, this breaks the
endless loop and the output looks like

	vmscan: ZONE=ffffffff8189f180 0 scanned=0 pages=6
	vmscan: ZONE=ffffffff8189eb00 0 scanned=1 pages=0
	...
	vmscan: ZONE=ffffffff8189eb00 0 scanned=2 pages=1
	vmscan: ZONE=ffffffff8189f180 0 scanned=4 pages=6
	...
	vmscan: ZONE=ffffffff8189f180 0 scanned=4 pages=6
	vmscan: ZONE=ffffffff8189f180 0 scanned=4 pages=6

the numbers are always small.

> [1] I am not really sure which kernel version have you tested - your
> config says 4.6.0-rc7 but this is true since 0db2cb8da89d ("mm, vmscan:
> make zone_reclaimable_pages more precise") which is 4.6-rc1.

Yes, I am on c5114626f33b62fa7595e57d87f33d9d1f8298a2, it has this change.

Oleg.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 142cb61..6d221f9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2614,6 +2614,12 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 		if (shrink_zone(zone, sc, zone_idx(zone) == classzone_idx))
 			reclaimable = true;
 
+if (fatal_signal_pending(current))
+	pr_crit("ZONE=%p %d scanned=%ld pages=%ld\n",
+		zone, reclaimable,
+		zone_page_state_snapshot(zone, NR_PAGES_SCANNED),
+		zone_reclaimable_pages(zone));
+else
 		if (global_reclaim(sc) &&
 		    !reclaimable && zone_reclaimable(zone))
 			reclaimable = true;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
